fltfpga
=======

FairLight FPGA demo board based on TerasIC G5C.

## Introduction ##
This project contains FPGA constraint files as well as RTL code to
enable use of the HDMI video and AC97 audio interfaces om ther TerasIC
FPGA development board. The purpose of this is to be able to implement
cool demo effects in HW for the benefit of entertainment.


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
(2014-04-30)

Project has just been started.


