**dialxplode** breaks a LAP6/DIAL volume into it's constituent files.

Given the name of a LAP6 or DIAL volume on the command line,
it is opened and inspected for LAP6/DIAL content.  If found,
the system areas and the various files of the directory are
extracted.

The output directory name is derived by removing the ".dsk"
extension, if any, from the input file name, and adding ".0".

Each file name in the directory may have a text file
and/or a binary file associated with it.  Text files
are converted from either the LAP6 or DIAL sixbit
format to ASCII, and written to a "filename.tx" file.
Binary files are written as one word every two bytes,
similar to the .dsk format.  LAP6 file name will have
".bN" appended, where N is the quarter into which the binary
is to be loaded. DIAL file name will have .bd appended.

In addition, a .order file is produced which documents lists
the files output sorted by their distance from the index.
This information should allow the files to be placed back
on physical media with performance similar to the original.

Deleted files in LAP6/DIAL have the first two characters
of their names over-written with '//'.  To prevent name
collisions, these characters are converted to '..'.  In
Linux and similar systems, these files won't appear in
the default directory listing.

System areas are also copied to output files with a single
dot prefix, so that they do not appear in the default
directory listing.

In addition, a .config file is written if the original
volume was LAP6. The seven octal values in the .config
file are the 9 bit beginning block numbers for:
1. The lower file area. (Currently always 0000.)
2. The first unused area, if any. (.unused1)
3. The FLAP6 system area. (.flap6)
4. The current manuscript (.manuscript).
5. The Index
6. The second unused area, if any (.unused2)
7. The upper file area. (Ends with block 0777.)
Since the particular instance of ".lap6" has these values
hard-coded, these values should facilitate re-assembly of
a working media image.

BUG: No XML instructions for the reconstruction of the
volume with mkdsk are generated.
