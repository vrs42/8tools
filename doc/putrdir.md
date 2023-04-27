**putdir** outputs a directory of a TSS/8 PUTR DECtape.

A single filename is expected, as the name of the
image of the TSS/8 PUTR DECtape to be processed.

The files on the DECtape image are listed.  The files are
also named with an extension based on the file type, but
these types are not generally reliable.

If the optional "-e" option is specified, the files on the
DECtape image are also extracted to a series of files, as
named in the PUTR directory listing.  Consider using 8tools
tss<xxx> to identify the actual file type.

For each file, the file name (with extension), the file length,
the file id (used only within the PUTR image), the first block
of the DECtape which pertains to the file, and the file's date
are output.

Note that the PUTR format does not support the TSS/8 notions
of permissions and user id's.

For more information about PUTR DECtape media format, see
"putrdt.md" in the 8tools documentation.
