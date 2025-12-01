;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Keypad.inc                                 ;
;                                 EE110a HW2                                 ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains constants used for the KeypadDemo program. 

; Keypad hardware and I/O mappings

KEYPAD_NUM_ROWS     .equ        4
KEYPAD_NUM_COLS     .equ        3   

KEYPAD_COL_0        .equ        20
KEYPAD_COL_1        .equ        19
KEYPAD_COL_2        .equ        18

DEMUX_PIN_A         .equ        4
DEMUX_PIN_B         .equ        21

NO_KEYPATT          .equ        0
BAD_KEY_VALUE       .equ        -1

; Debounce parameters

DEBOUNCE_TIME_MS    .equ        50
REPEAT_RATE_MS      .equ        500

KEYPAD_INT_MS       .equ        1       ;1ms/1KHz interrupts
