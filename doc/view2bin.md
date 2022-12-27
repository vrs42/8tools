**view2bin** converts **binview** output back into BIN format files.

Given a list of .view files of the sort that might
be created by capturing the output of binview, this
outputs a .bin file for each one, containing a BIN
format file which, when loaded, re-creates the memory
image.

This allows one to create an octal dump of a BIN tape
with binview, edit it, and re-create a BIN tape image
of the result.

One frequent use is to remove cruft introduced byt the
lack of word level granularity in the .sav format.
One can run sv2bn, then binview, then edit the cruft
out of the result.

The program generally handles the output of binview,
though it is more tolerant of whitespace, mixed case,
etc.  One feature added, is that words whose contents
contain one or more "X" increment the location counter,
but do not load the corresponding location(s).  This
facilitates the use of the bitmaps in the listings to
quickly elide words that should not be loaded, without
having to add location settings, etc.
