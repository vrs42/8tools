bincmp compares the contents of two .bin files

Each argument will be loaded into an array, checking 
for valid format and checksums.  Then, a side-by-side 
listing of the differences, sorted by address, will
be output.  A value of "XXXX" will be reported for
locations which were not loaded in one or the other
image.

Like most utilities using BIN format, DTORG directives
are not recognised.

An effort is made to also recognise Fortran II tapes,
which use format similar to .bin.
