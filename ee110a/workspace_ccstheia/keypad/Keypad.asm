





 .include  "GeneralConstants.inc"
 .include  "Keypad.inc"

; Assume input is at R0
; Counter is at R1
; Compare register is R2
KeyPattToNumber:

    MOV     R1, #0                  ;Setup counter

IncrementCounter:
    
    ADD     R1, R1, #1              ;increment

CheckIfZero:

    LSR     R2, R0, R1              ;Move the ith bit to the 0th bit
    AND     R2, R2, #1                  ;   mask it to get the ith bit
    CMP     R2, #0              
    BNE     IncrementCounter    
    ;BE     DoneKeyPattToNumber     

DoneKeyPattToNumber:
    
    BX      LR                      ; done so return
    


