#include "VelonaCore_Basys3.h"

volatile unsigned int *LEDS = LED_ADDR;
volatile unsigned int *SWITCHES = SW_ADDR;

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
    while (1)
        *LEDS = triangle(*SWITCHES);
}