

; Utilities
    .include  "inc/GeneralMacros.inc"
    .include  "inc/GeneralConstants.inc"
; CC26x2 hardware
    .include  "inc/CPUreg.inc"
    .include  "inc/GPIOreg.inc"
    .include  "inc/IOCreg.inc"
    .include  "inc/GPTreg.inc"
    .include  "inc/EVENTreg.inc"

; Servo constants
    .include  "inc/Servo.inc"
	.include  "inc/EVENTreg.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .align 4
ServoAngle      .space          BYTES_PER_WORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .text
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Export public functions
    .def InitServo
    .def GetServo
    .def SetServo
    .def ReleaseServo
    .def Dummy

    ; Import public functions
    .ref InitGPIO

	.align 4

ServoIOTable:
    ;           Pin                 Config
    .word       SERVO_PWM_PIN,      IOCFG_GEN_DOUT_4MA | IOCFG_PORT_EVENT2
    .word       SERVO_POT_PIN,      IOCFG_GEN_DIN
EndServoIOTable:


InitServo:
		MOVW	R2, #0xFFFE
		MOVT	R2, #0xFFFF
        MOVA    R0, ServoIOTable            ;get the table start
        MOVA    R1, EndServoIOTable         ;            and end
        AND 	R0, R0, R2
        AND		R1, R1, R2
        PUSH    {LR}                        ;save caller return address
        B       InitGPIO                    ;initialize the servo pins
        POP     {LR}                        ;restore caller return address

		MOV32	R1, EVENT_BASE_ADDR			;
		STREG	GPT1A_CAPT_SEL, R1, EVENT_GPT1A_OFFSET ; select output for timer



        MOVA    R1, ServoAngle              ;get the servo angle from meomory
        MOV     R0, #0
        STR     R0, [R1]                    ;and reset the angle to 0

        BX      LR                          ;done so return


GetServo:
        MOVA    R1, ServoAngle              ;get the servo angle from memory
        LDR     R0, [R1]                    ;and return it
        BX      LR

SetServo:

CheckPosValid:

        CMP     R0, #SERVO_MAX_POS          ;check if pos > max pos
        BGT     DoneSetServo                ;pos > max, so do nothing and return

SetServoPulse:
        MOVA    R1, ServoAngle              ;get the servo angle from memory
        STR     R0, [R1]                    ;update to the new angle

DoneSetServo:
        BX      LR                          ;done so return


ReleaseServo:
        BX      LR

Dummy:
        BX      LR
