**pxg2dt** converts PXG DECtape images to .dt format.

PXG format tapes essentially digitize TU56 head data for each tape
frame, eliminate the redundancy (and timing track), then record
the frames two to a bye, MSB first.

This essentially discards all but the frames containing data, then
reassembles the 12 bit words.  The most common format assembles 129
12 bit words from each DECtape block.

A list of DECTape images to be converted may be supplied on the
command line.  Extension .pxg, will be removed, then .dt will be
added to form the name of each output file.  (Existing files will
be over-written.)
