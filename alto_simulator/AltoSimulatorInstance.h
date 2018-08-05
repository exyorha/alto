#ifndef ALTO_SIMULATOR_INSTANCE_H
#define ALTO_SIMULATOR_INSTANCE_H

#include <Valto_simulator.h>
#include "SimulatedSDCard.h"

class AltoSimulatorInstance {
public:
    AltoSimulatorInstance(const std::wstring &sdImageFile);
    ~AltoSimulatorInstance();

    AltoSimulatorInstance(const AltoSimulatorInstance &other) = delete;
    AltoSimulatorInstance &operator =(const AltoSimulatorInstance &other) = delete;

    void run();

private:
    Valto_simulator m_simulator;
    SimulatedSDCard m_sdcard;
};

#endif
