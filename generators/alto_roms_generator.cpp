#include <stdio.h>

#include <array>
#include <vector>
#include <sstream>
#include <fstream>

#if !defined(_WIN32)
#include <unistd.h>

int wmain(int argc, wchar_t *argv[]);

static int _wchdir(const wchar_t *path) {
    size_t size = wcstombs(nullptr, path, 0);
    if(size == (size_t) -1)
        return -1;

    std::vector<char> buffer(size + 1);
    wcstombs(&buffer[0], path, buffer.size());

    return chdir(&buffer[0]);
}

int main(int argc, char **argv) {
    wchar_t **wideArgv = new wchar_t *[argc];

    for(int index = 0; index < argc; index++) {
        size_t size = mbstowcs(nullptr, argv[index], 0);
        if(size == (size_t) -1)
            wideArgv[index] = nullptr;
        else {
            wchar_t *buffer = new wchar_t[size + 1];
            mbstowcs(buffer, argv[index], size + 1);
            wideArgv[index] = buffer;
        }
    }

    return wmain(argc, wideArgv);
}

#endif

uint8_t scrambleConstantAddress(uint8_t address) {
    static const uint8_t constantAddressMapping[]{ 7, 2, 1, 0, 3, 4, 5, 6 };

    uint8_t outAddress = 0;

    for(size_t destination = 0; destination < sizeof(constantAddressMapping); destination++) {
		if((address & (1 << constantAddressMapping[destination])) != 0) {
			outAddress |= 1 << destination;
        }
    }

    return outAddress;
}

uint8_t scrambleConstantData(uint8_t data) {
    static const uint8_t constantDataMapping[]{ 3, 2, 1, 0 };

    uint8_t outData = 0;

    for(size_t destination = 0; destination < sizeof(constantDataMapping); destination++) {
		if((data & (1 << constantDataMapping[destination])) != 0) {
			outData |= 1 << destination;
        }
    }

    return outData;
}

int wmain(int argc, wchar_t **argv) {
    if (argc != 2) {
       fwprintf(stderr, L"Usage: %s <SOURCE DIRECTORY>\n", argv[0]);
       return 1;
    }

    std::vector<uint32_t> microcode(4096);
    std::vector<uint16_t> constants(256);

    size_t nibble = 0;
    for(const wchar_t *romfile: { L"U62", L"U61", L"U60", L"U53", L"U63", L"U65", L"U64", L"U55" }) {
        std::wstringstream namestream;
        namestream << argv[1] << L"/" << romfile;

        std::array<uint8_t, 1024> slice;
        std::ifstream stream;
        stream.exceptions(std::ios::eofbit | std::ios::badbit | std::ios::failbit);
        stream.open(namestream.str(), std::ios::in | std::ios::binary);
        stream.read(reinterpret_cast<char *>(slice.data()), slice.size());

        for(size_t offset = 0; offset < slice.size(); offset++) {
            microcode[offset ^ 1023] |= (slice[offset] ^ 0x0F) << (nibble * 4);
        }

        nibble++;
    }

    nibble = 0;
    for(const wchar_t *romfile: { L"C3", L"C2", L"C1", L"C0" }) {
        std::wstringstream namestream;
        namestream << argv[1] << L"/" << romfile;

        std::array<uint8_t, 256> slice;
        std::ifstream stream;
        stream.exceptions(std::ios::eofbit | std::ios::badbit | std::ios::failbit);
        stream.open(namestream.str(), std::ios::in | std::ios::binary);
        stream.read(reinterpret_cast<char *>(slice.data()), slice.size());

        for(size_t offset = 0; offset < slice.size(); offset++) {
            constants[scrambleConstantAddress(static_cast<uint8_t>(offset))] |= (scrambleConstantData(slice[offset]) ^ 0x0F) << (nibble * 4);
        }

        nibble++;
    }

    {
        std::ofstream stream;
        stream.exceptions(std::ios::eofbit | std::ios::badbit | std::ios::failbit);
        stream.open("alto_microcode.mem", std::ios::out | std::ios::trunc);
        for(auto word: microcode) {
            stream.setf(std::ios::hex, std::ios::basefield);
            stream.width(8);
            stream.fill('0');
            
            stream << word << "\n";
        }
    }

    {
        std::ofstream stream;
        stream.exceptions(std::ios::eofbit | std::ios::badbit | std::ios::failbit);
        stream.open("alto_constants.mem", std::ios::out | std::ios::trunc);
        for(auto word: constants) {
            stream.setf(std::ios::hex, std::ios::basefield);
            stream.width(4);
            stream.fill('0');
            
            stream << word << "\n";
        }
    }

    {
        std::ofstream stream;
        stream.exceptions(std::ios::eofbit | std::ios::badbit | std::ios::failbit);
        stream.open("alto_roms.h", std::ios::out | std::ios::trunc);
        stream << "#ifndef FIRMWARE_HEADER_alto_roms\n"
                  "#define FIRMWARE_HEADER_alto_roms\n"
                  "#include <stdint.h>\n"
                  "#if defined(__cplusplus)\n"
                  "extern \"C\" {\n"
                  "#endif\n"
                  "extern const uint32_t alto_microcode[4096];\n"
                  "extern const uint16_t alto_constants[256];\n"
                  "#if defined(__cplusplus)\n"
                  "}\n"
                  "#endif\n"
                  "#endif\n";
    }

    {
        std::ofstream stream;
        stream.exceptions(std::ios::eofbit | std::ios::badbit | std::ios::failbit);
        stream.open("alto_roms.cpp", std::ios::out | std::ios::trunc);

        stream << "#include \"alto_roms.h\"\n"
                  "const uint32_t alto_microcode[4096]{\n";

       for(uint32_t word: microcode) {
            stream << "  0x";

            stream.setf(std::ios::hex, std::ios::basefield);
            stream.width(8);
            stream.fill('0');
            
            stream << word << ",\n";
        }

        stream <<
            "};\n"
            "const uint16_t alto_constants[256]{\n";

       for(uint32_t word: constants) {
            stream << "  0x";

            stream.setf(std::ios::hex, std::ios::basefield);
            stream.width(4);
            stream.fill('0');
            
            stream << word << ",\n";
        }

        stream <<
            "};\n";
    }

    return 0;
}
