# The Makefile is only for developpers wanting to prepare the tarball.
# Make sure the CVS keywords for the sed command on the next line are not expanded.

VERSION=oddmuse-$(shell sed -n -e 's/^.*\$$Id: wiki\.pl,v \([0-9.]*\).*$$/\1/p' wiki.pl)
TRANSLATIONS=$(wildcard [a-z]*-utf8.pl)
MODULES=$(wildcard modules/*.pl)

dist: $(VERSION).tar.gz

upload: $(VERSION).tar.gz $(VERSION).tar.gz.sig
	curl -T $(VERSION).tar.gz      ftp://savannah.gnu.org/incoming/savannah/oddmuse/
	curl -T $(VERSION).tar.gz.sig  ftp://savannah.gnu.org/incoming/savannah/oddmuse/

upload-text: new-utf8.pl
	wikiupload new-utf8.pl http://www.oddmuse.org/cgi-bin/oddmuse-en/New_Translation_File

$(VERSION).tar.gz:
	rm -rf $(VERSION)
	mkdir $(VERSION)
	cp README FDL GPL ChangeLog wiki.pl $(TRANSLATIONS) $(MODULES) $(VERSION)
	tar czf $(VERSION).tar.gz $(VERSION)

%.tar.gz.sig: %.tar.gz
	gpg --sign -b $<

upload-translations: $(TRANSLATIONS)
	cgi-upload $^

.PHONY: always

*-utf8.pl: always
	wget http://www.oddmuse.org/cgi-bin/oddmuse/raw/$@ -O $@.wiki
	cvs status $@ | grep 'Status: Up-to-date'
	wikiput -u cvs -s update http://www.oddmuse.org/cgi-bin/oddmuse/raw/$@ < $@

update-translations: always
	for f in $(TRANSLATIONS); do \
		grep '^#' $$f > new-$$f; \
		perl oddtrans -l $$f $$f.wiki wiki.pl $(MODULES) >> new-$$f && mv new-$$f $$f; \
	done

deb:
	equivs-build control

install:
	@echo This only installs the deb file, not the script itself.
	dpkg -i oddmuse*.deb

test:
	perl test.pl

package-upload: debian-$(VERSION).tar.gz debian-$(VERSION).tar.gz.sig
	curl -T "{debian-$(VERSION).tar.gz,debian-$(VERSION).tar.gz.sig}" \
	ftp://savannah.gnu.org/incoming/savannah/oddmuse/

package: debian-$(VERSION).tar.gz
	gpg --ascii --encrypt $<

debian-$(VERSION).tar.gz:
	rm -rf $(VERSION)
	mkdir $(VERSION)
	cp README FDL GPL wiki.pl $(VERSION)
	tar czf $@ $(VERSION)
