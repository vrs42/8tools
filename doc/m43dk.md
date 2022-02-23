**m43dk** converts packed "M43" images to .dsk images.

M43 images are produced by imaging System Industries
3040-4043 disks and preparing the images for the
Vandermark PDP-8/E simulator.

The System Industries drive are similar to an RK05 (and
are typically treated by OS/8 much as if they were RK05).

There are two sections of 06300 blocks per drive, and each
block is prefaced by 33 bytes which are used in the simulator
to allow the diagnostics to run correctly.  The remaining 384
bytes per block pack two 12 bit words into a 24 bit word, then
unpack that into three bytes.  (Both are done MSB-first.)

The .dsk file output has the 12 bit words extracted, as needed
for SIMH, and the other 8tools.  Since there is no SIMH support
for the System Industries hardware, however, the result is not
mountable there without additional work.

The OS/8 driver for the SI drive interfaces to the first 06260
blocks of the 06300, leaving the remaining 16 blocks unaccessible.
This means, in principle, we could elide these blocks and create
a .dsk file which could be attached as an RK05 volume.  (The OS/8
drivers would be wrong, so the result would not be bootable.)
This was NOT done, so the second partition will be rubbish to
SIMH.  The output .dsk files are acceptable to os8dir and
os8xplode, however.

.m43 format is considered weird enough to have it's
own extension.  (It's incomprehensible without 
foreknowledge of the format.)

Multiple .m43 files can be listed on the command
line, and multiple .dsk files will be (over)written.
