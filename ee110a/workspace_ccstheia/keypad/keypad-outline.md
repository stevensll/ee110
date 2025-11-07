# HW2 Outline

## Hardware overview: 

* 4 x 3 keypad
* READ: 74ls251 MUX
  * 3 GPIO, 1 output, 1 input
  * toggle AB to output to rows
* SCAN: 74lS139 DEMUX
  * 2 GPIO, 2 output
  * toggle AB to read column input into Y
* 5 GPIO in total
* Pull up resistors
* Diodes to prevent columns shorting out
* **NO** ghosting diodes

## Software overview:

General initialization

* init power
* init timers
* init gpio pins
* init timer compare register for interrupts
* init event queue

Keypad specific

For 1 row:

* Need to output to 74ls139 AB to write to row
* Then read column from 74LS253 at Y. While doing this need to toggle AB 

Repeat this for all 4 rows

Now have the new entire switch pattern

Debounce it by comparing to old pattern

* Apply auto repeat if necessary
* if debounced the switch, create event queue

Event queue 


12 keys = 12 bits, use 16 bits. 1 = 0x0, 9 = 0x100000000, 0 = 0x100000000000

## Pseudo code
```C
// Switch constants
# define DEBOUNCE_TIME      10
# define REPEAT_RATE        20

// Keypad hardware constants
# define KEYPAD_NUM_ROWS     3
# define KEYPAD_NUM_COLS     4
# define MUX_PIN_A        DIO4    
# define MUX_PIN_B        DIO21
# define DEMUX_PIN_A      DIO26
# define DEMUX_PIN_B      DIO27
# define DEMUX_PIN_Y      DIO25

// No key is all 0s
# define NO_KEY           0x00

# define INTERRUPT_TIME_MS    1

// Shared variables in this code
shared int16_t prev_switch_patt;
shared int16_t curr_switch_patt;
shared size_t debounce_counter;


event_queue;

void KeypadDemo() {
    // No pseudo code for these functions, self explanatory
    InitPower();
    InitClocks();
    InitGPIO();
    InitGPT();
    //
    InitKeypad();
    InitEventQueue();
    while (1) {
        TimerEventHandler();
        ProcessEventQueue();
    }
}

// Reset all keypad and debouncing variables
void InitKeypad() {
    prev_switch_patt = NO_KEY;
    curr_switch_patt = NO_KEY;
    debounce_counter = DEBOUNCE_TIME;
}

// Upon every interrupt, check if there are keys pressed and debounce if any
// Note part of this function should not be actual code, it is done by hardware
void TimerEventHandler() {
    if (general_purpose_timer.time() = INTERRUPT_TIME_MS) {
        // Actual code we append to the timer event handler
        HandleSwitchPresses();
        //
        general_purpose_timer.reload();
    }
}

// Check if we have any switches pressed and debounce if we do
void HandleSwitchPresses() {
    UpdateSwitchPatt();
    if (curr_switch_patt != NO_KEY) {
        DebounceSwitches();
    }
}
// Get the switch pattern from the keypad by scanning rows and reading cols (note MUXes).
void UpdateSwitchPatt(){
    prev_switch_patt = curr_switch_patt;
    for (int i = 0; i < KEYPAD_NUM_ROWS; i++) {
    // Write to rows
    gpio_write(MUX_PIN_A, i);
    gpio_write(MUX_PIN_B, i);
        // Get columns by writing to demux and reading output
        for (int j = 0; j < KEYPAD_NUM_COLS; j++) {
            // Select the column to read
            gpio_write(DEMUX_PIN_A, j);
            gpio_write(DEMUX_PIN_B, j);
            // For simplicity of pseudo code, this reads the column into the
            // bit_number bit of switch patt. Technically need to bit mask and etc.
            bit_number = 1 + j * KEYPAD_NUM_ROWS  + i;
            // Invert the bit, use 1 as switch pressed, 0 as switch released
            gpio_read(!DEMUX_PIN_Y, curr_switch_patt, bit_number);
        }
    }
}


// Blocking code, called by timer event handler
void DebounceSwitches(){
    while (curr_switch_patt == prev_switch_patt) {
        // Start debouncing
        UpdateSwitchPatt();
        debounce_counter--;
        if (debounce_counter == 0) {
            // Done debouncing, set up for auto repeat
            debounce_counter == REPEAT_RATE;
            // Add key event with the switch pattern
            EnqueueEvent(KEY_EVENT | curr_switch_patt);
        }
    }
    // Switch pattern changed so reset
    debounce_counter = DEBOUNCE_TIME;
}

// Create the event queue (clear it)
void InitEventQueue() {
    event_queue.init();
}

// Since our code only handles 1 type of event, our enqueue/processe event queue
// should not be as complicated in implementation. It should just print the
// switch pattern to the buffer

void EnqueueEventQueue(event) {
    event_queue.add(event);
}
void ProcessEventQueue() {
    event = event_queue.pop();
    while (event) {
        switch(event.id) {
            // Print the switch pattern to the buffer;
            case KEY_EVENT: {
                PrintToBuffer(event.value);
            }
        }
        event = event_queue.pop();
    }
}
```