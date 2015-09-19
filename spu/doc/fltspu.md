FLTSPU
======
## Introduction ##
The fltfpga Sound Processing Unit (SPU) is a sound engine capable of
generating fairly high quality stereo sound. Or at least will be when
implemented. But some of the ideas I'm considering are:

- 2 x 4 sample voicess. Each with independent volume and possible
  filter.
- Master volume and filter for each stereo channel.
- Each sample voice can have different play rate, start, stop.
- Sync of channels.
- Some sort of mutating state, like Karplus Strong,
- 44.1 kHz with 16 bits DAC.

More ideas are needed.  This needs to be clarified. A lot.
