**tssasc** outputs the text of a TSS/8 ASC format file.

The arguments are processed, and if they are in the TSS/8
format for ASCII, the ASCII is extracted and output.

The "-q" option toggles "quiet" operation, in which the
ASCII output is not output, but the file is still checked
for ASC format.

Regardless of the "-q" status, zero exit status is returned
if all the supplied arguments are in fact in ASC format.

Nulls, with or without the parity bit set, are elided from
the output.
