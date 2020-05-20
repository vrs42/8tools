dt2dk convert SIMH dectape images to .dsk format.

This essentially just removes the extra 129th 
word of each DECtape block.

A list of DECTape images to be converted may be supplied on
the command line.  Extensions .tu55, .tu56, and .dta will be
removed, then .dsk will be added to form the name of each
output file.  (Existing files will be over-written.)
