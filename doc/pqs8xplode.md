























































**pqs8xplode** breaks a P?S/8 volume into it's constituent files.

Given the name of a P?S/8 volume on the command line,
it is opened and inspected for P?S/8 content.  If found,
the various files of the DIRECTory and the CATalog are
extracted.

The output directory name is derived by removing the ".dsk"
extension, if any, from the input file name, and adding ".0".

Deleted CATalog files in P?S/8 have the first two characters
of their names over-written with '??'.  To prevent name
collisions, these file names have their starting block
number added as a suffix.

Files in the CATalog may be text files, in which case they
are converted from the packed sixbit format to ASCII, and 
written with their line numbers.  Files without valid
line numbers are presumed binary, and written as packed
data 3 bytes for every 2 words, in the usual OS/8 bit
order.

Files extracted from the system DIRECTory are contain
executable code, and so are treated as binary.  A .sd
suffix is appended to note that they are not from the
CATalog.

BUG: File names are still shouted (uppercase).

BUG: Modification times and dates are not preserved.

BUG: The system areas are not yet extracted and saved.

BUG: No XML instructions for the reconstruction of the
volume are generated.