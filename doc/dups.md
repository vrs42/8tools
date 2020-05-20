dups creates a list of identical file pairs

The dups command takes a list of directories, optionally
preceded by "-r".  Each directory is processed (recursively 
if "-r" was used) in search of file.  Each file discovered 
is noted, then all files will be compared to the other files 
which have the same size.

A database ("dups.db") is used to cache file sizes and sums, 
to minimize redundant effort to compare files.

Ad hoc rules are built in to skip certain files.  (Usually 
not an issue unless you are the author.)

Files with "difficult" names for the host file system,
such as those with embedded blanks in their name, are 
skipped, with a warning message to that effect.

The output file "vv.bat" will be (over)written with 
pairs of file names that are identical.

Since checksums are kept between runs, it is possible
that files could be reported incorrectly which are no 
longer the same as the checksum'ed version.  If this
is an issue, just remove "dups.db" between runs.
