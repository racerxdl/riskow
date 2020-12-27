#include "main.h"

void boot(void) {
   int x = 10;
   int y = 15;
   int *magic = (int *)0x1000;

   while (1) {
	*magic = x + y;
        x = huebr(x);
        y--;
   }
}
