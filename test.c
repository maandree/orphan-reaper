#include <unistd.h>

int
main(void)
{
	fork();
	fork();
	return 0;
}
