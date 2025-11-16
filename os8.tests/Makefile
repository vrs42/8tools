#
# Update the canonical results.
OS8	= v3d
DSK	= $(OS8).dsk
XPLODE	= $(OS8).0 $(OS8).1
NEW	= $(OS8).new

all:	$(NEW) $(OS8).new.0 verify

%.dsk:	%.rk05
	cp $< $@

%.0 %.1: %.dsk
	os8xplode -rk $<

$(NEW):	$(OS8).0 $(OS8).0/* $(OS8).1 $(OS8).1/*
	os8implode -rk $(OS8)
	mkdsk $(OS8).xml+

# Once the OS/8 image is ready to use, use it to run the
# tests, then extract the results.
$(OS8).new.0:	$(NEW)
	./runtests
	os8xplode $(NEW)

# Once the results in $(OS8).new.0 are ready, run the
# tests with 8tools, and compare the results.
e8all.bn e8ball.ls: e8a.pa e8b.pa
	# This will take a while...
	pal8 $(@:.bn=),$(@:.bn=)_e8a.pa,e8b.pa

%.bn %.ls: %.pa
	pal8 $(<:.pa=),$(<:.pa=)_$(<:.pa=)

%.mp:	%.bn
	map $@_$<

%.ls:	%.bn
	cref $(@:.ls=)_$(@:.ls=)

%.rl %.ls: %.ra
	sabr $(<:.ra=),$(<:.ra=)_$(<:.ra=)

%.wu:	%.ro
	sabr $(<:.ro=)_$(<:.ro=)


verify: short.bn short.ls e8all.bn e8all.ls e8all.mp accept.rl alog.rl head.wu
	cmp short.bn $(OS8).new.0/short.bn
	# Expect 8 lines different (listing dates)
	@diff short.ls $(OS8).new.0/short.ls | wc -l || exit 0
	cmp e8all.bn $(OS8).new.0/e8all.bn
	# Expect 284 lines different (listing dates)
	@diff e8all.ls $(OS8).new.0/e8all.ls | wc -l || exit 0
	diff e8all.mp $(OS8).new.0/e8all.mp
	cmp accept.rl $(OS8).new.0/accept.rl
	diff accept.ls $(OS8).new.0/accept.ls
	cmp alog.rl $(OS8).new.0/alog.rl
	diff alog.ls $(OS8).new.0/alog.ls
	diff head.wu $(OS8).new.0/head.wu

