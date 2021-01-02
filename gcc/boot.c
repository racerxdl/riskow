#include "main.h"
#include "io.h"

void boot(void) {
  for (uint32_t p = PORTA; p <= LASTPORT; p++) {
    setDirection(p, 0);
    setPort(p, 0);
  }
  main();
}

__attribute__((section(".exception"))) void exception() {
  uint32_t t = 0;
  uint8_t b = 0;

  while(1) {
    setBit(LED_PORT, LED_PIN, b);
    while(t < 1500000) { // Wait some time
      t++;
    }
    t = 0;
    b = ~b;
  }
}
