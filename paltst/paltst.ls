   1               /Some simple expressions, to see if the assembler does them right.
   2               /It is a challenge to get both:
   3               /       SZA CLA^2       /7500, and
   4               /       TAD FOO+1       /*not* "TAD FOO"+1
   5               /right.  On the one hand space (OR) is treated like any other operator,
   6               /and evaluation is strictly left to right.  On the other, the MRI needs
   7               /a fully evaluated target address expression before correct code can be
   8               /generated.
   9               *200
  10 000200  1777          TAD FOO         / Needs a literal
  11 000201  1776          TAD FOO+1       / Needs a *different* literal!
  12 000202  1375          TAD (-214+212
  13 000203  1375          TAD (-214+212
  14 000204  1374          TAD (-212+207
  15 000205  0004          4;HLT   / hmm
     000206  7402  
  16               start,  / begin here
  17 000207  7774          1-2-3
  18 000210  0006          1^2^3
  19 000211  7775          1-2^3
  20 000212  7777          1^2-3
  21 000213  7640          SZA CLA
  22 000214  7500          SZA CLA^2
  23 000215  6213          CIF CDF 10
  24 000216  5010          JMP 10
  25 000217  5617          JMP I .
  26 000374  7775  *.-1 177+1      / This one is fun
     000375  7776  
     000376  0601  
     000377  0600  
  27 000400  7000          NOP
  28                       PAGE
  29               FOO,
  30                       FIELD
  31               $

FOO     0600
START   0207 unreferenced
