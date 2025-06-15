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
