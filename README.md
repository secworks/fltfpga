fltfpga
=======

FairLight FPGA demo board based on TerasIC G5C.

## Introduction ##
This project contains FPGA constraint files as well as RTL code to
enable use of the HDMI video and AC97 audio interfaces om ther TerasIC
FPGA development board. The purpose of this is to be able to implement
cool demo effects in HW for the benefit of entertainment.

The fltfpga system will contain a CPU a GPU, a DSP/sound engine and a
few peripherals as needed to implement cool demos.

The CPU, GPU and the rest of the system are developed separately, but
are all part of the repo.


## System Description ##

The following components will probably be needed
- CPU. Executing code as needed to control all other components, do
  processing etc. [Read more about the CPU here.](cpu/doc/fltcpu.md)

- GPU. Something like the GFX sub system in the Amiga and the
  C64. Support for 1024x768 with double buffering. Simple macro based
  (copper list) DMA functionality for fast movement. At least 64
  sprites. Text mode overlay. Raster counter to allow CPU to play around
  with effects.

- DSP/Sound. 16-32 voices with sample and synthesis based sound. Mixing
  and master volune. Filters. With sweeps.

- Timers and IRQ.

- External interface. At least a UART for external communication.

The CPU talks to the other parts as master-slaves. The GPU and DSP are
expected to have their own memories which they control, albeit they are
(might be) mapped into the CPU address space. This means that the CPU
will be able to read and write into the screen memory not being dispayed.


## Implementation details ##
The development board we are targeting:
http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=830

The development board provides High Performance HDMI Transmitter via the
Analog Devices ADV7513 which incorporates HDMI v1.4 features, including
3D video support, and 165 MHz supports all video formats up to 1080p and
UXGA. The ADV7513 is controlled via a serial I2C bus. Info about the
chip:

- http://www.analog.com/en/audiovideo-products/analoghdmidvi-interfaces/adv7513/products/product.html


The board provides high-quality 24-bit audio via the Analog Devices
SSM2603 audio CODEC (Encoder/Decoder). This chip supports microphone-in,
line-in, and line-out ports, with a sample rate adjustable from 8 kHz to
96 kHz. The SSM2603 is controlled via a serial I2C bus interface, which
is connected to pins on the Cyclone V GX FPGA. Info about the chip:

- http://www.analog.com/en/audiovideo-products/audio-codecs/ssm2603/products/product.html



## Status ##
*** (2015-09-07) ***

Started writing API for the CPU. The target right now is a simple 32-bit
CPU with shared code and data memory designed to allow self modifying
code and other fun things. The design is influenced by MIPS R3000 as
well as MOS 6502 and other CPUs. A bastard basically.

Not sure that the design will be using the HDMI and AC97/Audio interface
on the board, but instead use a simpler design with basically a VGA or
DVI output chip and a simpler sound chip that just includes DAC and
linear amplifier.


*** (2014-04-30) ***

Project has just been started.
