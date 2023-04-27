* PUTR DECtape Format *

The TSS/8 PUTR format is one of the more complicated and interesting formats
for PDP-8 media.

** The File **

The underlying DECtape media is essentially a linear array of 129 word blocks.

The TSS PUTR system uses 128 words for data, and the 129th word is used as a
"link", containing the block number of the "logically next" block.  At the
lowest level, this structure is used to organize the tape into linked chains,
each representing a "file".  Each such chain ends when the link points to
block 0.

BUGBUG: There is an assumption that the block lists are monotonic, or at
the very least that the lowest block number is logically first.  It is not
known how that requirement is maintained.

** File Allocation Table **

The File Allocation Table resides in the file that starts at block 0200.  It
describes which blocks belong to which file, as well as which blocks are free
to be used in the future.

Each 128 words (remember that word 129 links to the next block) describes 256
media blocks.  The low 6 bits of each word gives the "file id" of the file to
whhich the corresponding block belongs, describing 128 blocks.  Then the high
6 bits describes the next 128 blocks.  Following the link, we get to another
block, describing the next 256 blocks of the media, until all such blocks
have been described.  A "file id" of 000 implies the block is free for future
use.

Since the files are described in block order, the described files are
considered to start in the lowest numbered block which contains that file id.
Much of this data (except which block is first) is redundantly coded in the
link fields of each DECtape block.

** The Directory **

The Directory resides in the file which starts at block 0177.  Each directory
block consists of three overhead words, followed by 125 words of directory
entries (and of course a link word).

The overhead area of the first directory block contains 0000, 06463, 0200.
(The 06463 encodes "TS" in excess-32 sixbit.)  The overhead areas of other
blocks contain 0000, 0000, 0000.

That brings us to the directory entries.  Each block contains 125 words,
divided into 25 five word entries, each descibing a file.  Each directory
entry is laid out as follows:

1. The File Name is represented in excess-32 sixbit in three consecutive
   words.  Excess-32 sixbit means that 32 (040) is added to the sixbit
   character to reconstruct the ASCII character.  Thus 000 represents a
   space, 041 represents an "A", etc.  (The high 6 bits is considered to
   precede the low 6 bits.)  Three words imply that a file name can be
   at most six characters.  The name will be left justified and padded
   with 000 (space) to fill the three words.  A name beginning with a
   space represents an unused directory entry.

   The first directory entry of each directory is always for a file named
   "TS 8", with the following two words being 0000 0000.  This doesn't
   represent a real file, and should not be included or treated as one
   when directories are listed, etc.

2. The next word encodes a date in the standard TSS-8 format.  This
   calculates the TSS date as DATE = ((YEAR-1974)*12*(MONTH-1))*31+DAY-1.
   Notice that this is far from Y2K compliant, and dates beyond 04-JAN-85
   cannot be represented.  Some TSS systems opted to change the base year,
   so their PUTR tapes will generate misleading dates.

3. The last word of each directory entry encodes two values.  The high
   six bits encode the extension.
   BUGBUG: The extension encoding is not well understood.

   The low six bits are the file id, as discussed for the File Allocation
   Table above.  Note: 000 is not a valid file id.  When 000 is found,
   we use the number of the directory entry as the file id.

The directory continues for as many directory blocks as are required
to describe all 63 (077) possible file id values.  That is to say,
for 63/25 = 3 blocks.

** File Access **

To access a file, then, it is necessary to read the File Allocation Table,
retaining at least, the starting block for each file id.  Then, the file
can be looked up by name, the extension checked for the validity of the
intended action ("is it really a BASIC program?" etc.), and the first block
number identified from the file id.  Thereafter, each block can be retrieved,
giving 128 words of data and a link to the next block.

For random access, the File Allocation Table could be processed to create an
array of the block numbers associated with the file id, which would allow
direct access to the desired block without needing to read each intervening
block.
