/*
  PIC18F47Q43 ROM RAM and UART emulation firmware
  This single source file contains all code

  Target: EMUZ80 - The computer with only Z80 and PIC18F47Q43
  Compiler: MPLAB XC8 v2.36
  Written by Tetsuya Suzuki
  Modify by hayami
*/

#include "mcc_generated_files/mcc.h"

#include <xc.h>
#include <stdio.h>
#include "config.h"

extern const unsigned char rom[]; // Equivalent to ROM, see end of this file
asm("PSECT Z80RAM,class=BIGRAM,reloc=1000h");
unsigned char __section("Z80RAM") ram[RAM_SIZE]; // Equivalent to RAM

static union {
    unsigned int w; // 16 bits Address
    struct {
        unsigned char l; // Address low 8 bits
        unsigned char h; // Address high 8 bits
    };
} address;
    
#define dff6_reset() {CLCSELECT = 0x5; G3POL = 1; G3POL = 0;}
#define db_setin() (TRISC = 0xff)
#define db_setout() (TRISC = 0x00)

// Called at Z80 MREQ falling edge (PIC18F47Q43 issues WAIT)
void __interrupt(irq(CLC1),base(8)) CLC1_ISR(){
    asm(
//    );
//    asm(
    "clrf TRISC,c           \n"
    "movff PORTB,TBLPTRL    \n"
    "movff PORTD,TBLPTRH    \n"
    "tblrd *                \n"
    "movff TABLAT,LATC      \n"
    "bcf PIR0,5,c           \n"
//    "movlb 0x0              \n"
    "clrf CLCSELECT,b       \n"
    "bsf CLCnPOL,2,b        \n"
    "bcf CLCnPOL,2,b        \n"
    "retfie 1               \n"
    );
}

void __interrupt(irq(CLC5),base(8)) CLC5_ISR()
{
   
    if(!RA5) { // Z80 memory read cycle (RD active)
        asm( 
       "clrf TRISC,c            \n"
       "movff PORTB,FSR2L       \n"
       "movf  PORTD,w           \n"
       "xorlw (high _ram)^128   \n"
       "movwf FSR2H,c           \n"
       "movff INDF2,LATC        \n"
       "bcf PIR10,1,c           \n"
//       "movlb 0x0               \n"
       "movlw 0x4               \n"
       "movwf CLCSELECT,b       \n"
       "bsf CLCnPOL,2,b         \n"
       "bcf CLCnPOL,2,b         \n"
       "retfie 1                \n"
       );
    } else { // Z80 memory write cycle (RD inactive)
//        if(RE0) while(RE0);
        asm( 
       "setf TRISC,c           \n"
       "movff PORTB,FSR2L       \n"
       "movf  PORTD,w           \n"
       "xorlw (high _ram)^128   \n"
       "movwf FSR2H,c           \n"
       "movff PORTC,INDF2       \n"
       "bcf PIR10,1,c           \n"
//       "movlb 0x0               \n"
       "movlw 0x4               \n"
       "movwf CLCSELECT,b       \n"
       "bsf CLCnPOL,2,b         \n"
       "bcf CLCnPOL,2,b         \n"
       "retfie 1                \n"
       );
    }
}

void __interrupt(irq(CLC6),base(8)) CLC6_ISR()
{
    // Clear the CLC interrupt flag
    PIR11bits.CLC6IF = 0;

    address.h = PORTD; // Read address high
    address.l = PORTB; // Read address low
    
    if(!RA5) { // Z80 memory read cycle (RD active)
        db_setout(); // Set data bus as output
        if(address.w == UART_CREG){ // UART control register
            LATC = PIR9; // U3 flag
        } else if(address.w == UART_DREG){ // UART data register
            LATC = U3RXB; // U3 RX buffer
        } else { // Out of memory
            LATC = 0xff; // Invalid data
        }
    } else { // Z80 memory write cycle (RD inactive)
        db_setin();
        if(RE0) while(RE0);
        if(address.w == UART_DREG) { // UART data register
            U3TXB = PORTC; // Write into U3 TX buffer
        }
    }
    dff6_reset(); // WAIT inactive
}

// main routine
void main(void) {
    // Initialize the device
    SYSTEM_Initialize();

    // Z80 start
    INTERRUPT_GlobalInterruptHighEnable();

    asm(
    "movlb 0x0                  \n"
    "movlw 0x0                  \n"
    "movwf CLCSELECT,b          \n"
    "bsf CLCnPOL,2,b            \n"
    "bcf CLCnPOL,2,b            \n"
    "movlw 0x4                  \n"
    "movwf CLCSELECT,b          \n"
    "bsf CLCnPOL,2,b            \n"
    "bcf CLCnPOL,2,b            \n"
    "movlw 0x5                  \n"
    "movwf CLCSELECT,b          \n"
    "bsf CLCnPOL,2,b            \n"
    "bcf CLCnPOL,2,b            \n"
    "movlw low (_rom shr 16)    \n"
    "movwf TBLPTRU,c            \n"
    "bsf LATE,1,c               \n"
    "bsf INTCON0,7,c            \n" 
    );
    
    while(1); // All things come to those who wait
}
