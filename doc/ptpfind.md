**ptpfind** looks for paper tape images with similar content.

Arguments are taken to be the names of files or directories to be
scanned.  Directories are scanned recursively, looking for additional
files.  Sub-directories whose names start with "." are skipped.

Each file is read as if it were a paper taple.  That is,
bytes with values of 0000 and 0200 are ignored, and a value
of 0232 terminates the "tape".

Bytes not ignored are summed to form a hash token for that
file.  Files with the same hash token are listed, as there
is a significant probablility that they are the same, or at
least related.
