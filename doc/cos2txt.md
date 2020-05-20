cos2txt converts COS text files to ASCII

COS "text" files are actually stored in a packed,
6-bit representation, using an unconventional
character set.  In addition, each line of a .as
file has 12 bit integer length and line number
prepended.  Files of format .db are just a
string of 12 bit numbers.

This utility can be passed the name(s) of files
in these formats, and will output a corresponding 
.txt file for each.  Extensions .as and .db on
input files will be removed from the output files.

P?S/8 does something similar (yet different).
