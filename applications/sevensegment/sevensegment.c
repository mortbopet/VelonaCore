#include "VelonaCore_Basys3.h"

void spinSleep(int time) {
    // Sleeps for some variable amount of "time".
    volatile int cntr;
    while (cntr < time)
        cntr++;
}

void displayNumber(int number) {
    // If division or modulo subroutines are included into the binary,
    // it by far exceeds the current instruction memory size (making base-10
    // non-viable). Instead the number is displayed in hex
    volatile unsigned int* seg = (unsigned int*)BASYS3_7SD_BASE;
    for(int i = 0; i < 4; i ++) {
        unsigned int ssdval;
        // This should just be done as array indexing, but the compiler insists
        // on emitting array initialization values outside the .text segment
        switch(number & 0xF) {
            case 0x0: ssdval = 0x3f; break;
            case 0x1: ssdval = 0x06; break;
            case 0x2: ssdval = 0x5b; break;
            case 0x3: ssdval = 0x4f; break;
            case 0x4: ssdval = 0x66; break;
            case 0x5: ssdval = 0x6d; break;
            case 0x6: ssdval = 0x7d; break;
            case 0x7: ssdval = 0x07; break;
            case 0x8: ssdval = 0x7f; break;
            case 0x9: ssdval = 0x67; break;
            case 0xA: ssdval = 0x77; break;
            case 0xB: ssdval = 0x7C; break;
            case 0xC: ssdval = 0x39; break;
            case 0xD: ssdval = 0x5e; break;
            case 0xE: ssdval = 0x79; break;
            case 0xF: ssdval = 0x71; break;
        }
        *(seg + i) = ssdval;
        number >>= 4;
    }
}

int main() {
    int counter = 0;
    while(1) {
        displayNumber(counter);
        counter++;
        spinSleep(250000);
    }

    return 0;
}
