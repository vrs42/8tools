cksum is used to check the BIN checksum in .od files.

This utility examines the directories listed on the command
line and all their sub-directories, looking for directories
named "[Oo][Kk]" (case insensitive).

The current working directory and the "ok" directories
found above are scanned for .od files.

Each *.od file is checked to see if it would contain BIN
segments when converted by the mktapes utility.  BIN
segments, when found, are checked for checksum and format.

Files named *-pm.od are presumed known to be in RIM format,
and are skipped.

Files named *-pb.od or *-ba.od are presumed known to be
in BIN format, and are scanned, but do not warn when a
valid binary segment is found..

This script was useful for reporting hidden gold and/or
errors in large collections of paper tape images which 
were read from paper tape and/or found online.

This script has a lot of "dead" code that doesn't 
prevent it's working, but wastes time and obscures what
is going on.  Presumably this code is useful when
re-enabled, to perform other kinds of searches.
