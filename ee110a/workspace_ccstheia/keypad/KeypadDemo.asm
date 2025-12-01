

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
 .include  "inc/KeypadDemo.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data
        .ref prevKeyPatt
	.ref currKeyPatt

        ; the stack (must be double-word aligned)

        .align  8
TopOfStack:     .bes    TOTAL_STACK_SIZE

         ; the interrupt vector table in SRAM

        .data
        .align  512
VecTable:       .space  VEC_TABLE_SIZE * BYTES_PER_WORD

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        .text

        .global ResetISR
        .ref InitKeypad
        .ref DebounceKeyPatt
        .ref InitPower
        .ref InitClocks
        .ref InitGPT0
        .ref InitGPIO
        .ref InitEventQueue
		.ref UpdateKeyPatt
ResetISR:

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
        PUSH    {LR} ;save touched registers


        BL      UpdateKeyPatt           ;update the key pattern
        MOVA    R1, currKeyPatt	        ;get key pattern from memory
        LDR	R0, [R1]
        CMP     R0, #NO_KEYPATT         ;check if there is some key press
        BEQ     DoneKeypressHandler     ;   dont have any key press, so done
        BL      DebounceKeyPatt         ;have some key press, so debounce
        MOV32   R1, GPIO_BASE_ADDR
        STREG   (1 << INT_TEST_PIN), R1, GPIO_DTGL31_0_OFF
ResetInt:                               ;reset interrupt bit for GPT0A
        MOV32   R1, GPT0_BASE_ADDR      ;get base address
        STREG   GPT_IRQ_TATO, R1, GPT_ICLR_OFF ;clear timer A timeout interrupt
		NOP
		NOP

DoneKeypressHandler:
        POP     {LR} ;restore registers
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
