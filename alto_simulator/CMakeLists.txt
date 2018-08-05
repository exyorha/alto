add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator.cpp
                          ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator.h
                          ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator__Syms.cpp
                          ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator__Syms.h
                   COMMAND ${VERILATOR}
                           --compiler msvc
                           --cc alto_simulator.v
                           -O3
                           -I${CMAKE_CURRENT_SOURCE_DIR}
                           -I${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze
                           -I${PROJECT_SOURCE_DIR}/hardware
                           --no-skip-identical
                           --stats
                   MAIN_DEPENDENCY alto_simulator.v
                   WORKING_DIRECTORY  ${CMAKE_CURRENT_BINARY_DIR}
                   DEPENDS
                    ${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze/pacoblaze_alu.v
                    ${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze/pacoblaze_idu.v
                    ${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze/pacoblaze_inc.v
                    ${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze/pacoblaze_register.v
                    ${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze/pacoblaze_scratch.v
                    ${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze/pacoblaze_stack.v
                    ${PROJECT_SOURCE_DIR}/3rdparty/pacoblaze/pacoblaze.v
                    ${PROJECT_SOURCE_DIR}/hardware/disk_controller_rom.v
                    ${PROJECT_SOURCE_DIR}/hardware/disk_controller_spi.v
                    ${PROJECT_SOURCE_DIR}/hardware/disk_controller.v
                   VERBATIM)
                   
add_executable(alto_simulator
    AltoSimulatorInstance.cpp
    AltoSimulatorInstance.h
    main.cpp
    SimulatedSDCard.cpp
    SimulatedSDCard.h

    ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator.h
    ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator__Syms.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/obj_dir/Valto_simulator__Syms.h
    ${VERILATOR_ROOT}/include/verilated.cpp
)

target_compile_definitions(alto_simulator PRIVATE -DUNICODE -D_UNICODE)
target_include_directories(alto_simulator PRIVATE ${VERILATOR_ROOT}/include ${CMAKE_CURRENT_BINARY_DIR}/obj_dir)

target_link_libraries(alto_simulator PRIVATE disk_controller_firmware)