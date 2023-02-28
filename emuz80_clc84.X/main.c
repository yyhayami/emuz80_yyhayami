/*!
 * PIC18F47Q84 ROM RAM and UART emulation firmware
 * 
 * Target: EMUZ80
 *         PIC18F47Q43/47Q84 
 *  IDE: MPLAB X v6.0
 *  Compiler: MPLAB XC8 v2.40
 * 
 * Modified by y.hayami @yyhayami 
 * Version 1.00 2023/2/22
 * 
 */
/*
 * Original
  PIC18F47Q43 ROM RAM and UART emulation firmware
  This single source file contains all code

  Target: EMUZ80 - The computer with only Z80 and PIC18F47Q43
  Compiler: MPLAB XC8 v2.32
  Written by Tetsuya Suzuki
*/
#include "mcc_generated_files/mcc.h"

#include <xc.h>
#include <stdio.h>
#include "config.h"

extern const unsigned char rom[]; // Equivalent to ROM, see rom.c file

//#define Z80_4M

//Z80 RAM equivalent
asm("PSECT Z80RAM,class=BIGRAM,reloc=100h");    // Memory alignment 0x100
unsigned char __section("Z80RAM") ram[RAM_SIZE]; // Equivalent to RAM

// RAM Access emulation
void __interrupt(irq(CLC5),base(8)) CLC5_ISR()
{
    asm(
       "bcf   PIR10,1,c         \n"   // CLC5IF <- 0
       "bsf   CLCSELECT,2,b     \n"   // CLCSELECT <- 4
    );
    if(!RA5) { // Z80 memory read cycle (RD active)
        asm( 
       "clrf  TRISC,c           \n"   // set data bus as output 
       "movff PORTB,FSR2L       \n"   // low address to low RAM access pointer
       "movf  PORTD,w           \n"   // get high address to Wreg
       "addlw (high _ram) & 0x3f \n"  // add PIC RAM start address(+0x07))
       "movwf FSR2H,c           \n"   // RAM address to high RAM access pointer 
       "bsf   CLCnPOL,2,b       \n"   // D-FF Reset(Wait release)
        //--------above is WAIT state------------------------------
       "movf  INDF2,w           \n"   // PIC RAM data To Wreg
       "movwf LATC,c            \n"   // Wreg data to output bus
       "bcf   CLCnPOL,2,b       \n"   // CLC5 R release 
       "clrf  CLCSELECT,b       \n"   // CLCSELECT <- 0
#ifdef Z80_4M
       "clc5_loop:             \n"   //
       "btfss  PORTA,1,c       \n"   // polling _MREQ = H        
       "bra  clc5_loop         \n"   //
#endif
       "setf  TRISC,c           \n"   // set data bus as input
        );
    } else { // Z80 memory write cycle (RD inactive)
        asm( 
       "movff PORTB,FSR2L       \n"   // low address to low RAM access pointer
       "movf  PORTD,w           \n"   // get high address to Wreg
       "addlw (high _ram) & 0x3f \n"  // add PIC RAM start address(+0x07))
       "movwf FSR2H,c           \n"   // RAM address to high RAM access pointer
       "bsf   CLCnPOL,2,b       \n"   // D-FF Reset(Wait release)
        //--------above is WAIT state------------------------------
       "movf  PORTC,w           \n"   // bus data to Wreg 
       "movwf INDF2,c           \n"   // write to PIC RAM
       "bcf   CLCnPOL,2,b       \n"  // CLC5 R release
       "clrf  CLCSELECT,b       \n"   // CLCSELECT <- 0
       );
    }
 }

static union {
    unsigned int w; // 16 bits Address
    struct {
        unsigned char l; // Address low 8 bits
        unsigned char h; // Address high 8 bits
    };
} ad;

// UART Access emulation Interrupt low priority
void __interrupt(irq(CLC6),base(8),low_priority) CLC6_ISR()
{
    PIE10bits.CLC5IE = 0;   //CLC5 Interrupt disable
    PIR11bits.CLC6IF = 0;   //Clear the CLC6 interrupt flag

    ad.h = PORTD; // Read address high
    ad.l = PORTB; // Read address low
    
    if(!RA5) { // UART memory mapped IO read cycle (RD active)
        TRISC = 0x00; // set data bus as output
        if(ad.w == UART_CREG){ // UART control register?
            LATC = PIR9; // U3 flag
        } else if(ad.w == UART_DREG){ // UART data register?
            LATC = U3RXB; // U3 RX buffer
        } else { // Out of memory
            LATC = 0xff; // invalid datat
        }
        // WAIT inactive
        CLCSELECT = 0x5; 
        G3POL = 1; 
        G3POL = 0;
        CLCSELECT = 0;
        while(!RA1);            // until ^MREQ cancels
        TRISC = 0xff;           // set data bus as input
    } else { // UART memory mapped write cycle (RD inactive)
        TRISC = 0xff;           // set data bus as input
        if(RE0) while(RE0);     // until ^WR can be set
        if(ad.w == UART_DREG) { // UART data register?
            U3TXB = PORTC;      // write into U3 TX buffer
        }
        // WAIT inactive
        CLCSELECT = 0x5; 
        G3POL = 1; 
        G3POL = 0;
        CLCSELECT = 0;
    }
    PIE10bits.CLC5IE = 1;   //CLC5 Interrupt enable
}

// main routine
void main(void) {
    // Initialize the device
    SYSTEM_Initialize();
    // Interrupt enasble
    INTERRUPT_GlobalInterruptHighEnable();
    INTERRUPT_GlobalInterruptLowEnable();    

    // Initialize the PIC
    BSR = 0;        // BSR 0 fixed
    TBLPTRU = 1;    // TBLTPU 1 fixed ROM allocate 10000h
    CLCSELECT = 0;  // CLC1 usually selected for speed
    TRISC = 0xff;   // set data bus as input
    // Z80 start
    LATE1 = 1;      // release reset Z80 start

    //ROM read emulation by polling
    asm(                            // always BSR=0 CLCSELECT=0
#ifdef Z80_4M
        "bra    clc1_check      \n" // repeat L
        "rom_loop:"
        "btfss  PORTA,1,c       \n" // polling _MREQ = H
        "bra    rom_loop        \n" // repeat L
#else
        "rom_loop:"
#endif
        "setf   TRISC,c         \n" // set as input
        "clc1_check:            \n" //
        "btfsc  CLCDATA,0,b     \n" // check CLC1
        "bra    clc1_check      \n" // repeat if CLC1 = H
        "movf   PORTB,w         \n" // get low address to Wreg
        "movwf  TBLPTRL         \n" // set low address to low table pointer
        "movf   PORTD,w         \n" // get high address to Wreg
        "movwf  TBLPTRH         \n" // set high address to high table pointer
        "tblrd  *               \n" // ROM allocate 0x10000 TBLPTRU fixed 1
        "clrf   TRISC,c         \n" // set as output
        "movf   TABLAT,w        \n" // movff divided into 2 step for speed up
        "bsf    CLCnPOL,2,b     \n" // D-FF Reset(Wait release)
        //--------above is WAIT state------------------------------
        "movwf  LATC            \n" // movff divided into 2 step for speed up
        "bcf    CLCnPOL,2,b     \n" // CLC1 R release
        "bra    rom_loop        \n" // jump to polling while bus is idle
    );
}
