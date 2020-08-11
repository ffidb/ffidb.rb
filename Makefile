# This is free and unencumbered software released into the public domain.

VERSION      := $(shell cat VERSION)
VERSION_MAJOR = $(word 1,$(subst ., ,$(VERSION)))
VERSION_MINOR = $(word 2,$(subst ., ,$(VERSION)))
VERSION_PATCH = $(word 3,$(subst ., ,$(VERSION)))

BUNDLE        = bundle

all: build

build: Rakefile
	@$(BUNDLE) exec rake build

test: check

check: Rakefile
	@$(BUNDLE) exec rspec

install: build
	@$(BUNDLE) exec rake install

uninstall:
	@$(BUNDLE) exec rake uninstall

clean:
	@rm -Rf *~ *.gem

distclean: clean

mostlyclean: clean

maintainer-clean: clean

.PHONY: all build test check install uninstall
.PHONY: clean distclean mostlyclean maintainer-clean

.SECONDARY:
.SUFFIXES:
