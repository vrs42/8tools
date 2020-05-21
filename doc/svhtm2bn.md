**svhtm2bn** converts saved HTML dumps of .sv files to .bn.

Some *.sv files are most easily found on the web, and
most easily saved to local disk by saving the web page.

Given a list of such dumps on the command line, this
utility reads the dumps, and converts a popular format 
for the saved .sv file dumps into BIN format files.

The input extension .htm, if any is stripped, then
the remaining .sv, if any, is replaced by .bn when
constructing the name of the output files.

Existing output files will not be over-written.

Note that the output file is a proper .bn format file, 
not a .od file.
