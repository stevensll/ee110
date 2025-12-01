; utilities
 .include  "inc/GeneralMacros.inc"
 .include  "inc/GeneralConstants.inc"

; CC26x2 hardware
 .include  "inc/CPUreg.inc"
 .include  "inc/GPIOreg.inc"
 .include  "inc/IOCreg.inc"
 .include  "inc/GPTreg.inc"

; This program specific
 .include  "inc/Keypad.inc"

    .data
    .align  4
debounceCounter:        .space          BYTES_PER_WORD
prevKeyPatt:            .space          BYTES_PER_WORD
currKeyPatt:            .space          BYTES_PER_WORD

    .text
    .def InitKeypad
    .def DebounceKeyPatt
    .def UpdateKeyPatt


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
            ;Pattern    ;Return value       ;ASCII Equivalent   ;Key pressed
    .half   0x01,       1                   ;1                  ;1
    .half   0x02,       2                   ;2                  ;2
    .half   0x04,       3                   ;3                  ;3
    .half   0x08,       4                   ;4                  ;4
    .half   0x10,       5                   ;5                  ;5
    .half   0x20,       6                   ;6                  ;6
    .half   0x40,       7                   ;7                  ;7
    .half   0x80,       8                   ;8                  ;8
    .half   0x100,      9                   ;9                  ;9
    .half   0x200,     42                   ;*                  ;*
    .half   0x400,      0                   ;0                  ;0
    .half   0x800,     35                   ;#                  ;#
    .half	0x07,	  100					;					;1+2+3
    .half	0x38,	  101					;					;4+5+6
    .half   0x49,     200                   ;                   ;
EndKeyPattTable:

; GetKeyValueFromPatt:
; Description:       Converts the argument key pattern (1 = key pressed)
;                    to an integer value by looking up the pattern in the 
;                    KeyPattTable. If the pattern is not in the table, returns
;                    BAD_KEY_VALUE.
;           
; Operation:         The KeyPattTable is loaded from memory. The key pattern
;                    argument is then compared to each pattern entry in the 
;                    table and if a match is found, the value is loaded. If
;                    no match, the return is BAD_KEY_VALUE
;
; Arguments:         currKeyPatt: the key pattern to convert
; Return Value:      R0: the key value 
;
; Local Variables:   None.
; Shared Variables:  KeyPattTable (R): the table is read to find a key value
;                    currKeyPatt (R): the key patt is read for table lookup
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
; Registers Changed: R0, R1, R2, R4, R5
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

GetKeyValueFromPatt:

SetupGetKeyValueFromPatt:               ;load the key patt and table variables
        MOVA    R1, currKeyPatt             ;get the curr key patt
        LDR     R0, [R1]                    
        ADR     R4, KeyPattTable            ;get the start of the table

GetKeyValueLoop:                        ;loop through the key patt table
        LDRH    R1, [R4], #BYTES_PER_HALF_WORD  ;get the table key pattern 
        LDRH    R2, [R4], #BYTES_PER_HALF_WORD  ;get the table key value
        CMP     R0, R1                      ;compare the patterns
        BEQ     DoneGetKeyValue             ;   match, so return value
        ;BNE    CheckEndKeyPattTable        ;no match, so check if at table end

CheckEndKeyPattTable:                   ;check if loop has hit the end of table
        ADR     R5, EndKeyPattTable         ;get table end address
        CMP     R4, R5                      ;compare to current address
        BNE     GetKeyValueLoop             ;   not end of table, so still loop
        ;BEQ    NoKeyValueFound             ;end of table, so patt not in table
    
NoKeyValueFound:                        ;key pattern is not in table
        MOV     R2, #BAD_KEY_VALUE          ;so value is BAD_KEY_VALUE
        ;B       DoneGetKeyValue            ;return

DoneGetKeyValue:
        MOV     R0, R2                      ;return value must be in R0
        BX      LR                          ;done so return


; InitKeypad    
; Description:       Initializes the keypad by resetting the debounce counter
;                    and key pattern variables.
;                    
; Operation:         The debounceCounter is reset to the debounce time and the
;                    currKeyPatt and prevKeyPatt are reset to NO_KEYPATT.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  debounceCounter (W): debounce time is written
;                    currKeyPatt (W): NO_KEYPATT is written
;                    prevKeyPatt (W): NO_KEYPATT is written
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
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

InitKeypad:
        MOVA    R1, debounceCounter         ;get the counter from memory
        MOV32   R0, (DEBOUNCE_TIME_MS)
        STR     R0, [R1]                    ;and reset it to the debounce time

        MOVA    R1, prevKeyPatt             ;get the previous patt from memory  
        MOV     R0, #NO_KEYPATT
        STR     R0, [R1]                    ;and reset it to no key pressed
        
        MOVA    R1, currKeyPatt             ;get the curr patt from memory
        STR     R0, [R1]                    ;and reset it to no key pressed

        BX      LR                          ;done so return 


; WriteKeypadRows
; Description:       Handles keypresses by checking if any key is pressed and
;                    debouncing the pressed keys. This routine is expected to 
;                    be called by the timer interrupt every 1 ms.
;                    
; Operation:         Call UpdateKeyPatt to find the currently pressed keys
;                    and then DbounceKeyPatt if any keys are found.
;
; Arguments:         R0: the keypad row to select on the demux.
; Return Value:      None.
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
; Registers Changed: R0, R1
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision
; Arguments:        R0
; Returns:			R7
WriteDemuxPins:
        SUB     R0, R0, #1					;decrement index since 1-indexed
        AND     R6, R0, #BIT_0_MASK         ;get the 0th bit of the row index
        LSL     R6, R6, #DEMUX_PIN_A            ;and place it at demux pin A
        AND     R7, R0, #BIT_1_MASK         ;get the 1st bit of the row index
        LSL     R7, R7, #(DEMUX_PIN_B-1)        ;and place it at demux pin B
        ORR     R8, R7, R6                  ;combine the bit patterns

        MOV32   R5, GPIO_BASE_ADDR          ;get the GPIO base for writing
        STR     R8, [R5, #GPIO_DOUT31_0_OFF]    ;and output to the demux pins
DoneWriteDemuxPins:
        BX      LR                              ;done so return

;ReadKeypadCol
;Args: R0 - col to read, R1 - shift amount
;Return: R6

ReadKeypadCol:
        MOV32   R5, GPIO_BASE_ADDR			;get the GPIO base for reading
	    LDR     R6, [R5, #GPIO_DIN31_0_OFF] ;read the col bit, is active low
        MOV     R7, #0						;hold the correct bit pattern

        LSR     R6, R6, R0                  ;move col bit to 0 bit
        MVN     R6, R6                      ;negate it for active high
        AND     R6, R6, #BIT_0_MASK         ;mask the bit, only want 0 bit
        LSL     R6, R6, R1                  ;and shift it to the right spot

DoneReadKeypadCol:
        BX      LR




; UpdateKeyPatt

UpdateKeyPatt:
        PUSH    {LR}					   ;save return address
        MOVA    R1, currKeyPatt			   ;get the curr key patt from memory
        LDR     R0, [R1]
        MOVA    R1, prevKeyPatt            ;get the prev key patt from memory
        STR     R0, [R1]                   ;and update to the current key patt

        MOV     R2, #1                     ;hold row index for looping through
        MOV     R3, #0                     ;hold the final key pattern
		MOV 	R4, #0					   ;hold the shift amount for key pattern

UpdateKeyPattLoop:

        MOV     R0, R2					   ;argument row index must be in R0
        BL      WriteDemuxPins			   ;write the row index to demux pins

ReadKeypadCols:								;read columns at each row
        
        MOV     R0, #KEYPAD_COL_1			;argument col index is in R0
		MOV		R1, R4						;argument shift amt index is R1
        BL      ReadKeypadCol				;read the col bit of the row
        ORR     R3, R3, R6					;return is R6, accumulate in R3

		ADD		R4, R4, #1					;increment shift amount
        MOV     R0, #KEYPAD_COL_2			;argument col index is in R0
		MOV		R1, R4						;argument shift amt index is R1
        BL      ReadKeypadCol				;read the col bit of the row
        ORR     R3, R3, R6					;return is R6, accumulate in R3

		ADD		R4, R4, #1					;increment shift amount
        MOV     R0, #KEYPAD_COL_3			;argument col index is in R0
		MOV		R1, R4						;argument shift amt index is R1
        BL      ReadKeypadCol				;read the col bit of the row
        ORR     R3, R3, R6					;return is R6, accumulate in R3

		ADD		R4, R4, #1					;increment shift amount

CheckDoneUpdateKeyPattLoop:
        ADD     R2, R2, #1					;advance to next row to read cols
        CMP     R2, #(KEYPAD_NUM_ROWS + 1)	;check if looped through rows
        BNE     UpdateKeyPattLoop			;	not done looping, so continue
        ;BEQ    DoneUpdateKeyPatt			;looped all rows, so done

DoneUpdateKeyPatt:
        POP     {LR}						;restore the return address
        MOVA    R1, currKeyPatt           	;get the curr key patt from memory
        STR     R3, [R1]					;	and store the new key patt
        MOV     R0, R3                      ;return new key patt
        BX      LR                          ;done so return

; DebounceKeyPatt
; Description:       Debounces the key pattern pressed 
;                    and previous key pattern variables.
;                    
; Operation:         The debounceCounter is reset to the debounce time and the
;                    prevKeyPattern is reset to no key pressed.
;
; Arguments:         callback - the function to execute after a key is debounced
; Return Value:      None.
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
; Registers Changed: R0, R1
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

DebounceKeyPatt:
        PUSH    {LR}
DebounceKeyPattLoop:                    ;loop until counter is 0 or patt changes

        MOVA    R2, prevKeyPatt             ;get the previous patt from memory
        LDR     R1, [R2]
        MOVA    R2, currKeyPatt
        LDR     R0, [R2]

        CMP     R1, R0                      ;compare prev to current key patt
        BNE     ResetDebounceCounter        ;patts different, so reset counter

StartDebounceKeyPatt:                   ;prev and curr patts same, so debounce
        BL      UpdateKeyPatt               ;get the new switch pattern

        MOVA    R2, debounceCounter         ;get debounce counter from memory
        LDR     R1, [R2]                    
        SUBS    R1, R1, #1                  ;decrement counter, check if 0
        BEQ     ProcessDebouncedKeyPatt		;	counter is 0, so key debounced
        STR     R1, [R2]                    ;counter not 0, write to memory
        BNE     DoneDebounceKeyPatt         ;	and keep looping

ProcessDebouncedKeyPatt:                ;counter is 0, so process the key patt
        MOVA    R2, debounceCounter         ;get counter from memory
        MOV32   R1, (REPEAT_RATE_MS)        ;setup counter for auto repeat
        STR     R1, [R2]                    ;write new counter value to memory
        BL      GetKeyValueFromPatt         ;get the key value pressed
        BLX     R10                         ;call the callback
		B	DoneDebounceKeyPatt				;done

ResetDebounceCounter: 					;done debouncing, so always reset counter
        MOVA    R1, debounceCounter         ;get the counter from memory
        MOV32   R0, (DEBOUNCE_TIME_MS)    	;reset to debounce time
        STR     R0, [R1]                    ;write to memory

DoneDebounceKeyPatt:
        POP     {LR}						;restore return address
        BX      LR                          ;done so return
