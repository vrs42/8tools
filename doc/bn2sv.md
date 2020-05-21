**bn2sv** converts .bn files to .sv format.

Given a list of .bn or .bin format files on the command
line, each is read and verified.  Their combined contents
are then written in .sv format as "foo.sv".

Since the output is packed, it will always be a multiple
of 384 bytes (256 words) long.
