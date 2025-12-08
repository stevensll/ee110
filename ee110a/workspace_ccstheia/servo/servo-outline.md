## Servo Outline

### Code Structure

() = New files to write
[] = Files to modify/reuse
* (ServoDemo.asm)
  * Description:
  * 
  * Includes
    * (ServoDemo.inc)
    * [Init.asm]
* (Servo.asm)
  * Description
    * Allows the servo to be initialized and read/write. 
  * Includes
    * Servo.inc
    * GeneralConstants.inc
    * GeneralMacros.inc
    * CPUreg.inc
    * GPIOreg.inc
  * Functions to write
    * InitServo
    * SetServo
    * ReleaseServo
    * GetServo

### Code

#### Servo.asm
```
InitServo:
    

; Args: R0 - the angle, which is a signed int between -90 and +90
; Returns: R0 - TRUE if successfully moved the servo, FALSE if angle is not within range

SetServo(signed int32_t angle):
    compare angle, MIN_SERVO_ANGLE
    return FALSE if angle <= MIN_SERVO_ANGLE

    compare MAX_SERVO_ANGLE, angle
    return FALSE if MAX_SERVO_ANGLE <= angle

    int32_t pulse_width_register 
    call GetPWFromAngle(angle) 
    GPIO.write(pulse_width, SERVO_PIN);

    return TRUE in R0

; Args: None
; Returns: None
ReleaseServo():
    GPIO.write(NO_PULSE, SERVO_PIN);

; Args: None
; Returns: R0 - the angle of the servo
    int32_t pulse_width_register;
    GPIO.read(pulse_width, SERVO_PIN);
    

```

```
pg 1321
; get GPT.CFG addr
; clear TnEn
; 
```