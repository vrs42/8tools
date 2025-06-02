**swmissing** reports missing files for DECUS contributions.

The current directory is scanned for the various files
expected in the reconstruction of DECUS contributed
software from paper tapes.

Warnings are issued if there is no .lbl, neither -pb 
nor -pm, no corresponding .od, or no -d.pdf.

The presence of .bin, .pal, or .lst files also triggers
an expectation of the above files matching the base
name.
