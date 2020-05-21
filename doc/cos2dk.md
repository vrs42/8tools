**cos2dk** converts packed "cos" images to .dsk images.

The input bytes are packed.  Each sector is 128 (RX01)
or 256 (RX02) bytes.  There are 77 tracks and
26 sectors/track.

This gives a size of 128*77*26 = 256256 bytes
for RX01, and 512512 bytes for RX02.

The RX8E (in 8 bit mode) just reads the 128
byte sectors.  This means a 256 word block
requires 3 sectors.

COS floppies are encoded with each of the
3 sectors containing a byte of the 3 byte
encoding of a double word.  We have to
Read all three sectors, then swizzle the
bits to reassemble the 256 words of a
block, which we can then output.

Track 0 is not used, so 76*26/3 gives a
capacity of 658 blocks.

Known data points:
* Block 0 is sectors 1, 4, and 7.
* Block 1 is sectors 10, 13, and 16.

.cos format is considered weird enough to have it's
own extension.  (It's incomprehensible without 
foreknowledge of the format.)

Multiple .cos files can be listed on the command
line, and multiple .dsk files will be (over)written.
