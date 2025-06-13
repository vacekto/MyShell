#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include "main.h"

extern int yyparse();

void print_string_array(char **arr);
int main()
{
    printf("MyShell> ");
    fflush(stdout);
    yyparse();
    return 0;
}

void execute_pipeline(Command **commands)
{
    int i = 0;
    int fd[2];
    int input_fd = 0;

    while (commands[i] != NULL)
    {

        pipe(fd);
        pid_t pid = fork();

        if (pid == 0)
        {
            dup2(input_fd, 0);
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
            wait(NULL);
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
}