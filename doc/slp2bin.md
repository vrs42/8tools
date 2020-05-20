slp2bin converts SLURP (.slp) files to BIN (.bin).

Given the names of the input and output files, the input
is read and interpreted as a SLURP format binary file
from P?S/8.  A corresponding BIN format file is written
to the specified output.

Since essentially all bit patterns are valid for SLURP
format, there is no format checking.

The BIN output file will have 64 characters (6.4 inches)
of leader, correctly formatted BIN content, a valid
checksum, then 64 characters of trailer.

Translating things that aren't really SLURP files will
likely generate short, sometimes trivial, BIN output
files.
