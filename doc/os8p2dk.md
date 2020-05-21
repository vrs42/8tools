**os8p2dk** converts packed "os8p" to .dsk format.

In "os8p" media, the bytes are packed.  Each sector
is 128 (RX01) or 256 (RX02) bytes.  There are 77
tracks and 26 sectors/track.

This gives a size of 128*77*26 = 256256 bytes 
for RX01, and 512512 bytes for RX02.

The RX8E (in 8 bit mode) just reads the 128
byte sectors.  This means a 256 word OS/8
block requires 3 sectors.

The bits and bytes are in the OS/8 order, and
all three sectors are logically consecutive.

Track 0 is not used, so 76*26/3 would give
a theoretical capacity of 658 blocks.

Note: 660 are reported in the DIR listings!
667 OS/8 blocks is the theoretical maximum
for an RX01 in 8-bit mode.  660 free  data
blocks is the maximum, since the directory
segments occupy blocks 1-6.

We work around this by offsetting track by 
1, then wrapping to use track 0 last.

Oddly, the tracks are in the right order (not
interleaved) except that track 0 is logically 
last.

For each .os8p file listed on the command line,
a corresponding .dsk file will be (over)written.
