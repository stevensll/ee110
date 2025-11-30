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
; InitPower
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
; Description:       Initialize the I/O pins for the LEDs and push buttons.
;                    Note that the push buttons need to be pulled up since
;                    they are pulled low when pressed (from schematics).
;
; References:        Schematics for CC26XR1 Launch Pads
;                    https://www.ti.com/tool/LAUNCHXL-CC26X2R1
;                    
; Operation:         Setup GPIO pins 6 and 7 to be 4 mA outputs for the LEDs,
;                    pins 13 and 14 to be inputs with pullups for the push buttons.
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
; Revision History:  02/17/21   Glen George      initial revision
;                    10/28/25   Steven Lei       retrieved from website
;                    10/28/25   Steven Lei       add pinout for HW1 (LEDs)
;                    11/17/25   Steven Lei       update pinout for HW2 (keypad)

InitGPIO:

        MOV32   R1, IOC_BASE_ADDR       ;get base addr for I/O control registers
        MOV32   R0, IOCFG_GEN_DOUT_4MA  ;setup for general 4 mA outputs
        STR     R0, [R1, #IOCFG6]       ;write config for 
        STR     R0, [R1, #IOCFG7]       ;write config for green LED I/O

                                        ;R1 still has base addr for I/O control registers
        MOV32   R0, IOCFG_DIN_PULL_UP   ;input with pullup, since button down is low
        STR     R0, [R1, #IOCFG13]      ;write config for left push button I/O
        STR     R0, [R1, #IOCFG14]      ;write config for right push button I/O

                                        ;enable outputs for the GPIO pins
        MOV32   R1, GPIO_BASE_ADDR      ;get base addr for GPIO registers
        STREG   ((1 << RED_LED_IO_BIT) | (1 << GREEN_LED_IO_BIT)), R1, GPIO_DOE31_0_OFF
                                        ;       and write the enable

        BX      LR                      ;done so return
