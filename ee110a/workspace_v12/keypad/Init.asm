;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 Init.asm                                   ;
;                                 EE110a HW2                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains initalization functions for the CC26xR1 launchpad. It sets
; up the PRCM, clock, timer, and GPIO modules for use. 
;
; Public functions:
;   InitPower - turn on power to the peripherals
;   InitClock - turn on clocks to the GPIO and Timer0 peripherals.
;   InitGPIO  - configure and enable I/Os for selected pins 
;   InitGPT0  - setup timer 0 based on input configuration
;
; References: CC13x2, CC26x2 SimpleLink™ Wireless MCU Technical Reference Manual
;             https://www.ti.com/lit/ug/swcu185g/swcu185g.pdf?ts=1761608306803

; Revision History:
;    11/27/25  Steven Lei       initial revision
;    12/8/25   Steven Lei       convert InitGPIO to table driven code
;    12/12/25  Steven Lei	add InitGPT1 and support for Timer1 in InitClocks

; Local includes
    ; Utilities
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
	.include  "inc/Servo.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
         ; the interrupt vector table in SRAM
        .align  512
VecTable:       .space  VEC_TABLE_SIZE * BYTES_PER_WORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .text
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define public functions
    .def InitPower
    .def InitClocks
    .def InitGPIO
    .def InitGPT0
    .def InitGPT1
    .def MoveVecTable


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
; Description:       Turn on the clock to the GPIO and Timer0/1 perhipherals.
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
;                    12/12/25   Steven Lei       add Timer 1 clock for servo
InitClocks:


        MOV32   R1, PRCM_BASE_ADDR              ;get base for power registers

        STREG   GPIOCLK_EN, R1, GPIOCLKGR_OFF   ;turn on GPIO clocks
        STREG   GPT0CLK_EN, R1, GPTCLKGR_OFF    ;turn on Timer 0 clocks
        STREG	GPT1CLK_EN, R1, GPTCLKGR_OFF	;turn on Timer 1 clocks
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
                                                ;set timer to periodic countdown
        STREG   GPT_TxMR_PERIODIC | GPT_TxCDIR_DOWN, R1, GPT_TAMR_OFF 
                                                ;set timer for 1 ms interrupt
        STREG   (KEYPAD_INT_MS * CLK_PER_MS), R1, GPT_TAILR_OFF
        STREG   GPT_TxPR_PRSCL_1, R1, GPT_TAPR_OFF ;set prescale to 1
        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A with changes


        BX      LR                              ;done so return


; InitGPT1
;
; Description:       This function initializes GPT1. It sets up the timer to
;                    generate a PWM signal with SERV_PWM_PERIOD_MS width.
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
; References:        CC26xR manual: PWM mode sec 15.4.4
;
; Revision History:  12/12/25   Steven Lei       initial revision, Servo (HW5)

InitGPT1:

GPT1AConfig:            ;configure timer 1A as a down counter generating
                        ;PWM signal with SERVO_PWM_PERIOD_MS

        MOV32   R1, GPT1_BASE_ADDR              ;get GPT1 base address
        STREG   GPT_CTL_TADIS, R1, GPT_CTL_OFF  ;disable timer A before changes
        STREG   GPT_CFG_16x2, R1, GPT_CFG_OFF   ;setup as 2 - 16 bit timers
        ;STREG   0x02,         R1, GPT_TAMR_OFF  ;
        ;STREG   0x01,         R1, GPT_T
        ;STREG   R1, GPT_TCTL_OFF           ; not inverted PWM
        STREG   GPT_IRQ_NONE, R1, GPT_IMR_OFF   ;disable timeout interrupt

        STREG   0x0000180A, R1, GPT_TAMR_OFF    ;down counter starting high

   	    STREG   SERVO_PWM_INTERVAL, R1, GPT_TAILR_OFF ; set the period
        STREG   SERVO_PWM_PRESCALE, R1, GPT_TAPR_OFF  ;set prescale

        ;STREG	(SERVO_PWM_MIN_DIFF & 0xFFFF) , R1, GPT_TAMATCHR_OFF
        ;STREG	(SERVO_PWM_MIN_DIFF >> 16) , 	R1, GPT_TAPMR_OFF


        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A with changes

        BX      LR                              ;done so return


; InitGPIO
;
; Description:       Generic function to initialize I/O pins based on the arg
;                    IOTable. The table is expected to be formatted like so:
;                       .word   PIN_VALUE, IOCFG_CONFIG
;                    where PIN_VALUE is the pin to initialize with configuration
;                    IOCFG_CONFIG.
;                   
; Operation:         Starts at IOTableStart, loops through, and writes the pin 
;                    configuration to the corresponding IOC register (derived 
;                    from pin value). If the pin is selected as output, also 
;                    writes output enable for that pin. Stops at IOTableEnd.
;                           
; Arguments:         R0: IOTableStart - the start of the IOTable 
;                    R1: IOTableEnd   - the end of the IOTable
; Return Value:      None.
;
; Local Variables:   R0 (arg) - start of table / curr table entry
;                    R1 (arg) - end of the table
;                    R2       - IOCFG base address
;                    R3       - accumulator for bits to output enable
;                    R4       - the pin value from the table
;                    R5       - the corresponding IOCFG register from pin value
;                    R6       - the I/O configuration for this pin
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
; Registers Changed: flags, R0 - R6
; Stack Depth:       3 words max
;
; References:        CC26xR manual, sec 13.6 - "GPIO"
; 
; Revision History:  02/17/21   Glen George      initial revision
;                    10/28/25   Steven Lei       retrieved from website
;                    12/8/25    Steven Lei       convert to table driven code

InitGPIO:
        PUSH    {R4, R5, R6}              ;Save modified registers
        MOV32   R2, IOC_BASE_ADDR         ;get the IOC base address
        MOV     R3, #0                    ;clear to accumulate output enable bits
    
InitGPIOLoop:                           ;loop through to configure each pin
        LDR     R4, [R0], #BYTES_PER_WORD ;get the pin value from the table
        LSL     R5, R4, #PIN_TO_IOCFG_SHIFT ;get the IOCFG register from pin value
        LDR     R6, [R0], #BYTES_PER_WORD ;get the configuration to write
        STR     R6, [R2, R5]              ;write config to the matching IOCFG

        GETnBIT R6, IOCFG_OUTPUT_BIT      ;get the output bit (active low)
        EOR     R6, R6, #0x01             ;invert the bit (now active high)
        LSL     R6, R6, R4
        ORR     R3, R3, R6                ;enable the output for this pin
         
CheckEndGPIOTable:                    ;check if loop has hit end of table
        CMP     R1, R0                    ;end of table is at R1
        BNE     InitGPIOLoop              ;   not at end, so keep going
        ;BEQ    DoneInitGPIO              ;at end, so done

DoneInitGPIO:
        MOV32   R2, GPIO_BASE_ADDR          ;get base addr for GPIO pins
        STR     R3, [R2, #GPIO_DOE31_0_OFF] ;enable outputs to all output pins
        POP     {R4, R5, R6}                ;save touched registers
        BX      LR                          ;done so return 


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
