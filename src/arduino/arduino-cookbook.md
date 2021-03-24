# Arduino cookbook
I tend to like doing things on the command line, so I will be using the [PlatformIO](https://platformio.org/) open source IoT tool.

#### Configuring PlatformIO <a name="toc-sub-tag-0"></a>
I will probably end up making another document on using PlatformIO, but for the sake of getting started (edit: indeed I did; section moved to [PlatformIO notes](https://github.com/Dustpancake/Dust-Notes/blob/master/arduino/platformio.md)).

<!--BEGIN TOC-->
## Table of Contents
1. [Interacting with pins](#toc-sub-tag-1)
	1. [LED](#toc-sub-tag-2)
	2. [Servo](#toc-sub-tag-3)
	3. [Reading from analog pins](#toc-sub-tag-4)
2. [Serial data](#toc-sub-tag-5)
	1. [Writing to serial](#toc-sub-tag-6)
	2. [Reading from serial](#toc-sub-tag-7)
	3. [Serial communication](#toc-sub-tag-8)
		1. [A note on USB translation](#toc-sub-tag-9)
		2. [The `Serial` module](#toc-sub-tag-10)
3. [Interrupts](#toc-sub-tag-11)
	1. [Software interrupts](#toc-sub-tag-12)
	2. [Hardware interrupts](#toc-sub-tag-13)
4. [The EEPROM](#toc-sub-tag-14)
<!--END TOC-->

## Interacting with pins <a name="toc-sub-tag-1"></a>
Different recipes for interacting with pins. All of these scripts will require the
```cpp
#include "Arduino.h"
```
library.

### LED <a name="toc-sub-tag-2"></a>
The most basic circuit we can construct is an LED bridging a pin to ground; the code to interact with such a circuit is
```cpp
void setup() {
	pinMode(LED_PIN, OUTPUT);
}

void loop() {
	digitalWrite(LED_BUILTIN, HIGH);	// or LOW or whatever you like
}
```
### Servo <a name="toc-sub-tag-3"></a>
Common micro-servos have three connecting cables; **ground**, commonly brown, **live**, commonly +5V and red, and **control**, commonly orange. The ground and live cables connect trivially, but the control must connect to a pin capable of PWM.

Once the circuit is built, the servo may be controlled
```cpp
#include "Servo.h"

Servo testServo;

void setup() {
	testServo.attach(SERVO_PIN);
}

void loop() {
	// Make the servo swerve left and right
	for (int i = 0; i <= 180; i++) {
		testServo.write(i);
		delay(5);	// ms
	}
	for (int i = 179; i >= 1; i--) {
		testServo.write(i)
		delay(5);
	}
}
```

### Reading from analog pins <a name="toc-sub-tag-4"></a>
Some MCUs come with analog in pins, such as the Uno with 6 pins A0 through A5. These pins are able to detect voltages between 0V and 5V. We can read in the voltage value with
```cpp
analogRead(PIN);
```
which returns an integer in the range 0 to 1023, mapping to 0-5V; e.g. 2.5V would return 512.

We can go further and provide an `analogReference()` from which the voltage difference is measured in `analogRead()`. Available references are

- **DEFAULT** -- 5V on 5V boards, 3.3V on 3.3V boards
- **INTERNAL** -- built-in reference, equal to 1.1 volts on the ATmega168 or ATmega328 and 2.56 volts on the ATmega8 (not available on the Mega)
- **INTERNAL1V1** − 1.1V reference (Mega only)
- **INTERNAL2V56** − 2.56V reference (Mega only)
- **EXTERNAL** − voltage applied to the AREF pin (0 to 5V only)

Note that the AREF pin has built-in 32kOhm resistance. If, e.g. 2.5V applied to AREF with 5kOhm resistance, we measure
```
2.5 * 32 / (32 + 5) = ~2.2V 
```
at the AREF pin.

## Serial data <a name="toc-sub-tag-5"></a>
Interacting with serial data is included in the default arduino library. A thing to be cautious of is the baud rate, and that the IO is buffered. Common baud rates are 9600, 19200, 38400, 57600 and 115200.

The `setup` function for all of these recipes is identical, with changes made where necessary
```cpp
void setup() {
	Serial.begin(BAUD_RATE);
}
```

### Writing to serial <a name="toc-sub-tag-6"></a>
Serial data is written into bytes, with the decoding and encoding happening automatically in the built-in functions. Writing to serial is as easy as
```cpp
Serial.println("some string");
```

### Reading from serial <a name="toc-sub-tag-7"></a>
Reading from serial needs to ensure that data is available
```cpp
String readString = "";

void loop() {
	while (Serial.available()) {
			char c = Serial.read();	// read in one byte
			readString += c;
			// can be necessary to include a delay statement here
			// as to buffer the serial port correctly
	}
	if (readString.length() > 0) {
		// do something with the string
	}
}
```

### Serial communication <a name="toc-sub-tag-8"></a>
Standard MCUs come with TX (transmit) and RX (receive) digital pins. Serial data is not the same as USB data; these pins are 'multiplexed' into the USB connections, but a separate IC decodes and translates between the two. Some micro-controllers, such as the arduino Leonardo 32U4 MCU, have built in USB controllers.

#### A note on USB translation <a name="toc-sub-tag-9"></a>
On some MCU with USB-to-serial translation, this task is undertaken by a FTDI chip. This is often the case on smaller MC, such as the Nano.

Other MCUs, such as the Uno, have IC other than FTDI chips handling the translation, such as the Atmel 8U2 or 16U2.

And finally, some MCUs are even able to act as USB hosts, such as the Due, or Mega ADK. The ADK comes with Android Open Accessory Protocol (AOA) facilitating communication between arduino and android devices.

#### The `Serial` module <a name="toc-sub-tag-10"></a>
All of the printing functions allow different representations of data types. These include

Data types |  Code  | Output
:--- | :--- | :---
Decimal | `println(23);` | 23
Hexadecimal | `println(23, HEX);` | 17
Octal | `println(23, OCT);` | 27
Binary | `println(23, BIN);` | 00010111

There are also several 'probing' functions to ascertain the presence of serial data and retrieve it

- `Serial.available()` returns number of chars / bytes currently stored in the incoming serial buffer.
- `Serial.read()` returns and removes one byte of data from the serial buffer.
- `Serial.parseInt()` returns and removes the first valid integer (i.e. up until first non-numeric char).
- `Serial.find(target[, length])` reads data from buffer until character is found, or length is reached. Returns `true` or `false`.
- `Serial.readStringUntil(terminator)` reads buffer into a `String` until a terminator character is found.

Serial data can also be triggered using a timer interrupt and the `Serial.serialEvent()` function, such as using
```cpp
void serialEvent() {
	// Only triggered at the end of a loop cycle
	String inputString = "";
	while (Serial.available()) {
	inputString += (char)Serial.read();
	}
	Serial.print("TRIGGER: buffer contains '"); Serial.print(inputString); Serial.print("'\n");
}
```

## Interrupts <a name="toc-sub-tag-11"></a>
Interrupts are the closest many MCUs get to asynchronous code execution. Interrupts, as the name suggests, interrupt the code execution to complete a secondary routine, before resuming where the main thread left off. Interrupts may be included as either **software** or **hardware** interrupts.

Most arduino MCU have two defined harware interrupts `interrupt0` and `interrupt1` hardwired into IO pins 2 and 3 respectively. The Mega has six interrupts, namely `interrupt0` through `interrupt5`, additionally on pins 18-21.

Routines using interrupts are known as *interrupt service routines* (ISRs). For buttons, commonly used in hardware interrupts, we can trigger the interrupts on rising, falling, or both edges.

ISRs should be short and fast, can only be executed one at a time, and are executed sequentially as to the order they occur in. Global variables are commonly used to pass information from the main code execution to the ISR and back -- it is therefore best that they are declared as `volatile`.

### Software interrupts <a name="toc-sub-tag-12"></a>
To my knowledge, only hack implementation of software interrupts exist on most MCUs.

### Hardware interrupts <a name="toc-sub-tag-13"></a>
We can define a hardware interrupt using the `attachInterrupt()` syntax, defining a pin number, and ISR, and the triggering mode
```cpp
attachInterrupt(
	digitalPinToInterrupt(PIN),
	ISR,
	MODE
);
```
Here, the ISR is any function of the form
```
void functionName() {} ;
```
and the available modes are

- **LOW**: triggering when pin is low
- **CHANGE**: triggering when the voltage value changes
- **FALLING**: triggering when the pin goes from high to low


## The EEPROM <a name="toc-sub-tag-14"></a>
TODO