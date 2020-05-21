**3p2dk** converts triple packed images to .dsk format.

"Triple-packed" packed floppies just pack 2 words 
into 3 bytes.  3p2dk unpacks the 3 bytes into two
words, effecting the translation from triple packed
floppy to "dsk" format.

Note that the bit ordering is *not* the OS/8 bit
order.

This does not compensate for interleave, etc., so
if your triple-packed floppy is also interleaved, 
you will need to do more.
