**dialimplode** creats a LAP6/DIAL volume from it's constituent files.

Command line is 
dialimplode directory file [blocks]

Directory is directory containing files to make volume from. Should follow
   dialxplode conventions.
file is file that volume should be written to.
blocks is number of tape blocks the volume should have. Only valid for
   dial volumes.

If directory contains a .config file LAP6 format is used. See dialxplode
documentation for format.

If directory contains a .order file the files will be added to
the index in the order they appear in the .order file. This will
allocate file in increasing distance from the index. Any files found
not in the .order file will be added after the files in the .order file.

Files starting with '..' are converted to LAP6/DIAL deleted
files starting with '//'.

System areas files starting with . are copied to the proper location
in the volume.

.index file is not used since new index created.

For LAP6 .unused1 and .unused2 are not copied to the volume.
