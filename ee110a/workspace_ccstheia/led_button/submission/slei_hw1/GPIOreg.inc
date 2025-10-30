;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  GPIOreg.inc                               ;
;                            GPIO Register Constants                         ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the GPIO control registers for the TI
; CC2652 microcontroller.
;
; References: CC13x2, CC26x2 SimpleLink™ Wireless MCU Technical Reference Manual
;             https://www.ti.com/lit/ug/swcu185g/swcu185g.pdf?ts=1761608306803
;
; Revision History:
;     2/17/22  Glen George      initial revision
;    11/05/23  Glen George      updated style
;    10/28/25  Steven Lei       add references to CC2652 Reference manual


; The MCU GPIO allows I/O (DIO) pins to be read/written. The pins must first be
; configured to GPIO mode (see IOCreg.inc). The pin values can then be
; read as input or written to as output through the MCU_GPIO_MAP registers.
;   sec 13.6, pg 1072


; Base address of the registers
;   table 3-1, pg 319
GPIO_BASE_ADDR     .equ    0x40022000   ;General Purpose I/O registers


; GPIJO register offsets in memmory map
;   sec 13.10.2, pg 1083
GPIO_DOUT3_0_OFF   .equ    0x0000       ;data out bits 0 to 3
GPIO_DOUT7_4_OFF   .equ    0x0004       ;data out bits 4 to 7
GPIO_DOUT11_8_OFF  .equ    0x0008       ;data out bits 8 to 11
GPIO_DOUT15_12_OFF .equ    0x000C       ;data out bits 12 to 15
GPIO_DOUT19_16_OFF .equ    0x0010       ;data out bits 16 to 19
GPIO_DOUT23_20_OFF .equ    0x0014       ;data out bits 20 to 23
GPIO_DOUT27_24_OFF .equ    0x0018       ;data out bits 24 to 27
GPIO_DOUT31_28_OFF .equ    0x001C       ;data out bits 28 to 31
GPIO_DOUT31_0_OFF  .equ    0x0080       ;data out bits 0 to 31
GPIO_DSET31_0_OFF  .equ    0x0090       ;set data out bits 0 to 31
GPIO_DCLR31_0_OFF  .equ    0x00A0       ;clear data out bits 0 to 31
GPIO_DTGL31_0_OFF  .equ    0x00B0       ;toggle data out bits 0 to 31
GPIO_DIN31_0_OFF   .equ    0x00C0       ;data in bits 0 to 31
GPIO_DOE31_0_OFF   .equ    0x00D0       ;data output enable bits 0 to 31
GPIO_EVFLG31_0_OFF .equ    0x00E0       ;event flags for data bits 0 to 31