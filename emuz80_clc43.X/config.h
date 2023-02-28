/* 
 * File:   config.h
 * Author: y.hayami
 *
 * Target: EMUZ80
 *         PIC18F47Q43
 */

#ifndef CONFIG_H
#define	CONFIG_H

#ifdef	__cplusplus
extern "C" {
#endif

//#define Z80_4M

#define ROM_SIZE 0x7fff // ROM size 32K bytes
#define RAM_SIZE 0x1F00 // RAM size 7936 bytes
#define RAM_TOP 0x8000 // RAM start address
#define UART_DREG 0xE000 // UART data register address
#define UART_CREG 0xE001 // UART control register address

#ifdef	__cplusplus
}
#endif

#endif	/* CONFIG_H */
