;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               GeneralConstants.inc                         ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains general constants for CC2652 ARM Assembly.

; Revision History:
;    10/28/25  Steven Lei   initial revision, HW1
;    11/30/25  Steven Lei   add bit masks, HW2

;CPU 
CLK_PER_MS          .equ    48000       ;CPU runs at 48 MHz

; Booleans
FALSE              .equ     0            ;false
TRUE               .equ     1            ;true - non-zero

; Byte sizes
BYTES_PER_WORD      .equ    4           ;4 bytes in each word
BYTES_PER_HALF_WORD .equ    2           ;2 bytes in a half word

; Bit operations
ALL_ONES            .equ    ~0          ;all bits set
ALL_ZEROES          .equ    0           ;all bits clear

;Bit masks          
BIT_0_MASK          .equ    0x01        ;all bits clear except bit 0
BIT_1_MASK          .equ    0x02        ;all bits clear except bit 1
 
