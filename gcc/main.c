#include "main.h"

int main() {
  setBitDirection(LED_PORT, LED_PIN, OUTPUT);

  setDivideBy(64);
  resetTimer();
  startTimer();

  initDisplay();

  sendData('H');
  sendData('e');
  sendData('l');
  sendData('l');
  sendData('o');
  sendData(' ');
  sendData('W');
  sendData('o');
  sendData('r');
  sendData('l');
  sendData('d');

  while(1) {
    for(int i = 0; i < 6; i++) {
      setBit(LED_PORT, LED_PIN, HIGH);
      sleep(100);
      setBit(LED_PORT, LED_PIN, LOW);
      sleep(100);
    }
    sleep(5000);
  }

  return 0;
}