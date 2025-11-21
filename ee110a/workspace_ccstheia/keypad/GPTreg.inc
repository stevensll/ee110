;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  GPTreg.inc                                ;
;                            GPT Register Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the general purpose timer (GPT)
; control registers for the TI CC2652 microcontroller.
;
; References: CC13x2, CC26x2 SimpleLink™ Wireless MCU Technical Reference Manual
;             https://www.ti.com/lit/ug/swcu185g/swcu185g.pdf?ts=1761608306803
;
; Revision History:
;     2/16/22  Glen George      initial revision
;    11/05/23  Glen George      updated style and comments
;    11/05/23  Glen George      added more register constants
;    11/15/25  Steven Lei       add references to manual
;    11/17/25  Steven Lei       add constant definitions for TxMR, TxPR


; base addresses
;   table 3.1, pg 310
GPT0_BASE_ADDR     .equ    0x40010000   ;general purpose timer 0
GPT1_BASE_ADDR     .equ    0x40011000   ;general purpose timer 1
GPT2_BASE_ADDR     .equ    0x40012000   ;general purpose timer 2
GPT3_BASE_ADDR     .equ    0x40013000   ;general purpose timer 3



; register offsets (applies to all timers)
;   table 15-7, pg 1350
GPT_CFG_OFF        .equ    0x0000       ;configuration register
GPT_TAMR_OFF       .equ    0x0004       ;timer A mode register
GPT_TBMR_OFF       .equ    0x0008       ;timer B mode register
GPT_CTL_OFF        .equ    0x000C       ;control register
GPT_SYNC_OFF       .equ    0x0010       ;timer synchronization register
GPT_IMR_OFF        .equ    0x0018       ;interrupt mask register
GPT_RIS_OFF        .equ    0x001C       ;raw interrupt status register
GPT_MIS_OFF        .equ    0x0020       ;masked interrupt status register
GPT_ICLR_OFF       .equ    0x0024       ;interrupt clear register
GPT_TAILR_OFF      .equ    0x0028       ;timer A interval load register
GPT_TBILR_OFF      .equ    0x002C       ;timer B interval load register
GPT_TAMATCHR_OFF   .equ    0x0030       ;timer A match register
GPT_TBMATCHR_OFF   .equ    0x0034       ;timer B match register
GPT_TAPR_OFF       .equ    0x0038       ;timer A pre-scale register
GPT_TBPR_OFF       .equ    0x003C       ;timer B pre-scale register
GPT_TAPMR_OFF      .equ    0x0040       ;timer A pre-scale match register
GPT_TBPMR_OFF      .equ    0x0044       ;timer B pre-scale match register
GPT_TAR_OFF        .equ    0x0048       ;timer A register
GPT_TBR_OFF        .equ    0x004C       ;timer B register
GPT_TAV_OFF        .equ    0x0050       ;timer A value
GPT_TBV_OFF        .equ    0x0054       ;timer B value
GPT_TAPS_OFF       .equ    0x005C       ;timer A pre-scale snap-shot register
GPT_TBPS_OFF       .equ    0x0060       ;timer B pre-scale snap-shot register
GPT_TAPV_OFF       .equ    0x0064       ;timer A pre-scale value
GPT_TBPV_OFF       .equ    0x0068       ;timer B pre-scale value
GPT_DMAEV_OFF      .equ    0x006C       ;DMA event register
GPT_VERSION_OFF    .equ    0x0FB0       ;peripheral version register
GPT_ANDCCP_OFF     .equ    0x0FB4       ;combined CCP output register



; register bit and value definitions

; CFG - configuration register
;   sec 15.5.1.1, pg 1352
GPT_CFG_32x1       .equ    0x00000000   ;configure as a single 32-bit timer
GPT_CFG_16x2       .equ    0x00000004   ;configure as two 16-bit timers


; TxMR - timer A/B mode register
;   sec 15.5.1.2. pg 1353
GPT_TxMR_PERIODIC  .equ    0x00000002   ;Periodic timer mode

; TxPR - timer A/B prescale register
;   sec 15.5.1.14, pg 1370
GPT_TxPR_PRSCL_1    .equ   0x00000000   ;Prescale = 1

; CTL - control register
;   sec 15.5.1.4, pg 1357  
GPT_CTL_TBPWM_INV  .equ    0x00008000   ;invert timer B PWM output
GPT_CTL_TBEV_POS   .equ    0x00000000   ;timer B event on positive edge
GPT_CTL_TBEV_NEG   .equ    0x00000400   ;timer B event on negative edge
GPT_CTL_TBEV_BOTH  .equ    0x00000C00   ;timer B event on both edges
GPT_CTL_TBSTALL    .equ    0x00000200   ;stop timer B during debug halt
GPT_CTL_TBEN       .equ    0x00000100   ;enable timer B
GPT_CTL_TBDIS      .equ    0x00000000   ;disable timer B
GPT_CTL_TAPWM_INV  .equ    0x00000080   ;invert timer A PWM output
GPT_CTL_TAEV_POS   .equ    0x00000000   ;timer A event on positive edge
GPT_CTL_TAEV_NEG   .equ    0x00000004   ;timer A event on negative edge
GPT_CTL_TAEV_BOTH  .equ    0x0000000C   ;timer A event on both edges
GPT_CTL_TASTALL    .equ    0x00000002   ;stop timer A during debug halt
GPT_CTL_TAEN       .equ    0x00000001   ;enable timer A
GPT_CTL_TADIS      .equ    0x00000000   ;disable timer A


; SYNC - timer synchronization register
;   sec 15.5.1.5, pg 1359
GPT_SYNC_GPT3_NONE .equ    0x00000000   ;no GPT3 synchronization
GPT_SYNC_GPT3_A    .equ    0x00000040   ;synchronize GPT3A
GPT_SYNC_GPT3_B    .equ    0x00000080   ;synchronize GPT3B
GPT_SYNC_GPT3_AB   .equ    0x000000C0   ;synchronize GPT3A and GPT3B
GPT_SYNC_GPT2_NONE .equ    0x00000000   ;no GPT2 synchronization
GPT_SYNC_GPT2_A    .equ    0x00000010   ;synchronize GPT2A
GPT_SYNC_GPT2_B    .equ    0x00000020   ;synchronize GPT2B
GPT_SYNC_GPT2_AB   .equ    0x00000030   ;synchronize GPT2A and GPT2B
GPT_SYNC_GPT1_NONE .equ    0x00000000   ;no GPT1 synchronization
GPT_SYNC_GPT1_A    .equ    0x00000004   ;synchronize GPT1A
GPT_SYNC_GPT1_B    .equ    0x00000008   ;synchronize GPT1B
GPT_SYNC_GPT1_AB   .equ    0x0000000C   ;synchronize GPT1A and GPT1B
GPT_SYNC_GPT0_NONE .equ    0x00000000   ;no GPT0 synchronization
GPT_SYNC_GPT0_A    .equ    0x00000001   ;synchronize GPT0A
GPT_SYNC_GPT0_B    .equ    0x00000002   ;synchronize GPT0B
GPT_SYNC_GPT0_AB   .equ    0x00000003   ;synchronize GPT0A and GPT0B


; IMR - interrupt mask register
; RIS - raw interrupt status register
; MIS - masked interrupt status register
; ICLR - interrupt clear register
;   sec 15.5.1.6, pg 1360 
GPT_IRQ_DMAB       .equ    0x00002000   ;timer B DMA interrupt
GPT_IRQ_TBM        .equ    0x00000800   ;timer B match interrupt
GPT_IRQ_CBE        .equ    0x00000400   ;timer B capture event interrupt
GPT_IRQ_CBM        .equ    0x00000200   ;timer B capture mode match interrupt
GPT_IRQ_TBTO       .equ    0x00000100   ;timer B timeout interrupt
GPT_IRQ_DMAA       .equ    0x00000020   ;timer A DMA interrupt
GPT_IRQ_TAM        .equ    0x00000010   ;timer A match interrupt
GPT_IRQ_CAE        .equ    0x00000004   ;timer A capture event interrupt
GPT_IRQ_CAM        .equ    0x00000002   ;timer A capture mode match interrupt
GPT_IRQ_TATO       .equ    0x00000001   ;timer A timeout interrupt


; DMAEV - DMA event register
;   sec 15.5.1.26, pg 1382
GPT_DMA_TBM        .equ    0x00000800   ;DMA trigger on timer B match
GPT_DMA_CBE        .equ    0x00000400   ;DMA trigger on timer B capture event
GPT_DMA_CBM        .equ    0x00000200   ;DMA trigger on timer B capture match
GPT_DMA_TBTO       .equ    0x00000100   ;DMA trigger on timer B timeout
GPT_DMA_TAM        .equ    0x00000010   ;DMA trigger on timer A match
GPT_DMA_CAE        .equ    0x00000004   ;DMA trigger on timer A capture event
GPT_DMA_CAM        .equ    0x00000002   ;DMA trigger on timer A capture match
GPT_DMA_TATO       .equ    0x00000001   ;DMA trigger on timer A timeout


; ANDCCP - combined CCP output register
;   sec 15.5.1.28, pg 1384
GPT_PWM_LOAD       .equ    0x00000000   ;PWM assertion when match load value
GPT_PWM_TO         .equ    0x00000002   ;PWM assertion when timeout
GPT_CCP_IND        .equ    0x00000000   ;timer A and B PWM independent
GPT_CCP_AND        .equ    0x00000001   ;timer A PWM output is AND of timer A and B PWM signals

