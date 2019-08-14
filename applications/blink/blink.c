#include "VelonaCore_Basys3.h"

/* Blinks the LEDs on the Basys3 board */
volatile int *led_addr = BASYS3_LED_ADDR;

void main() {
    int led_state = 0;
    volatile int cntr;
    int max_cntr = 500000;
    while (1) {
        cntr = 0;
        while (cntr < max_cntr)
            cntr++;
        *led_addr = led_state ? 0xFFFFFFFF : 0x0;
        led_state = led_state == 0 ? 1 : 0;
    }
}
