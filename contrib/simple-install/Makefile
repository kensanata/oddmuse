all:
	@echo Please invoke make dist on the top level

%-simple.tar.gz: README config wiki.pl .htaccess current.pl FDL GPL
	tar czf $@ $^

current.pl: ../../wiki.pl
	cp $^ $@

FDL: ../../FDL
	cp $^ $@

GPL: ../../GPL
	cp $^ $@
