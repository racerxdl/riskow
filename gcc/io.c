#include "main.h"

#define PORT(N) *((uint32_t*)(_IO_ADDR) + N*2)
#define DIR(N)  *((uint32_t*)(_IO_ADDR) + N*2 + 1)

void setPort(uint32_t portN, uint32_t val) {
  if (portN <= LASTPORT) {
    PORT(portN) = val;
  }
}

uint32_t readPort(uint32_t portN) {
 if (portN <= LASTPORT) {
    return PORT(portN);
  }

  return 0;
}

void setBit(uint32_t portN, uint8_t bit, uint8_t val) {
  uint32_t v = readPort(portN);
  uint32_t b = 1 << bit;

  if (val) {
    v |= b;
  } else {
    v &= ~b;
  }

  setPort(portN, v);
}

void setDirection(unsigned int portN, unsigned int val) {
  if (portN <= LASTPORT) {
    DIR(portN) = val;
  }
}

uint32_t readDirection(uint32_t portN) {
 if (portN <= LASTPORT) {
    return DIR(portN);
  }

  return 0;
}


void setBitDirection(unsigned int portN, unsigned char bit, unsigned char val) {
  uint32_t v = readDirection(portN);
  uint32_t b = 1 << bit;

  if (val) {
    v |= b;
  } else {
    v &= ~b;
  }

  setDirection(portN, v);
}