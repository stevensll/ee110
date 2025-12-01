;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              GeneralMacros.inc                             ;
;                                CC2652  Macros                              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains generally useful macros for the CC2652 processor.  The
; macros included are:
;    MOV32 - move a 32-bit value into a register
;    MOVA  - move a 32-bit address into a register
;    STREG - store a 32-bit value in a MCU register using a base register
;
;
; Revision History
;     2/14/22  Glen George         initial revision
;    11/05/23  Glen George         updated style
;    10/28/25  Steven Lei          forked from Glen, update name for HW1
;    11/28/25  Steven Lei          add include guards

; local include files
;   none

;  .ifndef GENERAL_MACROS_INC
;  .define GENERAL_MACROS_INC

; MOV32
;
; Description:       This macro generates code to move a 32-bit constant into
;                    a CPU register.  The macro is passed the constant and the
;                    name of the register to move it into.
;
; Operation:         The register is loaded with the low 16 bits and then the
;                    high 16-bits of the constant.
;
; Arguments:         reg   - register to be loaded with the constant value.
;                    value - 32-bit constant to store in the register.
;
; Registers Changed: None.
; Stack Depth:       0 words
;
; Author:            Glen George
; Last Modified:     Feb. 14, 2022

MOV32   .macro  reg, value

        MOVW    reg, #(value & 0xFFFF)          ;load the low 16-bits
        MOVT    reg, #((value >> 16) & 0xFFFF)  ;load the high 16-bits

        .endm



; MOVA
;
; Description:       This macro generates code to move a 32-bit address into
;                    a CPU register.  The macro is passed the label of the
;                    address and the name of the register to move it into.
;
; Operation:         The register is loaded with the low 16 bits and then the
;                    high 16-bits of the address.
;
; Arguments:         reg  - register to be loaded with the address.
;                    addr - 32-bit address to store in the register.
;
; Registers Changed: None.
; Stack Depth:       0 words
;
; Author:            Glen George
; Last Modified:     Feb. 14, 2022

MOVA    .macro  reg, addr

        MOVW    reg, addr                       ;load the low 16-bits
        MOVT    reg, addr                       ;load the high 16-bits

        .endm

; STREG
;
; Description:       This macro generates code to store a 32-bit constant into
;                    an I/O register.  The macro is passed the constant to be
;                    stored, the register containing the base address of the
;                    I/O register, and the offset of the I/O register.
;
; Operation:         Register R0 is loaded with the low 16 bits and then the
;                    high 16 bits of the value.  This is then written to the
;                    specified register using the passed base register.
;
; Arguments:         value - 32-bit value to be stored in the I/O register.
;                    base  - register containing the I/O register base address
;                    off   - 16-bit offset (from the base) of the I/O register
;                            to be written.
;
; Registers Changed: R0.
; Stack Depth:       0 words
;
; Author:            Glen George
; Last Modified:     Feb. 14, 2022

STREG   .macro  value, base, off

        MOVW    R0, #(value & 0xFFFF)           ;load the low 16 bits of value
        MOVT    R0, #((value >> 16) & 0xFFFF)   ;load high 16 bits of value
        STR     R0, [base, #off]                ;and store the 32-bit value

        .endm

;  .endif GENERAL_MACROS_INC
