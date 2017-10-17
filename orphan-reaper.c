/* See LICENSE file for copyright and license details. */
#include <sys/prctl.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "arg.h"

#ifdef TEST
# define LIBEXECDIR "."
# define REAPD "reapd.test"
#else
# ifndef REAPD
#  define REAPD "reapd"
# endif
#endif

char *argv0;

static
void usage(void)
{
	fprintf(stderr, "usage: %s [-f] command ...\n", argv0);
	exit(1);
}

int
main(int argc, char *argv[])
{
	int fatal = 0;

	ARGBEGIN {
	case 'f':
		fatal = 1;
		break;
	default:
		usage();
	} ARGEND;

	if (!argc)
		usage();

	if (access(LIBEXECDIR"/"REAPD, X_OK) < 0) {
		fprintf(stderr, "%s: access %s: %s\n", argv0, LIBEXECDIR"/"REAPD, strerror(errno));
		return 2;
	}

	if (prctl(PR_SET_CHILD_SUBREAPER, 1) < 0) {
		fprintf(stderr, "%s: prctl PR_SET_CHILD_SUBREAPER: %s\n", argv0, strerror(errno));
		if (fatal)
			return 2;
		goto exec;
	}

	switch (fork()) {
	case -1:
		fprintf(stderr, "%s: fork: %s\n", argv0, strerror(errno));
		if (fatal)
			break;
		/* fall through */

	case 0:
		(void) prctl(PR_SET_CHILD_SUBREAPER, 0);
	exec:
		execvp(*argv, argv);
		fprintf(stderr, "%s: execvp %s: %s\n", argv0, *argv, strerror(errno));
		break;

	default:
		execl(LIBEXECDIR"/"REAPD, LIBEXECDIR"/"REAPD, NULL);
		fprintf(stderr, "%s: execl %s: %s\n", argv0, *argv, strerror(errno));
		break;
	}

	return 2;
}
