PREFIX     = /usr
MANPREFIX  = $(PREFIX)/share/man
LIBEXECDIR = $(PREFIX)/libexec/orphan-reaper

CC = cc

CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700
CFLAGS   = -std=c99 -Wall -O2
LDFLAGS  = -s
