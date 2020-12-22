**toepic** creates file images for use with EPIC.SV. 

Given an OS/8 compatible file name and a target file 
name as arguments, the OS/8 file is converted to EPIC
format and written to the target file.

EPIC writes files with a even parity for each word,
in 8 word segments.  Each pair of words is output
as three bytes, and all 8 are followed by the parity
byte.

This content is prepended by a byte of 0201, followed
by the file version of EPIC, name, extension, block
number, size and a zero word.  Followed of course by 
a parity byte.

Every 041 segments form a 0400 word OS/8 block, and
are followed by two bytes of CRC.  The CRC is in
turn followed by at least one frame of leader/trailer
if more data follows; otherwise by a <DEL>.

The current implementation restricts the OS/8 file name
to be in 6.2 format (of course), but also restricts
the character set for filename and extensiont to
alphanumeric or underscore.
