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
# define KEYPAD_COL_0     DIO20
# define KEYPAD_COL_1     DIO19
# define KEYPAD_COL_2     DIO18
# define BAD_KEY_VALUE       -1

# define QUEUE_SIZE         10
# define STACK_SIZE        512

// No key is all 0s
# define NO_KEY           0x00


/* SHARED VARIABLES */
word_t *event_queue;
int16_t *queue_index;

int64_t *stack;

shared int16_t prev_key_patt;
shared int16_t curr_key_patt;
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

/* "Dummy" event queue, just allocate memory space for the buffer */
void InitEventQueue() {
    event_queue = calloc(QUEUE_SIZE, BYTES_PER_WORD);
    queu_index = 0;
}

/* "Dummy" enqueue, just write the event to the buffer. */
void EnqueueEvent(event) {
    event_queue[queue_index] = event;
    queue_index++;
    // Wrap around to start of buffer if run out of size
    if (buff_index == BUFFER_SIZE) {
        buff_index = 0;
    }
}

// Reset all keypad and debouncing variables
void InitKeypad() {
    prev_key_patt = NO_KEY;
    curr_key_patt = NO_KEY;
    debounce_counter = DEBOUNCE_TIME;
}

// Check if we have any switches pressed and debounce if we do
void KeypressHandler() {
    UpdateKeyPatt();
    if (curr_key_patt != NO_KEY) {
        DebounceSwitches();
    }
}
// Get the switch pattern from the keypad by scanning rows and reading cols (note MUXes).
void UpdateKeyPatt(){
    prev_key_patt = curr_key_patt;
    for (int i = 0; i < KEYPAD_NUM_ROWS; i++) {
        // Write to rows
        gpio_write(MUX_PIN_A, i&0b1);
        gpio_write(MUX_PIN_B, i&0b10);
        // For simplicity of pseudo code, this reads the column into the 
        // into the switch pattern, technically need to do bit shifts
        gpio_read(KEYPAD_COL_0, curr_key_patt, bit_number);
        gpio_read(KEYPAD_COL_1, curr_key_patt, bit_number);
        gpio_read(KEYPAD_COL_2, curr_key_patt, bit_number);
    }
}


// Called by timer event handler
void DebounceKeyPatt(){
    while (curr_key_patt == prev_key_patt) {
        // Start debouncing
        debounce_counter--;
        if (debounce_counter == 0) {
            // Done debouncing, set up for auto repeat
            debounce_counter == REPEAT_RATE;
            // Add key event with the switch pattern
            EnqueueEvent(KEY_EVENT | curr_key_patt);
        }
        UpdateKeyPatt();
    }
    // Switch pattern changed so reset
    debounce_counter = DEBOUNCE_TIME;
}

/* Table of key pattern to key values. Non int keys are converted to ASCII */

int16_t [][2] KeyPattTable = {
    /* Pattern  Return value    ASCII Equivalent    Key Pressed */
    {0x01,      1            /* 1                   1           */}   
    {0x02,      2            /* 2                   2           */}
    {0x04,      3            /* 3                   3           */}
    {0x08,      4            /* 4                   4           */}
    {0x10,      5            /* 5                   5           */}
    {0x20,      6            /* 6                   6           */}
    {0x40,      7            /* 7                   7           */}
    {0x80,      8            /* 8                   8           */}
    {0x100,     9            /* 9                   9           */}
    {0x200,     42           /* *                   *           */}
    {0x400,     0            /* 0                   0           */}
    {0x800,     35           /* #                   #           */}
}

/* Converts the raw key pattern to a key value through lookup in the table*/
/* If the pattern is not in the table, just return BAD_KEY_VALUE */

int GetKeyValueFromPatt(int16_t key_patt) {
    for (size_t i = 0; i < key_patt_table; i++) {
        int16_t row = key_patt_table[i];
        int16_t tab_patt = row[0];
        int16_t tab_value = row[1];
        if (key_patt = tab_patt) {
            return tab_value;
        }
    }
    return BAD_KEY_VALUE;
}
```
