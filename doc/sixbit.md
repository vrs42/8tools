**sixbit** outputs a file as sixbit text.

Given the name of a file on the command line,
the successive words are interpreted and output 
on the standard output as if they were sixbit
text.

The output is formatted as an octal dump of
the data with sixbit text to the right, as
might by output by the "od" utility, if it
had a sixbit option.

The input file is expected to be unpacked, as 
found in .dsk format files, or unpacked by the 
3to4 utility.
