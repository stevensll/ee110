;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  Servo.inc                                 ;
;                                 EE110a HW5                                 ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 

; References:
;   
;

; Servo hardware
SERVO_PWM_PIN               .equ    7      
SERVO_POT_PIN               .equ    6

; Servo timing - according to data sheet
SERVO_PWM_PERIOD_MS         .equ    20          ;Servo operates @ 50 Hz
SERVO_MIN_PULSE_MS          .equ    0.5         ;min pulse width
SERVO_MAX_PULSE_MS          .equ    2           ;max pulse width

; 48 000 0000 / 50 = 960 000
SERVO_PULSE_PERIOD .equ  960000 ; clocks
SERVO_PWM_INTERVAL .equ        (SERVO_PULSE_PERIOD & 0xFFFF)        ; interval
SERVO_PWM_PRESCALE .equ         (SERVO_PULSE_PERIOD >> 16)           ; prescale
SERVO_PWM_MIN      .equ     24000
SERVO_PWM_MAX      .equ     120000
SERVO_PWM_MIN_DIFF .equ     960000 - 24000


; Servo software
SERVO_MIN_POS               .equ   -90          ;in degrees
SERVO_MAX_POS               .equ    90          ;in degrees

SERVO_POT_MIN_V             .equ    1
SERVO_POT_MAX_V             .equ    0
