#include "VelonaCore_basys3.h"

volatile unsigned int *LEDS = 0x9FFF0000;
volatile unsigned int *SWITCHES = 0x9FFF0004;

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