**os8dir** prints a directory listing of an OS/8 image.

For media in the standard .dsk format, this tool will
list the OS/8 directory that begins in block one.

If the volume is too large to be a single OS/8 file system,
it will be construed to be a number of equal sized units,
and a seperate directory will be printed for each.

The directory is written to the standard output, in a 
format meant to be similar to the OS/8 DIR command.
