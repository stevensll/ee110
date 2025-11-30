;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               GeneralConstants.inc                         ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains general constants for CC2652 ARM Assembly.
;
; Revision History:
;    10/28/25  Steven Lei   initial revision, HW1
;    11/27/25  Steven Lei   add include guards

;  .ifndef GENERAL_CONSTANTS_INC
;  .define GENERAL_CONSTANTS_INC

; Booleans
FALSE              .equ    0            ;false
TRUE               .equ    1            ;true - non-zero

; Byte sizes
BYTES_PER_WORD     .equ    4            ;4 bytes in each word
BYTES_PER_HALF_WORD .equ   2            ;4 bytes in a half word
; Bit operations

ALL_ONES            .equ    0xFFFFFFFF  ;all bits set
ALL_ZEROES          .equ    0           ;all bits clear

CLK_PER_MS          .equ    48000

;  .endif  GENERAL_CONSTANTS_INC
 
