**rke2dsk** converts RKE format to .dsk (SIMH) format.

This utility removes the file header, per-track controller independent
data, and controller dependent data (header, CRC, postamble) from the
data to form a SIMH RK05 image.  It also repacks the data 4 bytes per
doubleword as expected by SIMH.

A list of .rke images to be converted may be supplied on
the command line.  Extensions of .rke will be removed,
then .dsk will be added to form the name of each
output file.  (Existing files will be over-written.)
