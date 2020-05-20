os8implode Composes an XML description of an OS/8 volume

A list of .xml files, or .[0-9] directories are provided
on the command line.  For each, a .new and .xml+ file 
are (over)written.

For each directory, an OS/8 file-system is described, listing
the relevant files in the OS/8 directory, and including system 
files outside the OS/8 directory as indicated.

Files considered relevant to the OS/8 directory are expected to
conform to the OS/8 "6.2" naming conventions.  As such, up to
six characters may precede a ".", and up to two characters may
follow the ".", if any.

File names must be lowercase (and will be monocased when the
OS/8 file-system is built by the mkdsk utility).  Files with
upper or mixed case will currently cause failure.

This allows you to work with .bin, .pal, etc. files, which will 
not be included, or with .bn, .pa, etc. files, which will.

Files with extension .sv, .lo,, .hi, .rl, and .bn are considered
binary.  Other files will be considered text (and converted
accordingly by the mkdsk utility).

The output OS/8 directory and files will be sorted alphabetically
by name.  This affects certain old versions of "advent.sv", which
were dependent on theirh position on the media to operate correctly.

A directory with a .kmon is expected to be a system directory, 
and required to have the other associated "dot" files.  These 
files will be destined for the system areas, and not included
in the constructed OS/8 directory.

NOTE: This only creates the XML assembly instructions for the
volume.  You will still need to run the mkdsk utility to create
(or update) the media image.
 
BUG: Currently requires exactly .0 and .1 to work.  Volumes
with only one directory, or more than two, will fail.
