elabel looks for files with embedded tape labels

Given a list of files to be processed on the command
line, this script looks for files that start with
something like:
    digital
    MAINDEC-08-DHRKA-B-PB  4/19/73
    RK8E DISKLESS CONTROL TEST
    ^Z
followed by a valid BIN format image.

When such a file is found, a .lbl file is created
from the text before the ^Z, and the rest of the
file will be output to a -pb file and also in octal
to a -pb.od file.

Existing .lbl, -pb, and -pb.od files will not be
over-written.
