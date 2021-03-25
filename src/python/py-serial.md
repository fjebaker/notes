# Serial communication with Python

Part of a project I am working on using micro-controllers is being able to efficiently and quickly communicate data backwards and forwards across the serial ports. The python package
```
pip install pyserial
```
provides an abstraction that allows this task to be completed with ease.

<!--BEGIN TOC-->
## Table of Contents
1. [Synchronous interaction](#synchronous-interaction)
    1. [Reading](#reading)
    2. [Writing](#writing)
2. [Asynchronous interaction](#asynchronous-interaction)

<!--END TOC-->

## Synchronous interaction
Reading and writing to a serial port is pretty straight forward with `serial`. We can begin instantiate and open a connection with
```python
import serial 

ser = serial.Serial(
		port = DEV_PORT,
		baudrate = BAUD_RATE,
		timeout=0.1
	)
```
The timeout is in seconds, representing the wait time for `read()` invocations, before releasing the block. `write()` is blocking by default, unless the `write_timeout` is set to `True`.

When opening a connection with a MCU, the RTS (ready to send) and DTR (data terminal ready) signals are sent. For arduinos, by default, these signals will reset the current script running.

### Reading
The idiom for reading from the serial port is much like the idiom used in the arduino script; i.e., while there is data, read. We can implement this as
```python
while ser.inWaiting() > 0:	# number of bytes in waiting
	inp = ser.read(ser.inWaiting()).decode()
	if inp != '':
		# do something with input
```

### Writing
When writing to the serial port, it can be of importance to wait until the written data is consumed. The `ser.flush()` method can facilitate this.

Writing to an open port is as easy as
```python
ser.write("string".encode())
```

## Asynchronous interaction