FLTSPU
======
## Introduction ##
The fltfpga Sound Processing Unit (SPU) is a sound engine capable of
generating fairly high quality stereo sound. Or at least will be when
implemented. But some of the ideas I'm considering are:

- 2 x 4 (or 8 or 16) sample voicess. Each with independent volume and
  possible filter. Filters possible with resonance.
- Master volume and filter with resonance for each stereo channel.
- Each sample voice can have different play rate, start, stop. Play
  forward or backward.
- Each voice has its separate sample buffer of 16, 32, 64 ksamples.
- Some sort of mutating state of samples, like Karplus Strong,
- Sync of channels.
- 44.1 kHz with 16 bits DAC.
- Possibly some other synthesis methods that are easy to implement.
  FM synthesis?

More ideas are needed.  This needs to be clarified. A lot.
