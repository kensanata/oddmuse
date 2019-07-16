# In order to build a copy of Oddmuse with all the version numbers, use:
# make build. This creates modified copies of the files in the build
# subdirectory.

VERSION_NO=$(shell git describe --tags)
TRANSLATIONS=$(wildcard modules/translations/[a-z]*-utf8.pl$)
MODULES=$(sort $(wildcard modules/*.pl))
BUILD=build/wiki.pl $(foreach file, $(notdir $(MODULES)) $(notdir $(TRANSLATIONS)), build/$(file))

# PREPARE/BUILD: this creates copies of wiki.pl and all the modules
# and translations in the build subdirectory. These copies all contain
# a reference to the revision they were created from (git describe
# --tags).

prepare: build $(BUILD)

build:
	mkdir -p build

clean:
	rm -rf build
	prove t/setup.pl

release:
	perl stuff/release ~/oddmuse.org/releases 2.3.3

build/wiki.pl: wiki.pl
	perl -lne "s/(\\\$$q->a\(\{-href=>'https:\/\/www.oddmuse.org\/'\}, 'Oddmuse'\))/\\\$$q->a({-href=>'https:\/\/alexschroeder.ch\/cgit\/oddmuse\/tag\/?id=$(VERSION_NO)'}, 'wiki.pl') . ' ($(VERSION_NO)), see ' . \$$1/; print" < $< > $@

build/%-utf8.pl: modules/translations/%-utf8.pl
	perl -lne "s/(AddModuleDescription\('[^']+', '[^']+')\)/\$$1, 'translations\/', '$(VERSION_NO)')/; print" < $< > $@

build/national-%.pl: modules/translations/national-%.pl
	perl -lne "s/(AddModuleDescription\('[^']+', '[^']+')\)/\$$1, 'translations\/', '$(VERSION_NO)')/; print" < $< > $@

build/month-names-%.pl: modules/translations/month-names-%.pl
	perl -lne "s/(AddModuleDescription\('[^']+', '[^']+')\)/\$$1, 'translations\/', '$(VERSION_NO)')/; print" < $< > $@

# from: https://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/namespaces.pl
#   to: https://git.savannah.gnu.org/cgit/oddmuse.git/tree/modules/namespaces.pl?id=2.1-11-gd4f1e27

build/%.pl: modules/%.pl
	perl -lne "s/(AddModuleDescription\('[^']+', '[^']+')\)/\$$1, undef, '$(VERSION_NO)')/; print" < $< > $@

modules/translations/new-utf8.pl: wiki.pl $(MODULES)
	cp $@ $@-old
	perl stuff/oddtrans -l $@-old wiki.pl $(MODULES) > $@
	rm -f $@-old

translations: $(TRANSLATIONS)
	for f in $^; do \
	  echo updating $$f...; \
	  perl stuff/oddtrans -l $$f wiki.pl $(MODULES) > $$f-new && mv $$f-new $$f; \
	done

# Running four jobs in parallel, but clean up data directories without
# race conditions!

jobs ?= 4
test:
	prove t/setup.pl
	prove --jobs=$(jobs) --state=slow,save t

# Spin up a quick test

development:
	morbo --listen http://*:8080 \
	--watch wiki.pl --watch test-data/config --watch test-data/modules/ \
	stuff/mojolicious-app.pl
