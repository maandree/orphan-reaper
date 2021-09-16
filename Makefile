.POSIX:

CONFIGFILE = config.mk
include $(CONFIGFILE)

DEFS = -D'LIBEXECDIR="$(LIBEXECDIR)"'

BIN =\
	orphan-reaper\
	reapd

TEST_BIN =\
	orphan-reaper.test\
	reapd.test\
	test

OBJ =\
	$(BIN:=.o)\
	$(TEST_BIN:=.o)


all: $(BIN) $(TEST_BIN)
$(OBJ): arg.h

.o:
	$(CC) -o $@ $< $(LDFLAGS)

.c.o:
	$(CC) -c -o $@ $< $(CFLAGS) $(CPPFLAGS) $(DEFS)

.c.test.o:
	$(CC) -c -o $@ $< $(CFLAGS) $(CPPFLAGS) -DTEST

check: $(TEST_BIN)
	test $$(./orphan-reaper.test ./test | wc -l) = 4

install: $(BIN)
	mkdir -p -- "$(DESTDIR)$(PREFIX)/bin"
	mkdir -p -- "$(DESTDIR)$(LIBEXECDIR)"
	mkdir -p -- "$(DESTDIR)$(MANPREFIX)/man1"
	cp -- orphan-reaper "$(DESTDIR)$(PREFIX)/bin/"
	cp -- reapd "$(DESTDIR)$(LIBEXECDIR)/"
	cp -- orphan-reaper.1 "$(DESTDIR)$(MANPREFIX)/man1/orphan-reaper.1"

uninstall:
	-rm -f -- "$(DESTDIR)$(PREFIX)/bin/orphan-reaper"
	-rm -f -- "$(DESTDIR)$(LIBEXECDIR)/reapd"
	-rmdir -- "$(DESTDIR)$(LIBEXECDIR)"
	-rm -f -- "$(DESTDIR)$(MANPREFIX)/man1/orphan-reaper.1"

clean:
	-rm -rf -- *.o *.su $(BIN) $(TEST_BIN)

.SUFFIXES:
.SUFFIXES: .test.o .o .c

.PHONY: all check install uninstall clean
