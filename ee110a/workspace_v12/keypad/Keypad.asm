;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Keypad.asm                                 ;
;                                 EE110a HW2                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for the keypad interface.  The 
; keypad used is a 4 (row) x 3 (col) mechanical keypad with 6 pinouts.
; The key presses are handled by reading the columns of the keypad row by row.
; To achieve this, the column pins of the keypad are connected to the launchpad
; as inputs. The row pins of the keypad are connected to the SN74LS139ADR 
; demux and the demux pins are connected to the launchpad as outputs.
;
; The key presses are also debounced with an auto repeat rate. Keypress
; debouncing should be called by a timer interrupt. The debounced keypress is
; stored constructed such that it is in a one hot  scheme, e.g. bit 0 high means 
; key 1 is pressed, bit 11 high means key 12 is pressed, etc. The key pattern
; is then converted to a key value constant, which is defined in Keypad.inc
; 
; NOTE: the keypad has no ghosting diodes, so the only key preses supported are:
;   any individual key press
;   any combination of keys within the same row (e.g. 1 + 2 + 3, 2 + 3), 
; Unsupported keypresses will return BAD_KEY_VALUE instead.
;
; Public functions:
;   InitKeypad - setup the keypad variables and init the GPIO pins used
;   DebounceKeyPatt  - debounce the key pattern by comparing new and old key 
;                      key patt. Returns TRUE and the key value from the patt
;                      if debounced, FALSE otherwise
;   UpdateKeyPatt  - get the new key pattern press by scanning through keypad 
;                    and upate the prev/curr key pattern variables
; 
; Private functions:
;   ReadKeypadCol - reads the specified keypad col pin and places it at nth bit
;   SelectKeypadRow - selects the keypad row to drive from the demux
;   GetKeyValueFromPatt - gets the key value given the key pattern
; 
; Private data:
;   
; References:
;   keypad_schematic.pdf, keypad_pinout.jpg, SN74LS139AN data sheet
;
; Revision History:
;    11/30/25  Steven Lei       initial revision

; Local includes
    ; Utilities
    .include  "inc/GeneralMacros.inc"
    .include  "inc/GeneralConstants.inc"
    ; CC26x2 hardware
    .include  "inc/CPUreg.inc"
    .include  "inc/GPIOreg.inc"
    .include  "inc/IOCreg.inc"
    ; Program specific
    .include  "inc/Keypad.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .align  4
    ; the counter for key press debouncing
debounceCounter:        .space          BYTES_PER_WORD
    ; the current key pattern, in a one hot scheme
prevKeyPatt:            .space          BYTES_PER_WORD
    ; the preve key pattern, in a one hot scheme
currKeyPatt:            .space          BYTES_PER_WORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .text
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;Define public functions
    .def InitKeypad
    .def DebounceKeyPatt
    .def UpdateKeyPatt
    .ref InitGPIO

; KeypadIOTable
; Description:      This table maps the IO pins used in the keypad to their
;                   respective IO configuration. This allows for a function
;                   to initialize the KeypadIO by reading the table.
;
; Revision history: 11/27/25    Steven Lei      initial revision                   
KeypadIOTable:
            ;Pin                    Config             
    .word   KEYPAD_DEMUX_PIN_A,     IOCFG_GEN_DOUT_4MA                     
    .word   KEYPAD_DEMUX_PIN_B,     IOCFG_GEN_DOUT_4MA                     
    .word   KEYPAD_COL_PIN_1,       IOCFG_GEN_DIN
    .word   KEYPAD_COL_PIN_2,       IOCFG_GEN_DIN
    .word   KEYPAD_COL_PIN_3,       IOCFG_GEN_DIN
EndKeypadIOTable:

; KeyPattTable
; Description:      This table maps key pattern presses from the 4x3 keypad
;                   to an integer value. The key pattern should be active
;                   high for the key that is pressed. For special characters
;                   like * and #, the corresponding value are their ASCII int
;                   encodings. The patterns are stored as half words (16 bits)
;                   since there are only 12 keys.
;   
; Revision history: 11/27/25    Steven Lei      initial revision
;                   
KeyPattTable:
            ;Pattern                ;Return value           ;Key pressed
    .half   KEYPAD_1_KEY_PATT,      KEYPAD_1_KEY_VALUE      ;1                  
    .half   KEYPAD_2_KEY_PATT,      KEYPAD_2_KEY_VALUE      ;2                  
    .half   KEYPAD_3_KEY_PATT,      KEYPAD_3_KEY_VALUE      ;3                  
    .half   KEYPAD_4_KEY_PATT,      KEYPAD_4_KEY_VALUE      ;4                  
    .half   KEYPAD_5_KEY_PATT,      KEYPAD_5_KEY_VALUE      ;5                  
    .half   KEYPAD_6_KEY_PATT,      KEYPAD_6_KEY_VALUE      ;6                  
    .half   KEYPAD_7_KEY_PATT,      KEYPAD_7_KEY_VALUE      ;7                  
    .half   KEYPAD_8_KEY_PATT,      KEYPAD_8_KEY_VALUE      ;8                  
    .half   KEYPAD_9_KEY_PATT,      KEYPAD_9_KEY_VALUE      ;9                  
    .half   KEYPAD_STAR_KEY_PATT,   KEYPAD_STAR_KEY_VALUE   ;*
    .half   KEYPAD_0_KEY_PATT,      KEYPAD_0_KEY_VALUE      ;0                  
    .half   KEYPAD_POUND_KEY_PATT,  KEYPAD_POUND_KEY_VALUE  ;# 
    .half   KEYPAD_1_2_KEY_PATT,    KEYPAD_1_2_KEY_VALUE    ;1+2
    .half   KEYPAD_1_3_KEY_PATT,    KEYPAD_1_3_KEY_VALUE    ;1+3
    .half   KEYPAD_2_3_KEY_PATT,    KEYPAD_2_3_KEY_VALUE    ;2+3
    .half   KEYPAD_1_2_3_KEY_PATT,  KEYPAD_1_2_3_KEY_VALUE  ;1+2+3
    .half   KEYPAD_4_5_KEY_PATT,    KEYPAD_4_5_KEY_VALUE    ;4+5
    .half   KEYPAD_4_6_KEY_PATT,    KEYPAD_4_6_KEY_VALUE    ;4+6
    .half   KEYPAD_5_6_KEY_PATT,    KEYPAD_5_6_KEY_VALUE    ;5+6
    .half   KEYPAD_4_5_6_KEY_PATT,  KEYPAD_4_5_6_KEY_VALUE  ;4+5+6
    .half   KEYPAD_7_8_KEY_PATT,    KEYPAD_7_8_KEY_VALUE    ;7+8
    .half   KEYPAD_7_9_KEY_PATT,    KEYPAD_7_9_KEY_VALUE    ;7+9
    .half   KEYPAD_8_9_KEY_PATT,    KEYPAD_8_9_KEY_VALUE    ;8+9
    .half   KEYPAD_7_8_9_KEY_PATT,  KEYPAD_7_8_9_KEY_VALUE  ;7+8+9
EndKeyPattTable:

; GetKeyValueFromPatt:
; Description:       Converts the argument key pattern (one hot scheme)
;                    to an integer value by looking up the pattern in the 
;                    KeyPattTable. If the pattern is not in the table, returns
;                    BAD_KEY_VALUE.
;           
; Operation:         The KeyPattTable is loaded from memory. The key pattern
;                    argument is then compared to each pattern entry in the 
;                    table and if a match is found, the value is loaded. If
;                    no match, the return is BAD_KEY_VALUE
;
; Arguments:         currKeyPatt: the key pattern to get a key value from
; Return Value:      R0: the key value 
;
; Local Variables:   R0 - the key value to return
;                    R1 - the curr key patt from memory
;                    R2 - the current table entry address
;                    R3 - the key patt from the table
; Shared Variables:  KeyPattTable - read the table to get key value and patts
;                    currKeyPatt -  curr patt is compared to patts in the table
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R0 - R3
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

GetKeyValueFromPatt:

SetupGetKeyValueFromPatt:               ;load the key patt and table variables
        MOVA    R2, currKeyPatt             ;get the curr key patt
        LDR     R1, [R2]                    
        ADR     R2, KeyPattTable            ;get the start of the table

GetKeyValueLoop:                        ;loop through the key patt table
        LDRH    R3, [R2], #BYTES_PER_HALF_WORD  ;get the table key pattern 
        LDRH    R0, [R2], #BYTES_PER_HALF_WORD  ;get the table key value
        CMP     R3, R1                      ;compare the patterns
        BEQ     DoneGetKeyValue             ;   match, so return value
        ;BNE    CheckEndKeyPattTable        ;no match, so check if at table end

CheckEndKeyPattTable:                   ;check if loop has hit the end of table
        ADR     R3, EndKeyPattTable         ;get table end address
        CMP     R2, R3                      ;compare to current address
        BNE     GetKeyValueLoop             ;   not end of table, so still loop
        ;BEQ    NoKeyValueFound             ;end of table, so patt not in table
    
NoKeyValueFound:                        ;key pattern is not in table
        MOV     R0, #BAD_KEY_VALUE          ;so value is BAD_KEY_VALUE
        ;B       DoneGetKeyValue            ;return
        
DoneGetKeyValue:
        BX      LR                          ;done so return


; InitKeypad    
; Description:       Initializes the keypad by resetting the debounce counter
;                    and key pattern variables. Also initializes the GPIO pins
;                    that the keypad uses.
;                    
; Operation:         The debounceCounter is reset to the debounce time and the
;                    currKeyPatt and prevKeyPatt are reset to NO_KEYPATT. 
;                    InitGPIO is called with the KeypadIOTable as the argument.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  debounceCounter - the counter is reset to its debounce time
;                    currKeyPatt - the current key pattern is reset to NO_KEY
;                    prevKeyPatt - the prev key pattern is reset to NO_KEY
;   
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1
; Stack Depth:       1 word
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

InitKeypad:

        MOVA    R0, KeypadIOTable           ;get the IO table start and end
        MOVA    R1, EndKeypadIOTable
        PUSH    {LR}                        ;save return address
        BL      InitGPIO                    ;init the pins in the IO table
        POP     {LR}                        ;restore return address

        MOVA    R1, debounceCounter         ;get the counter from memory
        MOV32   R0, (DEBOUNCE_TIME_MS)
        STR     R0, [R1]                    ;and reset it to the debounce time

        MOVA    R1, prevKeyPatt             ;get the previous patt from memory  
        MOV     R0, #NO_KEYPATT
        STR     R0, [R1]                    ;and reset it to no key pressed
        
        MOVA    R1, currKeyPatt             ;get the curr patt from memory
        STR     R0, [R1]                    ;and reset it to no key pressed

        BX      LR                          ;done so return 


; SelectKeypadRow
; Description:       Outputs the keypad row for the demux to select. The 
;                    demux will then drive the selected row low and all 
;                    other rows high (so active LOW).
;
; Operation:         Writes the 0th bit of the keypad row to pin A of the demux
;                    and the 1st bit of the keypad row to pin B of the demux.
;
; Arguments:         R0 - the keypad row to select on the demux
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            KEYPAD_ DEMUX_PIN_A - pin a of the demux input 
;                    KEYPAD_ DEMUX_PIN_B - pin b of the demux input
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2
; Stack Depth:       0 words
;
; References:        SN74LS139AN Data sheet, Keypad schematic     
;
; Revision History:  11/27/25   Steven Lei       initial revision

SelectKeypadRow:
        AND     R1, R0, #BIT_0_MASK         ;get the 0th bit of the row index
        LSL     R1, R1, #KEYPAD_DEMUX_PIN_A      ;and place it at demux pin A
        AND     R2, R0, #BIT_1_MASK         ;get the 1st bit of the row index
        LSL     R2, R2, #(KEYPAD_DEMUX_PIN_B-1)  ;and place it at demux pin B
        ORR     R2, R2, R1                  ;combine the bit patterns

        MOV32   R1, GPIO_BASE_ADDR          ;get the GPIO base for writing
        STR     R2, [R1, #GPIO_DOUT31_0_OFF]    ;and output to the demux pins
        
DoneSelectKeypadRow:
        BX      LR                              ;done so return

; ReadKeypadCol
; Description:       Reads the specified column pin of the keypad through GPIO. 
;                    The column bit is then shifted such that it is now at bit n
;                    with all other bits 0, and then this value is returned.
;                    NOTE: When key is pressed, the col bit is active LOW.
;
; Operation:         Gets the specified column pin from GPIO and places it in 
;                    the 0th bit. Then negates it, masks and shifts it into the 
;                    nth bit.
;
; Arguments:         R0 - the column bit to read
;                    R1 - the nth bit to shift the column bit to
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             KEYPAD_COL_PIN_X - the keypad column pin to read
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R2, R3
; Stack Depth:       0 words
;
; References:        Keypad schematic
;
; Revision History:  11/27/25   Steven Lei       initial revision

ReadKeypadCol:
        MOV32   R2, GPIO_BASE_ADDR			;get the GPIO base for reading
	    LDR     R3, [R2, #GPIO_DIN31_0_OFF] ;read all GPIO pins

        LSR     R3, R3, R0                  ;move col pin to 0 bit
        MVN     R3, R3                      ;negate it for (now active high)
        AND     R3, R3, #BIT_0_MASK         ;mask the bit, only want 0 bit
        LSL     R3, R3, R1                  ;and shift it to the nth bit
        MOV     R0, R3                      ;return is in R0

DoneReadKeypadCol:  
        BX      LR                          ;done so return




; UpdateKeyPatt
; Description:       Gets the new key patt that is being pressed and 
;                    updates key pattern variables. The prev key patt is set to 
;                    the current key pattern. The curr key patt is set to new 
;                    key patt, which is found by scanning through the keypad rows.
;                    A keypad row is selected and the column values are read.
;                    The column values are then shifted to create a one hot 
;                    scheme key pattern where bit 0 high represents key 0 
;                    pressed, bit 1 high represents key 1 pressed, etc.
;
; Operation:         Sets prevKeyPatt to currKeyPatt. Then sets up a loop
;                    to go through the rows of the keypad. At each row,
;                    calls SelectKeypadRow to select the row so that
;                    ReadKeypadCol can be called on each column bit. The 
;                    column bits must be shifted to the right positions so 
;                    the final key pattern is 1 hot scheme. The new key patt
;                    is returned.
;
; Arguments:         None.
; Return Value:      R0 - the new key patt that is pressed, which is one hot
;
; Local Variables:   R1 - the bit to shift the col bit to
;                    R2 - the row index for looping
;                    R3 - accumulator for the new key pattern
; Shared Variables:  prevKeyPatt - the previous key is set to the currKeyPatt
;                    currKeyPatt - the currKeyPatt is set to the new key patt
;                                  found by reading the keypad columns.
; Global Variables:  None.
;
; Input:             KEYPAD_COL_PIN_X - the keypad column pins to read
; Output:            KEYPAD_DEMUX_PIN_N - the keypad demux pins to write, which
;                                         selects the row
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0 - R3
; Stack Depth:       3 words max
;
; References:        Keypad schematic
;
; Revision History:  11/27/25   Steven Lei       initial revision

UpdateKeyPatt:
        PUSH    {LR}					;save LR since calling other functions

UpdatePrevKeyPatt:                      ;set prev key patt to current one
        MOVA    R1, currKeyPatt			    ;get the curr key patt from memory
        LDR     R0, [R1]
        MOVA    R1, prevKeyPatt             ;get the prev key patt from memory
        STR     R0, [R1]                    ;and update to the current key patt

UpdateKeyPattInit:                      ;initialize local variables
		MOV 	R1, #0					    ;the shift amount for col bit
        MOV     R2, #0                      ;row index for looping through
        MOV     R3, #0                      ;accumulator for new key pattern

UpdateKeyPattLoop:                      ;loop through keypad, writing to rows
        MOV     R0, R2					    ;argument row index must be in R0
        PUSH    {R1, R2}                    ;save modified registers
        BL      SelectKeypadRow			    ;write the row index to demux pins
        POP     {R1, R2}                    ;restore modified registers

ReadKeypadCols:								;read columns at each row
        MOV     R0, #KEYPAD_COL_PIN_1	    ;argument col bit must be in R0
        PUSH    {R2, R3}                    ;save modified registers
        BL      ReadKeypadCol				;read the col bit of the row
        POP     {R2, R3}                    ;restore modified registers
        ORR     R3, R3, R0					;return is R0, accumulate in R3

		ADD		R1, R1, #1					;increment shift amount
        MOV     R0, #KEYPAD_COL_PIN_2		;argument col bit must be in R0
        PUSH    {R2, R3}                    ;save modified registers
        BL      ReadKeypadCol				;read the col bit of the row
        POP     {R2, R3}                    ;restore modified registers
        ORR     R3, R3, R0					;return is R6, accumulate in R3

		ADD		R1, R1, #1					;increment shift amount
        MOV     R0, #KEYPAD_COL_PIN_3	    ;argument col bit must be in R0
        PUSH    {R2, R3}                    ;save modified registers
        BL      ReadKeypadCol				;read the col bit of the row
        POP     {R2, R3}                    ;restore modified registers
        ORR     R3, R3, R0					;return is R0, accumulate in R3

		ADD		R1, R1, #1					;increment shift amount

CheckDoneUpdateKeyPattLoop:
        ADD     R2, R2, #1					;advance to next row to read cols
        CMP     R2, #(KEYPAD_NUM_ROWS)	    ;check if looped through rows
        BNE     UpdateKeyPattLoop			;	not done looping, so continue
        ;BEQ    DoneUpdateKeyPatt			;looped all rows, so done

DoneUpdateKeyPatt:
        POP     {LR}						;restore the return address
        MOVA    R1, currKeyPatt           	;get the curr key patt from memory
        STR     R3, [R1]					;	and store the new key patt
        MOV     R0, R3                      ;return new key patt
        BX      LR                          ;done so return


; DebounceKeyPatt
; Description:       Debounces the key pattern pressed for DEBOUNCE_TIME_MS
;                    with auto repeat. Since this function is expected to be
;                    called by a timer interrupt, it only does one debounce
;                    cycle (debounceCounter only decrements once). If the key 
;                    is successfully debounced, sets the counter up for 
;                    auto repeat and returns the key value with a TRUE status.
;                    If the key is not debounced yet, returns a FALSE status.
;                    
; Operation:         The prev and curr key patterns are checked to see if the
;                    counter should be reset or decremented. Then calls 
;                    UpdateKeyPatt to get the new key pattern. 
;                    If the counter hits 0, then the counter is loaded with the 
;                    repeat rate and GetKeyValueFromPatt is called.
;                    
; Arguments:         None.
; Return Value:      R0 - TRUE if done debouncing, FALSE if not done debouncing.
;                    R1 - the key value, only relevant if debounced is TRUE.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0 - R3
; Stack Depth:       1 word max
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

DebounceKeyPatt:
        PUSH    {LR}

CheckKeyPattChanged:                    ;Check if key presses have changed
        MOVA    R2, prevKeyPatt             ;get the previous patt from memory
        LDR     R1, [R2]                
        MOVA    R2, currKeyPatt             ;get the curr key patt from memory
        LDR     R3, [R2]
        CMP     R1, R3                      ;check if prev = curr patt
        BNE     ResetDebounceCounter        ;patts different, so reset counter
        ;BEQ    StartDebounceKeyPatt        ;patts same, so debounce

StartDebounceKeyPatt:                  
        BL      UpdateKeyPatt               ;get the new key patt pattern
        MOVA    R2, debounceCounter         ;get debounce counter from memory
        LDR     R1, [R2]                    
        SUBS    R1, R1, #1                  ;decrement counter, check if 0
        BEQ     ProcessDebouncedKeyPatt		;	counter is 0, so key debounced
        STR     R1, [R2]                    ;counter not 0, save new count value
        MOV     R0, #FALSE                  ;return false - key not debounced 
        BNE     DoneDebounceKeyPatt         ;done with 1 debounce cycle

ProcessDebouncedKeyPatt:                ;counter is 0, so process the key patt
        MOVA    R2, debounceCounter         ;get counter from memory
        MOV32   R1, (REPEAT_RATE_MS)        ;setup counter for auto repeat
        STR     R1, [R2]                    ;write new counter value to memory
        BL      GetKeyValueFromPatt         ;get the key value - now in R0
        MOV     R1, R0                      ;key value if debounced is at R1
        MOV     R0, #TRUE                    ;return true - key is debounced
		B	    DoneDebounceKeyPatt		    ;done

ResetDebounceCounter: 					;reset debounce counter - not debounced
        MOVA    R2, debounceCounter         ;get the counter from memory
        MOV32   R1, (DEBOUNCE_TIME_MS)    	;reset to debounce time
        STR     R1, [R2]                    ;write to memory
        MOV     R0, #FALSE                  ;return false - key not debounced 
        ;B      DoneDbeounceKeyPatt         ;done

DoneDebounceKeyPatt:
        POP     {LR}						;restore return address
        BX      LR                          ;done so return
