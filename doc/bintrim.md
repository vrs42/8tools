**bintrim** trims cruft from .bin files.

The bintrim utility is intended to take name(s) of
paper tape image file(s) as read by a paper tape
reader, and get quickly to cleaned up tape segments
that can be studied and/or loaded into simulators.

Given a list of files on the command line, each is
examined for segments that look like BIN format tape
segments.

Each such segment found is written to a corresponding
.od file.  Material before, between, or after segments
that look like BIN format is output instead to a
corresponding .lbl file.

The output file naming has been changed:
Previously, the first segment was written as .od; subsequent 
segments were written as .od2, etc.  Now, all output segments
are written as .od, with the segment number preceding the ".od".

Existing files will not be over-written.  All .od files are
written in the format expected by mktapes.

Warnings will be issued for BIN segments that have an 
incorrect checksum or format errors.

Non-existent input files and .od or files listed for
input are silently skipped.

Existing .lbl files will not be over-written.
