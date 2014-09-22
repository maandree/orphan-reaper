/**
 * orphan-reaper — Place subreapers in your process tree to keep it structured
 * Copyright © 2014  Mattias Andrée (maandree@member.fsf.org)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/prctl.h>



static void usage(void)
{
  printf("USAGE: reapd [--fatal] [--] <command...>\n");
  printf("\n");
  printf("Unless `--fatal` is used, the program will run <command>\n");
  printf("even if the process cound not be marked as a child subreaper.\n");
  printf("\n");
}


int main(int argc, char** argv)
{
  int i, j, r, fatal = 0;
  char** exec_argv;
  pid_t pid;
  
  if ((argc < 2) || !strcmp(argv[1], "--help"))
    return usage(), argc < 2 ? 1 : 0;
  
  for (i = 1; i < argc; i++)
    if (!strcmp(argv[i], "--fatal"))
      fatal = 1;
    else if (!strcmp(argv[i], "--"))
      {
	i++;
	break;
      }
    else if (strstr(argv[i], "-") == argv[i])
      return usage(), 1;
    else
      break;
  
  if (i == argc)
    return usage(), 1;
  
  exec_argv = malloc((argc - i + 1) * sizeof(char*));
  if (exec_argv == NULL)
    return perror(*argv), 2;
  exec_argv[argc - i] = NULL;
  for (j = 0; i < argc; j++, i++)
    exec_argv[j] = argv[i];
  
  r = prctl(PR_SET_CHILD_SUBREAPER, 1);
  if (r < 0)
    goto error;
  
  pid = fork();
  if (pid == -1)
    goto error;
  
  if (pid == 0)
    goto exec;
  else
    {
      free(exec_argv);
      for (;;)
	if (pid = wait(NULL), pid == -1)
	  {
	    if (errno == ECHILD)
	      return 0;
	    else if (errno != EINTR)
	      return perror(*argv), 2;
	  }
    }
  
 exec:
  (void) prctl(PR_SET_CHILD_SUBREAPER, 0);
  execvp(*exec_argv, exec_argv);
  perror(*argv);
 fail:
  free(exec_argv);
  return 2;
  
 error:
  perror(*argv);
  if (fatal)
    goto fail;
  goto exec;
}

