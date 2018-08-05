#include <fstream>
#include <string>
#include <vector>
#include <stdexcept>
#include <stdint.h>

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

int wmain(int argc, wchar_t *argv[]) {

   if (argc != 4) {
       fwprintf(stderr, L"Usage: %s <SOURCE DIRECTORY> <BUILD DIRECTORY> <PROJECT NAME>\n", argv[0]);
       return 1;
   }
   
   try {
       std::wstring projectName(argv[3]);

       _wchdir(argv[2]);

       std::ifstream rmhStream;
       rmhStream.exceptions(std::ios::failbit | std::ios::badbit);
       rmhStream.open(projectName + L".rmh", std::ios::in);
       rmhStream.exceptions(std::ios::badbit);
       
       std::ofstream memStream;
       memStream.exceptions(std::ios::failbit | std::ios::badbit);
       memStream.open(projectName + L"_rom.mem", std::ios::out | std::ios::trunc);
       
       std::wofstream hStream;
       hStream.exceptions(std::ios::failbit | std::ios::badbit);
       hStream.open(projectName + L"_rom.h", std::ios::out | std::ios::trunc);
       
       std::wofstream cppStream;
       cppStream.exceptions(std::ios::failbit | std::ios::badbit);
       cppStream.open(projectName + L"_rom.cpp", std::ios::out | std::ios::trunc);
       
       std::string rmhLine;
           
       std::vector<uint32_t> romContents(1024);
       unsigned int romAddress = 0;
       
       while(rmhStream) {
            std::getline(rmhStream, rmhLine);
            size_t pos = rmhLine.find("/");
            if(pos == 0 || rmhLine.empty())
                continue;
            else if(pos == std::string::npos)
                pos = rmhLine.size();
            
            if(rmhLine[0] == '@') {
                romAddress = std::stoi(rmhLine.substr(1, std::string::npos), nullptr, 16);
            } else {
                uint32_t value = std::stoi(rmhLine, nullptr, 16);
                romContents[romAddress] = value;
                romAddress++;
            }
       }
       
       for(uint32_t word: romContents) {
            memStream.setf(std::ios::hex, std::ios::basefield);
            memStream.width(5);
            memStream.fill('0');
            
            memStream << word << "\n";
        }

        hStream << L"#ifndef FIRMWARE_HEADER_" << projectName << L"\n"
                   L"#define FIRMWARE_HEADER_" << projectName << L"\n"
                   L"#include <stdint.h>\n"
                   L"#if defined(__cplusplus)\n"
                   L"extern \"C\" {\n"
                   L"#endif\n"
                   L"extern const uint32_t " << projectName << L"[1024];\n"
                   L"#if defined(__cplusplus)\n"
                   L"}\n"
                   L"#endif\n"
                   L"#endif\n";

        cppStream << L"#include \"" << projectName << L"_rom.h\"\n"
                     L"const uint32_t " << projectName << L"[1024]{\n";

       for(uint32_t word: romContents) {
            cppStream << L"  0x";

            cppStream.setf(std::ios::hex, std::ios::basefield);
            cppStream.width(5);
            cppStream.fill('0');
            
            cppStream << word << L",\n";
        }

        cppStream << "};\n";

        return 0;
   } catch(const std::exception &e) {
       fwprintf(stderr, L"Uncaught error: %S\n", e.what());
       return 1;
   }
}
