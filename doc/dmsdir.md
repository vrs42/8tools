**dmsdir** prints a directory listing of a DMS image.

For media in the standard DF32 .dsk format or DECtape .tu56 format,
this tool will list the DMS directory.

The directory is written to the standard output.  Each
volume name is followed by a report of the free blocks available,
the version, and a header for the file info.  Each file name is
followed by the type/extension, the number of blocks allocated to
the file, the internal file identifier, and the loading and starting
addresses.

BUG: The listing is not sorted by filename.
