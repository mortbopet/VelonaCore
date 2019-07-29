void main() {
  volatile int *led_addr = 0x9FFF0000;
  int led_state = 0;
  volatile int cntr;
  int max_cntr = 500000;
enter:
  while (1) {
    cntr = 0;
  count:
    while (cntr < max_cntr)
      cntr++;
  test:
    *led_addr = led_state ? 0xFFFFFFFF : 0x0;
  assign:
    led_state = led_state == 0 ? 1 : 0;
  }
}
