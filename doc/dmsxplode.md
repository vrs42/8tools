**dmsxplode** breaks a DMS volume into it's constituent files.

Given the name of a DMS volume on the command line,
it is opened and inspected for DMS content.  If found,
the system areas and the various files of the directory are
extracted.

The output directory name is derived by removing the ".dsk" or
".dms" extension, if any, from the input file name, and adding ".0".

Text files are converted from sixbit format to ASCII.
Binary files are written as one word every two bytes,
similar to the .dsk format.

BUG: No XML instructions for the reconstruction of the
volume with mkdsk are generated.
