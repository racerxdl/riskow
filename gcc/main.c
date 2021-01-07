#include "main.h"

int main() {
  uint32_t t = 0;
  uint8_t b = 0;

  setBitDirection(LED_PORT, LED_PIN, OUTPUT);

  while(1) {
    setBit(LED_PORT, LED_PIN, b);
    while(t < 1041666) { // Wait half second
      t++;
    }
    t = 0;
    b = ~b;
  }

  return 0;
}