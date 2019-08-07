#include "VelonaCore_Basys3.h"

/*
 * Program, which reads the input switches of the Basys3 board, calculates the
 * triangle number of this binary input, and outputs the result on the
 * LEDs.
 */

int triangle(int n)
{
    int sum = 0;
    for (int i = n; i > 0; i--)
    {
        sum += n;
        n -= 1;
    }
    return sum;
}

void main()
{
    volatile unsigned int *LEDS = BASYS3_LED_ADDR;
    volatile unsigned int *SWITCHES = BASYS3_SW_ADDR;
    while (1)
        *LEDS = triangle(*SWITCHES);
}