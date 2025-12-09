
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               KeypadDemo.asm                               ;
;                                 EE110a HW2                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file demonstrates the keypad for HW2 by handling keypresses and adding
; them to the event queue. The event queue is implemented as a buffer in memory,
; so the keypresses values are displayed in value. The keypresses 
;
; Public functions:
;   InitPower - turn on power to the peripherals
;   InitClock - turn on clocks to the peripherals
;   InitGPIO  - enable output and inputs for configured pins 
;   InitGPT0  - setup timer 0 based on input configuration
;
; Revision History:
;    11/30/25  Steven Lei       initial revision

; Local include
    ; General utilities
    .include  "inc/GeneralMacros.inc"
    .include  "inc/GeneralConstants.inc"
    ; CC26x2 hardware
    .include  "inc/CPUreg.inc"
    .include  "inc/GPIOreg.inc"
    .include  "inc/IOCreg.inc"
    .include  "inc/GPTreg.inc"
    ; Keypad and event queue
    .include  "inc/Keypad.inc"
    .include  "inc/EventQueue.inc"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
        .data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ; the stack (must be double-word aligned)
        .align  8
TopOfStack:     .bes    TOTAL_STACK_SIZE

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
        .text
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        ;Import public functions from other files
        .ref InitPower
        .ref InitClocks
        .ref InitGPT0
        .ref InitEventQueue
        .ref EnqueueEvent
        .ref InitKeypad
        .ref DebounceKeyPatt
        .ref UpdateKeyPatt
        .ref MoveVecTable

        .global ResetISR
ResetISR:

Main:
        MOVA    R0, TopOfStack          ;initialize the stack pointers
        MSR     MSP, R0
        SUB     R0, R0, #HANDLER_STACK_SIZE
        MSR     PSP, R0


        BL      InitPower               ;turn on power to everything
        BL      InitClocks              ;turn on clocks to everything
        BL      MoveVecTable            ;move the vector table to RAM

        BL      InstallGPT0Handler      ;install the event handler
        BL      InitGPT0                ;initialize the internal timer
                                        
        BL      InitEventQueue          ;initialize the event queue (buffer)
        BL      InitKeypad              ;initalize the keypad (variables, IO)

        MOV32   R1, SCS_BASE_ADDR       ;and finally allow interrupts.
        STREG   (1 << GPT0A_IRQ_NUM), R1, NVIC_ISER0

Forever:
        MOV32     R9, NO_KEYPATT

DoneMain:
        B      Forever


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
; Registers Changed: R0 - R3
; Stack Depth:       4 words max
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

KeypressHandler:
        PUSH    {LR}                    ;save LR since have function calls
        BL      UpdateKeyPatt           ;update the key pattern (returned in R0)
        CMP     R0, #NO_KEYPATT         ;check if there is some key press
        BEQ     DoneKeypressHandler     ;   dont have any key press, so done

DebounceKeypresses:                 ; have                          
        BL      DebounceKeyPatt         ;have some key press, so debounce
        CMP     R0, #TRUE               ;check if done debouncing
        BNE     ResetInt                ;   not done debouncing, so do nothing

AddKeyEvent:                        ;done debouncing, so create keypresse event
        MOV     R0, R1                  ; key value was returned in R1
        ORR     R0, R0, #KEYPRESS_EVENT ; add the event ID to make the key event
        BL      EnqueueEvent            ; add the event to queue, arg is R0

ResetInt:                               ;reset interrupt bit for GPT0A
        MOV32   R1, GPT0_BASE_ADDR      ;get base address
        STREG   GPT_IRQ_TATO, R1, GPT_ICLR_OFF ;clear timer A timeout interrupt
		NOP
		NOP

DoneKeypressHandler:
        POP     {LR}                    ;restore LR
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
        .end
