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

; Keypad key mappings
KEYPAD_1_KEY_PATT           .equ        0x01
KEYPAD_2_KEY_PATT           .equ        0x02
KEYPAD_3_KEY_PATT           .equ        0x04
KEYPAD_4_KEY_PATT           .equ        0x08
KEYPAD_5_KEY_PATT           .equ        0x10
KEYPAD_6_KEY_PATT           .equ        0x20
KEYPAD_7_KEY_PATT           .equ        0x40
KEYPAD_8_KEY_PATT           .equ        0x80
KEYPAD_9_KEY_PATT           .equ        0x100
KEYPAD_STAR_KEY_PATT        .equ        0x200
KEYPAD_0_KEY_PATT           .equ        0x400
KEYPAD_POUND_KEY_PATT       .equ        0x800

KEYPAD_1_KEY_VALUE          .equ        1
KEYPAD_2_KEY_VALUE          .equ        2
KEYPAD_3_KEY_VALUE          .equ        3
KEYPAD_4_KEY_VALUE          .equ        4
KEYPAD_5_KEY_VALUE          .equ        5
KEYPAD_6_KEY_VALUE          .equ        6
KEYPAD_7_KEY_VALUE          .equ        7
KEYPAD_8_KEY_VALUE          .equ        8
KEYPAD_9_KEY_VALUE          .equ        9
KEYPAD_0_KEY_VALUE          .equ        0
KEYPAD_STAR_KEY_VALUE       .equ        42
KEYPAD_POUND_KEY_VALUE      .equ        35

KEYPAD_1_2_KEY_PATT         .equ        KEYPAD_1_KEY_PATT  | KEYPAD_2_KEY_PATT
KEYPAD_1_2_KEY_VALUE        .equ        12

KEYPAD_1_3_KEY_PATT         .equ        KEYPAD_1_KEY_PATT  | KEYPAD_3_KEY_PATT
KEYPAD_1_3_KEY_VALUE        .equ        13

KEYPAD_2_3_KEY_PATT         .equ        KEYPAD_2_KEY_PATT  | KEYPAD_3_KEY_PATT
KEYPAD_2_3_KEY_VALUE        .equ        23

KEYPAD_1_2_3_KEY_PATT       .equ        KEYPAD_1_2_KEY_PATT | KEYPAD_3_KEY_PATT
KEYPAD_1_2_3_KEY_VALUE      .equ        123

KEYPAD_4_5_KEY_PATT         .equ        KEYPAD_4_KEY_PATT  | KEYPAD_5_KEY_PATT
KEYPAD_4_5_KEY_VALUE        .equ        45

KEYPAD_4_6_KEY_PATT         .equ        KEYPAD_4_KEY_PATT  | KEYPAD_6_KEY_PATT
KEYPAD_4_6_KEY_VALUE        .equ        46

KEYPAD_5_6_KEY_PATT         .equ        KEYPAD_5_KEY_PATT  | KEYPAD_6_KEY_PATT
KEYPAD_5_6_KEY_VALUE        .equ        56

KEYPAD_4_5_6_KEY_PATT       .equ        KEYPAD_4_5_KEY_PATT | KEYPAD_6_KEY_PATT
KEYPAD_4_5_6_KEY_VALUE      .equ        456

KEYPAD_7_8_KEY_PATT         .equ        KEYPAD_7_KEY_PATT  | KEYPAD_8_KEY_PATT
KEYPAD_7_8_KEY_VALUE        .equ        78

KEYPAD_7_9_KEY_PATT         .equ        KEYPAD_7_KEY_PATT  | KEYPAD_9_KEY_PATT
KEYPAD_7_9_KEY_VALUE        .equ        79

KEYPAD_8_9_KEY_PATT         .equ        KEYPAD_8_KEY_PATT  | KEYPAD_9_KEY_PATT
KEYPAD_8_9_KEY_VALUE        .equ        89

KEYPAD_7_8_9_KEY_PATT       .equ        KEYPAD_7_8_KEY_PATT | KEYPAD_9_KEY_PATT
KEYPAD_7_8_9_KEY_VALUE      .equ        789