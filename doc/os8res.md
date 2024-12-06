**os8res** prints the driver listing of an OS/8 image.

For media in the standard .dsk format, this tool will list information
about the drivers available in the (bootable) OS/8 image.

The information is written to the standard output, in a 
format meant to be similar to the OS/8 RES command.

If the exact device name cannot be reliably determined, a device name
with the same hash code is constructed and output with a trailing "hash" ("#).
