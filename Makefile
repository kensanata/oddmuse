# The Makefile is only for developpers wanting to prepare the tarball.

VERSION=oddmuse-$(shell sed -n -e 's/^.*\$$Id: wiki\.pl,v \([0-9.]*\).*$$/\1/p' wiki.pl)

dist:
	mkdir $(VERSION)
	cp README FDL GPL ChangeLog wiki.pl $(VERSION)
	tar czf $(VERSION).tar.gz $(VERSION)

upload:
	scp oddmuse-1.16.tar.gz as@subversions.gnu.org:/upload/oddmuse
