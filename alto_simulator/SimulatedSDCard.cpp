#include "SimulatedSDCard.h"

#include <stdio.h>
#include <Windows.h>
#include <comdef.h>

void SimulatedSDCard::HandleDeleter::operator()(void *handle) const {
	CloseHandle(handle);
}

SimulatedSDCard::SimulatedSDCard(const std::wstring &filename) : m_prevSCK(false), m_prevSS(false), m_shiftIn(0), m_shiftOut(0xFF), m_bitCounter(0), m_state(State::Idle),
	m_spiModeEntered(false), m_inIdleState(false), m_nextCmdIsACMD(false) {

	HANDLE rawHandle = CreateFile(filename.c_str(),
		GENERIC_READ | GENERIC_WRITE,
		FILE_SHARE_READ | FILE_SHARE_WRITE,
		nullptr,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		nullptr);
	if (rawHandle == INVALID_HANDLE_VALUE)
		_com_raise_error(HRESULT_FROM_WIN32(GetLastError()));

	m_handle.reset(rawHandle);

	uint8_t CRCPoly = 0x89;

	for (size_t i = 0; i < 256; ++i) {
		auto bi = static_cast<uint8_t>(i);
		m_crc7Table[i] = (bi & 0x80) ? bi ^ CRCPoly : bi;
		for (size_t j = 1; j < 8; ++j) {
			m_crc7Table[i] <<= 1;
			if (m_crc7Table[i] & 0x80)
				m_crc7Table[i] ^= CRCPoly;
		}
	}
}

SimulatedSDCard::~SimulatedSDCard() {

}

void SimulatedSDCard::tick(unsigned char sck, unsigned char ss, unsigned char mosi, unsigned char &miso) {
	auto bsck = static_cast<bool>(sck);
	auto bss = static_cast<bool>(ss);

	if (bsck != m_prevSCK) {
		m_prevSCK = bsck;

		if (bsck) {
			// rising edge

			if (bss != m_prevSS) {
				m_prevSS = bss;

				if (bss) {
					printf("SimulatedSDCard: now deselected\n");
				}
				else {
					printf("SimulatedSDCard: now selected\n");
					m_shiftOut = 0xFF;
					m_bitCounter = 0;
					m_state = State::Idle;
				}
			}

			if (!m_prevSS) {
				m_shiftIn = (m_shiftIn << 1) | mosi;
			}
		}
		else {
			// falling edge


			if (m_prevSS)
				miso = 1;
			else {
				if (++m_bitCounter == 8) {
					processByte(m_shiftIn);
					m_bitCounter = 0;
				}

				miso = m_shiftOut >> 7;

				m_shiftOut <<= 1;
			}
		}
	}
}

void SimulatedSDCard::processByte(unsigned char byteIn) {
	//printf("SD: byte in: %02X\n", byteIn);
	
	m_shiftOut = 0xFF;

	switch (m_state) {
	case State::Idle:
		if ((byteIn & 0xC0) == 0x40) {
			m_command = byteIn & 0x3F;
			m_state = State::CommandArg3;
		}
		break;

	case State::CommandArg3:
		m_commandArg = byteIn;
		m_state = State::CommandArg2;
		break;

	case State::CommandArg2:
		m_commandArg = (m_commandArg << 8) | byteIn;
		m_state = State::CommandArg1;
		break;

	case State::CommandArg1:
		m_commandArg = (m_commandArg << 8) | byteIn;
		m_state = State::CommandArg0;
		break;

	case State::CommandArg0:
		m_commandArg = (m_commandArg << 8) | byteIn;
		m_state = State::CommandCRC;
		break;

	case State::CommandCRC:
		m_commandCRC = byteIn;
		m_state = State::Idle;
		executeCommand();
		break;

	case State::Response1:
		m_state = State::Idle;
		break;

	case State::Response1ThenLong:
		m_state = State::ResponseLong3;
		m_shiftOut = m_longResponse >> 24;
		m_longResponse <<= 8;
		break;

	case State::ResponseLong3:
		m_state = State::ResponseLong2;
		m_shiftOut = m_longResponse >> 24;
		m_longResponse <<= 8;
		break;

	case State::ResponseLong2:
		m_state = State::ResponseLong1;
		m_shiftOut = m_longResponse >> 24;
		m_longResponse <<= 8;
		break;

	case State::ResponseLong1:
		m_state = State::ResponseLong0;
		m_shiftOut = m_longResponse >> 24;
		m_longResponse <<= 8;
		break;

	case State::ResponseLong0:
		m_state = State::Idle;
		break;

	case State::Response1ThenBlock:
		m_state = State::ResponseBlock;
		m_shiftOut = 0xFE;
		m_blockPos = 0;
		break;

	case State::ResponseBlock:
		if (m_shiftIn != 0xFF && m_multiblock == MultiblockState::InterimBlock) {
			// fake stop transmission handling
			m_multiblock = MultiblockState::LastBlock;
		}
		m_shiftOut = m_blockData[m_blockPos];

		if (++m_blockPos >= m_blockData.size()) {
			m_state = State::ResponseBlockCRC1;
		}
		break;

	case State::ResponseBlockCRC1:
		m_shiftOut = 0xEE;
		m_state = State::ResponseBlockCRC0;
		break;

	case State::ResponseBlockCRC0:
		m_shiftOut = 0xBB;
		if (m_multiblock == MultiblockState::SingleBlock)
			m_state = State::Idle;
		else if (m_multiblock == MultiblockState::InterimBlock)
			m_state = State::ReadMultipleBlockNextPause;
		else if (m_multiblock == MultiblockState::LastBlock)
			m_state = State::ReadMultipleBlockTerminate;

		break;

	case State::ReadMultipleBlockNextPause:
		m_shiftOut = 0xFF;
		m_state = State::ReadMultipleBlockNext;
		break;

	case State::ReadMultipleBlockNext:
		m_shiftOut = 0xFF;
		continueReadMultipleBlock();
		break;

	case State::ReadMultipleBlockTerminate:
		m_shiftOut = 0xFF;
		m_state = State::ReadMultipleBlockTerminate2;
		break;

	case State::ReadMultipleBlockTerminate2:
		m_shiftOut = 0x00;
		m_state = State::Idle;
		break;
	}

	//printf("SD: byte out: %02X\n", m_shiftOut);
}

void SimulatedSDCard::executeCommand() {
	printf("%cCMD%d(%08X), CRC %02X\n", m_nextCmdIsACMD ? 'A' : ' ', m_command, m_commandArg, m_commandCRC);

	m_state = State::Response1;

	unsigned char commandCRCData[5] = {
		static_cast<unsigned char>(m_command | 0x40),
		static_cast<unsigned char>(m_commandArg >> 24),
		static_cast<unsigned char>(m_commandArg >> 16),
		static_cast<unsigned char>(m_commandArg >> 8),
		static_cast<unsigned char>(m_commandArg),
	};

	auto crc = calculateCRC7(commandCRCData, sizeof(commandCRCData));

	if (m_command == 0)
		m_nextCmdIsACMD = false;
	else if (m_nextCmdIsACMD) {
		m_nextCmdIsACMD = false;
		m_command |= 0x40;
	}

	if (crc != m_commandCRC && (!m_spiModeEntered || m_command == 8)) {
		printf("Command CRC error: expected %02X, received %02X\n", crc, m_commandCRC);
		m_shiftOut = 8;
		return;
	}
		
	switch (m_command) {
	case 0:
		m_spiModeEntered = true;
		m_inIdleState = true;
		m_shiftOut = 0;
		break;

	case 8:
		if ((m_commandArg >> 8) == 1) {
			m_longResponse = m_commandArg;
		}
		else {
			m_longResponse = m_commandArg & 0xFF;
		}
		m_state = State::Response1ThenLong;
		m_shiftOut = 0;
		break;

	case 9:
		m_blockData.assign(m_csd, m_csd + sizeof(m_csd));
		m_state = State::Response1ThenBlock;
		m_multiblock = MultiblockState::SingleBlock;
		m_shiftOut = 0;
		break;

	case 18:
		m_shiftOut = 0;
		m_multiblock = MultiblockState::InterimBlock;
		m_state = State::ReadMultipleBlockNextPause;
		break;

	case 55:
		m_nextCmdIsACMD = true;
		m_shiftOut = 0;
		break;

	case 58:
		m_longResponse = (1 << 30);
		m_state = State::Response1ThenLong;
		m_shiftOut = 0;
		break;

	case 0x40 | 41:
		if (m_commandArg & (1 << 30)) {
			m_inIdleState = false;
		}
		m_shiftOut = 0;
		break;

	default:
		printf("Unknown command\n");
		m_shiftOut = 4;
		break;
	}

	if (m_inIdleState)
		m_shiftOut |= 1;

	//printf("Response: %02X\n", m_shiftOut);
}

uint8_t SimulatedSDCard::calculateCRC7(unsigned char *data, size_t dataSize) {
	uint8_t crc = 0;

	for (size_t index = 0; index < dataSize; index++) {
		crc = m_crc7Table[(crc << 1) ^ data[index]];
	}

	return (crc << 1) | 1;
}

void SimulatedSDCard::continueReadMultipleBlock() {
	printf("READ: reading block %d\n", m_commandArg);

	uint64_t block = (uint64_t)512 * m_commandArg;

	m_commandArg++;

	OVERLAPPED overlapped;
	ZeroMemory(&overlapped, sizeof(overlapped));
	overlapped.Offset = (uint32_t)block;
	overlapped.OffsetHigh = (uint32_t)(block >> 32);

	m_blockData.resize(512);

	DWORD bytesRead;

	if (!ReadFile(m_handle.get(), m_blockData.data(), m_blockData.size(), &bytesRead, &overlapped))
		_com_raise_error(HRESULT_FROM_WIN32(GetLastError()));

	if (bytesRead != 512)
		throw std::runtime_error("short read");

	m_state = State::ResponseBlock;
	m_shiftOut = 0xFE;
	m_blockPos = 0;
}

const unsigned char SimulatedSDCard::m_csd[16] = {
	0x40, 0x0E, 0x00, 0x32, 0x5B, 0x59, 0x00, 0x00, 0xEF, 0x5D, 0x7F, 0x80, 0x0A, 0x40, 0x00, 0xDF
};