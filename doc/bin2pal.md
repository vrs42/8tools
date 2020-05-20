bin2pal is a rudimentary disassembler.

It takes a single argument, the name of a file
in .bin format.  This file will be disassembled,
and "foo.pal" will be (over)written with source
code that, when assembled, should result in a 
.bin that reconstructs the memory contents from
the original .bin.

The program will attempt to intuit the use of the 
FPP instructions, and the the common emulation 
packages that simulate them.

In general, the instructions recognised are the
"family of eight" subset of instructions which
are expected to work on all machines except the
8/S.
