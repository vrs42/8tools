**sv2bn** converts a .sv file into a .bn file.

Given a list of .sv files of the sort that might
be created with os8xplode, this outputs a .svb 
file for each one, containing a BIN format file 
which, when loaded, re-creates the memory image 
of the matching .sv.

Note that .sv files lack the word level granularity 
of the BIN format.  As a result, the .sv file
nearly always specifies contents for values not
needed by the original program.  This extra content
will be preserved in the BIN files created.

The other information about starting address and 
co-operation with OS/8 (from the JSW) will also be
lost, as these cannot be represented in BIN format.

Existing files whose names match output file names
will *not* be over-written.