
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 KeypadDemo.inc                             ;
;                                 EE110a HW2                                 ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains constants for the KeypadDemo (HW2). It includes constants
; to set up the stack, interrupt handler, and event queue

; system constants
HANDLER_STACK_SIZE .equ    128          ;interrupt handler stack size
PROCESS_STACK_SIZE .equ    256          ;main loop stack size
TOTAL_STACK_SIZE   .equ    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE

VEC_TABLE_SIZE     .equ    54           ;number of interrupts in table
GPT0A_EX_NUM       .equ    31           ;exception number for GPT0 Timer A
GPT0A_IRQ_NUM      .equ    GPT0A_EX_NUM - 16 ;interrupt number for GPT0 Timer A

; Interrupt check pin
INT_TEST_PIN       .equ    5

; Event queue constants
QUEUE_SIZE         .equ    12           ;number of queue entries

