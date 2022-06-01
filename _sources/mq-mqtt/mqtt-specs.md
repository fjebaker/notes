# MQTT Specifications
The MQTT Protocol Packet structure is discussed [elsewhere](http://www.steves-internet-guide.com/mqtt-protocol-messages-overview/), however I personally found the explanation style a little confusing, so have opted to write my own overview of the MQTT specification.

<!--BEGIN TOC-->
## Table of Contents
1. [The Message Structure](#the-message-structure)
    1. [Control Header](#control-header)
        1. [Message Type](#message-type)
        2. [Header Flags](#header-flags)
    2. [Remaining Length](#remaining-length)
    3. [Type Specific Header](#type-specific-header)
        1. [`CONNECT`](#connect)
2. [Practical Examples](#practical-examples)
    1. [`CONNECT`](#connect)
    2. [`CONNACK`](#connack)

<!--END TOC-->


## The Message Structure
The overall structure of an MQTT packet is as follows

| Control Header | Remaining Length | Type specific Header | Packet Payload |
|-|-|-|-|
| (required) | (required) |  |  |
| 1 Byte | 1-4 Bytes | 0+ Bytes | 0+ Bytes |

such that the simplest message is a 2 byte control field + 1 byte length, e.g. `CONNACK`.

### Control Header
The control header is a single byte, with the first 4 bits representing the *Message Type* and the last 4 bits the *Header Flags*:

<table>
  <tr>
  	<td><b>Bit</b></td>
  	<td>7</td>
    <td>6</td>
    <td>5</td>
    <td>4</td>
    <td>3</td>
    <td>2</td>
    <td>1</td>
    <td>0</td>
  </tr>
  <tr>
  	<td>-</td>
    <td colspan="4">Message Type</td>
    <td colspan="4">Header Flags</td>
  </tr>
</table>

#### Message Type
I have transcribed a table of message types

| Message Type | Bits | Description |
|-|-|-|
| Reserved | `0000` | Reserved |
| `CONNECT` | `0001` | Client connection request |
| `CONNACK` | `0010` | Connect request acknowledged |
| `PUBLISH` | `0011` | Publish a message |
| `PUBACK` | `0100` | Publish acknowledged |
| `PUBREC` | `0101` | Publish receive |
| `PUBREL` | `0110` | Publish release |
| `PUBCOMP` | `0111` | Publish complete |
| `SUBSCRIBE` | `1000` | Client subscribe request |
| `UNSUBSCRIBE` | `1001` | Unsubscribe request |
| `UNSUBACK` | `1010` | Unsubscribe acknowledged |
| `PINGREQ` | `1100` | PING request |
| `PINGRESP` | `1101` | PING response |
| `DISCONNECT` | `1110` | Client disconnecting |
| Reserved | `1111` | Reserved |

Any one of these must be included in the control header.

#### Header Flags
There are 3 Header flags, namely `DUP`, `QOS`, and `RETAIN`, formatted as
<table>
  <tr>
  	<td><b>Bit</b></td>
    <td>3</td>
    <td>2</td>
    <td>1</td>
    <td>0</td>
  </tr>
  <tr>
  	<td>-</td>
    <td>`DUP`</td>
    <td>`QOS`</td>
    <td>`QOS`</td>
    <td>`RETAIN`</td>
  </tr>
</table>

`DUP` is the duplicate flag. If it is set, it indicates that the client is trying to send a packet again.

`QOS` is the Quality of Service: 

- `00` is send once (Fire and Forget)
- `01` is at least once and acknowledge 
- `10` is exactly once and acknowledge (assured delivery) 

`11` is reserved for future implementation.

`RETAIN` indicates whether the broker will hold the packet until it has been consumed by a subscriber. If it is not set, the broker will not hold the packet.

### Remaining Length
The packet length, as described in the [official specifications](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.pdf) is calculated by a variable length encoding scheme, utilizing up to 4 bytes, and indicates the number of bytes remaining in the packet.

The easiest way to understand the variable length encoding scheme is by example; we separate the leading bit as a continuation flag, and so 0-127 can be encoded in the range
```
0  0 00 00 00	(bin)	= 0 (dec)
```
up to
```
0  1 11 11 11	(bin)   = 127 (dec)
```
**NB:** the separated bit (far left) is the 8th bit, and the right most is the 1st.

The range >127 requires at least two bytes, and is encoded
```
1  0 00 00 00	(bin)   = 0 (dec)
0  0 00 00 01	(bin)	= 128 (dec)
```

With 4 bytes available, up to 268'435'455 can be stored (as the final byte must have the continuation bit turned off, equivalent to around 256M of data.

### Type Specific Header
This section may include all sorts of different information, including a packet identifier ([2.3.1 of the specification](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.pdf)). 

#### `CONNECT`
My specific interest lies in extracting the client name from the `CONNECT` packet, which does not contain a packet identifier field. Instead, the header contains the protocol name over 6 bytes, including the length of the protocol:
```
00 04   4d 51 54 54		(hex)
		M  Q  T  T 
```
The following bytes are then:

- byte 7: version byte (commonly 4, equivalent to MQTT v3.1.1)
- byte 8: a connection flag byte, with each bit representing

<table>
  <tr>
  	<td><b>Bit</b></td>
  	<td>7</td>
    <td>6</td>
    <td>5</td>
    <td>4</td>
    <td>3</td>
    <td>2</td>
    <td>1</td>
    <td>0</td>
  </tr>
  <tr>
  	<td>-</td>
  	<td>Username flag</td>
  	<td>Password flag</td>
  	<td>Will retain</td>
  	<td colspan="2">Will QoS</td>
  	<td>Will Flag</td>
  	<td>Clean Session</td>
  	<td>Reserved</td>
  </tr>
</table>

- byte 9-10: keep alive MSB and LSB.

Exactly how each flag may be set is involved, but outlined in section [3.1.2 of the specification](http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.pdf).

The next bytes, unless the Username flag is not set, is a UTF-8 encoded string, with the first two bytes being the string length MSB and LSB.


## Practical Examples
Using Wireshark we can capture and examine MQTT packets.

### `CONNECT`
Here is a `CONNECT` packet from a Python client with the client name `python test client`:
```
0000   10 23 00 04 4d 51 54 54 04 02 00 3c 00 17 70 79   .#..MQTT...<..py
0010   74 68 6f 6e 20 74 65 73 74 20 63 6c 69 65 6e 74   thon test client
0020   20 20 20 20 20                                         
```

### `CONNACK`
And the associated `CONNACK` returned by the broker to the above `CONNECT` packet:
```
0000   20 02 00 00                                        ...
```