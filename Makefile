# The Makefile is only for developpers wanting to prepare the tarball.
# Make sure the CVS keywords for the sed command on the next line are not expanded.

VERSION_NO=$(shell git describe --tags)
TRANSLATIONS=$(wildcard modules/translations/[a-z]*-utf8.pl$)
MODULES=$(wildcard modules/*.pl)
BUILD=build/wiki.pl $(foreach file, $(notdir $(MODULES)) $(notdir $(TRANSLATIONS)), build/$(file))

# PREPARE/BUILD: this creates copies of wiki.pl and all the modules
# and translations in the build subdirectory. These copies all contain
# a reference to the revision they were created from (git describe
# --tags).

prepare: build $(BUILD)

build:
	mkdir -p build

build/wiki.pl: wiki.pl
	sed "s/\\\$$q->a({-href=>'http:\/\/www.oddmuse.org\/'}, 'Oddmuse')/\\\$$q->a({-href=>'http:\/\/git.savannah.gnu.org\/cgit\/oddmuse.git\/tag\/?id=$(VERSION_NO)'}, 'wiki.pl') . ' ($(VERSION_NO)), see ' . &/" < $< > $@

build/%-utf8.pl: modules/translations/%-utf8.pl
	sed "s/<a href=\"http:\/\/git.savannah.gnu.org\/cgit\/oddmuse.git\/tree\/modules\/translations\/\\(.*\\).pl\">\\(.*\\).pl<\/a>/<a href=\"http:\/\/git.savannah.gnu.org\/cgit\/oddmuse.git\/tree\/modules\/translations\/\\1.pl?id=$(VERSION_NO)\">\\1.pl<\/a> (for $(VERSION_NO))/" < $< > $@

# Currently oddtrans introduces encoding errors!

# %-utf8.pl: wiki.pl $(MODULES)
# 	perl oddtrans -l $@ $^ > $@-new && mv $@-new $@

# from: http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/namespaces.pl
#   to: http://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/namespaces.pl?id=2.1-11-gd4f1e27

build/%.pl: modules/%.pl
	sed "s/<a href=\"http:\/\/git.savannah.gnu.org\/cgit\/oddmuse.git\/tree\/modules\/\\(.*\\).pl\">\\(.*\\).pl<\/a>/<a href=\"http:\/\/git.savannah.gnu.org\/cgit\/oddmuse.git\/tree\/modules\/\\1.pl?id=$(VERSION_NO)\">\\1.pl<\/a> (for $(VERSION_NO))/" < $< > $@




# UNTESTED/OBSOLETE: these targets have not been tested in a long time
# and are potentially obsolete.
VERSION=oddmuse-$(VERSION_NO)
UPLOADVERSION=oddmuse-inkscape-$(VERSION_NO)
INKSCAPE=GPL $(wildcard inkscape/*.py inkscape/*.inx inkscape/*.sh)
PACKAGEMAKER=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker
DIST=$(VERSION).tar.gz $(VERSION).tar.gz.sig \
	contrib/simple-install/$(VERSION)-simple.tar.gz \
	contrib/simple-install/$(VERSION)-simple.tar.gz.sig
OLDDIST=$(VERSION).dmg $(VERSION).dmg.sig \
	$(VERSION).tgz $(VERSION).tgz.sig
PWD=$(shell pwd)

dist: $(DIST)

upload: $(DIST)
	for f in $^; do \
		scp $$f as@dl.sv.nongnu.org:/releases/oddmuse/; \
	done

upload-text: new-utf8.pl
	wikiupload new-utf8.pl http://www.oddmuse.org/cgi-bin/oddmuse-en/New_Translation_File

contrib/simple-install/$(VERSION)-simple.tar.gz:
	cd contrib/simple-install && make $(VERSION)-simple.tar.gz

$(VERSION).tar.gz: README FDL GPL ChangeLog wiki.pl $(TRANSLATIONS) $(MODULES) current.pl
	rm -rf $(VERSION)
	mkdir $(VERSION)
	cp $^ $(VERSION)
	tar czf $@ $(VERSION)

$(UPLOADVERSION).tar.gz: $(INKSCAPE)
	rm -rf $(UPLOADVERSION)
	mkdir $(UPLOADVERSION)
	cp $^ $(UPLOADVERSION)
	cp wikiupload $(UPLOADVERSION)/oddmuse-upload.py
	tar czf $@ $(UPLOADVERSION)

%.sig: %
	gpg --sign -b $<

# OSX: .pkg is the package, and .dmg is the disk image.

# Make sure to copy the files into a new directory so that the CVS
#subdirectory are not inlcuded in the .pkg. And fix permissions. Skip
#if we can't run PackageMaker. All cp commands need sudo because on a
#second run the directories will already exist.
$(VERSION).pkg: wiki.pl modules/creole.pl Mac/config Mac/wiki
	if test -x $(PACKAGEMAKER); then \
		mkdir -p Mac/pkg/CGI-Executables; \
		sudo cp wiki.pl Mac/pkg/CGI-Executables/current; \
		sudo cp Mac/wiki Mac/pkg/CGI-Executables/wiki; \
		sudo chown -R root:admin Mac/pkg/CGI-Executables; \
		sudo chmod 644 Mac/pkg/CGI-Executables/current; \
		sudo chmod 755 Mac/pkg/CGI-Executables/wiki; \
		mkdir -p Mac/pkg/Oddmuse; \
		sudo cp Mac/config Mac/pkg/Oddmuse; \
		sudo chown www:admin Mac/pkg/Oddmuse; \
		sudo chmod 775 Mac/pkg/Oddmuse; \
		sudo chown root:admin Mac/pkg/Oddmuse/config; \
		sudo chmod 664 Mac/pkg/Oddmuse/config; \
		mkdir -p Mac/pkg/Oddmuse/modules; \
		sudo cp modules/mac.pl Mac/pkg/Oddmuse/modules; \
		sudo cp modules/creole.pl Mac/pkg/Oddmuse/modules; \
		sudo chown -R root:admin Mac/pkg/Oddmuse/modules; \
		sudo chmod 775 Mac/pkg/Oddmuse/modules; \
		sudo chmod 644 Mac/pkg/Oddmuse/modules/*; \
		$(PACKAGEMAKER) -build \
			-p $(PWD)/$@ \
			-i $(PWD)/Mac/Info.plist \
			-d $(PWD)/Mac/Description.plist \
			-f $(PWD)/Mac/pkg; \
	fi;

$(VERSION).dmg: $(VERSION).pkg
	hdiutil create -srcfolder $< -fs HFS+ -volname "Oddmuse" $@

# Slackware: .tgz are .tar.gz files used by the installer
# Slackware webserver is run by nobody uid/gid 99/99.

$(VERSION).tgz: wiki.pl modules/creole.pl Mac/config Mac/wiki
	sudo rm -rf Slack/var Slack/install
	mkdir -p Slack/var/www/wiki/modules
	mkdir -p Slack/var/www/cgi-bin
	mkdir -p Slack/install
	sudo cp Mac/config Slack/var/www/wiki
	sudo cp Mac/wiki Slack/var/www/cgi-bin
	sudo cp README Slack/var/www/wiki
	sudo cp modules/creole.pl Slack/var/www/wiki/modules
	sudo cp wiki.pl Slack/var/www/cgi-bin/current
	sudo sed -e 's/VERSION/$(VERSION_NO)/' < Slack/slack-desc > Slack/install/slack-desc
	sudo chown -R 0:0 Slack/var Slack/install
	sudo chgrp 99 Slack/var/www/cgi-bin/wiki
	sudo chmod 644 Slack/var/www/cgi-bin/current
	sudo chmod 775 Slack/var/www/cgi-bin/wiki
	cd Slack && tar czf ../$@ var install

update-translations: $(TRANSLATIONS)

upload-translations: always
	for f in $(TRANSLATIONS); do \
		cvs status $$f | grep 'Status: Up-to-date'; \
		wikiput -z "ham" -u "cvs" -s "update" \
		"http://www.oddmuse.org/cgi-bin/oddmuse/raw/$$f" < $$f; \
	done

deb:
	equivs-build control

install:
	@echo This only installs the deb file, not the script itself.
	dpkg -i oddmuse*.deb

test:
	prove t

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
