indirect_test.pa makes literals on the 0400 page of field 0, then
does a bunch of other stuff, then returns to the 0400 page to create
another literal.  This isn't supported.  A cross assembler could
conceivably remember the old literals from the 0400 page of field 0,
but any native assembler would have forgotten them.  Perhaps better
than over-writing them (as the native assemblers would), we should
flag an error, since assembled code is unlikely to perform as expected.
