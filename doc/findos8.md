**findos8** attempts to find an OS/8 directory in a media image.

Floppies, in particular, use a huge variety of encoding
schemes to convert the words of OS/8 blocks into bytes
on the media.

This tool tries various bit ordering schemes to attempt
to recognize the first six words that herald the beginning
of an OS/8 directory.

It is typical that two words are packed together.  If the 
two words are aaaaaaaaaaaa and bbbbbbbbbbbb, they are often
stored as
* 0000aaaa aaaaaaaa 0000bbbb bbbbbbbb	Usual format
* aaaabbbb aaaaaaaa bbbbbbbb         	"3P" format 
* aaaaaaaa aaaabbbb bbbbbbbb         	"rx8e" format 
* aaaaaaaa bbbbbbbb aaaabbbb         	"os8" format 

Since interleave is also an issue, we examine every sector.
This still isn't good enough to recognize things like COS 
media, which spread the bits of a single word across more 
than one sector.

We also presume that OS/8 blocks will always start on a
sector boundary.

A sector is reported as the possible directory header if
* The negative number of entries in the segment is negative, but > -35.
* The number of additional information words is 0 or 07777.
Each such sector will be reported, displaying the number of
segments, sector number, number of additional information
words, and the format used for the decoding.

Each media image named on the command line is processed in 
turn.
