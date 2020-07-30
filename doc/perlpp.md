**perlpp** is a simple pre-processor written in Perl.

Each argument must be of the form -D<sym>, where <sym>
will be considered defined during the preprocessing,
except the last, which is the name of the file to be
processed.  The supplied <sym> will be uppercased before
use.

Lines in the input may contain #define and #udef directives
to define or undefine additional symbols.  All #ifdef and
#ifndef directives, and their #else and #endif directives
will be processed and omitted from the output file.  All
directives are mon-cased, and the relevant symbols will be
upper case.

The file "perlpp.out" is (over-)written with the result.
