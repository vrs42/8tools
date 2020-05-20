pal is a PDP-8 cross-assembler

The argument is taken to be the name of a file to be
parsed as PDP-8 assembly code, to generate a binary
and a listing file.

Currently, the following options may precede the name
of the source file:
* -d	dump the symbol table at end of assembly
* -e	Define Omnibus-era only instructions
* -j	Do not pad TEXT or SIXBIT
* -l	do not warn about offpage references
* -r	produce output in rim format (default is bin format)

The following extensions are used when creating output files:
* .lst	assembly listing
* .bin	assembly output in DEC's bin format
* .rim	assembly output in DEC's rim format

The extension, if any, on the input file will be removed before
these extensions are added to create output files.

This is a decendant of Doug Jones' assembler, with many fixes and
features added over the years..
