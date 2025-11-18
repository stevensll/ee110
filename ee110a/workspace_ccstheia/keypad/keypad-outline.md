# HW2 Outline

## Hardware overview: 

* 4 x 3 Keypad
* READ: SNL74LS139ADR 
* * 2 output on GPIO
* * write to select row to read
* * note that logical high from 139ADR is 3.4V, should be ok when tying with 3v3

* SCAN: Directly
* * 3 input on GPIO
* * scan the col pattern from the given row. Note that this is tied to 3v3,

* Pull up resistors
* Diodes to prevent columns shorting out
* **NO** ghosting diodes

## Software overview:

```C

// Turn on power for peripheral devices
# define INTERRUPT_TIME_MS      1

void InitPower() {
    PRCM.power.peripheral.enable();
    bool power_status = false;
    while (!power_status) {
        power_status = PRCM.power.GetStatus();
    }
}

void InitClocks() {
    PRCM.clocks.GPIO.enable();
    PRCM.clocks.TIMER0.enable();
    // Wait for clocks to load
    bool clock_status = false; 
    while (!clock_status) {
        clock_status = PRCM.clocks.GetStatus();
    }
}

// Setup timer for 1 ms interrupts
void InitGPT0() {
    GPT.GPT0.config = 32_BIT_MODE;
    GPT.GPT0.timerA.enable();
    GPT.GPT0.timerA.tmeout.enable();
    // Install the timer handler
    GPT.GPT0.handler = HandleSwitchPresses();
}

// Enable input and outputs for keypad row/cols
void InitGPIO() {
    GPIO.set(KEYPAD_COL_0, input);
    GPIO.set(KEYPAD_COL_1, input);
    GPIO.set(KEYPAD_COL_2, input);
    GPIO.set(MUX_PIN_A, output);
    GPIO.set(MUX_PIN_B, output);
    GPIO.outputs.enable();
}

void InitStack() {
    stack = malloc(STACK_SIZE);
}
```

```C
// Switch constants, MS
# define DEBOUNCE_TIME      10
# define REPEAT_RATE        20

// Keypad hardware constants
# define KEYPAD_NUM_ROWS     3
# define KEYPAD_NUM_COLS     4
# define MUX_PIN_A        DIO4    
# define MUX_PIN_B        DIO21
# define KEYPAD_COL_0     DIO25
# define KEYPAD_COL_1     DIO26
# define KEYPAD_COL_2     DIO27

# define BUFFER_SIZE      1000
# define STACK_SIZE        512

// No key is all 0s
# define NO_KEY           0x00


/* SHARED VARIABLES */
word_t *buff;
int32_t stack;
size_t buff_index;

shared int16_t prev_switch_patt;
shared int16_t curr_switch_patt;
shared size_t debounce_counter;



void KeypadDemo() {
    InitStack();
    InitPower();
    InitClocks();
    InitGPT();
    EnableInterrupts();
    InitGPIO();
    InitKeypad();
    InitEventQueue();
    while (1) {
        // Nothing, the code is just based on interrupts.
    }
}

// Reset all keypad and debouncing variables
void InitKeypad() {
    prev_switch_patt = NO_KEY;
    curr_switch_patt = NO_KEY;
    debounce_counter = DEBOUNCE_TIME;
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
        // For simplicity of pseudo code, this reads the column into the 
        // into the switch pattern, technically need to do bit shifts
        gpio_read(KEYPAD_COL_0, curr_switch_patt, bit_number);
        gpio_read(KEYPAD_COL_1, curr_switch_patt, bit_number);
        gpio_read(KEYPAD_COL_2, curr_switch_patt, bit_number);
    }
}


// Called by timer event handler
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

// "Dummy" event queue, just allocate memory space for the buffer
void InitEventQueue() {
    buffer = malloc(BUFFER_SIZE); 
    buff_index = 0;
}

// "Dummy" enqueue, just write the event to the buffer.
void EnqueueEvent(event) {
    buffer[buff_index] = event;
    buff_index++;
    // Wrap around to start of buffer if run out of size
    if (buff_index == BUFFER_SIZE) {
        buff_index = 0;
    }
}
```
