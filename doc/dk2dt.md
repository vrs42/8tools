**dk2dt** converts .dsk format to SIMH DECtape format.

This essentially just adds the extra 129th 
word of each DECtape block.

A list of .dsk images to be converted may be supplied on
the command line.  Extensions of .dsk will be removed,
then .dt will be added to form the name of each
output file.  (Existing files will be over-written.)
