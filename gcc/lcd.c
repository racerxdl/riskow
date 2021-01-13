#include "io.h"
#include "lcd.h"

#define LCDPORT                   PORTA
#define RS_BIT                    0
#define EN_BIT                    1
#define RS                        (1 << RS_BIT)
#define EN                        (1 << EN_BIT)

#define DATA_LO(X)                setPort(LCDPORT, ( ((X & 0x0F) << 2) | RS ))
#define DATA_HI(X)                setPort(LCDPORT, ( ((X & 0xF0) >> 2) | RS ))
#define CMD_LO(X)                 setPort(LCDPORT, ( ((X & 0x0F) << 2) ))
#define CMD_HI(X)                 setPort(LCDPORT, ( ((X & 0xF0) >> 2) ))
#define CLOCK()                   setBit(LCDPORT, EN_BIT, 1)
#define CLOCK_LOW()               setBit(LCDPORT, EN_BIT, 0)
#define LCD_DELAY()               sleep(3)

// Commands
#define CMD_CLEAR_DISPLAY         0b00000001
#define CMD_CURSOR_HOME           0b00000010
#define CMD_ENTRY_MODE            0b00000100
#define CMD_DISPLAY_MODE          0b00001000
#define CMD_CD_SHIFT              0b00010000
#define CMD_FUNCTION              0b00100000


// Command ENTRY_MODE
#define ENTRY_MODE_DISPLAY_SHIFT  (1 << 0)
#define ENTRY_MODE_INCREMENT      (1 << 1)

// Command DISPLAY_MODE
#define DISPLAY_MODE_BLINK        (1 << 0)
#define DISPLAY_MODE_CURSOR_ON    (1 << 1)
#define DISPLAY_MODE_DISPLAY_ON   (1 << 2)

// Command CD_SHIFT
#define CD_SHIFT_SHIFT_LEFT       (1 << 2)
#define CD_SHIFT_SHIFT_DISPLAY    (1 << 3)

// Command FUNCTION
#define FUNCTION_FONT5X10         (1 << 2)
#define FUNCTION_LINES2           (1 << 3)
#define FUNCTION_BUS8BIT          (1 << 4)

void initDisplay() {
  setDirection(LCDPORT, 0xFFFFFFFF);

  sleep(40); // Wait Init

  // Init
  for (int i = 0; i < 3; i++) {
    CMD_HI(CMD_FUNCTION | FUNCTION_BUS8BIT);
    sleep(10);
    CLOCK();
    sleep(10);
    CLOCK_LOW();
  }
  CMD_HI(CMD_FUNCTION);
  sleep(10);
  CLOCK();
  sleep(10);
  CLOCK_LOW();
  sleep(10);

  // Set Mode to 4 bits
  sendCommand(CMD_FUNCTION | FUNCTION_LINES2);
  sendCommand(CMD_DISPLAY_MODE);
  sendCommand(CMD_CLEAR_DISPLAY);
  sendCommand(CMD_ENTRY_MODE | ENTRY_MODE_INCREMENT);

  // Turn on with blinking cursor
  sendCommand(CMD_DISPLAY_MODE | DISPLAY_MODE_BLINK | DISPLAY_MODE_DISPLAY_ON | DISPLAY_MODE_CURSOR_ON);

  // Cursor home
  sendCommand(CMD_CURSOR_HOME);
}

void sendCommand(char cmd) {
  CMD_HI(cmd);
  LCD_DELAY();
  CLOCK();
  LCD_DELAY();
  CLOCK_LOW();

  CMD_LO(cmd);
  LCD_DELAY();
  CLOCK();
  LCD_DELAY();
  CLOCK_LOW();
}

void sendData(char cmd) {
  DATA_HI(cmd);
  LCD_DELAY();
  CLOCK();
  LCD_DELAY();
  CLOCK_LOW();

  DATA_LO(cmd);
  LCD_DELAY();
  CLOCK();
  LCD_DELAY();
  CLOCK_LOW();
}
