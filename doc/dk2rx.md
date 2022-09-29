**dk2rx** converts .dsk format images to SIMH RX01 format.

The bytes are packed.  Each sector is 128 (RX01) 
or 256 (RX02) bytes.  There are 77 tracks and 
26 sectors/track.

This gives a size of 128*77*26 = 256256 bytes 
for RX01, and 512512 bytes for RX02.

The RX8E (in 12 bit mode) packs 64(128) 12 bit
words into the first 96(192) bytes of a sector,
then zeroes the last 32(64) bytes.

This means a 256 word OS/8 block requires 4(2)
sectors, 77*26/4(2) would give a theoretical 
capacity of 500(1000) blocks.

A list of .dsk files is expected on the command line.
Each is processed to (over)write a corresponding .rx0[12] file.
