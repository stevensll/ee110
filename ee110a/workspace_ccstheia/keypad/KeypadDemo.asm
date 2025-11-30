






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
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data

        ; the stack (must be double-word aligned)

        .align  8
TopOfStack:     .bes    TOTAL_STACK_SIZE



        ; the interrupt vector table in SRAM

        .align  512
VecTable:       .space  VEC_TABLE_SIZE * BYTES_PER_WORD

        .align 4

eventQueue:         .space  QUEUE_SIZE * BYTES_PER_WORD

        ; variables

        .align  4

debounceCounter:        .space          BYTES_PER_WORD
prevKeyPatt:            .space          BYTES_PER_WORD
currKeyPatt:            .space          BYTES_PER_WORD
queueIndex:             .space          BYTES_PER_WORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




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

                                        ;initialize the variables

        BL      InstallGPT0Handler      ;install the event handler
        BL      InitGPT0                ;initialize the internal timer

        BL      InitEventQueue
        BL      InitKeypad

        MOV32   R1, SCS_BASE_ADDR       ;and finally allow interrupts.
        STREG   (1 << GPT0A_IRQ_NUM), R1, NVIC_ISER0



        
        ; MOV32   R0, 0x0001
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0002
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0004
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0008
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0010
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0020
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0040
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0080
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0100
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0200
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0400
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent

        ; MOV32   R0, 0x0800
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent
Forever:
        MOV32     R9, NO_KEYPATT
        ; BL      UpdateKeyPatt
        ; BL      GetKeyValueFromPatt
        ; BL      EnqueueEvent        

DoneMain:
        B      Forever

; TestKeypressRead:
;         ; read input to rows
;         LDR     R2, [R1, #GPIO_DIN31_0_OFF] ;read the column inputs
;         LSR     R3, R2, #KEYPAD_COL_0            ;get the column 0 value
;         LSL     R3, #1                              ; and put it in right spot
;         LSR     R3, R2, #KEYPAD_COL_1            ;get the column 1 value
;         LSL     R3, #2                              ;and put it in right spot
;         LSR     R3, R2, #KEYPAD_COL_2            ;get the column 2 value
;         LSL     R3, #3                              ;and put it in right spot
;         MOV     R0, R3                          ;return must be in R0

; InitEventQueue
; Description:       Initializes the event queue. Note that this is a "dummy"
;                    event queue implemented as a buffer, so all it does is 
;                    reset the index to the buffer.
;           
; Operation:         The queueIndex variable is reset to 0, which is the
;                    start of the event queue.
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

InitEventQueue:
        MOVA    R1, queueIndex              ;get the index from memory
        MOV     R0, #0                      
        STR     R0, [R1]                    ;and reset it to 0

        BX      LR                          ;done so return


; EnqueueEvent
; Description:       Adds an event (argument) into the event queue. Note that
;                    this event queue is implemented as a buffer, so all it 
;                    does is write the event to the buffer at the current
;                    queue index. It then increments the queue index.
;                    NOTE: If the queue is full, the queue will OVERWRITE 
;                   itself by wrapping the queue index back to start.
;           
; Operation:         The event is stored in the queue and the queue index
;                    is then incremented. The queue index is then reset to 0
;                    if it exceeds the queue size (wrap around).
;
; Arguments:         R0: the event to add to the queue
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
; Registers Changed: R0, R1, R2, R3, R4
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

EnqueueEvent:

AddEventToQueue:                       
                                        ;arg: R0 contains the event 
        MOVA    R3, queueIndex              ;get the queue index from memory 
        LDR     R2, [R3]

        MOV     R4, #BYTES_PER_WORD         ;scale queue index to create offset
        MUL     R4, R2, R4                  ;R4 is now byte offset to the queue 

        MOVA    R1, eventQueue              ;get base addr for event queue 
        STR     R0, [R1, R4]                ;and store event at base + offset

UpdateQueueIndexValue:                  ;update the queue index with wraparound
        ADD     R2, R2, #1                  ;increment
        CMP     R2, #QUEUE_SIZE             ;check if index is past end of queue
        BNE     DoneEnqueueEvent            ;   within bounds, so done
        MOV     R2, #0                      ;   past end, so wrap back to start

DoneEnqueueEvent:                       
        STR     R2, [R3]                    ;write new queue index to memory
        BX      LR                          ;done so return

; ConvertKeyPattToValue
; Description:       Creates the KeyPatt event, which denotes that key(s) are
;                    pressed. The event code for this event is broken up into
;                    portions: event type and event value. The event type is
;                    USER_INPUT and the event value is the converted key 
;                    value generated from the key pattern.
;                    The key
;           
; Operation:         The event is stored in the queue and the queue index
;                    is then incremented. The queue index is then reset to 0
;                    if it exceeds the queue size (wrap around).
;
; Arguments:         R0: the event to add to the queue
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
; Registers Changed: R0, R1, R2
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision


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

GetKeyValueFromPatt:
        MOVA    R1, currKeyPatt
        LDR     R0, [R1]
        ADR     R4, KeyPattTable            ;get the start of the table

GetKeyValueLoop:
        LDRH    R1, [R4], #2                ;get the pattern from the table
        LDRH    R2, [R4], #2                ;get the value from the table
        CMP     R0, R1                      ;compare it to the argument pattern 
        BEQ     DoneGetKeyValue             ;patterns match, so return value
        ;BNE    CheckEndKeyPattTable        ;no match, so check if at table end

CheckEndKeyPattTable:
        ADR     R5, EndKeyPattTable         ;check if at end of table
        CMP     R4, R5                      
        BNE     GetKeyValueLoop             ;not at end, so keep looping
        ;BEQ    NoKeyValueFound             ;at end of table so no value found
    
NoKeyValueFound:
        MOV     R2, #-1                     ;return -1 if no key value found
        ;B       DoneGetKeyValue            ;done

DoneGetKeyValue:
        MOV     R0, R2                      ;return value must be in R0
        BX      LR                          ;done so return

; InitKeypad    
; Description:       Initializes the keypad by resetting the debounce counter
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

InitKeypad:
        MOVA    R1, debounceCounter         ;get the counter from memory
        MOV32   R0, (DEBOUNCE_TIME_MS)
        STR     R0, [R1]                    ;and reset it to the debounce time

        MOVA    R1, prevKeyPatt             ;get the previous patt from memory  
        MOV     R0, #NO_KEYPATT
        STR     R0, [R1]                    ;and reset it to no key pressed
        
        MOVA    R1, currKeyPatt
        STR     R0, [R1]
        BX      LR                          ;done so return 


KeypressHandler:
        PUSH    {R0, R1, R2, R3, R4, R5, R6, LR}
        BL      UpdateKeyPatt           ;get the new key pattern
        CMP     R0, #NO_KEYPATT         ;check if there is some key press
        BEQ     DoneKeypressHandler     ;dont have any key press, so done
        ;BNE    Debounce
Debounce:
        BL      DebounceKeyPatt         ;have some key press, so debounce

DoneKeypressHandler:
        POP     {R0, R1, R2, R3, R4, R5, R6, PC}                ;restore registers
        BX      LR                      ;done so return
        
; UpdateKeyPatt

UpdateKeyPatt:
        MOVA    R1, currKeyPatt
        LDR     R0, [R1]
        MOVA    R1, prevKeyPatt            ;get the prev key patt from memory
        STR     R0, [R1]                   ;and update to the current key patt

        MOV     R0, #0                     ;setup looping through keypad rows
        MOV32   R1, GPIO_BASE_ADDR         ;get base addr for reading/writing
UpdateKeyPattLoop:
        ; output to demux
WriteToRow:
        AND     R2, R0, #0x01              ;get the 0th bit of the row number
        LSL     R2, R2, #DEMUX_PIN_A            ;and place it at demux pin A
        AND     R3, R0, #0x02              ;get the 1st bit of the row number
        LSL     R3, R3, #(DEMUX_PIN_B-1)            ;and place it at demux pin B
        ORR     R2, R3, R2                 ;combine the bit patterns
        STR     R2, [R1, #GPIO_DOUT31_0_OFF]    ;and output to the demux pins

ReadCol:     
        ; read input to rows
        LDR     R2, [R1, #GPIO_DIN31_0_OFF] ;read the column as active high

        MOV     R4, #0                          

        LSR     R3, R2, #KEYPAD_COL_0           ;move col bit to 0th bit
        MVN     R3, R3                          ;negate it
        AND     R3, R3, #0x01                   ;mask
        ORR     R4, R4, R3, LSL #0              ;and rotate back to right pos

        LSR     R3, R2, #KEYPAD_COL_1          
        MVN     R3, R3                          
        AND     R3, R3, #0x01                   
        ORR     R4, R4, R3, LSL #1              

        LSR     R3, R2, #KEYPAD_COL_2          
        MVN     R3, R3                         
        AND     R3, R3, #0x01                  
        ORR     R4, R4, R3, LSL #2              

        MOV     R0, R4                          ;return must be in R0

DoneUpdateKeyPatt:
        MOVA    R1, currKeyPatt            ;get the curr key patt from memory
        STR     R0, [R1]   
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                   Init                                     ;
;                                 EE110a HW2                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains all initialization functions to setup the hardware for 
; the CC26xR launchpad for the keypad demo. Power, clocks, GPIO, and the GPT0 
; timer are setup for 1 ms interrupts. 
;
; Public functions:
;   InitPower  - turns on power to the peripherals
;   InitClocks - turns on clocks for GPIO and Timer 0
;   InitGPT0   - sets up Timer0 to generate interrupts
;   InitGPIO   - configures the input pins and output pins for keypad read and
;                write
;
;
;
; Revision History:
;    11/17/25  Steven Lei       initial revision

 

;
; Description:       Turn on the power to the peripherals. 
;
; Operation:         Setup PRCM registers to turn on power to the peripherals.
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
; Registers Changed: flags, R0, R1
; Stack Depth:       0 words
;
; References:        CC26xR manual: Active mode: sec 7.6.2 (pg 519) 
;
; Revision History:  02/17/21   Glen George      initial revision
;                    10/30/25   Steven Lei       retrieved from Glen's website

InitPower:
        MOV32   R1, PRCM_BASE_ADDR              ;get base for power registers
        STREG   PD_PERIPH_EN, R1, PDCTL0_OFF    ;turn on peripheral power

WaitPowerOn:                                    ;wait for power on
        LDR     R0, [R1, #PDSTAT0_OFF]          ;get power status
        ANDS    R0, #PD_PERIPH_STAT             ;check if power is on
        BEQ     WaitPowerOn                     ;if not, keep checking
        ;BNE    DonePeriphPower                 ;otherwise done

DonePeriphPower:                                ;done turning on peripherals
        BX      LR


; InitClocks
;
; Description:       Turn on the clock to the peripherals. 
;
; Operation:         Setup PRCM registers to turn on clock to the peripherals.
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
; Registers Changed: flags, R0, R1
; Stack Depth:       0 words
;
; References:        CC26xR manual: Clock gating, sec 7.5.2.1, pg 516 - 517
;   
; Revision History:  02/17/21   Glen George      initial revision
;                    10/30/25   Steven Lei       retrieved from Glen's website

InitClocks:


        MOV32   R1, PRCM_BASE_ADDR              ;get base for power registers

        STREG   GPIOCLK_EN, R1, GPIOCLKGR_OFF   ;turn on GPIO clocks
        STREG   GPT0CLK_EN, R1, GPTCLKGR_OFF    ;turn on Timer 0 clocks
        STREG   GPTCLKDIV_1, R1, GPTCLKDIV_OFF  ;timers get system clock

        STREG   CLKLOADCTL_LD, R1, CLKLOADCTL_OFF  ;load clock settings

WaitClocksLoaded:                               ;wait for clocks to be loaded
        LDR     R0, [R1, #CLKLOADCTL_OFF]       ;get clock status
        ANDS    R0, #CLKLOADCTL_STAT            ;check if clocks are on
        BEQ     WaitClocksLoaded                ;if not, keep checking
        ;BNE    DoneClockSetup                  ;otherwise done


DoneClockSetup:                                 ;done setting up clock
        BX      LR


; InitGPT0
;
; Description:       This function initializes GPT0.  It sets up the timer to
;                    generate interrupts every KEYPAD_INT_MS milliseconds.
;
; Operation:         The appropriate values are written to the timer control
;                    registers such that the Timer0A is configured to 32 bit,
;                    periodic mode with interrupts enabled. 
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
; References:        CC26xR manual: Periodic timer modes, sec 15.4.1 pg 1347
;
; Revision History:  02/17/21   Glen George      initial revision
;                    11/17/25   Steven Lei       retrieved from Glen's website
;                    11/17/25   Steven Lei       update procedure to reflect
;                                                steps in manual guide
InitGPT0:

GPT0AConfig:            ;configure timer 0A as a down counter generating
                        ;   interrupts every KEYPAD_INT_MS milliseconds

        MOV32   R1, GPT0_BASE_ADDR              ;get GPT0 base address
        STREG   GPT_CTL_TADIS, R1, GPT_CTL_OFF  ;disable timer A before changes
        STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer

        STREG   GPT_IRQ_TATO, R1, GPT_IMR_OFF   ;enable timeout interrupt
        STREG   GPT_TxMR_PERIODIC, R1, GPT_TAMR_OFF ;set timer mode to periodic
                                                ;set timer for 1 ms interrupt
        STREG   (KEYPAD_INT_MS * CLK_PER_MS), R1, GPT_TAILR_OFF 
        STREG   GPT_TxPR_PRSCL_1, R1, GPT_TAPR_OFF ;set prescale to 1
        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A with changes


        BX      LR                              ;done so return

; InitGPIO
;
; Description:       Initialize the I/O pins for the keypad. The keypad
;                    rows are written as outputs and the keypad rows are read
;                    as inputs.
;
; References:        keypad-schematic.pdf
;                    
;                    
; Operation:         Setup pins 20, 19, and 18 as inputs to read keypad cols.
;                    Setup pins 4 and 20 as outputs to write keypad rows.
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
; Revision History:  02/17/21   Glen George      initial revision
;                    10/28/25   Steven Lei       retrieved from website
;                    11/17/25   Steven Lei       update pinout for HW2 (keypad)

InitGPIO:

        MOV32   R1, IOC_BASE_ADDR       ;get base addr for I/O control registers
        MOV32   R0, IOCFG_GEN_DIN       ;setup for general inputs
        STR     R0, [R1, #IOCFG20]      ;write config for keypad column pin 0 
        STR     R0, [R1, #IOCFG19]      ;                               pin 1
        STR     R0, [R1, #IOCFG18]      ;                               pin 2

                                        ;R1 still has base addr for I/O control registers
        MOV32   R0, IOCFG_GEN_DOUT_4MA  ;setup for general 4mA outputs
        STR     R0, [R1, #IOCFG4]       ;write config for keypad demux pin a
        STR     R0, [R1, #IOCFG21]      ;                              pin b  

        MOV32   R1, GPIO_BASE_ADDR      ;get base addr for GPIO pins
                                        ;and write enable for output pins
        STREG   ((1 << DEMUX_PIN_A) | (1 << DEMUX_PIN_B)), R1, GPIO_DOE31_0_OFF


        BX      LR                      ;done so return




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



; MoveVecTable
;
;
; Description:       This function moves the interrupt vector table from its
;                    current location to SRAM at the location VecTable.
;
; Operation:         The function reads the current location of the vector
;                    table from the Vector Table Offset Register and copies
;                    the words from that location to VecTable.  It then
;                    updates the Vector Table Offset Register with the new
;                    address of the vector table (VecTable).
;
; Arguments:         None.
; Return Values:     None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             VTOR.
; Output:            VTOR.
;
; Error Handling:    None.
;
; Registers Changed: flags, R0, R1, R2, R3
; Stack Depth:       1 word
;
; Algorithms:        None.
; Data Structures:   None.
;
; Revision History:  11/03/21   Glen George      initial revision
;                    11/25/25   Steven Lei       retrieved from website

MoveVecTable:

        PUSH    {R4}                    ;store necessary changed registers
        ;B      MoveVecTableInit        ;start doing the copy


MoveVecTableInit:                       ;setup to move the vector table
        MOV32   R1, SCS_BASE_ADDR       ;get base for CPU SCS registers
        LDR     R0, [R1, #VTOR_OFF]     ;get current vector table address

        MOVA    R2, VecTable            ;load address of new location
        MOV     R3, #VEC_TABLE_SIZE     ;get the number of words to copy
        ;B      MoveVecCopyLoop         ;now loop copying the table


MoveVecCopyLoop:                        ;loop copying the vector table
        LDR     R4, [R0], #BYTES_PER_WORD   ;get value from original table
        STR     R4, [R2], #BYTES_PER_WORD   ;copy it to new table

        SUBS    R3, #1                  ;update copy count

        BNE     MoveVecCopyLoop         ;if not done, keep copying
        ;B      MoveVecCopyDone         ;otherwise done copying


MoveVecCopyDone:                        ;done copying data, change VTOR
        MOVA    R2, VecTable            ;load address of new vector table
        STR     R2, [R1, #VTOR_OFF]     ;and store it in VTOR
        ;B      MoveVecTableDone        ;and all done


MoveVecTableDone:                       ;done moving the vector table
        POP     {R4}                    ;restore registers and return
        BX      LR



        .end

