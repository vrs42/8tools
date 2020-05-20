binview dumps a .bin file in a human readable octal format.

Given the name of a BIN format file, the file is checked for
validity, while at the same time being written to standard
output in a human readable octal format similar to one that
was popular back in the day.

Field settings just print "FIELD n".  Location settings
print as an address followed by a ')'.  Data is printed
followed by a space.

An extra location setting, followed by '/' instead of ')'
is printed when the current address is evenly divisible
by 16(020).  This is done at the start of a new line, and
helps keep the result human readable.
