**tssfcl** outputs the text of a TSS/8 FOCAL format file.

The arguments are processed, and if they are in the TSS/8
format for FOCAL source code, the source is extracted and output.

The "-q" option toggles "quiet" operation, in which the
source is not output, but the file is still checked
for FOCAL source format.

Regardless of the "-q" status, zero exit status is returned
if all the supplied arguments are in fact FOCAL source files.
