bintrim trims cruft from .bin files.

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

The first segment will be written as .od; subsequent 
segments will be written as .od2, etc.  Existing files
will not be over-written.  All .od* files are written
in the format expected by mktapes (though all but the
first would have to be renamed to be recognised as .od
files).

Warnings will be issued for BIN segments that have an 
incorrect checksum or format errors.

Non-existant input files and .od or files listed for
input are silently skipped.

Existing .lbl files will not be over-written.
