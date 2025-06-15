#include <stdlib.h>
#include "main.h"

Redirection *create_redirection(RedirType type, int source_fd, int target_fd, char *target_filename, int flags)
{
    Redirection *redir = malloc(sizeof(Redirection));

    if (!redir)
        return NULL;

    redir->source_fd = source_fd;
    redir->target_fd = target_fd;
    redir->type = type;
    redir->filename = target_filename;
    redir->flags = flags;
    return redir;
}

void free_commands(Command **commands)
{
    for (int i = 0; commands[i] != NULL; i++)
    {

        for (int l = 0; l < commands[i]->redir_count; l++)
        {
            free(commands[i]->redirs[l]->filename);
            free(commands[i]->redirs[l]);
        }
        free(commands[i]->redirs);

        for (int j = 0; commands[i]->args[j] != NULL; j++)
        {
            free(commands[i]->args[j]);
        }
        free(commands[i]->args);
        free(commands[i]);
    }
}