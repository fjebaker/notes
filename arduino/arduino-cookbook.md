# Arduino cookbook
I tend to like doing things on the command line, so I will be using the [PlatformIO](https://platformio.org/) open source IoT tool.

#### Configuring PlatformIO <a name="toc-sub-tag-0"></a>
I will probably end up making another document on using PlatformIO, but for the sake of getting started (edit: indeed I did; section moved to [PlatformIO notes](https://github.com/Dustpancake/Dust-Notes/blob/master/arduino/platformio.md)).

<!--BEGIN TOC-->
## Table of Contents
1. [Interacting with pins](#toc-sub-tag-1)
	1. [LED](#toc-sub-tag-2)
	2. [Servo](#toc-sub-tag-3)
2. [Serial data](#toc-sub-tag-4)
	1. [Writing to serial](#toc-sub-tag-5)
	2. [Reading from serial](#toc-sub-tag-6)
3. [Detailed notes](#toc-sub-tag-7)
	1. [Serial communication](#toc-sub-tag-8)
	2. [A note on USB translation](#toc-sub-tag-9)
	3. [The `Serial` module](#toc-sub-tag-10)
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

## Serial data <a name="toc-sub-tag-4"></a>
Interacting with serial data is included in the default arduino library. A thing to be cautious of is the baud rate, and that the IO is buffered. Common baud rates are 9600, 19200, 38400, 57600 and 115200.

The `setup` function for all of these recipes is identical, with changes made where necessary
```cpp
void setup() {
	Serial.begin(BAUD_RATE);
}
```

### Writing to serial <a name="toc-sub-tag-5"></a>
Serial data is written into bytes, with the decoding and encoding happening automatically in the built-in functions. Writing to serial is as easy as
```cpp
Serial.println("some string");
```

### Reading from serial <a name="toc-sub-tag-6"></a>
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

## Detailed notes <a name="toc-sub-tag-7"></a>
These are notes I am making whilst reading some literature on the arduino MCUs.

### Serial communication <a name="toc-sub-tag-8"></a>
Standard MCUs come with TX (transmit) and RX (receive) digital pins. Serial data is not the same as USB data; these pins are 'multiplexed' into the USB connections, but a separate IC decodes and translates between the two. Some micro-controllers, such as the arduino Leonardo 32U4 MCU, have built in USB controllers.

### A note on USB translation <a name="toc-sub-tag-9"></a>
On some MCU with USB-to-serial translation, this task is undertaken by a FTDI chip. This is often the case on smaller MC, such as the Nano.

Other MCUs, such as the Uno, have IC other than FTDI chips handling the translation, such as the Atmel 8U2 or 16U2.

And finally, some MCUs are even able to act as USB hosts, such as the Due, or Mega ADK. The ADK comes with Android Open Accessory Protocol (AOA) facilitating communication between arduino and android devices.

### The `Serial` module <a name="toc-sub-tag-10"></a>
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