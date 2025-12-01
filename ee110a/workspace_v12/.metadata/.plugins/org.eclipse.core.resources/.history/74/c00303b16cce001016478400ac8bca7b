

; system constants

HANDLER_STACK_SIZE .equ    128          ;interrupt handler stack size
PROCESS_STACK_SIZE .equ    256          ;main loop stack size
TOTAL_STACK_SIZE   .equ    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE

VEC_TABLE_SIZE     .equ    54           ;number of interrupts in table

QUEUE_SIZE         .equ    10           ;number of queue entries
GPT0A_EX_NUM       .equ    31           ;exception number for GPT0 Timer A
GPT0A_IRQ_NUM      .equ    GPT0A_EX_NUM - 16 ;interrupt number for GPT0 Timer A

; Interrupt check pin

INT_TEST_PIN       .equ    5

; I/O constants

REDLED_IO_BIT      .equ    6            ;red LED on bit 6
GREENLED_IO_BIT    .equ    7            ;green LED on bit 7

GPT0A_EX_NUM       .equ    31           ;exception number for GPT0 Timer A
GPT0A_IRQ_NUM      .equ    GPT0A_EX_NUM - 16       ;interrupt number for GPT0 Timer A

; timing constants

MS_PER_BLINK       .equ    1000         ;milliseconds for each blink
LOOPS_PER_BLINK    .equ    100000       ;number of loops for blinking LED
CLK_PER_MS         .equ    48000        ;timer clocks per millisecond
