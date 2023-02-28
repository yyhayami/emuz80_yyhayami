/*!
 * PIC18F47Q84/PIC18F47Q43 ROM RAM and UART emulation firmware
 *
 * Target: EMUZ80
 * Compiler: MPLAB XC8 v2.40
 * 
 * Modified by y.hayami @yyhayami 
 * Version 1.00 2023/2/22
 * unimon + EMUBASIC
 * 
 */
/*
  PIC18F47Q43 ROM RAM and UART emulation firmware
  ROM BASIC array/Z80 code

  Target: EMUZ80 - The computer with only Z80 and PIC18F47Q43
  Compiler: MPLAB XC8 v2.36
  Written by Tetsuya Suzuki
*/

#include "config.h"

const unsigned char rom[ROM_SIZE] __at(0x10000) = { // ROM address 0x10000
#include "emuz80mon43RevB023.txt"         
#include "add_EMUBASIC.txt" 
};
