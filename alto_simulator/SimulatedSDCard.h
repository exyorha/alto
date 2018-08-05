#ifndef SIMULATED_SD_CARD__H
#define SIMULATED_SD_CARD__H

#include <stdint.h>
#include <vector>
#include <memory>

class SimulatedSDCard {
public:
	SimulatedSDCard(const std::wstring &filename);
	~SimulatedSDCard();

	SimulatedSDCard(const SimulatedSDCard &other) = delete;
	SimulatedSDCard &operator =(const SimulatedSDCard &other) = delete;

	void tick(unsigned char sck, unsigned char ss, unsigned char mosi, unsigned char &miso);

private:
	void processByte(unsigned char byteIn);
	void executeCommand();

	uint8_t calculateCRC7(unsigned char *data, size_t dataSize);
	
	void continueReadMultipleBlock();

	struct HandleDeleter {
		void operator()(void *handle) const;
	};

	enum class State {
		Idle,
		CommandArg3,
		CommandArg2,
		CommandArg1,
		CommandArg0,
		CommandCRC,
		Response1,
		Response1ThenLong,
		ResponseLong3,
		ResponseLong2,
		ResponseLong1,
		ResponseLong0,
		Response1ThenBlock,
		ResponseBlock,
		ResponseBlockCRC1,
		ResponseBlockCRC0,
		ReadMultipleBlockNext,
		ReadMultipleBlockNextPause,
		ReadMultipleBlockTerminate,
		ReadMultipleBlockTerminate2
	};

	enum class MultiblockState {
		SingleBlock,
		InterimBlock,
		LastBlock
	};

	uint8_t m_crc7Table[256];

	bool m_prevSCK, m_prevSS;
	unsigned char m_shiftIn, m_shiftOut, m_bitCounter;
	State m_state;
	MultiblockState m_multiblock;
	unsigned char m_command;
	unsigned int m_commandArg;
	unsigned char m_commandCRC;
	bool m_spiModeEntered, m_inIdleState;
	unsigned int m_longResponse;
	bool m_nextCmdIsACMD;
	static const unsigned char m_csd[16];
	std::vector<unsigned char> m_blockData;
	size_t m_blockPos;
	std::unique_ptr<void, HandleDeleter> m_handle;
};

#endif
