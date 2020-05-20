isepic checks files created by EPIC.SV. 

Given a single file name as argument, that file is
checked for valid EPIC format.

EPIC writes files with a even parity for each word,
in 8 word segments.  Each pair of words is output
as three bytes followed by the parity byte.

This content is prepended by a byte of 0201, followed
by the file name, extension, block number, size and
an unknown (date?) word.

Every 041 segments form a 0400 word OS/8 block, and
are followed by two bytes of CRC.  The CRC is in
turn followed by at least one frame of leader/trailer
if more data follows; otherwise by a <DEL>.
