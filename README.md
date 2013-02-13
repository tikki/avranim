#AVRAnim#

AVRAnim is a simple/sample project/toolset to display images on an array of LEDs via an ATmegaX (or any other means – it's quite generic).

It relies only on [AVRDUDE](http://www.nongnu.org/avrdude/), avr-gcc with [avr-libc](http://www.nongnu.org/avr-libc/), [Python](http://python.org/), [GNU Make](https://www.gnu.org/software/make/) and the Bourne shell.

##Project files##

###animation.h###
contains the animation class.

###bin2carray.py###
converts any input data to its C array representation.

###bmp2bin.py###
extracts one colour channel from a BMP and optionally reduces its range (e.g. 8 bit => 3 bit).

###clean.py###
removes/replaces unwanted characters in a string.

###main.cpp###
the main program.

###Make_frames_cpp.sh, Make_frames_h.sh#
create frames.cpp and frames.h respectively.

###Makefile###
the make file drives the whole compilation process – like makefiles always (pretend to) do.
This is also where the hardware configuration goes.

##Details/Tutorial##

The **Makefile** has two main targets, `all` and `flash`, where `all` builds the whole project and `flash` uploads the program to the microcontroller.  
There is also a `clean` target which removes all generated files, as usual.

###Makefile configuration###

In the first segment, **tool paths**, you tell the script where your tools (avrdude, avr-gcc, python, etc.) are located.

The second segment, **avrdude config**, specifies some values for your programmer.  
I'm using a cheap *DIAMEX USB ISP-Programmer Stick* and an *ATmega168A-PU*, so I built AVRDUDE with USB support and set the port `AVRDUDE_PORT` to /dev/cu.usbmodem – your device name will certainly differ from mine, also depending on your programmer.  
Both the programmer and the ATmega168 support the *STK500v2* programming protocol, so that's what I set prog id `AVRDUDE_PROG_ID` to.  
The part number `AVRDUDE_PARTNO` is just the name/type of microcontroller.  
All supported programmer types and part names are listed in the *avrdude.conf* file.  
You can also get a list of all supported programmer types by calling `avrdude -c .`.  
Or get a list of all supported parts by calling `avrdude -c stk500`.

The third and final segment of interest, **avr-gcc config**, deals with some more hardware dependents and the include path.  
`AVRGCC_MCU` tells the compiler what microcontroller you're using, this is essentially the same as `AVRDUDE_PROG_ID`. A list of all currently supported microcontrollers is available at http://www.nongnu.org/avr-libc/user-manual/.
The clock speed `AVRGCC_CLOCK` should be set to the desired clock speed you're running your microcontroller with. Note that this does not actually set/change the clock speed, it's just sets a precompiler constant (`F_CPU`) that can be used in your code.  
And finally, all your include paths go to `AVRGCC_INCLUDES`.

###What's happening?###

When **building** everything, the *Makefile* first looks for *.bmp* files in your source directory. It will extract *luminocity information* from these images and wrap them up in *C arrays* that are then accessible in your code by including a `frames.h` that will be generated. After this the build process goes on to create an *ELF binary* and convert it to an *Intel HEX* dump which can be used by your programmer.

When **flashing**, *AVRDUDE* is invoked with the set configuration and will upload the generated *Intel HEX* dump to your microcontroller.

###The code###

As you can see, the main function is pretty short – as it should be for a program as simple as this.  
I'm using a grid of 3 x 3 LEDs for this which are hooked up directly to the ATmega's pins *PD0-7* and *PB0*.  
`_frames` is an array of all exported frames available via `frames.h` and is of type `const uint8_t*[]`. We use this to access all our animation frames and instantiate an `Animation` object.  
The `Animation` class handles the loading of our frames and keeps the correct timings, but it does not know how to actually display the output; that's why we have to set a display function `displayFunction` which is of type `Animation::displayFunctionType`.  
Our *display function* (`render`) will be called each *display step* with a binary frame buffer that holds the information which LED to turn on (buffer field is `true`) or off (buffer field is `false`).  
To make it easier for myself to construct the `uint8_t` that `PORTD` will be set to, I defined a union `Pd` which reflects my pin connections with its memory layout; this way I don't have to manually shift around bits.

##The reason for this project##

I had quite a hard time to get a properly working toolchain up and running, because I didn't want to rely on any pre-compiled packages (AVRStudio, CrossPack, …).

So to make it easier for people trying to do the same in the future, here's a starting point.

##TODO##

- add infinite playback to `Animation::play` when setting `repeats` to 0.
- 
