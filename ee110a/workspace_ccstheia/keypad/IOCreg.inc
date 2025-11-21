;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  IOCreg.inc                                ;
;                            IOC Register Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the IOC control registers for the TI
; CC2652 microcontroller.
;
; References: CC13x2, CC26x2 SimpleLink™ Wireless MCU Technical Reference Manual
;             https://www.ti.com/lit/ug/swcu185g/swcu185g.pdf?ts=1761608306803
;
; Revision History:
;     2/16/22  Glen George      initial revision
;    11/05/23  Glen George      update style and comments
;    10/28/25  Steven Lei       add references to CC2652 Reference manual


; I/O (DIO) pins are configured through the IOCFGn registers in the MCU IOC
; IOCFGn registers are memory mapped 
;   sec 13.3, pg 1070

; Base address of the registers
;   table 3-1, pg 319
IOC_BASE_ADDR      .equ    0x40081000   ;I/O Controller registers

; IOCFGn register offsets in memory map
;   sec 13.10.3, pg 1106

IOCFG0             .equ    0x0000       ;I/O configuration for DIO0
IOCFG1             .equ    0x0004       ;I/O configuration for DIO1
IOCFG2             .equ    0x0008       ;I/O configuration for DIO2
IOCFG3             .equ    0x000C       ;I/O configuration for DIO3
IOCFG4             .equ    0x0010       ;I/O configuration for DIO4
IOCFG5             .equ    0x0014       ;I/O configuration for DIO5
IOCFG6             .equ    0x0018       ;I/O configuration for DIO6
IOCFG7             .equ    0x001C       ;I/O configuration for DIO7
IOCFG8             .equ    0x0020       ;I/O configuration for DIO8
IOCFG9             .equ    0x0024       ;I/O configuration for DIO9
IOCFG10            .equ    0x0028       ;I/O configuration for DIO10
IOCFG11            .equ    0x002C       ;I/O configuration for DIO11
IOCFG12            .equ    0x0030       ;I/O configuration for DIO12
IOCFG13            .equ    0x0034       ;I/O configuration for DIO13
IOCFG14            .equ    0x0038       ;I/O configuration for DIO14
IOCFG15            .equ    0x003C       ;I/O configuration for DIO15
IOCFG16            .equ    0x0040       ;I/O configuration for DIO16
IOCFG17            .equ    0x0044       ;I/O configuration for DIO17
IOCFG18            .equ    0x0048       ;I/O configuration for DIO18
IOCFG19            .equ    0x004C       ;I/O configuration for DIO19
IOCFG20            .equ    0x0050       ;I/O configuration for DIO20
IOCFG21            .equ    0x0054       ;I/O configuration for DIO21
IOCFG22            .equ    0x0058       ;I/O configuration for DIO22
IOCFG23            .equ    0x005C       ;I/O configuration for DIO23
IOCFG24            .equ    0x0060       ;I/O configuration for DIO24
IOCFG25            .equ    0x0064       ;I/O configuration for DIO25
IOCFG26            .equ    0x0068       ;I/O configuration for DIO26
IOCFG27            .equ    0x006C       ;I/O configuration for DIO27
IOCFG28            .equ    0x0070       ;I/O configuration for DIO28
IOCFG29            .equ    0x0074       ;I/O configuration for DIO29
IOCFG30            .equ    0x0078       ;I/O configuration for DIO30
IOCFG31            .equ    0x007C       ;I/O configuration for DIO31


; Port IDs determine the what peripheral function is routed to the pin
; (e.g. GPIO, SSI). Bits 0 to 5 of IOCFGn registers 
;   sec 13.8, pg 1074

IOCFG_GPIO         .equ    0            ;use pin for GPIO
IOCFG_AON32        .equ    7            ;use pin for AON 32 KHz clock
IOCFG_AUXIO        .equ    8            ;use pin for AUX IO
IOCFG_SSI0_RX      .equ    9            ;use pin for SSI0 receive
IOCFG_SSI0_TX      .equ    10           ;use pin for SSI0 transmit
IOCFG_SSI0_FSS     .equ    11           ;use pin for SSI0 frame signal
IOCFG_SSI0_CLK     .equ    12           ;use pin for SSI0 clock
IOCFG_I2C_MSSDA    .equ    13           ;use pin for I2C data
IOCFG_I2C_MSSCL    .equ    14           ;use pin for I2C clock
IOCFG_UART0_RX     .equ    15           ;use pin for UART0 receive
IOCFG_UART0_TX     .equ    16           ;use pin for UART0 transmit
IOCFG_UART0_CTS    .equ    17           ;use pin for UART0 CTS
IOCFG_UART0_RTS    .equ    18           ;use pin for UART0 RTS
IOCFG_UART1_RX     .equ    19           ;use pin for UART1 receive
IOCFG_UART1_TX     .equ    20           ;use pin for UART1 transmit
IOCFG_UART1_CTS    .equ    21           ;use pin for UART1 CTS
IOCFG_UART1_RTS    .equ    22           ;use pin for UART1 RTS
IOCFG_PORT_EVENT0  .equ    23           ;use pin for I/O for event 0
IOCFG_PORT_EVENT1  .equ    24           ;use pin for I/O for event 1
IOCFG_PORT_EVENT2  .equ    25           ;use pin for I/O for event 2
IOCFG_PORT_EVENT3  .equ    26           ;use pin for I/O for event 3
IOCFG_PORT_EVENT4  .equ    27           ;use pin for I/O for event 4
IOCFG_PORT_EVENT5  .equ    28           ;use pin for I/O for event 5
IOCFG_PORT_EVENT6  .equ    29           ;use pin for I/O for event 6
IOCFG_PORT_EVENT7  .equ    30           ;use pin for I/O for event 7
IOCFG_CPU_SWV      .equ    32           ;use pin for CPU SWV
IOCFG_SSI1_RX      .equ    33           ;use pin for SSI1 receive
IOCFG_SSI1_TX      .equ    34           ;use pin for SSI1 transmit
IOCFG_SSI1_FSS     .equ    35           ;use pin for SSI1 frame signal
IOCFG_SSI1_CLK     .equ    36           ;use pin for SSI1 clock
IOCFG_I2S_AD0      .equ    37           ;use pin for I2S data 0
IOCFG_I2S_AD1      .equ    38           ;use pin for I2S data 1
IOCFG_I2S_WCLK     .equ    39           ;use pin for I2S WCLK
IOCFG_I2S_BCLK     .equ    40           ;use pin for I2S BCLK
IOCFG_I2S_MCLK     .equ    41           ;use pin for I2S MCLK
IOCFG_RFC_TRACE    .equ    46           ;use pin for RF core trace
IOCFG_RFC_DO0      .equ    47           ;use pin for RF core data out 0
IOCFG_RFC_DO1      .equ    48           ;use pin for RF core data out 1
IOCFG_RFC_DO2      .equ    49           ;use pin for RF core data out 2
IOCFG_RFC_DO3      .equ    50           ;use pin for RF core data out 3
IOCFG_RFC_DI0      .equ    51           ;use pin for RF core data in 0
IOCFG_RFC_DI1      .equ    52           ;use pin for RF core data in 1
IOCFG_RFC_SDO      .equ    53           ;use pin for RF core SMI data link out
IOCFG_RFC_SDI      .equ    54           ;use pin for RF core SMI data link in
IOCFG_RFC_SCO      .equ    55           ;use pin for RF core SMI command link out
IOCFG_RFC_SCI      .equ    56           ;use pin for RF core SMI command link in


; General IOCFGn configurations (applies to all registers), bits 31:0
;   example for ICOFG0:
;   sec 13.10.3.1, pg 1103

IOCFG_GEN_DIN      .equ    0x20006000   ;general purpose data input pin
                ;0------------------------------- reserved
                ;-0------------------------------ no hysteresis
                ;--1----------------------------- input
                ;---00--------------------------- no wakeup
                ;-----000------------------------ normal mode
                ;--------000--------------------- no edge detect events
                ;-----------00------------------- reserved
                ;-------------0------------------ no edge detect IRQ
                ;--------------00---------------- no edge detection
                ;----------------0--------------- reserved
                ;-----------------11------------- no pull up/down
                ;-------------------0------------ normal slew
                ;--------------------00---------- 2mA output
                ;----------------------00-------- auto drive strength control
                ;------------------------0------- no edge detect RTC event
                ;-------------------------0------ no edge detect wake up event
                ;--------------------------000000 general purpose I/O

IOCFG_GEN_DOUT     .equ    0x00006000   ;general purpose data output pin
                ;0------------------------------- reserved
                ;-0------------------------------ no hysteresis
                ;--0----------------------------- output
                ;---00--------------------------- no wakeup
                ;-----000------------------------ normal mode
                ;--------000--------------------- no edge detect events
                ;-----------00------------------- reserved
                ;-------------0------------------ no edge detect IRQ
                ;--------------00---------------- no edge detection
                ;----------------0--------------- reserved
                ;-----------------11------------- no pull up/down
                ;-------------------0------------ normal slew
                ;--------------------00---------- 2mA output
                ;----------------------00-------- auto drive strength control
                ;------------------------0------- no edge detect RTC event
                ;-------------------------0------ no edge detect wake up event
                ;--------------------------000000 general purpose I/O

IOCFG_GEN_DOUT_4MA .equ    0x00006400   ;general data output pin with 4mA drive
                ;0------------------------------- reserved
                ;-0------------------------------ no hysteresis
                ;--0----------------------------- output
                ;---00--------------------------- no wakeup
                ;-----000------------------------ normal mode
                ;--------000--------------------- no edge detect events
                ;-----------00------------------- reserved
                ;-------------0------------------ no edge detect IRQ
                ;--------------00---------------- no edge detection
                ;----------------0--------------- reserved
                ;-----------------11------------- no pull up/down
                ;-------------------0------------ normal slew
                ;--------------------01---------- 4mA output
                ;----------------------00-------- auto drive strength control
                ;------------------------0------- no edge detect RTC event
                ;-------------------------0------ no edge detect wake up event
                ;--------------------------000000 general purpose I/O
