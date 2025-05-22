**rkechk** checks an RKE file and a DSK file for equivalence

The arguments are the name of an RKE format file, then the name of
a corresponding DSK format file.

This utility checks the file header, per-track controller independent
data, and controller dependent data (header, CRC, postamble) from the
RKE file, then extracts the data. It then compares this data to the
data from the DSK file.

Issues with the RKE file are reported, as are any differences in the
data represented by the two files.
