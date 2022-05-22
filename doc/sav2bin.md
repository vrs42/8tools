**sav2bin** converts TSS8 .sav files into .svb files.

Given a list of .sav files of the sort that might
be created with tss8xplode, this outputs a .svb 
file for each one, containing a BIN format file 
which, when loaded, re-creates the memory image 
of the matching .sav.

Note that .sav files lack the word level granularity 
of the BIN format.  As a result, the .sav file
nearly always specifies contents for values not
needed by the original program.  This extra content
will be preserved in the BIN files created.

The load address is assumed to be location 0000.
