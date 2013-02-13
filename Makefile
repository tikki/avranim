# tool paths

AVRDUDE_PATH    = avrdude
AVRAR_PATH      = avr/bin/avr-ar
AVROBJCOPY_PATH = avr/bin/avr-objcopy
AVROBJDUMP_PATH = avr/bin/avr-objdump
AVRSIZE_PATH    = avr/bin/avr-size
AVRGCC_PATH     = avr/bin/avr-gcc
AVRGPP_PATH     = avr/bin/avr-g++
PYTHON_PATH     = python

# avrdude config

AVRDUDE_PROG_ID = stk500v2
AVRDUDE_PARTNO  = atmega168
AVRDUDE_PORT    = /dev/cu.usbmodem1d1111
# AVRDUDE_FUSES   = -U hfuse:w:0xd9:m -U lfuse:w:0x24:m

AVRDUDE = $(AVRDUDE_PATH) -v -c $(AVRDUDE_PROG_ID) -p $(AVRDUDE_PARTNO) -P $(AVRDUDE_PORT)

# avr-gcc config

# AVRGCC_MCU: for available device ids see http://www.nongnu.org/avr-libc/user-manual/
AVRGCC_MCU      = $(AVRDUDE_PARTNO)
AVRGCC_CLOCK    = 1000000U
AVRGCC_INCLUDES = -Iavr/avr/include/

CTUNING = -ffunction-sections -fdata-sections -fpack-struct -fshort-enums -funsigned-bitfields
CPPTUNING = -fno-exceptions -ffunction-sections -fdata-sections -fpack-struct -fshort-enums -funsigned-bitfields

AVRGCC = $(AVRGCC_PATH) -Wall -Os -DF_CPU=$(AVRGCC_CLOCK) -mmcu=$(AVRGCC_MCU) $(AVRGCC_INCLUDES) $(CTUNING)
AVRGPP = $(AVRGPP_PATH) -Wall -Os -DF_CPU=$(AVRGCC_CLOCK) -mmcu=$(AVRGCC_MCU) $(AVRGCC_INCLUDES) $(CPPTUNING)

# project file

TARGET = main
FRAMES = frames

# make targets

all: $(TARGET).hex

.c.o:
	$(AVRGCC) -c $< -o $@

.cpp.o:
	$(AVRGPP) -c $< -o $@

.S.o:
	$(AVRGCC) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(AVRGCC) -S $< -o $@

flash: all
	$(AVRDUDE) -U flash:w:$(TARGET).hex:i

# setting fuses is potentially dangerous, so let's disable it for now until we know exactly what we do
# fuse:
# 	$(AVRDUDE) $(AVRDUDE_FUSES)

clean:
	rm -f $(TARGET).hex $(TARGET).elf $(TARGET).o $(FRAMES).h $(FRAMES).o $(FRAMES).cpp

# file targets:
$(TARGET).elf: images $(TARGET).o animation.h
	$(AVRGCC) -o $(TARGET).elf $(TARGET).o $(FRAMES).o

$(TARGET).hex: $(TARGET).elf
	rm -f $(TARGET).hex
	$(AVROBJCOPY_PATH) -j .text -j .data -O ihex $(TARGET).elf $(TARGET).hex
	$(AVRSIZE_PATH) --format=avr --mcu=$(AVRGCC_MCU) $(TARGET).elf
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

$(FRAMES).o: $(FRAMES).cpp $(FRAMES).h
	$(AVRGCC) -c $< -o $@

$(FRAMES).h:
	/bin/sh Make_frames_h.sh > $@

$(FRAMES).cpp:
	/bin/sh Make_frames_cpp.sh > $@

images: $(FRAMES).o

.PHONY: clean

# Targets for code debugging and analysis:
disasm:	$(TARGET).elf
	$(AVROBJDUMP_PATH) -d $(TARGET).elf

cpp:
	$(AVRGCC) -E $(TARGET).cpp
