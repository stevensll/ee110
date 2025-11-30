;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 LEDButton                                  ;
;                                 EE110a HW1                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program toggles the CC26xR Launch Pad LEDs based on 
;                   the button that is pressed. When BTN1 (left) is pressed,
;                   the RED LED is on, and when it is released, the RED LED is off.
;                   Respectively applied for BTN2 (right) and GREEN LED.
;
; Operation:        The program sets up the hardware by initializing power, timers,
;                   and GPIO. The push buttons are read as inputs via GPIO pins 13/14,
;                   while the LEDs are written to as outputs via GPIO pins 6/7. 
;                   Note that the push buttons are pulled low when pressed, so
;                   they are hooked up to pull up resistors via the MCU.
;                   This program does NOT setup a stack, since it is not needed 
;                   (no nested code).
;
; References:       CC26xR launchpad pin mapping and schematic:
;                   https://www.ti.com/tool/LAUNCHXL-CC26X2R1#tech-docs
;                 
; Input:            BTN1 and BTN2 push buttons on the CC2xR Launchpad.
; Output:           The RED and GREEN LEDs on the CC26xR launch pad are toggled.
;
; User Interface:   Two buttons (BTN1 and BTN2) can be pressed on the CC26xR 
;                   launch pad.
;
; Error Handling:   None.
;
;
; Revision History:
;    10/27/25  Steven Lei       initial revision
;    10/30/25  Steven Lei       final revision, HW1



; local include

; utilities
 .include  "GeneralMacros.inc"
 .include  "GeneralConstants.inc"

; CC26x2 hardware
 .include  "CPUreg.inc"
 .include  "GPIOreg.inc"
 .include  "IOCreg.inc"

; This program specific
 .include  "LEDButton.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data

; Stack goes here normally, but not needed since no nested subroutines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .text

        .global resetISR
        
resetISR:

Init:                                   ; setup CC26x2 hardware 

        BL      InitPower               ;turn on power to everything
        BL      InitClocks              ;turn on clocks to everything
        BL      InitGPIO                ;setup the I/O (only output)
                                        ;initialize the variables

        MOV32   R2, GPIO_BASE_ADDR      ;use R2 to access GPIO registers
        STREG   ((1 << RED_LED_IO_BIT) |(1 << GREEN_LED_IO_BIT)), R2, GPIO_DCLR31_0_OFF
                                        ;       and turn both LEDs off   

HandleButtonPresses:                    ; Toggle LEDs when button pressed/released

        MOV32   R1, GPIO_BASE_ADDR              ;read button input from GPIO base address
        LDR     R0, [R1, #GPIO_DIN31_0_OFF]     ;       + offset

        ; Can just shift button bits down to where LED bits are, since both are 32 bit aligned 
        LSR     R0, R0, #(LEFT_BTN_IO_BIT - RED_LED_IO_BIT)     
        EOR     R0, R0, #ALL_ONES               ;LED bit on when button bit is low (pull up), 
                                                ;       and vice versa, so negate button bits           
        STR     R0, [R1, #GPIO_DOUT31_0_OFF]    ;write to LEDs via GPIO output
        
DoneHandleButtonPresses:                        ;done checking button presses
        B       HandleButtonPresses             ;       so do it again, loop forever

        BX      LR                              ;should never get here. if so, just ret


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
; Revision History:  02/17/21   Glen George      initial revision

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
; Revision History:  02/17/21   Glen George      initial revision
;                    10/28/25   Steven Lei       remove GPT0CLK, not used

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
;                    10/28/25   Steven Lei       fork from EHDemo.s, add push buttons

InitGPIO:

        MOV32   R1, IOC_BASE_ADDR       ;get base addr for I/O control registers
        MOV32   R0, IOCFG_GEN_DOUT_4MA  ;setup for general 4 mA outputs
        STR     R0, [R1, #IOCFG6]       ;write config for red LED I/O
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
