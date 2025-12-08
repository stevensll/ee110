;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Keypad.inc                                 ;
;                                 EE110a HW2                                 ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains constants used for the Keypad interface for HW2. The 
; keypad used is a 4 (row) x 3 (col) mechanical keypad with 6 pinouts.
; The key presses are handled by reading the columns of the keypad row by row.
; To achieve this, the column pins of the keypad are connected to the launchpad
; as inputs. The row pins of the keypad are connected to the SN74LS139ADR 
; decoder and the decoder pins are connected to the launchpad as outputs.
; The key presses are also debounced with an auto repeat rate. Keypress
; debouncing should be called by a timer interrupt.

; References: Keypad pinout picture
;               
;             Keypad schematic with CC26xR launchpad 
;               

; Keypad hardware
KEYPAD_NUM_ROWS     .equ        4 
KEYPAD_NUM_COLS     .equ        3           

; Keypad columns, 1 indexed     
KEYPAD_COL_1        .equ        20      ;Connected to GPIO 20
KEYPAD_COL_2        .equ        19      ;"               " 19
KEYPAD_COL_3        .equ        18      ;"               " 18  

; Keypad rows - connected to demux
DEMUX_PIN_A         .equ        4
DEMUX_PIN_B         .equ        21

; Debounce parameters
DEBOUNCE_TIME_MS    .equ        50      ;50 ms debouncing
REPEAT_RATE_MS      .equ        500     ;500 ms repeat rate

; Keypad deboncing should be called by 1ms interrupt
KEYPAD_INT_MS       .equ        1       ;1ms/1KHz interrupts

; Software constants
NO_KEYPATT          .equ        0       ;key pattern for no key pressed
BAD_KEY_VALUE       .equ        -1      ;unrecognized/unsupported key press 