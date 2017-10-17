.POSIX:

CONFIGFILE = config.mk
include $(CONFIGFILE)

DEFS = -D'LIBEXECDIR="$(LIBEXECDIR)"'


all: orphan-reaper reapd orphan-reaper.test reapd.test

.o:
	$(CC) -o $@ $^ $(LDFLAGS)

orphan-reaper.o: orphan-reaper.c arg.h
	$(CC) -c -o $@ orphan-reaper.c $(CFLAGS) $(CPPFLAGS) $(DEFS)

orphan-reaper.test.o: orphan-reaper.c arg.h
	$(CC) -c -o $@ orphan-reaper.c $(CFLAGS) $(CPPFLAGS) -DTEST

reapd.o: reapd.c
	$(CC) -c -o $@ reapd.c $(CFLAGS) $(CPPFLAGS) $(DEFS)

reapd.test.o: reapd.c
	$(CC) -c -o $@ reapd.c $(CFLAGS) $(CPPFLAGS) -DTEST

check: orphan-reaper.test reapd.test
	test $$(./orphan-reaper.test sh -c 'true & true & true &' | wc -l) = 4

install: orphan-reaper reapd
	mkdir -p -- "$(DESTDIR)$(PREFIX)/bin"
	mkdir -p -- "$(DESTDIR)$(LIBEXECDIR)"
	mkdir -p -- "$(DESTDIR)$(PREFIX)/share/licenses/orphan-reaper"
	mkdir -p -- "$(DESTDIR)$(MANPREFIX)/man1"
	cp -- orphan-reaper "$(DESTDIR)$(PREFIX)/bin/"
	cp -- reapd "$(DESTDIR)$(LIBEXECDIR)/"
	cp -- LICENSE "$(DESTDIR)$(PREFIX)/share/licenses/orphan-reaper/"
	cp -- orphan-reaper.1 "$(DESTDIR)$(MANPREFIX)/man1/orphan-reaper.1"

uninstall:
	-rm -f -- "$(DESTDIR)$(PREFIX)/bin/orphan-reaper"
	-rm -f -- "$(DESTDIR)$(LIBEXECDIR)/reapd"
	-rmdir -- "$(DESTDIR)$(LIBEXECDIR)"
	-rm -rf -- "$(DESTDIR)$(PREFIX)/share/licenses/orphan-reaper"
	-rm -f -- "$(DESTDIR)$(MANPREFIX)/man1/orphan-reaper.1"

clean:
	-rm -rf -- *.o orphan-reaper reapd orphan-reaper.test reapd.test

SUFFIXES: .o

.PHONY: all check install uninstall clean
