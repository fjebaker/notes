# Using the ECC0X08 with Arduino devices

Part of my ongoing IoT project is to utilize the ATECC608a embedded in the Arduino Nano 33 IoT micro controller. I outline my aims and list my guides in my [dedicated repository](https://github.com/fjebaker/MQTT-with-TLS), and will use these notes to document the exploration process.

<!--BEGIN TOC-->
## Table of Contents
1. [Available libraries and specifications](#available-libraries-and-specifications)
    1. [ArduinoECCX08](#arduinoeccx08)
    2. [ECC608 data sheets](#ecc608-data-sheets)
    3. [A few warnings](#a-few-warnings)
2. [Configuring the ECC608](#configuring-the-ecc608)
    1. [Configuring AES and the respective key slots](#configuring-aes-and-the-respective-key-slots)
    2. [Slot and Key configuration bytes](#slot-and-key-configuration-bytes)

<!--END TOC-->

## Available libraries and specifications
The ATECC608a chip, developed by [Microchip Tech](https://www.microchip.com/wwwproducts/en/ATECC608A) is an all encompassing improvement on their previous ATECC508, now supporting a secure boot feature, AES, and all sorts of performance enhancements. Unfortunately, the (summary) data sheet available on the [official website](http://ww1.microchip.com/downloads/en/DeviceDoc/ATECC608A-CryptoAuthentication-Device-Summary-Data-Sheet-DS40001977B.pdf) is somewhat lackluster when it comes to working out how to interface with the device, beyond indicating that the ECC508 libraries will interface with the I2C in the same way, and that only *new* functionality has been added (the datasheet for the ATECC508 can be found [here](https://content.arduino.cc/assets/mkr-microchip_atecc508a_cryptoauthentication_device_summary_datasheet-20005927a.pdf).

Also indicated is the [`cryptoauthlib`](https://github.com/MicrochipTech/cryptoauthlib), which is a generic library for interfacing with different cryptographic authentication chips made by Microchip Tech, for use with a full blown OS, as well as MCUs.

I had a good long go at trying to get `cryptoauthlib` to work satisfactorily on the Arduino Nano 33 IoT, but found it very difficult to interface with the chip, even when following essentially [the only tutorial](https://www.instructables.com/id/Secure-Communication-Arduino/) I could find.

### ArduinoECCX08
I searched on GitHub and found an Arduino library called [ArduinoECCX08](https://github.com/arduino-libraries/ArduinoECCX08) for both the ATECC508 and ATECC608. This library worked with little adjustment on my Nano 33 IoT, but comes with very limited functionality -- at the time of writing (August 2020), it only supports some of the ECC508 features

- random numbers
- JWS signing
- different sorts of certificate generation and validation
- public/private key generation
- SHA256 digests

My particular interest lies in the secure boot, AES crypto, and key storage features in the ECC608, not currently present. *I have forked the repo* **[fjebaker/ArduinoECCX08](https://github.com/fjebaker/ArduinoECCX08)**, and intend to implement those features myself soon. As such, these notes will act as a development log as well as their overview purpose.

### ECC608 data sheets
After a lot of searching, I found two, more complete, data sheets for the ECC608

- an NDA protected [preliminary data sheet](https://atecc608a.neocities.org/ATECC608A.pdf)
- a Microchip Tech [full data sheet](http://ww1.microchip.com/downloads/en/DeviceDoc/ATECC608A-TNGTLS-CryptoAuthentication-Data-Sheet-DS40002112B.pdf)

I use these as references for my implementations, and will refer to them heavily in the development logs.

### A few warnings
Something to note is that development with the ECC608 can be very infuriating at times, since the majority of the chip's functionality only becomes available after the configuration has been locked. **Once the configuration is locked, it can never be unlocked.** 

It can also be annoying, since the One Time Programmable (OTP) and Data stores can also be locked. **Once the OTP & Data stores are locked, they can never be unlocked.**

A mistake I made on my first exploration was executing code from the ArduinoECCX08 example, which called a `lock()` method. My intuition suggested this would only lock the config, but it locks **both config and OTP/Data.** My fork separates these methods, as I think, especially for newcomers, that function can be quite painful, and for most learning cases, you don't need to lock the OTP/Data, and it is arguably a silly thing to do unless going into production.

## Configuring the ECC608
These notes are explicitly for the ECC608, though the general technique is applicable for general ECCX08s.

Drawing from [Section 2.1](http://ww1.microchip.com/downloads/en/DeviceDoc/ATECC608A-TNGTLS-CryptoAuthentication-Data-Sheet-DS40002112B.pdf#_OPENTOPIC_TOC_PROCESSING_d137e1597), we see the device is configured by a 128 byte location in memory, which can be summarized as

<table>
  <tr>
  	<td>Bytes 0 - 15</td>
  	<td>Read-only device information</td>
  </tr>
  <tr>
  	<td align="right">16 - 19</td>
  	<td>misc.</td>
  </tr>
  <tr>
  	<td align="right">20 - 51</td>
  	<td>Slot configurations</td>
  </tr>
  <tr>
  	<td align="right">52 - 85</td>
  	<td>misc.</td>
  </tr>
  <tr>
  	<td align="right">6</td>
  	<td>LockValue; related to data lock</td>
  </tr>
  <tr>
  	<td align="right">87</td>
  	<td>LockConfig; related to config lock</td>
  </tr>
  <tr>
  	<td align="right">88 - 89</td>
  	<td>Individual slot locks</td>
  </tr>
  <tr>
  	<td align="right">90 - 95</td>
  	<td>misc.</td>
  </tr>
  <tr>
  	<td align="right">96 - 127</td>
  	<td>Key configurations</td>
  </tr>
</table>

Within the read-only section, there are a few important flag bytes. You can print the current configuration using the ArduinoECCX08 library, and the following sketch
```cpp
#include <Arduino.h>
#include <ArduinoECCX08.h>

void printHex(char c) {
   if (c < 16) {Serial.print("0");}
   Serial.print(c, HEX); Serial.print(" ");
}

void printArr(byte arr[], int length) {
    for (int i = 0; i < length; i++) {
        printHex(arr[i]);
        if ((i+1) % 8 == 0) Serial.println("");
    }
}

void setup() {
    Serial.begin(9600);
    while (!Serial) {
        ;
    }

    if (!ECCX08.begin()) {
        Serial.println("Failed to communicate with ECC508/ECC608!");
        while (1);
    }  

    byte data[128];
    if ( !ECCX08.readConfiguration(data) ) {
        Serial.println("Could not read configuration...");
        while (1);
    } else {
        printArr(data, 128);
    }
}


void loop() { 
	// ...
}
```
The output on my unused Arduino Nano 33 IoT, which I copied into an iPython console, was
```py
data = """
01 23 3D E4 00 00 60 02 
AE 07 3B 91 EE 01 5D 00
C0 00 00 00 83 20 87 20  
8F 20 C4 8F 8F 8F 8F 8F    
9F 8F AF 8F 00 00 00 00    
00 00 00 00 00 00 00 00    
00 00 AF 8F FF FF FF FF    
00 00 00 00 FF FF FF FF     
00 00 00 00 00 00 00 00 
00 00 00 00 00 00 00 00 
00 00 00 00 00 00 55 55 
FF FF 00 00 00 00 00 00 
33 00 33 00 33 00 1C 00 
1C 00 1C 00 1C 00 1C 00 
3C 00 3C 00 3C 00 3C 00 
3C 00 3C 00 3C 00 1C 00 
""".replace("\n", "")
```
I then quickly wrote a few helper functions and parsed the configuration bytes with
```py
parsed = [int(i, 16) for i in data.split(" ") if i != '']


def toHex(i):
    res = hex(i)[2:]
    if i < 16:
        res = "0" + res
    return res

def toBin(i, buf=8):
    res = bin(i)[2:]
    return ("0" * (buf - len(res))) + res

def gB(num, stop=None):
    def pprint(n):
        b = parsed[n]
        print(f"Byte {n}:\n  {toHex(b)}\n  {toBin(b)}")

    if stop is None:
        pprint(num)
    else:
        for i in range(num, stop+1):
            pprint(i)
```
I could now view each configuration byte (and range) in both hexadecimal and binary (NB: I cast to int, and then recast to hex in this approach -- this was an oversight of not planning my code before writing it).

### Configuring AES and the respective key slots
The first byte of interest is 13, as it tells us if AES is enabled on this chip (I use this as a sanity check so far)

```py
>>> gB(13)
Byte 13:
  01
  00000001

```
And true enough, we have AES functionality. Very little else needs to be changed in this configuration step to enable us to store an AES key in the Data zone, and have enough debug functionality to read/write even after the configuration is locked. **NB:** although you need to lock the configuration to write an AES key, you will not be able to unlock the device again afterwards. Finish your full configuration, before committing.

I have included in my fork a configuration that extends the default TLS config to use and enables AES key storage under [`utility/ECCX08DefaultAESConfig.h`](https://github.com/fjebaker/ArduinoECCX08/blob/master/src/utility/ECCX08DefaultAESConfig.h). This configuration enables slot 9 for debug AES keys, by setting the slot config bytes to
```c
0x07, 0x0F
```
and the key config bytes to 
```c
0x1A, 0x00
```
Let's examine what that means.

### Slot and Key configuration bytes
To understand what the slot and key configurations dictate, we need to refer to the preliminary data sheet [Section 2.2.10](https://atecc608a.neocities.org/ATECC608A.pdf#%5B%7B%22num%22%3A43%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C32%2C727%2C0%5D) and [Section 2.2.11](https://atecc608a.neocities.org/ATECC608A.pdf#%5B%7B%22num%22%3A53%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C32%2C603%2C0%5D) respectively. We learn that both the slot and key configurations are separated into 16 two-byte flags, each mapping the the 16 available data slots in progressive order. We thus examine the two-byte flags:

First, the **Slot configuration**:

Bits      | Name | Description
-:|-|-
0<br>- 3 | Read Key | Multi use but generally:<br>bit 0: enable external signatures of arbitrary messages<br>bit 1: enable internal signatures through digest or key generation methods<br>bit 2: ECDH operation is permitted<br>bit 3: if disabled, ECDH master key is readable
4 | No MAC | `0`: key stored may be used by all commands<br>`1`: key stored may not be used by MAC commands (i.e. key is for verification)
5 | Limited Use | `0`: No use limit<br>`1`: Limited use, see [`Counter0`](https://atecc608a.neocities.org/ATECC608A.pdf#%5B%7B%22num%22%3A86%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C32%2C379%2C0%5D)
6 | Encrypt Read | `0`: Clear text reads permitted<br>`1`: Reads will be encrypted, see specifications for details
7 | Is Secret | `0`: Does not contain secret information (key generation commands will fail on this slot)<br>`1`: Contents secret, clear text and 4 byte read/write prohibited
8<br>- 15 | Write Key and Config | See specification

Translating the above `0x07 0x0F -> 0x0F07`, we get
```py
>>> toBin(int("0F07", 16), 16)
'0000111100000111'
```
which we can read to mean

- enable external signatures
- enable internal signatures
- enable ECDH
- ECDH master key readable
- usable by all commands
- Unlimited Use
- Reads plain text
- not secret

**NB:** 0th bit is right most.

This is my test configuration for the AES keys, as it allows for full sanity checks to ensure that what the device is doing is what I planned.


Now the **Key configuration** for the specific data slot:

Bits      | Name | Description
-:|-|-
0 | Private | If set, designated that this slot contains a private key
1 | Public Key Info | Depending on whether the key is private or not, will designate a different verification flag.
2<br>- 4 | Key Type | `000` - `011`: Reserved<br>`100`: P256 NIST ECC Key<br>`101`: Reserved<br>`110`: AES Key<br>`111`: SHA Key or Other<br>
5 | Lockable | `0`: Slot is locked when Data locked<br>`1`: Key is individually lockable, see [Section 2.4](https://atecc608a.neocities.org/ATECC608A.pdf#%5B%7B%22num%22%3A53%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C32%2C603%2C0%5D)
6 | Requires Random Nonce | `0`: No Nonce required<br>`1`: Nonce required
7 | Requires Auth | `0`: No auth required<br>`1`: Authentication required, see [Section 4.4.8](https://atecc608a.neocities.org/ATECC608A.pdf#%5B%7B%22num%22%3A53%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C32%2C603%2C0%5D)
8<br>- 11 | Auth Key | Must be `0000` if no auth required
12<br>- 15 | Misc. | See specification


Translating our `0x1A 0x00 -> 0x001A`, we obtain
```py
>>> toBin(int("001A", 16), 16)
'0000000000011010'
```
which reads to configure this slot with

- public key
- must be validated
- AES Key

A good summary of all of this is presented as specific implementations in the full data sheet, [Section 2.2.4](http://ww1.microchip.com/downloads/en/DeviceDoc/ATECC608A-TNGTLS-CryptoAuthentication-Data-Sheet-DS40002112B.pdf#_OPENTOPIC_TOC_PROCESSING_d137e3321). Also included there are good sample configurations for other keys and storages.
