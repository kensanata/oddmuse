# The Makefile is only for developpers wanting to prepare the tarball.
# Make sure the CVS keywords for the sed command on the next line are not expanded.

VERSION=oddmuse-$(shell sed -n -e 's/^.*\$$Id: wiki\.pl,v \([0-9.]*\).*$$/\1/p' wiki.pl)
TRANSLATIONS=$(wildcard [a-z]*-utf8.pl)

dist:
	rm -rf $(VERSION)
	mkdir $(VERSION)
	cp README FDL GPL ChangeLog wiki.pl $(TRANSLATIONS) $(VERSION)
	tar czf $(VERSION).tar.gz $(VERSION)

upload:
	scp $(VERSION).tar.gz as@subversions.gnu.org:/upload/oddmuse

update-translations: $(TRANSLATIONS)

.PHONY: always

*-utf8.pl: always
	grep '^#' $@ > new-$@
	perl umtrans.pl wiki.pl $@ >> new-$@ && mv new-$@ $@

deb:
	equivs-build control

install:
	@echo This only installs the deb file, not the script itself.
	dpkg -i oddmuse*.deb

test:
	perl test-markup.pl
