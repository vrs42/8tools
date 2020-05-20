sv2sd outputs the code from a .sv to P?S/8 .sd format.

Given the name of a .sv file, write a corresponding .sd
file containing the code segments in the order expected
bu P?S/8.

P?S/8 system DIRECTory files contain the executable code
for the basic utilities and services that the system 
provides.

During the build process, P?S/8 assembles and links these
utilities into .sv files, which are contrived to load
entire 4K segments at a time.  The build process places
these .sv files on a scratch volume in a specific order,
such that the destination block address of every code
segment is known.

A series of "dd" like commands are then run, extracting 
this code from the OS/8 scratch volume and writing it
to the P?S/8 bootable media.

This utility partially mimics this behavior, copying
instead a single .sv file to an output file in which
the code offsets are known.
