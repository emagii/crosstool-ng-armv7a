
TOPDIR=$(PWD)
BUILD=$(TOPDIR)/.build
CROSSTOOL_VERSION=1.19.0
SRC=$(TOPDIR)/crosstool-ng-$(CROSSTOOL_VERSION)



COMPLETION=/etc/bash_completion.d

DESTDIR=/usr/local/uclibc

CT_NG=$(DESTDIR)/bin/ct-ng

all:	sudo build toolchain.sh

sudo:
	@sudo echo "Start Build"

crosstool-ng-1.19.0.tar.bz2:
	wget	http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.19.0.tar.bz2

.source:	crosstool-ng-1.19.0.tar.bz2
	tar	-jxvf $<
	(cd $(SRC) ; git init ; git add . ; git commit -m "Initial Commit" -s)
	(cd $(SRC) ; git am ../patches/*.patch)
	touch	$@

$(SRC)/ct-ng:	.source
	echo "(cd $(SRC) ; make)"

$(SRC)/Makefile:	$(SRC)/.gitignore
	(cd $(SRC) ; ./configure --prefix=$(DESTDIR) ; git add . ; git commit -m "Makefile" -s)
	echo DIR=$(PWD)

$(SRC)/ct-ng:	$(SRC)/Makefile
	$(MAKE) MAKELEVEL=0	-C $(SRC)
	(cd $(SRC) ; git add . ; git commit -m "ct-ng" -s)

	$(MAKE) MAKELEVEL=0	-C $(SRC) install

$(DESTDIR)/bin/ct-ng:	$(SRC)/ct-ng
	sudo	mkdir	-p	$(DESTDIR)
	sudo	chown	$(USER)	$(DESTDIR)
	$(MAKE) MAKELEVEL=0	-C $(SRC) install

$(SRC)/.gitignore:	.source
	echo	"*~"				>	$@
	echo	"*.o"				>>	$@
	echo	"*.dep"				>>	$@
	echo	"*.log"				>>	$@
	echo	"*.backup"			>>	$@
	echo	"*.status"			>>	$@
	echo	"config/configure.in"		>>	$@
	echo	"docs/ct-ng.1"			>>	$@
	echo	"docs/ct-ng.1.gz"		>>	$@
	echo	"kconfig/conf"			>>	$@
	echo	"kconfig/conf.dep"		>>	$@
	echo	"kconfig/lex.zconf.c"		>>	$@
	echo	"kconfig/mconf"			>>	$@
	echo	"kconfig/nconf"			>>	$@
	echo	"kconfig/zconf.hash.c"		>>	$@
	echo	"kconfig/zconf.tab.c"		>>	$@
	echo	"paths.mk"			>>	$@
	echo	"paths.sh"			>>	$@
	echo	"scripts/crosstool-NG.sh"	>>	$@
	echo	"scripts/saveSample.sh"		>>	$@
	echo	"scripts/showTuple.sh"		>>	$@
	(cd $(SRC) ; git add . ; git commit -m ".gitignore" -s)

# ------------------------------
$(BUILD)/tools.sh:	$(CT_NG)
	mkdir	-p $(BUILD)
	echo	"#!/bin/sh"					>	$@
	echo	"export PATH=/usr/local/uclibc/bin:$$PATH"	>>	$@
	chmod	a+x $@

.config:	$(BUILD)/tools.sh
	(cd $(BUILD) ; $(CT_NG) list-samples)
	touch	$@

.toolchain:	.config
	(cd $(BUILD) ; $(CT_NG) arm-unknown-linux-gnueabi ; \
	cp ../uclibc-cortex-a8.config 	./.config ; \
	cp ../uClibc-0.9.32.config	./uClibc-0.9.33.config)
	touch	$@
http://www.mentor.com/embedded-software/multimedia/player/identify-and-solve-qt-ui-performance-problems-331eeb3e-a154-49c3-9089-fb9ec6a1b4ca
build:	.toolchain
	(cd $(BUILD) ; . ./tools.sh ; $(CT_NG) build)

toolchain.sh:
	echo	"#!/bin/sh"								>	$@
	echo	"export	GCCROOT=/usr/local/uclibc/arm-unknown-linux-uclibcgnueabihf"	>>	$@
	echo	"export PATH=\$$GCCROOT/bin:\$$PATH"					>>	$@
	echo	"export CROSS_COMPILE=arm-linux-"					>>	$@
	chmod	a+x $@

completion:
	sudo cp	$(SRC)/ct-ng.comp	$(COMPLETTION)

debug:
	echo	USER=$(USER)


clean:
	rm -fr $(SRC)
	rm -fr $(DESTDIR)/*
	rm -f	.source	.config	.toolchain
	rm -fr	$(BUILD)
	rm -fr toolchain.sh
#	rm -f  $(COMPLETTION)/ct-ng.comp


