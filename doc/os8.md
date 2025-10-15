**os8** Simulates OS/8

Given a file in the output format of "svview", "os8" will create a
simulated SYS: device from the current working directory, and simulate
the contents of that .SV file in the simulated working directory.
When the simulated program exists or halts, the working directory
is updated to reflect the changes made by the simulated OS/8 program.

In particular, the "#!os8" at the top of the output of "svview" is meant
to allow the capture of the output into a file, which when made executable,
will behave as the OS/8 program would have done.

Thus the commands
	svview direct.sv >dir
	chmod 755 dir
will create a "dir" command, which when found on the PATH, will print the
OS/8 directory corresponding to the current working directory.

Note that the OS/8 directory only includes files whose names follow the "6.2"
naming rules allowed in OS/8.  Other files in the current working directory
are not made available in the simulated OS/8 environment.

Note that flags and filespecs are allowed:
	dir /f
While flags in parenthesis are allowed, it is easier to use "/", since the
use of "()" in most host shells would require quoting.

Similarly, specifying file names:
	pal8 short.bn_short.pa
is also more easily done using "_" instead of "<", because it doesn't require
quoting.
