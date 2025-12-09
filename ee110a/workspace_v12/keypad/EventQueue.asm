;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 EventQueue                                 ;
;                                 EE110a HW2                                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the EventQueue structure for EE110a programs.

; NOTE: Currently (for HW2), the EventQueue is simply a buffer that is written  
; to using the EnqueueEvent function. When the buffer is full, the queue will
; overwrite itself (wrap around) with event values.
;
; The event queue expects events to be a 32 bit value of the form:
;
;           31 ................. 16 15 .....................0 
;           |----- EVENT ID -----|  |----- EVENT VALUE -----| 
;
; Where the event ID denotes the type of event and the event value is the 
; value that the event generated.The event IDs are defined in EventQueue.inc.

; Public functions:
;   InitEventQueue - initializes the event queue
;   EnqueueEvent   - adds an event to the queue, with wrap around
;
; Revision History:
;    11/30/25  Steven Lei       initial revision

; Local includes
; Utilities
 .include  "inc/GeneralMacros.inc"
 .include  "inc/GeneralConstants.inc"

; Program specific constants
 .include  "inc/EventQueue.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .align  4
    ; the event queue, by default all values initalized to 0 with .space
eventQueue:         	.space  		QUEUE_SIZE * BYTES_PER_WORD
    ; the queue index (0 indexed)
queueIndex:             .space          BYTES_PER_WORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
    .text
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Define public functions
    .def EnqueueEvent
    .def InitEventQueue


; InitEventQueue
; Description:       Initializes the event queue. Note that this is a "dummy"
;                    event queue implemented as a buffer, so all it does is 
;                    reset the index to the buffer. By default, the queue
;                    values are initializaed to 0 when declare with
;                    the ".space" directive.
;           
; Operation:         The queueIndex variable is reset to 0, which is the
;                    start of the event queue.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  queueIndex  (W): the queue index is reset to 0
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1
; Stack Depth:       0 words
;
; Revision History:  11/27/25   Steven Lei       initial revision

InitEventQueue:
        MOVA    R1, queueIndex              ;get the index from memory
        MOV     R0, #QUEUE_INDEX_START                      
        STR     R0, [R1]                    ;and reset it (0 indexed)

        BX      LR                          ;done so return


; EnqueueEvent
; Description:       Adds an event (argument) into the event queue.Note that
;                    this event queue is implemented as a buffer, so all it 
;                    does is write the event to the buffer at the current
;                    queue index. It then increments the queue index.
;                    NOTE: If the queue is full, the queue will OVERWRITE 
;                    the next value by wrapping the queue index back to start.
;           
; Operation:         The event is stored in the queue and the queue index
;                    is then incremented. The queue index is then reset to 0
;                    if it exceeds the queue size (wrap around).
;
; Arguments:         R0: the event to add to the queue. Assumes this is properly
;                        formatted, see EventQueue.inc
;
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  queueIndex (R, W): the queue index is read to determine
;                                       where to write to the queue and updated
;                                       to point to the next queue entry
;                    eventQueue (W):    the event is added to the queue
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R0 - R3
; Stack Depth:       0 words
;
;
; Revision History:  11/27/25   Steven Lei       initial revision

EnqueueEvent:

AddEventToQueue:                        ;write the event (R0) to the queue 
        MOVA    R2, queueIndex              ;get the queue index from memory 
        LDR     R1, [R2]                    

        MOV     R2, #BYTES_PER_WORD         ;scale queue index to create offset
        MUL     R2, R1, R2                  ;R2 is now byte offset to the queue 

        MOVA    R3, eventQueue              ;get base addr for event queue 
        STR     R0, [R3, R2]                ;and store event at base + offset

UpdateQueueIndexValue:                  ;update the queue index with wraparound
        ADD     R1, R1, #1                  ;increment queue index
        CMP     R1, #QUEUE_SIZE             ;check if index is past end of queue
        BNE     DoneEnqueueEvent            ;   within bounds, so done
        MOV     R1, #QUEUE_INDEX_START      ;past end, so reset to start
        
DoneEnqueueEvent:   
        MOVA    R2, queueIndex              ;write queue index back to memory
        STR     R1, [R2]                
        BX      LR                          ;done so return
