add_custom_target(alto_roms_mems DEPENDS 
    ${CMAKE_CURRENT_BINARY_DIR}/alto_microcode.mem
    ${CMAKE_CURRENT_BINARY_DIR}/alto_constants.mem
)

add_library(alto_roms STATIC
    ${CMAKE_CURRENT_BINARY_DIR}/alto_roms.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/alto_roms.h
)
target_include_directories(alto_roms PUBLIC ${CMAKE_CURRENT_BINARY_DIR})

add_custom_command(
    OUTPUT
        ${CMAKE_CURRENT_BINARY_DIR}/alto_microcode.mem
        ${CMAKE_CURRENT_BINARY_DIR}/alto_constants.mem
        ${CMAKE_CURRENT_BINARY_DIR}/alto_roms.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/alto_roms.h

    COMMAND alto_roms_generator ${CMAKE_CURRENT_SOURCE_DIR}/source_roms
    DEPENDS 
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/C0
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/C1
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/C2
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/C3
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U53
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U55
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U60
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U61
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U62
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U63
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U64
        ${CMAKE_CURRENT_SOURCE_DIR}/source_roms/U65       
        $<TARGET_FILE:alto_roms_generator> 
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    VERBATIM)
