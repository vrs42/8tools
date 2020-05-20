mkdsk remakes media images from their .xml descriptions.

An XML description created by os8xplode or os8implode is
used to recreate the volume image from it's constituent
files.

See also: os8xplode, os8implode

No particular effort is made to accept free format XML.

OS/8 directory structures are created as described in 
the XML files listed on the command line.  In addition, 
files as indicate that lie outside the directory structures
will be (over)written in the resulting .dsk file.

Files recognized as text will be converted (parity bits
set, ^Z at end of file, padded to block boundary).
Files not recognized as text must be a multiple of the 
block size (384 bytes) long, and will be copied as-is.
Files not named in a directory are presumed to be binary.

The exception is that empty areas (no semantic content)
will not be written.

OS/8 system volumes are recognized, and the various "dot"
files representing the reserved areas must exist.

tss8xplode and pqs8xplode XML files are not yet supported.
