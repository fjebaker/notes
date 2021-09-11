# Copying (root) CA certificates onto Arduino devices

Certificate authority (CA) certificates are the basis for secure and trustworthy transport layer security (TLS). Depending on the Arduino library used, the methods for copying these certificates onto the device can vary. Here I document my exploration of this task, using the WiFiNina library, and the [Arduino Nano 33 IoT](https://store.arduino.cc/arduino-nano-33-iot).

Note, there is a discussion as to the security of different WiFi chips, and whether they are SSL/TLS compatible in the [Arduino forums](https://forum.arduino.cc/index.php?topic=679562.0).

<!--BEGIN TOC-->
## Table of Contents
1. [WiFi(Nina) Toolkit](#wifinina-toolkit)
    1. [Brief discussion of the library state](#brief-discussion-of-the-library-state)
2. [Using the shipped Toolkit with custom CA certificates](#using-the-shipped-toolkit-with-custom-ca-certificates)
    1. [Wireshark](#wireshark)
    2. [OpenSSL to view certificate chains](#openssl-to-view-certificate-chains)
    3. [Configuring a CA](#configuring-a-ca)
3. [Reverse-engineering the shipped Toolkit with custom CA certificates](#reverse-engineering-the-shipped-toolkit-with-custom-ca-certificates)
4. [Using other Libraries](#using-other-libraries)
    1. [BearSSL](#bearssl)
    2. [Ameba IoT devices](#ameba-iot-devices)
    3. [mbedTLS](#mbedtls)
    4. [WiP links](#wip-links)

<!--END TOC-->

## WiFi(Nina) Toolkit
The arduino WiFi and [WiFiNina](https://www.arduino.cc/en/Reference/WiFiNINA) both ship with a tool for updating the device's firmware, and copying new certificates. There are [tutorials](https://www.arduino.cc/en/Tutorial/WiFiNINAFirmwareUpdater) on the internet as to how to accomplish this, but a brief summary of the simplest method is as follows

- install the Arduino IDE
- under Tools -> Manage Libraries, install the WiFi(Nina)
- load the example sketch, under File -> Examples -> WiFi(Nina) -> Tools -> Firmware Updater, and upload it onto your MC device
- under Tools, select the WiFi101 / WiFiNina Firmware Updater, and follow the Toolkit's instructions

The final section of the tool allows you to enter the desired domains you wish to access with the device over SSL/TLS, and the device will then receive the root CA certificates in order to complete that task. As such, the security of the device is in only allowing specific domains to be trustfully accessed, preventing some Man-in-the-Middle attacks (MitM). However, uploading custom CA certificates, for, e.g. a home server, becomes more involved, since you would have to provide a domain where the certificate may be accessed; understanding exactly how these certificates are obtained by the Toolkit also requires exploration to complete this.

There exist essentially two solutions then, in uploading a custom CA onto the device; either providing an endpoint on your server where the Toolkit may fetch it, so that it may be uploaded, or reverse-engineering the Firmware Updater sketch, and feeding the device your own `.pem` or `.cert` files. 

### Brief discussion of the library state

Unfortunately, despite quite extensive research, I have not found an easier way of adding certificates onto these IoT devices. I found discussion in some forums about the [official Nina Firmware](https://github.com/arduino/nina-fw), and how you could compile and flash the device with your own keys inserted in `data/roots.pem`, but that is itself not a straight-forward task, and requires additional tools. My general approach is always to install the minimal amount of new software on my main machine, so I've dismissed that for now.

I saw in a repository issue ([issue #10](https://github.com/arduino/nina-fw/issues/10)) that a feature will be added that solves this problem of uploading certificate files. Until then, and for my own learning, I will explore an alternative solution.

## Using the shipped Toolkit with custom CA certificates
First I wanted to know if the root certificates aquired by the Toolkit are done by the arduino device, or by the host machine before uploading. An info message during the upload step shows that the Toolkit is fetching the certificates, however it did not describe in detail how it achieves this, nor explicitly which device was acquiring the keys.

### Wireshark
I monitored my network traffic whilst running the certificate tookit with the domain `arduino.cc:443`. Filtering with
```
ip.addr == 192.168.1.120 and ip.addr == 100.24.172.113
```
where the first is my machine's IP address, and the latter the IP of `arduino.cc`. We see in the logs the full TLS handshake, key exchange, and cipher specification.
```
Source          Destination     Protocol    Length  Info
---------------|---------------|-----------|-------|------------------------------------------------
192.168.1.120   100.24.172.113  TLSv1.2     275     Client Hello
100.24.172.113  192.168.1.120   TCP         66      443 → 59172 [ACK]
100.24.172.113  192.168.1.120   TLSv1.2     1514    Server Hello
100.24.172.113  192.168.1.120   TLSv1.2     1514    Certificate [TCP segment of a reassembled PDU]
192.168.1.120   100.24.172.113  TCP         66      59172 → 443 [ACK]
100.24.172.113  192.168.1.120   TLSv1.2     166     Server Key Exchange, Server Hello Done
192.168.1.120   100.24.172.113  TCP         66      59172 → 443 [ACK]
192.168.1.120   100.24.172.113  TLSv1.2     141     Client Key Exchange
192.168.1.120   100.24.172.113  TLSv1.2     72      Change Cipher Spec
192.168.1.120   100.24.172.113  TLSv1.2     111     Encrypted Handshake Message
100.24.172.113  192.168.1.120   TCP         66      443 → 59172 [ACK]
100.24.172.113  192.168.1.120   TLSv1.2     117     Change Cipher Spec, Encrypted Handshake Message
192.168.1.120   100.24.172.113  TCP         66      59172 → 443 [ACK]
192.168.1.120   100.24.172.113  TLSv1.2     97      Encrypted Alert
```
The interaction ends with an `Encrypted Alert`; if we examine this package 
```
TLSv1.2 Record Layer: Encrypted Alert
    Content Type: Alert (21)
    Version: TLS 1.2 (0x0303)
    Length: 26
    Alert Message: Encrypted Alert
```
we don't see much. I read on forums that these sort of `Alert (21)`s are an ambiguous alert, and would have to be decoded using the TLS keys (a [CISCO comment](https://community.cisco.com/t5/network-security/ssl-content-type-alert-21/td-p/1218378) suggests Wireshark may be able to do this automatically, else the keys can be obtained using other methods). For now, this is a task for a slow day, and one I may revisit later.

The general handshake however clues in that we may be able to just host a `443` socket on our webserver, which is TLS savvy, and let the Toolkit fetch the root certificate for us (our custom CA in this case), and add it to the device. A possible caveat of this is that the handshake may be rejected by the host machine, unless the custom CA is added to the host's keychain -- something that is completely acceptable to do, but none the less is something I am reluctant to do. My views on this sort of a topic are that I want the IoT device only to be able to connect to this server securely and reliably, and don't wish to have to pollute other machines to accomplish this.

### OpenSSL to view certificate chains
Another handy technique when examining this sort of a problem, and one that may come in handy when testing the success of either solution, is to view the certificate chains, and examine exactly which CA is the root. Examining the `Server Hello` packet from the Wireshark capture a little closer, we see
```
...
00e0   0b 05 00 30 4a 31 0b 30 09 06 03 55 04 06 13 02   ...0J1.0...U....
00f0   55 53 31 16 30 14 06 03 55 04 0a 13 0d 4c 65 74   US1.0...U....Let
0100   27 73 20 45 6e 63 72 79 70 74 31 23 30 21 06 03   's Encrypt1#0!..
0110   55 04 03 13 1a 4c 65 74 27 73 20 45 6e 63 72 79   U....Let's Encry
0120   70 74 20 41 75 74 68 6f 72 69 74 79 20 58 33 30   pt Authority X30
...

```
a `Let's Encrypt` ASCII string. We can also probe the site with OpenSSL, using the command
```bash
openssl s_client -showcerts -connect arduino.cc:443
```
which ouputs
```
---
Certificate chain
 0 s:/CN=arduino.cc
   i:/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
 1 s:/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3
   i:/O=Digital Signature Trust Co./CN=DST Root CA X3
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
---
Server certificate
subject=/CN=arduino.cc
issuer=/C=US/O=Let's Encrypt/CN=Let's Encrypt Authority X3
---
...
```
Here `s:` is the subject line, and `i:` informs us about the issuing authority. In the final lines of the output, we also see explicitly again that the issuer is `Let's Encrypt`. Presumably then, if we can construct a server where OpenSSL is able to fetch a certificate chain with our own certificate as the root, then the Toolkit should also be able to fetch and pass the certificate to our arduino device.

I will write more explicit [notes](https://github.com/furges/notes/blob/master/security/ssl-tls-certificates.md) on certificate authorities, SSL/TLS, and how to configure custom certificate chains at a later date, which will elaborate on different analysis methods more completely.

### Configuring a CA
TODO


## Reverse-engineering the shipped Toolkit with custom CA certificates
TODO


## Using other Libraries
An alternative solution to all of this is to use a different library (though in doing so it could be argued we learn less). From digging for a solution using WiFiNina, I found a few other libraries which already improved upon what I was trying to accomplish, however with their own issues here an there.

### BearSSL
BearSSL allows you do pass x.509 certificates, set trust anchors and Client RSA certificates. The prevelent issue with this library at the moment is securely injecting the certificates in such a way as to prevent them being accessed by a would-be intruder; storing them in the source code, as in the examples, is a very bad practice.

BearSSL builds on the [ESP8266WiFi](https://github.com/esp8266/Arduino/tree/master/libraries/ESP8266WiFi) library, which includes a solution for reading in CA certificates during the `setup()` in the examples.

Other examples, such as the [`ServerClientCert`](https://github.com/esp8266/Arduino/blob/master/libraries/ESP8266WiFi/examples/BearSSL_ServerClientCert/BearSSL_ServerClientCert.ino) simply store the certificates as character arrays in the source code.

A PoC for BearSSL is provided [here](https://github.com/tsi-software/Secure_ESP8266_MQTT_poc), which includes full secure MQTT setup.

**NB:** The ESP8266 is its own WiFi hardware chip, and thus these solutions will not work with the Arduino Nano 33 IoT's u-blox NINA-W102. I've included them just for posterity, and maybe a little inspiration, if nothing else.

### Ameba IoT devices
https://www.instructables.com/id/Arduino-Using-AWS-IoT-Serivce/

### mbedTLS
https://tls.mbed.org/discussions/generic/mbedtls-configuration-for-google-iot


### WiP links
https://forum.arduino.cc/index.php?topic=608492.0

https://forum.arduino.cc/index.php?topic=526033.0 final tmp2k post

https://www.savjee.be/2019/07/connect-esp32-to-aws-iot-with-arduino-code/

http://www.iotsharing.com/2017/08/how-to-use-esp32-mqtts-with-mqtts-mosquitto-broker-tls-ssl.html i wanna get an esp32