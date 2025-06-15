#ifndef UTIL_H
#define UTIL_H

#include "main.h"

Redirection *create_redirection(RedirType type, int source_fd, int target_fd, char *target_filename, int flags);
void free_commands(Command **commands);

#endif