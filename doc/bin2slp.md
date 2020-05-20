bin2slp converts a .bin file to a SLURP (.slp) file.

Passed the name of the input and output files on the command
line, this program reads the first and checks it for valid
BIN format and checksum; while at the same time writing the
equivalent operations and data to the output file in SLURP
format.

DTORG, if any, is assumed to be of the proposed new form.
DTORG of the old form will be treated as a BIN format error.

SLURP format consists of 128 word blocks, which consist
of 7 word segments.  The first word of head segment controls
the disposition of the remaining six.  This control word is
made up of six two bit commands, starting with the MSB.  The 
commands are:
* 00  Data word to be stored.
* 01  EOF.  Stop processing further words.
* 10  Set the origin.
* 11  Use as a CDF instruction to set the field.

The two pad words at the end of each 128 word block will
be written with "SLRP" in sixbit (not required by SLRP
format).

The last block of the file will be padded additional EOF
commands until the block is full.
