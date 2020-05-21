**mktapes** reconstructs files from their dumps.

Given a directory as argument, or the current
directory as default, scan for *.od files.

For each .od file found, the original file is rebuilt 
from the dump.

Octal dump (.od) files contain a single octal byte 
per line of text, which is useful for visualizing
and processing paper tape data, and for fixing it
when necessary.

This utility takes a directory of updated .od files, 
and rebuilds the files to match the (possibly modified)
dumps.
