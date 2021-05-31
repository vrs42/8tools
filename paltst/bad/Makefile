PAL	= $(shell which pal)
SRC	= $(wildcard *.pa)
#SRC	= indirect_test.pa
BIN	= $(SRC:.pa=.bin)

all:	$(BIN)

clean:
	rm -f $(BIN) $(BIN:.bin=.lst)

%.bin:	%.pa $(PAL)
	pal -l -e -d $(@:.bin=.pa) || (rm $@; exit 1)
	bincmp $(@:.bin=.bn) $@


fort.bin: fort.pa $(PAL)
	pal -l -d $(@:.bin=.pa) || (rm $@; exit 1)
	bincmp $(@:.bin=.bn) $@

