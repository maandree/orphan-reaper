/* See LICENSE file for copyright and license details. */
#include <sys/wait.h>
#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>


int
main(int argc, char *argv[])
{
	for (;;) {
		if (wait(NULL) == -1) {
			if (errno == ECHILD)
				return 0;
			if (errno == EINTR)
				continue;
			fprintf(stderr, "%s: wait: %s\n", *argv, strerror(errno));
			return 2;
		}
#ifdef TEST
		printf("reaped\n");
#endif
	}

	(void) argc;
}
