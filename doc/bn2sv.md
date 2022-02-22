**bn2sv** converts .bn files to .sv format.

The first argument specifies an output file, which (to prevent accidental file
over-writing) must have extension ".sv".  Optional "=" and "%" modifiers will
set the starting address and JSW in the output file.  If the output file name
is missing (that is, the first doesn't start with ".sv"), the name "foo.sv"
is used.

Following the output file specification is a list of .bn or .bin format files.
Each is read and verified.  Their combined contents are then (over)written in
the .sv format output file.

This is similar in function to OS/8 ABSLDR.

Since the output is packed, it will always be a multiple
of 384 bytes (256 words) long.
