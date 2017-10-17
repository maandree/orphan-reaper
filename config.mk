PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

LIBEXECDIR = $(PREFIX)/lib/orphan-reaper

CFLAGS   = -std=c99 -Wall -Wextra -O2
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700
LDFLAGS  = -s
