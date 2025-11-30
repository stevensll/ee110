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

 
 .include  "GeneralConstants.inc"
 .include  "GeneralMacros.inc"

 .include  "CPUreg.inc"
 .include  "GPIOreg.inc"
 .include  "IOCreg.inc"
 .include  "GPTreg.inc"
 .include  "Keypad.inc"
 .include  "KeypadDemo.inc"

         ; the interrupt vector table in SRAM

        .align  512
VecTable:       .space  VEC_TABLE_SIZE * BYTES_PER_WORD

; InitPower
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
        .def InitPower
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
        .def InitClocks
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

        .def InitGPIO
InitGPIO:

        MOV32   R1, IOC_BASE_ADDR       ;get base addr for I/O control registers
        MOV32   R0, IOCFG_GEN_DIN       ;setup for general inputs
        STR     R0, [R1, #IOCFG20]      ;write config for keypad column pin 0 
        STR     R0, [R1, #IOCFG19]      ;                               pin 1
        STR     R0, [R1, #IOCFG18]      ;                               pin 2

                                        ;R1 still has base addr for IOC reg
        MOV32   R0, IOCFG_GEN_DOUT_4MA  ;setup for general 4mA outputs
        STR     R0, [R1, #IOCFG4]       ;write config for keypad demux pin a
        STR     R0, [R1, #IOCFG21]      ;                              pin b  

        MOV32   R1, GPIO_BASE_ADDR      ;get base addr for GPIO pins
                                        ;and write enable for output pins
        STREG   ((1 << DEMUX_PIN_A) | (1 << DEMUX_PIN_B)), R1, GPIO_DOE31_0_OFF


        BX      LR                      ;done so return

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

        .def InitGPT0
InitGPT0:

GPT0AConfig:            ;configure timer 0A as a down counter generating
                        ;   interrupts every KEYPAD_INT_MS milliseconds

        ; MOV32   R1, GPT0_BASE_ADDR              ;get GPT0 base address
        ; STREG   GPT_CTL_TADIS, R1, GPT_CTL_OFF  ;disable timer A before changes
        ; STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer

        ; STREG   GPT_IRQ_TATO, R1, GPT_IMR_OFF   ;enable timeout interrupt
        ; STREG   GPT_TxMR_PERIODIC | GPT_TxCDIR_DOWN, R1, GPT_TAMR_OFF ;set timer mode to periodic
        ;                                         ;set timer for 1 ms interrupt
        ; STREG   (KEYPAD_INT_MS*CLK_PER_MS-1), R1, GPT_TAILR_OFF 
        ; STREG   0x00, R1, GPT_TAPR_OFF ;set prescale to 1
        ; STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A with changes

        MOV32   R1, GPT0_BASE_ADDR              ;get GPT0 base address
        STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer
        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A
        STREG   GPT_IRQ_TATO, R1, GPT_IMR_OFF   ;enable timer A timeout ints
        STREG   GPT_TxMR_PERIODIC, R1, GPT_TAMR_OFF    ;set timer A mode
                                                ;set 32-bit timer count
        STREG   (1 * CLK_PER_MS), R1, GPT_TAILR_OFF

        BX      LR                              ;done so return



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
       
        .def MoveVecTable

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
