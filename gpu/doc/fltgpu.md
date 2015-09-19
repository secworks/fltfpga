FLTGPU
======
## Introduction ##
The fltfpga GPU is still in very, very early stages. Nothing is really
started yet. The inspiration is the graphics processing in the C64 and
the Amiga. But some of the ideas I'm considering are:

- Focused on 2D manipulation.
- Chunky pixels.
- Internal double buffering
- Exposed raster beam with triggers to allow for raster tricks
- Many sprites with fixed draw ordering
- Separate text overlay channel (i.e. graphics, sprites and overlay)
- Something like 1024x768 for fairly high resolution
- 24 bits color depth.
- Blitter and copper like functionality for fast movement with
  manipulation independent from the CPU.
- A high degree of functionality exposed to the CPU for manipulation. If
  something goes out of whack, it was probbaly intended anyway.

This needs to be clarified. A lot.
