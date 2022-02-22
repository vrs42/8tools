**sv2sd** outputs the code from a .sv to P?S/8 .sd format.

Given the name of a .sv file, write a corresponding .sd
file containing the code segments in the order expected
by P?S/8.

P?S/8 system DIRECTory files contain the executable code
for the basic utilities and services that the system 
provides.

The ".sd" file format is intended as a container for a
file to be placed in the PQS8 system directory.  As such,
it contains the system directory entry, followed by the
actual code segments to implement the system utility.

The starting address is propogated from the ".sv" file,
unless over-ridden on the command line.  Various flags
are also accepted to manipulate the system directory
entry.
