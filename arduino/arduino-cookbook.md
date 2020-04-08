# Arduino cookbook
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
