**dsk2rke** converts .dsk format to RKE (emulator) format.

This utility adds the file header, per-track controller independent
data, and controller dependent data (header, CRC, postamble) to the
data from a SIMH RK05 image.  It also repacks the data 3 bytes per
doubleword in the RKE/RK8E bit order. The result is a file which
can be used with the George Wiley RK05 emulator (V2), in conjunction
with an RK8E controller.

A list of .dsk images to be converted may be supplied on
the command line.  Extensions of .dsk will be removed,
then .rke will be added to form the name of each
output file.  (Existing files will be over-written.)
