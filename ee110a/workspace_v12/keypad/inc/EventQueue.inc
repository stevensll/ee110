;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 EventQueue                                 ;
;                                   EE110a                                   ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains constants for the EventQueue structure for EE110a programs.
;
; The event queue expects events to be a 32 bit value of the form:
;
;           31 ................. 16 15 .....................0 
;           |----- EVENT ID -----|  |----- EVENT VALUE -----| 
;
; Where the event ID denotes the type of event and the event value is the 
; value that the event generated.

; Revision History:
;    11/30/25  Steven Lei       initial revision

; Event queue parameters         
QUEUE_INDEX_START     .equ        0           ;queue is 0 indexed 
QUEUE_SIZE            .equ        12          ;number of elements in queue

; Event IDs
KEYPRESS_EVENT        .equ        0x01        ;ID for when key(s) are pressed
; Add more event IDS here ....
