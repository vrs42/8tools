```markdown
# 8tools

These are a set of tools being developed to deal with PDP-8
and PDP-12 media like paper tapes, as well as block oriented
media (like floppy, DECtape, RK8, RK05, RL01, RL02, etc.).

See the individual tool documents in the doc/ directory
for details.

## Requirements
- Perl (most scripts are in Perl)
- Make
- C compiler (pal.c)

## Installation
- git clone git@github.com:vrs42/8tools.git
- cd 8tools
- make
- (Add 8tools directory to your PATH, if desired.)

## Tools
### Text files
- 2asc / 2mark

### Paper tape images
- bincmp
- bintrim
- binview / view2bin / mmap
- bin2cbl / cbl2bin
- bnhtm2od
- cksum
- dood / mktapes
- elabel

### BIN (.bn) Format
- bincmp binsvcmp
- bin2bn
- binfind / ptpfind
- bn2sv / sv2bn

### SAVE .sv Format
- bn2sv / sv2bn
- binsvcmp
- isepic / toepic / epic
- svview
- sixbit / sv2od
- svhtm2bn / svhtm2od

### Media Conversion
- 3p2dk
- cos2dk / cos2txt
- dk2rx / rx2dk / os8p2dk / findos8
- dsk2rke / rke2dsk / rkechk
- dt2dk / dk2dt / pxg2dt
- linc2dsk
- m43dk / m43rk

### O/S Media
- 3to4 / 4to3
- dialdir / dialxplode / dialimplode / dialinfo / bd2bin
- dmsdir / dmsxplode
- os8dir / os8xplode / os8implode / mkdsk / os8res
- tss8dir / tss8xplode
- pqs8dir / pqs8xplode / sv2sd
- putrdir
- isreloc
- bin2slp / slp2bin
- tssasc / tssbas / tssfcl / ascat / sav2bin

### Cross Assembly
- pal / pal.c / bin2pal / paltst / perlpp / Makefile

### OS/8 Emulation
- os8
- cref / dir / e8 / edit / focal8 / focl69 / focl71 / focl8k / fotp / futil
- map / pal8 / pip / ralf / runoff / sabr / srccom / svview / teco

### Experiments
- 8info
- bin2c / bin2perl
- dups
- man5
- pdfcmp
- simh-trace
- tests

## License
The license is spelled out in the boilerplate file "bp".
