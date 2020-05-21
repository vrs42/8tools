**pdfcmp** compares PDF files, ignoring CreationDate.

Given two PDF file names, are their contents the
same, apart from the CreationDate?

The files are compared line by line, skipping
the remaining content of lines which begin with
'CreationDate' in both files.

Errors are reported if lines in the first file 
don't match the second, or if the second file is
found to have more lines than the first.
