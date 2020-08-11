**cbl2bin** converts CBL format to BIN format.

A single file name on the command line is interpreted as a CBL
or XCB file, depending on the file name (XCB files must use the
extension .xcb).  The BIN format equivalent is written to the
standard output.

CBL is the format used in decus-5,8-26[a-d] to compress binary
tapes by approximately 25%.

CBL tapes consist of one or more blocks, each marked with an
initial NUL byte.  After the NUL byte, an XCB tape has an extra
byte which encodes the data field, which is not present in the
basic CBL format.

Each block consists of a set of frames, each consisting of 3 bytes.
The first frame of the block is heraled with with a NUL (possibly
followed by the field, if this is XCB format).  Neither the NUL or
the field setting is taken to be a part of the frame being assembled.
(The field is always implicitly zero in CBL format.)
Each frame is assembled into a doubleword thus:
   Bytes	Words
   --------	------------
   abcdefgh	abcdefghmnop
   ijklmnop	ijklqrstuvwx
   qrstuvwx

The two words are then interpreted as:
location, length (first frame)
   The length is encoded in two's complement form in bits 3-11 of word2.
   (Bits 0-2 of word2 are ignored.)  A length of zero indicates the end
   of the file.
Data1, Data2
   One or more data frames, containing data to be loaded into successive
   locations starting where specified above.  Odd numbered lengths mean
   that word2 is ignored for the last data frame.
Checksum1, Checksum2 (last frame)
   As words are assembled, they are added to a 12 bit block checksum.
   Carries out of this sum are added back in.  This sum is expected to
   equal 7777 after the last frame is read if all the data was read
   correctly.

In practice, only one word of checksum is required, and the second
word is set to 0000.

While any non-zero byte will do for leader-trailer, in practice 0200
was used, and a few (4) frames of leader-trailer seperated each block.

Blocks consisting entirely of NUL bytes form blocks that indicate EOF.
This means that NUL bytes also made an ideal trailer.
