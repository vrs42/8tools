#
# Remake binaries from source, as needed
#
# This is a list of architecture dependant binaries.
ARCH	= pal

all:	pal ../8tools.tgz

../8tools.tgz: .
	(cd ..; tar czf 8tools.tgz 8tools)

#
# 'make arch' if the existing executable is wrong for
# your machine.
arch:
	rm -f $(ARCH); make
