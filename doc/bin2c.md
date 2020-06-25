**bin2c** is a rudimentary disassembler to C.

It currently takes a single argument, the name
of a file in .bin format.  This file will be
disassembled into equivalent "C" code, and
and "foo.c" will be (over)written with source
code that, when compiled, should result in an
executable that simulates the original .bin.
At some point, I should fix it to allow more
than a single .bin input file, to facilitate
the popular overlay and patch tapes.

Command line options consisting of a special 
character followed by an octal number (as
indicated with a leading "0").  The =0nnnn 
option sets the starting address.  The %0nnnn
option sets the contents of the switch register.
These options are also accepted by the executable
created from the compiled code.  In addition, the 
compiled executable accepts the "-t" option, to 
enable tracing to stderr, and the "-i" option.
The "-i" option is intended to someday cause the
HLT instruction to enter an interactive ODT like 
command interpreter, instead of just exiting.

In general, the output will emulate the behavior
of an PDP-8/E with EAE option and a TTY.  (It is
hoped to eventually mimic the OS/8 operating 
environment, USR calls, etc.)  A suite of 8/E
diagnostics runs sucessfully, though the timeshare 
feature of the MMU is not yet implemented.

The code generated is generally quite simple,
consisting of an assignment statement or two for 
each PDP-8 word.  Where this is not possible, and
for self modifying code, an emulation routine is
used.
