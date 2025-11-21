;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                LEDButton.inc                               ;
;                                 EE110a HW1                                 ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the LED Button program.
;
; References: CC13x2, CC26x2 SimpleLink™ Wireless MCU Technical Reference Manual
;             https://www.ti.com/lit/ug/swcu185g/swcu185g.pdf?ts=1761608306803
;             
;             CC26xR launchpad pin mapping and schematic:
;             https://www.ti.com/tool/LAUNCHXL-CC26X2R1#tech-docs
;
; Revision History:
;    10/28/25  Steven Lei         initial revision  
; 


; I/O Constants

RED_LED_IO_BIT      .equ    6            ;red LED on DIO6 -> bit 6 of GPIO_DOE
GREEN_LED_IO_BIT    .equ    7            ;green LED on DIO7 -> bit 7 of GPIO_DOE
LEFT_BTN_IO_BIT     .equ    13           ;left button on DIO13 -> bit 13 of GPIO_DOE
RIGHT_BTN_IO_BIT    .equ    14           ;right button on DIO14 -> bit 14 of GPIO_DOE

; Configuration for a GPIO input that needs a pull up.
; This is used for the push buttons since they are pulled low when pressed, 
;   according to schematic.
; see pg 1108 
IOCFG_DIN_PULL_UP  .equ    0x20004000   ;
                                        ;0------------------------------- reserved
                                        ;-0------------------------------ no hysteresis
                                        ;--1----------------------------- input
                                        ;---00--------------------------- no wakeup
                                        ;-----000------------------------ normal mode
                                        ;--------000--------------------- no edge detect events
                                        ;-----------00------------------- reserved
                                        ;-------------0------------------ no edge detect IRQ
                                        ;--------------00---------------- no edge detection
                                        ;----------------0--------------- reserved
                                        ;-----------------10------------- pull up enabled
                                        ;-------------------0------------ normal slew
                                        ;--------------------00---------- 2mA output
                                        ;----------------------00-------- auto drive strength control
                                        ;------------------------0------- no edge detect RTC event
                                        ;-------------------------0------ no edge detect wake up event
                                        ;--------------------------000000 general purpose I/O