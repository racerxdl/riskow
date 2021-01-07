#pragma once

#define HIGH 1
#define LOW  0

#define INPUT 0
#define OUTPUT 1

#define PORTA 0
#define PORTB 1
#define LASTPORT PORTB

#define _IO_ADDR 0xF0000000
#define _T0_ADDR 0xF1000000

#define LED_PORT PORTB
#define LED_PIN  0

#define CPU_CLOCK 25000000

void setPort(unsigned int portN, unsigned int val);
void setDirection(unsigned int portN, unsigned int val);
unsigned int readPort(unsigned int portN);
void setBit(unsigned int portN, unsigned char bit, unsigned char val);
void setBitDirection(unsigned int portN, unsigned char bit, unsigned char val);

unsigned int getTimer();
void setTimer(unsigned int val);
void resetTimer();
void setDivideBy(unsigned int N);
void startTimer();


void sleep(unsigned int ms);