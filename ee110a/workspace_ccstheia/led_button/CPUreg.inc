;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  CPUreg.inc                                ;
;                            CPU Register Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the CPU control registers for the TI
; CC2652 microcontroller.
;
; References: CC13x2, CC26x2 SimpleLink™ Wireless MCU Technical Reference Manual
;             https://www.ti.com/lit/ug/swcu185g/swcu185g.pdf?ts=1761608306803
;   
; Revision History:
;     2/17/22  Glen George      initial revision
;    11/05/23  Glen George      updated style and comments
;    10/30/25  Steven Lei       add references to manual
;    11/15/25  Steven Lei       update manual reference page numbers

; base addresses
;   table 3.1, pg 310
PRCM_BASE_ADDR     .equ    0x40082000   ;power/reset/clock module registers
SCS_BASE_ADDR      .equ    0xE000E000   ;core system control space registers



; register offsets

; SCS - system control space registers

NVIC_ISER0         .equ    0x0100       ;interrupt set enable (irq 0-31)
NVIC_ISER1         .equ    0x0104       ;interrupt set enable (irq 32-63)
VTOR_OFF           .equ    0x0D08       ;vector table offset register
CCR_OFF            .equ    0x0D14       ;configuration control register


; PRCM - power/reset/clock module registers
;   table 7.27, pg 544

PDCTL0_OFF         .equ    0x012C       ;power domain control register 0
PDCTL1_OFF         .equ    0x017C       ;power domain control register 1
PDSTAT0_OFF        .equ    0x0140       ;power domain status register 0
PDSTAT1_OFF        .equ    0x0194       ;power domain status register 1

CLKLOADCTL_OFF     .equ    0x0028       ;load PRCM settings to CLKCTRL domain
GPIOCLKGR_OFF      .equ    0x0048       ;GPIO clock gate settings
GPTCLKGR_OFF       .equ    0x0054       ;GPT clock gate settings
GPTCLKDIV_OFF      .equ    0x00CC       ;GPT clock divisor register



; register bit and value definitions

; CCR - configuration control register

STACK_ALIGN_4      .equ    0x00000000   ;keep stack on 4 byte alignment
STACK_ALIGN_8      .equ    0x00000100   ;keep stack on 8 byte alignment


; PDCTL0 - power domain control register 0
;   sec 7.8.2.46, pg 595
;
PD_PERIPH_EN       .equ    0x00000004   ;enable power to peripheral domain
PD_SERIAL_EN       .equ    0x00000002   ;enable power to serial domain
PD_RFC_EN          .equ    0x00000001   ;enable power to RF core domain


; PDSTAT0 - power domain status register 0
;   sec 7.8.2.50, pg 599

PD_PERIPH_STAT     .equ    0x00000004   ;status of peripheral power domain
PD_SERIAL_STAT     .equ    0x00000002   ;status of serial power domain
PD_RFC_STAT        .equ    0x00000001   ;status of RF core power domain


; CLKLOADCTL - load PRCM settings to CLKCTRL domain
;   sec 7.8.2.5, pg 552
CLKLOADCTL_LD      .equ    0x00000001   ;load CLKCTL power domain
CLKLOADCTL_STAT    .equ    0x00000002   ;status of CLKCLK power domain load


; GPIOCLKGR - GPIO clock gate settings
;   sec 7.8.2.11, pg 560
GPIOCLK_EN         .equ    0x00000001   ;enable GPIO clock in run mode
GPIOCLK_ON         .equ    0x00000100   ;force GPIO clock on in all modes


; GPTCLKGR - GPT clock gate settings
;   sec 7.8.2.14, pg 563
GPTCLK_EN          .equ    0x0000000F   ;enable all GPT clocks in run mode
GPT0CLK_EN         .equ    0x00000001   ;enable GPT0 clock in run mode
GPT1CLK_EN         .equ    0x00000002   ;enable GPT1 clock in run mode
GPT2CLK_EN         .equ    0x00000004   ;enable GPT2 clock in run mode
GPT3CLK_EN         .equ    0x00000008   ;enable GPT3 clock in run mode
GPTCLK_ON          .equ    0x00000F00   ;force all GPT clocks on in all modes
GPT0CLK_ON         .equ    0x00000100   ;force GPT0 clock on in all modes
GPT1CLK_ON         .equ    0x00000200   ;force GPT1 clock on in all modes
GPT2CLK_ON         .equ    0x00000400   ;force GPT2 clock on in all modes
GPT3CLK_ON         .equ    0x00000800   ;force GPT3 clock on in all modes


; GPTCLKDIV - GPT clock divisor register
;   sec 7.8.2.34, pg 583
GPTCLKDIV_1        .equ    0x00000000   ;divide GPT incoming clock by 1
GPTCLKDIV_2        .equ    0x00000001   ;divide GPT incoming clock by 2
GPTCLKDIV_4        .equ    0x00000002   ;divide GPT incoming clock by 4
GPTCLKDIV_8        .equ    0x00000003   ;divide GPT incoming clock by 8
GPTCLKDIV_16       .equ    0x00000004   ;divide GPT incoming clock by 16
GPTCLKDIV_32       .equ    0x00000005   ;divide GPT incoming clock by 32
GPTCLKDIV_64       .equ    0x00000006   ;divide GPT incoming clock by 64
GPTCLKDIV_128      .equ    0x00000007   ;divide GPT incoming clock by 128
GPTCLKDIV_256      .equ    0x00000008   ;divide GPT incoming clock by 256
