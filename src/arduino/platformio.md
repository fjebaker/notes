# PlatformIO notes
Notes for using the PlatformIO CLI.

<!--BEGIN TOC-->
## Table of Contents
1. [Getting started](#toc-sub-tag-2)
2. [Serial communication](#toc-sub-tag-3)
	1. [USB device debugging on OSX](#toc-sub-tag-4)
3. [Distribution](#toc-sub-tag-5)
	1. [Specifying dependencies](#toc-sub-tag-6)
	2. [Unit testing](#toc-sub-tag-7)
	3. [Build flags](#toc-sub-tag-8)
<!--END TOC-->

### Configuring PlatformIO <a name="toc-sub-tag-0"></a>
I will probably end up making another document on using PlatformIO, but for the sake of getting started, PlatformIO may be installed with

- **OSX**: 
```bash
brew install platformio
```
- **Linux**: 
```bash
sudo python -c "$(curl -fsSL https://raw.githubusercontent.com/platformio/platformio/develop/scripts/get-platformio.py)"
```

### Packages for a project <a name="toc-sub-tag-1"></a>
You can install dependencies using
```bash
platformio lib install "Name"
```

## Getting started <a name="toc-sub-tag-2"></a>
All of the supported micro-controller boards can be listed using
```bash
platformio boards
```
Narrowing the search options, to find, e.g. the Atmel AVR MCUs, can be achieved with
```bash
platform boards atmelavr
```

I'm using the Elegoo Uno MC, so will use the appropriate configuration
```
uno                          ATMEGA328P     16MHz        31.50KB   2KB     Arduino Uno
```
The appropriate development environment is then created using
```bash
mkdir dev-env
cd dev-env
platformio init --board uno 
```
Note that more than one board can be specified, by using additional `--board` flags. The output of the `init` command initializes the environment

```
The current working directory /Users/minerva/Developer/MCU/uno-test will be used for the project.

The next files/directories have been created in /Users/minerva/Developer/MCU/uno-test
include - Put project header files here
lib - Put here project specific (private) libraries
src - Put project source files here
platformio.ini - Project Configuration File
```

Next we create `src/main.cpp`, and include our MCU source code to be flashed to the unit.

```bash
platformio run -t upload
```
PlatformIO comes with multiple different target and environment flags

- `platformio run`: Process all environments specified in `platformio.ini`
- `platformio run -t upload`: Build project and upload firmware to the devices
- `platformio run -t clean`: Clean project (delete compiled objects)
- `platformio run -e uno`: Process only the `uno` environment

## Serial communication <a name="toc-sub-tag-3"></a>
Serial communication with the MCU device is packaged into PlatformIO. We can monitor the MCU with
```bash
platformio device monitor -b [baudrate]
```

### USB device debugging on OSX <a name="toc-sub-tag-4"></a>
It can be a little bit tentative sometimes to discover the right USB port on OSX. The command
```bash
system_profiler SPUSBDataType
```
will help indicate whether your device is discoverable or not. From experience, unplugging and pluggin the device back in can help a lot. Another useful thing to monitor are the 
```bash
ls /dev/tty*
ls /dev/cu.*
```
outputs.

## Distribution <a name="toc-sub-tag-5"></a>
PlatformIO can also act as a distribution tool if the environments are correctly defined.

### Specifying dependencies <a name="toc-sub-tag-6"></a>
We can specify the dependencies for a specific environment, e.g. `[env:uno]` with
```
lib_deps =
  arduino
  SomePackageName
```
or for all environments under the `[common_env_data]` section. Dependencies are automatically installed when the environment is run.

More information can be seen here in the [PlatformIO Docs](https://docs.platformio.org/en/latest/projectconf/index.html).

### Unit testing <a name="toc-sub-tag-7"></a>
TODO

### Build flags <a name="toc-sub-tag-8"></a>
TODO