tss8xplode breaks a TSS/8 volume into it's constituent files

A single file name is expected on the command line.  This file
is opened and interpreted to contain a TSS file-system.  The
files for this file-system are extracted and written, as well
as the contents of system reserved areas.  In addition, a .xml 
file will be written with sufficient information to reconstruct 
the file-system.

The input file extension .dsk or .tss8, if any will be removed 
before .xml is added to create the file name for the XML file
which will be (over)written.

Output files are repacked from TSS/8 byte order to OS/8 byte
order, facilitating their subsequent processing by other tools.

Text files will have their parity bits stripped, and will be
terminated by the first ^Z.  Currently, only .asc, .lst, and 
.pal extensions are considered text.

The current effort to find the MFD will fail to find it if the
TSS/8 system had been built for less than 8 or more than 32 
users.

BUG: No corresponding implode utility yet exists.
