## Servo Outline

### Code Structure


; ServoDemo.asm

; This file demonstrates the servo by allowing the user to rotate the servo
; position or release the servo and read the position using the keypad interface.
; Here is how to use the demo: 
;   Move mode: The servo can be rotated left or right by pressing 4 key or 6 key
;              on the keypad respectively
;   Release mode: The servo is released (no PWM signal) and can be freely rotated.
;              Press 4 or 6 key to read the servo angle, which is displayed in
;              the event queue - buffer.
; To change between modes, press the 5 key.
; For more information on how the servo handles angles (reading/writing), 
; see Servo.asm documentation.

; Revision history:
;   12/12/2025    Steven Lei    initial revision

; Local includes/refs
; General utilities:
;   GeneralMacros.inc
;   GeneralConstants.inc
;
; Servo interface:
;   Servo.inc
;   Servo.sam
;
; Keypad interface:
;   Keypad.inc
;   Keypad.asm
;
; EventQueue:
;   EventQueue.asm
;   EventQueue.inc

; Functions
; 
; KeypressHandler() 
;   This function should be called by timer interrupt every 1ms. It handles
;   keypresses by searching for a debounced key pattern and if a key was pressed,
;   enqueues the key value into the event queue

KeypressHandler:
  keypatt = UpdateKeyPatt
  IF keypatt != NO_KEYPATT {
    status, keypatt = DebounceKeyPatt(keypatt)
    IF (status) {
      EnqeueuEvent(KEYPRESS_EVENT | keypatt)
    }
  }
  reset interrupt
  return

; InstallKeypressHandler()
;   This function installs the keypress handler onto the interrupt table.


; Main
; 
; Description: The main loop for the servo demo code. First sets up the stack
;              and then initializes the power and clocks modudules for all
;              other peripherals. Then moves the vector table. The interrupt handlers are installed and 
;              the corresponding timers are initialized.
;             Then initializes hardware (keypad, servo) and the software data
;             structures (event queue)
;             Loops infinitely, checking for keypress events and then handling
;             them appropriately based on the demo state
;             Should never return

Main:
; initialize the stack
; InitPower
; InitClocks
; MoveVectable
; InstallKeyPressHandler
; InitGPT0
; InitGPT1

; InitEventQueue
; InitKeypad
; InitServo
; Allow interrupts
; 

ServoLoop:
  most recent event = GetMostRecentEvent(eventQueue)

  IF most recent event == keypress 4:
      angle delta = SERVO_ANGLE_DELTA
      angle  = ReadServo
      GOTO  HandleServoState
  
  IF most recent event == keypress 6:
      angle delta = -SERVO_ANGLE_DELTA
      GOTO  HandleServoState
  
  IF most recent event == keypress 5:
      GOTO  ToggleServoState
  
  GOTO  DoneMain

ToggleServoState:
  servo released = ServoReleased
  IF ServoReleased == FALSE:
    ReleaseServo()
  ELSE:
    angle = DEFAULT_SERVO_ANGLE
    SetServo(angle)
  ServoReleased = !servo released
  GOTO DoneServo

HandleServoState:
  IF ServoReleased == FALSE       ;move the servo
    angle = angle + angle delta
    SetServo(angle)
  
DoneServo:
  event = SERVO_EVENT | angle 
  enequeueEvent(event)

DoneServoLoop:
  GOTO ServoLoop; loop back to forever
  return  ; should never get here
First sets up the power and clock modules. Then 


### Code

### Servo.inc

SERVO_PWM_PIN = 7
SERVO_POT_PIN = 6

SERVO_MIN_PULSE_MS = 0.5
SERVO_MAX_PULSE_MS = 2
SERVO_PWM_PERIOD_MS = 20

SERVO_POS_MAX = 90
SERVO_MIN_POS = -90

SERVO_POT_MIN_V = 1
SERVO_POT_MAX_V = 0

#### Servo.asm
```

InitGPT1:

ServoIOTable:
  SERVO_PWM_PIN,   

InitServo:
  InitGPIO(ServoIOTable)
  SetServo(0)




SetServo:
    
; Args: R0 - the angle, which is a signed int between -90 and +90
; Returns: None
SetServo:

CheckAngleInvalid:         ;if angle is outside servo angle range, just do nothing
  IF angle > MAX_SERVO_ANGLE:
    GOTO  DoneSetServo
  
  IF angle < MIN_SERVO_ANGLE:
    GOTO  DoneSetServo

SetServoPulse:
    pulse width = RemapRange(angle, SERVO_MIN_PULSE, SERVO_MAX_PULSE)
    SetPulseWidth(pulse width)
    ServoAnglePtr = &ServoAngle
    *ServoAnglePtr = servo angle
    
DoneSetServo                  ;done so return
    return 

; Args: None
; Returns: None
ReleaseServo:
  SetPulseWidth(0)
  Return

GetServo:
  ServoAnglePtr = &ServoAngle
  *ServoAnglePtr = servo angle
  return servo angle


```

```
pg 1321
; get GPT.CFG addr
; clear TnEn
; 
```

15.4.4 
; base = GPT1_BASE_ADDR
; base[GPT_CTL] = GPT_CTL_TADIS    ; disable timerA before making changes
; base[GPT_CFG] = 0x0000 0004 ;2 - 16 bit timer
; base[GPT_TnMR][TnMR] = 0x02
; base[GPT_TnMR][TnCMR] = 0x1
; base[GPT_TnCMR] = 0x1
; base[GPT_CTL][TnPWML] = not inverted
; optional base[GPT_TnPR] = 1 ; no prescale
; optional base[GPT_TnMR][TnPWMIE] = 1 for interrupt
; base[GPT_TnILR] = timer start
; base[GPT_TnMATCHR] = timer match
; base[GPT_CTL] = GPT_CT_TxEN   ; enable timer to make changes
; PWM period can be adjust by writing TnILR


;