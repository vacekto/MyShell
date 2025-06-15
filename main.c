#include "main.h"
#include "util.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <sys/wait.h>
#include <errno.h>
#include <unistd.h>

extern FILE *yyin;
extern int yyparse();
extern int yyrestart(FILE *);

int main()
{

  yyin = stdin;
  yyrestart(stdin);

  while (1)
  {
    printf("MyShell> ");
    fflush(stdout);
    if (yyparse() != 0)
    {
      break;
    }
    printf("\n");
  }
  return 0;
}

void execute_pipeline(Command **commands)
{
  int i = 0;
  int fd[2];
  int input_fd = 0;

  int pids[20];
  pids[0] = -1;

  if (strcmp(commands[0]->args[0], "quit") == 0)
  {
    free_commands(commands);

    exit(0);
  }

  while (commands[i] != NULL)
  {

    pipe(fd);
    pid_t pid = fork();
    pids[i] = pid;
    pids[i + 1] = -1;

    if (pid == 0)
    {
      dup2(input_fd, 0);
      for (int l = 0; l < commands[i]->redir_count; l++)
      {
        if (commands[i]->redirs[l]->type == REDIR_FILE)
        {
          int redir_target_fd = open(commands[i]->redirs[l]->filename, commands[i]->redirs[l]->flags, 0644);
          if (redir_target_fd == -1)
          {
            exit(1);
          }
          dup2(redir_target_fd, commands[i]->redirs[l]->source_fd);
        }
        else
        {
          dup2(commands[i]->redirs[l]->target_fd, commands[i]->redirs[l]->source_fd);
        }
      }

      if (commands[i + 1] != NULL)
      {
        dup2(fd[1], 1);
      }
      close(fd[0]);
      execvp(commands[i]->args[0], commands[i]->args);
      perror("execvp");
      exit(1);
    }
    else if (pid > 0)
    {
      close(fd[1]);

      input_fd = fd[0];
      i++;
    }
    else
    {
      perror("fork");
      exit(1);
    }
  }

  for (int i = 0; pids[i] != -1; i++)
  {
    waitpid(pids[i], NULL, 0);
  }

  free_commands(commands);

  close(input_fd);
}
