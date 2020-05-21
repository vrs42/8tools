**os8xplode** breaks an OS/8 volume into it's constituent files.

OS/8 media may contain one or more file-systems, each with
it's own directory and optional system areas.

This utility attempts to extract the content from these 
file-systems, writing each to a directory on the host
system.  Files which should were not indexed in the OS/8
directory are assigned names with a leading ".".  (On
some systems, this conveniently means the they do not
clutter the default directory listings.)

Each command line argument should be the name of a volume
in .dsk format.  For each such volume, a .xml file will be
written describing the volume in sufficient detail to
recreate it.  In addition, for each file-system found in
the volume, a directory will be created and populated
with the files from that file-system.  Such directories
are numbered starting with ".0".

All files are output in as three bytes for every two words.
The bytes have the OS/8 bit ordering, so that byte oriented
data just naturally ends up as bytes in the result.  This
means that each 256 word block ends up as 384 bytes in the
created files.

An elaborate (but silly) scheme is used to decide between
binary files, which are output packed but otherwise
unchanged, and text files, which are rewritten for the
host environment.

Currently, files are treated as binary unless their name
includes a .bi, .fc, .ft, .hl, .ls, .ma, .pa, .ps, .ra,
.sb, .te, .tx, or .wu extension.  This does *not* exactly 
match the rule used in the os8implode utility, leading to
possibly questionable treatment for some files.

The treatment for files deemed to be text is to mask off
the parity bit, and to stop at the first ^Z, discarding
the remainder of the bytes in the file.  This treatment
effectively converts most files to "DOS mode" ASCII files
(seven bit characters with CR-LF line endings).

A warning is printed if a block is found in the media
image but not accounted for in the resulting .xml.

Currently, COS images are supported in addition to OS/8.
Other operating systems will likely require their own
similar tools.

BUG: Date conversion and modify times are basically
nonsense.  OS/8 cannot represent a modern date, nor 
even unambiguously represent a vintage date.  A message
is printed stating which date era was used, FWIW.

BUG: File system length inference is buggy.  OS/8 prior
to the RL01/RL02 used equal length partitions, but the
RL02 doesn't.  In addition, images not actually extracted
from vintage media don't necessarily have the correct
size, as reported by stat().
