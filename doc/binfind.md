**binfind** looks for -pb, .bin, or .bn files with similar content.

Arguments are taken to be the names of files or directories to be
scanned.  Directories are scanned recursively, looking for additional
files whose names suggest BIN content (as above).  Sub-directories
whose names start with "." are skipped.

Each file is read (and checked) in BIN format.  The words
loaded are summed to form a hash token for that file.
Files with the same hash token are listed, as there is a
significant probablility that they are the same, or at
least related.

Like most utilities using BIN format, DTORG directives
are not recognized.
