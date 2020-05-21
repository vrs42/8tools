**sv2od** dumps the contents of a packed .sv file.

This weird little command reads a list of .sv files
of the sort that might be created with os8xplode,
and outputs on standard output the octal dump of an
equivalent BIN format tape.

For each input file on the command line, extensions
of .dg, -dg, .sv or -sv are changed to "-pb.od" to 
form the corresponding output file name.

Existing files whose names match output file names
will *not* be over-written.

Output files are suitable for input to the mktapes
utility.
