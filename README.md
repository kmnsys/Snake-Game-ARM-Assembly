# Snake-Game-ARM-Assembly
Snake game implementation using Cortex M0 ARM Assembly on a 240*360 LCD.

<img src="https://user-images.githubusercontent.com/42515502/125162057-95d06400-e18e-11eb-93fa-647fcbcee682.gif" width="425" height="250"/>

LCD registers are at these addresses:

* 0x40010000 LCD row register
* 0x40010004 LCD column register
* 0x40010008 LCD color register
* 0x4001000C LCD control register (for refresh(...01)/clean((...10))) 
* 0x40010010 Button register

Each button press or release generates an IRQ#0 at index 16 of the interrupt vector table. The generated interrupt sets the pending bit (bit 31) as well as the bit corresponding
to the pressed button in button register to 1 (only if the button is pressed).


_Note: I cannot provide LCD dll files since it belongs to someone else and i do not have the permission to share._
