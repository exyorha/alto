cmake_minimum_required(VERSION 3.10.2)
project(Alto)

include(${PROJECT_SOURCE_DIR}/cmake/picoblaze_firmware.txt)

find_package(Java REQUIRED)

if (WIN32)
    message(STATUS "This is Windows build. Assuming that Verilator is built and")
    message(STATUS "installed at default MSYS location.")
    configure_file(${PROJECT_SOURCE_DIR}/verilator_windows_launch.cmd.in
                ${PROJECT_BINARY_DIR}/verilator_windows_launch.cmd)
    set(VERILATOR "${PROJECT_BINARY_DIR}/verilator_windows_launch.cmd")
    set(VERILATOR_ROOT "D:/mingw/msys/1.0/local/share/verilator")
else()
    find_program(VERILATOR verilator)

    if(VERILATOR)
        string(REGEX REPLACE "bin/verilator$" "share/verilator" VERILATOR_ROOT ${VERILATOR})
    endif()

endif()

if (NOT VERILATOR)
    message(WARNING "Verilator was not found. All simulation targets will be unavailable.")
endif()

add_subdirectory(generators)
add_subdirectory(firmware)
if(VERILATOR)
    add_subdirectory(alto_simulator)
endif()
