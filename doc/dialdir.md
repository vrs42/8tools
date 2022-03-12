**dialdir** prints a directory listing of a LAP6 or DIAL image.

For media in the standard .dsk format, this tool will
list the LAP6 or DIAL directory.

The directory is written to the standard output.  Each
file name is followed by the starting block number and
files size in blocks for each of the corresponding source
and binary files, if any.

The heading at the top identifies the volume as LAP6 or
DIAL, as appropriate.

BUG: The listing is not yet sorted by filename.
