#include "AltoSimulatorInstance.h"

int main(int argc, char **argv) {
    AltoSimulatorInstance instance(L"C:\\projects\\alto\\system\\sd.img");
    instance.run();
}

