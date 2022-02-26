**m43rk** converts packed "M43" images to .rk05 images.

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

The .rk05 file output has the 12 bit words extracted, as needed
for SIMH, and the other 8tools.  It also elides the unused 16 blocks
from each half of the disk, saving only the RK05-style file-system
areas.  Since there is no SIMH support for the System Industries
hardware, this allows the .rk05 file to be mounted and the files
accessed.  The .rk05 will not be bootable, however, as it still
has the system head of the original System Industries pack.

The output .rk05 files are also acceptable to os8dir and os8xplode.

.m43 format is considered weird enough to have it's
own extension.  (It's incomprehensible without 
foreknowledge of the format.)

Multiple .m43 files can be listed on the command
line, and multiple .rk05 files will be (over)written.
