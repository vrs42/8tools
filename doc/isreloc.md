isreloc checks relocatable tapes used by LOADER and LIBSET.

Given a single file name as argument, that file is opened
and checked for valid relocatable format.

Relocatable tapes should have leader, followed by a list
of information blocks terminated by a checksum block.

Information blocks are two tape bytes; the high 4 bits of
the first contain the block type, and the low four bits
combine with the next byte to form a 12 bit word.  This is
the file format typically output by SABR.

The OS/8 Language Reference Manual describes the format on
pages 6-38 through 6-41 of the SABR description.
