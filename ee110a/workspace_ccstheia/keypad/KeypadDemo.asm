

; utilities
 .include  "GeneralMacros.inc"
 .include  "GeneralConstants.inc"

; CC26x2 hardware
 .include  "CPUreg.inc"
 .include  "GPIOreg.inc"
 .include  "IOCreg.inc"
 .include  "GPTreg.inc"

; This program specific
 .include  "Keypad.inc"
 .include  "KeypadDemo.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        .ref InitPower
        .ref InitClocks
        .ref InitGPT0
        .ref InitGPIO
        .ref MoveVecTable
        .text

        .global resetISR
        
resetISR:

Main:
        MOVA    R0, TopOfStack               ;initialize the stack pointers
        MSR     MSP, R0
        SUB     R0, R0, #HANDLER_STACK_SIZE
        MSR     PSP, R0


        BL      InitPower               ;turn on power to everything
        BL      InitClocks              ;turn on clocks to everything
        BL      MoveVecTable            ;move the vector table to RAM
        BL      InitGPIO                ;setup the I/O (only output)

        BL      InstallGPT0Handler      ;install the event handler
        BL      InitGPT0                ;initialize the internal timer
                                        ;initialize the variables
        BL      InitEventQueue
        BL      InitKeypad

        MOV32   R1, SCS_BASE_ADDR       ;and finally allow interrupts.
        STREG   (1 << GPT0A_IRQ_NUM), R1, NVIC_ISER0

Forever:
        MOV32     R9, NO_KEYPATT

DoneMain:
        B      Forever

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


; KeyPressHandler
; Description:       Handles keypresses by checking if any key is pressed and
;                    debouncing the pressed keys. This routine is expected to 
;                    be called by the timer interrupt every 1 ms.
;                    
; Operation:         Call UpdateKeyPatt to find the currently pressed keys
;                    and then DbounceKeyPatt if any keys are found.
;
; Arguments:         None.
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

KeypressHandler:
        PUSH    {R0, R1, R2, R3, R4, R5, R6, LR} ;save touched registers
        NOP
        MOV32   R1, GPIO_BASE_ADDR
        NOP
        STREG   ((1 << DEMUX_PIN_A)), R1, GPIO_DTGL31_0_OFF

        ; BL      UpdateKeyPatt           ;get the new key pattern
        ; CMP     R0, #NO_KEYPATT         ;check if there is some key press
        ; BEQ     DoneKeypressHandler     ;   dont have any key press, so done
        ; BL      DebounceKeyPatt         ;have some key press, so debounce
ResetInt:                               ;reset interrupt bit for GPT0A
        MOV32   R1, GPT0_BASE_ADDR      ;get base address
        ; STREG   GPT_IRQ_TATO, R1, GPT_ICLR_OFF ;clear timer A timeout interrupt

DoneKeypressHandler:
        POP     {R0, R1, R2, R3, R4, R5, R6, LR} ;restore registers
        BX      LR                      ;done so return



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
WriteKeypadRows:
        MOV32   R2, GPIO_BASE_ADDR          ;get the GPIO base for writing
        AND     R1, R0, #BIT_0_MASK         ;get the 0th bit of the row number
        LSL     R3, R1, #DEMUX_PIN_A            ;and place it at demux pin A
        AND     R1, R0, #BIT_1_MASK         ;get the 1st bit of the row number
        LSL     R4, R1, #(DEMUX_PIN_B-1)        ;and place it at demux pin B
        ORR     R4, R4, R3                  ;combine the bit patterns
        STR     R4, [R2, #GPIO_DOUT31_0_OFF]    ;and output to the demux pins
DoneWriteKeypadRows:                        
        BX      LR                              ;done so return

;ReadKeypadCol
;Args: R0 - col to read, R1 - rotation amount
;Return: R3

ReadKeypadCol:
        MOV32   R2, GPIO_BASE_ADDR
        LDR     R3, [R2]
        MOV     R4, #0

        LSR     R3, R3, R0                      ;move col bit to 0th bit
        MVN     R3, R3                          ;negate it
        AND     R3, R3, #BIT_0_MASK             ;mask
        LSL     R3, R3, R1                      ;and shift it to the right spot

DoneReadKeypadCol:
        BX      LR


; ReadKeypadCols:     
;         ; read input to rows
;         MOV32   R1, GPIO_BASE_ADDR
;         LDR     R2, [R1, #GPIO_DIN31_0_OFF] ;read the column as active high

;         MOV     R4, #0                          

;         LSR     R3, R2, #KEYPAD_COL_0           ;move col bit to 0th bit
;         MVN     R3, R3                          ;negate it
;         AND     R3, R3, #BIT_0_MASK             ;mask
;         ORR     R4, R4, R3, LSL #0              ;and rotate back to right pos

;         LSR     R3, R2, #KEYPAD_COL_1          
;         MVN     R3, R3                          
;         AND     R3, R3, #BIT_0_MASK                   
;         ORR     R4, R4, R3, LSL #1              

;         LSR     R3, R2, #KEYPAD_COL_2          
;         MVN     R3, R3                         
;         AND     R3, R3, #BIT_0_MASK                  
;         ORR     R4, R4, R3, LSL #2              

        ; MOV     R0, R4                          ;return must be in R0

; UpdateKeyPatt

UpdateKeyPatt:
        PUSH    {LR}
        MOVA    R1, currKeyPatt
        LDR     R0, [R1]
        MOVA    R1, prevKeyPatt            ;get the prev key patt from memory
        STR     R0, [R1]                   ;and update to the current key patt

        MOV     R6, #0                     ;setup looping through keypad rows
        MOV     R8, #0                     ;hold the pattern here

UpdateKeyPattLoop:
        ; output to demux
        MOV     R0, R6
        BL      WriteKeypadRows

        MOV     R0, #KEYPAD_COL_0
        ADD     R1, R6, #1
        MOV     R2, #KEYPAD_NUM_COLS
        MUL     R1, R1, R2
        SUB     R1, R1, #3
        BL      ReadKeypadCol
        ORR     R8, R3, R3

        MOV     R0, #KEYPAD_COL_1
        ADD     R1, R6, #1
        MOV     R2, #KEYPAD_NUM_COLS
        MUL     R1, R1, R2
        SUB     R1, R1, #2
        BL      ReadKeypadCol
        ORR     R8, R3, R3

        MOV     R0, #KEYPAD_COL_2
        ADD     R1, R6, #1
        MOV     R2, #KEYPAD_NUM_COLS
        MUL     R1, R1, R2
        SUB     R1, R1, #1
        BL      ReadKeypadCol
        ORR     R8, R3, R3
        
CheckDoneUpdateKeyPattLoop:
        ADD     R6, R6, #1
        CMP     R6, #KEYPAD_NUM_ROWS
        BNE     UpdateKeyPattLoop
        ;BEQ    DoneUpdateKeyPatt

DoneUpdateKeyPatt:
        POP     {PC}
        MOVA    R1, currKeyPatt            ;get the curr key patt from memory
        STR     R8, [R1]   
        BX      LR                              ;done so return
; DebounceKeyPatt
; Description:       Debounces the key pattern pressed 
;                    and previous key pattern variables.
;                    
; Operation:         The debounceCounter is reset to the debounce time and the
;                    prevKeyPattern is reset to no key pressed.
;
; Arguments:         None.
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

DebounceKeyPattLoop:                    ;loop until counter is 0 or patt changes

        MOVA    R2, prevKeyPatt             ;get the previous patt from memory
        LDR     R1, [R2]
        MOVA    R2, currKeyPatt
        LDR     R0, [R2]

        CMP     R1, R0                      ;compare prev to current key patt
        BNE     DoneDebounceKeyPatt         ;patts different, so done debouncing

StartDebounceKeyPatt:                   ;prev and curr patts same, so debounce
        MOVA    R2, debounceCounter         ;get debounce counter from memory
        LDR     R1, [R2]                    
        SUBS    R1, R1, #1                  ;and decrement counter, check for 0
        BEQ     ProcessDebouncedKeyPatt
        STR     R1, [R2]                    ;write new counter value to memory
        PUSH    {LR}
        BL      UpdateKeyPatt               ;get the new switch pattern
        POP     {PC}
        BNE     DebounceKeyPattLoop         ;counter is not 0, keep debouncing

ProcessDebouncedKeyPatt:                ;counter is 0, so process the key patt
        MOVA    R2, debounceCounter         ;get counter from memory
        MOV32   R1, (REPEAT_RATE_MS)         ;setup counter for auto repeat
        STR     R1, [R2]                    ;write new counter value to memory
        PUSH    {LR}
        BL      GetKeyValueFromPatt         ;get the key value pressed
        BL      EnqueueEvent                ;   and enqueue the key event
        POP     {PC}
        B       DebounceKeyPattLoop         ;loop back for auto repeat

DoneDebounceKeyPatt:                    ;done debouncing, so always reset counter
        MOVA    R1, debounceCounter         ;get the counter from memory
        MOV32   R0, (DEBOUNCE_TIME_MS)    ;reset to debounce time
        STR     R0, [R1]                    ;write to memory

        BX      LR                          ;done so return


; InitEventQueue
; Description:       Initializes the event queue. Note that this is a "dummy"
;                    event queue implemented as a buffer, so all it does is 
;                    reset the index to the buffer. By default, the queue
;                    values are initializaed to 0 when declare with
;                    the ".space" directive.
;           
; Operation:         The queueIndex variable is reset to 0, which is the
;                    start of the event queue.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  queueIndex  (W): the key index is reset to 0
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
; Revision History:  11/27/25   Steven Lei       initial revision

InitEventQueue:
        MOVA    R1, queueIndex              ;get the index from memory
        MOV     R0, #0                      
        STR     R0, [R1]                    ;and reset it (0 indexed)

        BX      LR                          ;done so return


; EnqueueEvent
; Description:       Adds an event (argument) into the event queue. Note that
;                    this event queue is implemented as a buffer, so all it 
;                    does is write the event to the buffer at the current
;                    queue index. It then increments the queue index.
;                    NOTE: If the queue is full, the queue will OVERWRITE 
;                    the next value by wrapping the queue index back to start.
;           
; Operation:         The event is stored in the queue and the queue index
;                    is then incremented. The queue index is then reset to 0
;                    if it exceeds the queue size (wrap around).
;
; Arguments:         R0: the event to add to the queue
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  queueIndex (R, W): the queue index is read to determine
;                                       where to write to the queue and updated
;                                       to point to the next writeable entry
;                    eventQueue (W):    the event is written to the queue
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
; Registers Changed: R0, R1, R2, R3, R4
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

EnqueueEvent:

AddEventToQueue:                        ;write the event (R0) to the queue 
        MOVA    R3, queueIndex              ;get the queue index from memory 
        LDR     R2, [R3]                    

        MOV     R4, #BYTES_PER_WORD         ;scale queue index to create offset
        MUL     R4, R2, R4                  ;R4 is now byte offset to the queue 

        MOVA    R1, eventQueue              ;get base addr for event queue 
        STR     R0, [R1, R4]                ;and store event at base + offset

UpdateQueueIndexValue:                  ;update the queue index with wraparound
        ADD     R2, R2, #1                  ;increment queue index
        CMP     R2, #QUEUE_SIZE             ;check if index is past end of queue
        BNE     DoneEnqueueEvent            ;   within bounds, so done
        MOV     R2, #0                      ;past end, so wrap back to start

DoneEnqueueEvent:                       
        STR     R2, [R3]                    ;write new queue index to memory
        BX      LR                          ;done so return




; InstallGPT0Handler
;
; Description:       Install the keypad handler for the GPT0 timer interrupt.
;
; Operation:         Writes the address of the timer event handler to the
;                    appropriate interrupt vector.
;
; Arguments:         None.
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
; Revision History:  02/16/21   Glen George      initial revision
;                    11/25/25   Steven Lei       retrieved from website
;                                                update for keypad handler

InstallGPT0Handler:


        MOVA    R0, KeypressHandler     ;get keypress handler address
        MOV32   R1, SCS_BASE_ADDR       ;get address of SCS registers
        LDR     R1, [R1, #VTOR_OFF]     ;get table relocation address
        STR     R0, [R1, #(4 * GPT0A_EX_NUM)]   ;store vector address


        BX      LR                      ;all done, return



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data
        ; the stack (must be double-word aligned)

        .align  8
TopOfStack:     .bes    TOTAL_STACK_SIZE


        .align 4
        ; the event queue, NOTE: for this demo, it is just a dummy buffer
eventQueue:         .space  QUEUE_SIZE * BYTES_PER_WORD

        ; variables
        .align  4
debounceCounter:        .space          BYTES_PER_WORD
prevKeyPatt:            .space          BYTES_PER_WORD
currKeyPatt:            .space          BYTES_PER_WORD
queueIndex:             .space          BYTES_PER_WORD


        .end
