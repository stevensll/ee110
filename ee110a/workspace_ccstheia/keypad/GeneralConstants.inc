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

; Booleans
FALSE              .equ    0            ;false
TRUE               .equ    1            ;true - non-zero

; Byte sizes
BYTES_PER_WORD     .equ    4            ;4 bytes in each word

; Bit operations

ALL_ONES            .equ    ~0          ;all bits set
ALL_ZEROES          .equ    0           ;all bits clear
