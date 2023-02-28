/* 
 * File:   config.h
 *
 * Created on April 16, 2022, 4:07 PM
 */

#ifndef CONFIG_H
#define	CONFIG_H

#ifdef	__cplusplus
extern "C" {
#endif

//#define Z80_CLK 4300000UL // Z80 clock frequency
#define ROM_SIZE 0x2000 // ROM size 8K bytes
#define RAM_SIZE 0x1000 // RAM size 4K bytes
#define RAM_TOP 0x8000 // RAM start address
#define UART_DREG 0xE000 // UART data register address
#define UART_CREG 0xE001 // UART control register address

#ifdef	__cplusplus
}
#endif

#endif	/* CONFIG_H */
