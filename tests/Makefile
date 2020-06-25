DIAG8E	= d0ab d0bb d0cc d0db d0eb d0fc d0gc d0hc \
	d0ib d0jc d0lb d0mb
CFLAGS	= -g
PASSED	=  d01c d02b focal focal69 d0ab d0bb d0cc d0db d0eb d0fc d0gc \
	d0hc d0ib d0jc d0lb # d0mb
TODO	= d0mb

all:	d01c d02b focal focal69 $(DIAG8E)

test:	d01c.pl
	./d01c.pl

# BUGBUG: $swr must be 05400
d01c.c:	bin2c d01c-pb
	./bin2c d01c-pb=00147 && mv foo.c $@

d02b.c:	bin2c d02b-pb
	./bin2c d02b-pb=00200 && mv foo.c $@

focal.c: bin2c focal.bin
	./bin2c focal.bin=00200 && mv foo.c $@

focal69.c: bin2c focal69.bin
	./bin2c focal69.bin=00200 && mv foo.c $@

# BUGBUG: Need to fix starting address and $swr for all following.
d0ab.c:	bin2c d0ab-pb
	./bin2c d0ab-pb=00147 && mv foo.c $@

d0bb.c:	bin2c d0bb-pb
	./bin2c d0bb-pb=00200 && mv foo.c $@

d0cc.c:	bin2c d0cc-pb
	./bin2c d0cc-pb=00200 %0000 && mv foo.c $@

d0db.c:	bin2c d0db-pb
	./bin2c d0db-pb=00200 && mv foo.c $@

d0eb.c:	bin2c d0eb-pb
	./bin2c d0eb-pb=00200 %0000 && mv foo.c $@

d0fc.c:	bin2c d0fc-pb
	./bin2c d0fc-pb=00200 %0000 && mv foo.c $@

d0gc.c:	bin2c d0gc-pb
	./bin2c d0gc-pb=00200 %0000 && mv foo.c $@

d0hc.c:	bin2c d0hc-pb
	./bin2c d0hc-pb=00200 %0000 && mv foo.c $@

d0ib.c:	bin2c d0ib-pb
	./bin2c d0ib-pb=00200 %0000 && mv foo.c $@

d0jc.c:	bin2c d0jc-pb
	./bin2c d0jc-pb=00200 %0000 && mv foo.c $@

d0lb.c:	bin2c d0lb-pb
	./bin2c d0lb-pb=00200 %05000 && mv foo.c $@

d0mb.c:	bin2c d0mb-pb
	./bin2c d0mb-pb=00202 %0000 && mv foo.c $@
