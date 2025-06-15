#ifndef COMMAND_H
#define COMMAND_H

typedef enum
{
    REDIR_FILE,
    REDIR_FD
} RedirType;

typedef struct
{
    int target_fd;
    int source_fd;
    char *filename;
    int flags;
    RedirType type;
} Redirection;

typedef struct
{
    char **args;
    Redirection **redirs;
    int redir_count;

} Command;

#endif