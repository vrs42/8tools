PAL	= $(shell which pal)
SRC	= $(wildcard *.pa)
BIN	= $(SRC:.pa=.bin)

all:	$(BIN)

clean:
	rm -f $(BIN) $(BIN:.bin=.lst)

%.bin:	%.pa $(PAL)
	echo $(PAL)
	pal -l -e -d $(@:.bin=.pa) || (rm $@; exit 1)
	bincmp $(@:.bin=.bn) $@
