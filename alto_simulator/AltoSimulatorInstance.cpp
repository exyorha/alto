#include "AltoSimulatorInstance.h"

#include <disk_controller_firmware_rom.h>

AltoSimulatorInstance::AltoSimulatorInstance(const std::wstring &sdImageFile) : m_sdcard(sdImageFile) {
    m_simulator.eval();

    static_assert(sizeof(m_simulator.v__DOT__disk__DOT__rom__DOT__memory) == sizeof(disk_controller_firmware), "Disk controller firmware size must match ROM size in HDL");
    memcpy(m_simulator.v__DOT__disk__DOT__rom__DOT__memory, disk_controller_firmware, sizeof(disk_controller_firmware));

    m_simulator.rst_i = 1;
    m_simulator.clk_i = 1;
    m_simulator.eval();
    m_simulator.clk_i = 0;
    m_simulator.eval();
	m_simulator.rst_i = 0;
}

AltoSimulatorInstance::~AltoSimulatorInstance() {

}

void AltoSimulatorInstance::run() {
    while(1) {
        m_simulator.clk_i = 1;
        m_simulator.eval();

        m_sdcard.tick(m_simulator.sd_sck_o, m_simulator.sd_ss_n_o, m_simulator.sd_mosi_o, m_simulator.sd_miso_i);

        m_simulator.clk_i = 0;
        m_simulator.eval();
    }
}
