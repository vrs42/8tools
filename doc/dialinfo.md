**dialinfo** outputs information about LAP6 or DIAL binaries.

Given the names of a files on the command line,
the files named "*.bd" are opened and the binary
file header information is printed.

The output reports on whether the binary will halt
after loading or begin execution.  If the latter,
the location and mode (PDP or LINC) of the starting
address is reported.

In addition, the loader memory map is displayed,
listing the load address of each block to be loaded.
