**dialxplode** breaks a LAP6/DIAL volume into it's constituent files.

Given the name of a LAP6 or DIAL volume on the command line,
it is opened and inspected for LAP6/DIAL content.  If found,
the various files of the directory are extracted.

The output directory name is derived by removing the ".dsk"
extension, if any, from the input file name, and adding ".0".

Deleted files in LAP6/DIAL have the first two characters
of their names over-written with '//'.  To prevent name
collisions, these characters are converted to '..'.  In
Linux and similar systems, these files won't appear in
the default directory listing.

Each file name in the directory may have a text file
and/or a binary file associated with it.  Text files
are converted from either the LAP6 or DIAL sixbit
format to ASCII, and written to a "filename.tx" file.
Binary files are written as one word every two bytes,
similar to the .dsk format.  Their file name will have
".bd" appended.

BUG: The directory is currently printed, making the
output quite verbose.

BUG: No XML instructions for the reconstruction of the
volume are generated.
