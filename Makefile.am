AUTOMAKE_OPTIONS = foreign

ACLOCAL_AMFLAGS = -I m4

composed_bin_scripts = \
	sbu-check-sigs.sh \
	sbu-generate-user-keys.sh \
	sbu-lib.sh \
	sbu-list-sigs.sh \
	sbu-make-combo-loader.sh \
	sbu-sign-files.sh

bin_SCRIPTS = $(composed_bin_scripts)

nobase_bin_SCRIPTS = \
	tdd-lib/util.sh

edit = sed \
	-e 's|@PACKAGE\@|$(PACKAGE)|g' \
	-e 's|@PACKAGE_BUGREPORT\@|$(PACKAGE_BUGREPORT)|g' \
	-e 's|@PACKAGE_NAME\@|$(PACKAGE_NAME)|g' \
	-e 's|@PACKAGE_URL\@|$(PACKAGE_URL)|g' \
	-e 's|@PACKAGE_VERSION\@|$(PACKAGE_VERSION)|g' \
	-e 's|@datadir\@|$(pkgdatadir)|g' \
	-e 's|@libexecdir\@|$(libexecdir)|g' \
	-e 's|@prefix\@|$(prefix)|g'

$(composed_bin_scripts): % : Makefile $(srcdir)/%.in
	rm -f $@ $@.tmp
	mkdir -p $$(dirname $@)
	$(edit) $(srcdir)/$@.in > $@.tmp
	chmod +x $@.tmp
	mv $@.tmp $@

AM_CPPFLAGS = $(DEFAULT_CPPFLAGS)
AM_CFLAGS = $(DEFAULT_CFLAGS)

bin_PROGRAMS = sbu-hex-test

sbu_hex_test_DEPENDENCIES = Makefile
sbu_hex_test_SOURCES = sbu-hex-test.c
#sbu_hex_test_LDADD = -lssl -lcrypto

EXTRA_DIST = bootstrap configure.ac COPYING m4 mit-plus-license.txt README.md \
	version.sh $(addsuffix .in, $(composed_bin_scripts)) \
	$(nobase_bin_SCRIPTS)

CLEANFILES = $(bin_SCRIPTS)

MAINTAINERCLEANFILES = aclocal.m4 compile config.h* configure depcomp \
 install-sh Makefile.in missing $(PACKAGE)-*.gz

maintainer-clean-local:
	rm -rf m4 .deps

.PHONY: help

help:
	@echo "Targets:"
	@echo "  make install"
	@echo "  make dist"
	@echo "  make distcheck"
	@echo "  make distclean"
	@echo "  make maintainer-clean"
