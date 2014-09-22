# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.


# The package path prefix, if you want to install to another root, set DESTDIR to that root.
PREFIX ?= /usr
# The binary path excluding prefix.
BIN ?= /bin
# The library binary path excluding prefix.
LIBEXEC ?= /libexec
# The resource path excluding prefix.
DATA ?= /share
# The binary path including prefix.
BINDIR ?= $(PREFIX)$(BIN)
# The library binary path including prefix.
LIBEXECDIR ?= $(PREFIX)$(LIBEXEC)
# The resource path including prefix.
DATADIR ?= $(PREFIX)$(DATA)
# The license base path including prefix.
LICENSEDIR ?= $(DATADIR)/licenses


# The name of the package as it should be installed.
PKGNAME ?= orphan-reaper

# The name of the command as it should be installed.
COMMAND ?= orphan-reaper


# Flags to compile with.
USER_FLAGS = $(CFLAGS) $(LDFLAGS) $(CPPFLAGS)
WARN = -Wall -Wextra -pedantic
OPTIMISE = -O3
DEFS = -D'LIBEXECDIR="$(LIBEXECDIR)"'
C_FLAGS = $(OPTIMISE) $(WARN) $(DEFS) $(USER_FLAGS)



# Build rules.

.PHONY: all
all: bin/orphan-reaper bin/reapd


bin/%: src/%.c
	mkdir -p bin
	$(CC) $(C_FLAGS) -o $@ $<


# Install rules.

.PHONY: install
install: install-base

.PHONY: install
install-all: install-base

.PHONY: install-base
install-base: install-cmd install-copyright


.PHONY: install-cmd
install-cmd: bin/orphan-reaper bin/reapd
	install -dm755 -- "$(DESTDIR)$(BINDIR)"
	install -dm755 -- "$(DESTDIR)$(LIBEXECDIR)"
	install -m755 bin/orphan-reaper -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"
	install -m755 bin/reapd -- "$(DESTDIR)$(LIBEXECDIR)/reapd"


.PHONY: install-copyright
install-copyright: install-copying install-license

.PHONY: install-copying
install-copying:
	install -dm755 -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	install -m644 COPYING -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"

.PHONY: install-license
install-license:
	install -dm755 -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	install -m644 LICENSE -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"



# Uninstall rules.

.PHONY: uninstall
uninstall:
	-rm -- "$(DESTDIR)$(BINDIR)/$(COMMAND)"
	-rm -- "$(DESTDIR)$(LIBEXECDIR)/reapd"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"


# Clean rules.

.PHONY: clean
clean:
	-rm -rf obj bin

