%code requires {
    #include "main.h"
    #include "util.h"
}

%{
    
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include "main.h"


void execute_pipeline(Command **commands);
int command_index = 0;
Command *commands[20] = {NULL};  

int yylex();         
void yyerror(const char *s); 

%}

%union {
    char *string_val;
    char **string_list; 
    int int_val;
    Command *cmd;
    Redirection *redir;
}

%token <int_val> FD_GREATER FD_GREATER_GREATER FILE_DESCRIPTOR
%token <string_val> WORD
%token PIPE NEWLINE GREATER GREATER_GREATER LESSER LESSER_LESSER

%type <cmd> command command_with_redirs simple_command
%type <redir> redirection

%nonassoc REDIRECTION  
%left PIPE

%%

input:
    /* empty */
  | input line
  ;

line:
    pipeline NEWLINE {
        commands[command_index] = NULL;
        execute_pipeline(commands);
        command_index = 0;
    }
  ;

pipeline:
    command { commands[command_index++] = $1; }
  | pipeline PIPE command { commands[command_index++] = $3; }
  ;

command:
    command_with_redirs
  ; 

command_with_redirs:
    simple_command { $$ = $1; }
  | command_with_redirs redirection %prec REDIRECTION {
        $1->redirs[$1->redir_count++] = $2;
        $$ = $1;
    }
  ;

simple_command:
    WORD {
        Command *cmd = malloc(sizeof(Command));
        cmd->args = malloc(sizeof(char *) * 20);
        cmd->args[0] = $1;
        cmd->args[1] = NULL;
        cmd->redirs = malloc(sizeof(Redirection *) * 20);
        cmd->redir_count = 0;
        $$ = cmd;
    }
  | simple_command WORD {
        int i = 0;
        while ($1->args[i] != NULL) i++;
        $1->args[i] = $2;
        $1->args[i + 1] = NULL;
        $$ = $1;
    }
  ;

redirection:
    GREATER WORD {
        int flags = O_WRONLY | O_CREAT | O_TRUNC;
        $$ = create_redirection(REDIR_FILE, 1, -1, $2, flags);
    }
  | GREATER FILE_DESCRIPTOR {
      $$ = create_redirection(REDIR_FD, 1, $2, NULL, -1);
    }

  | LESSER WORD {
      int flags = O_RDONLY | O_CREAT | O_TRUNC;
      $$ = create_redirection(REDIR_FILE, 0, -1, $2, flags);
    }

  | LESSER FILE_DESCRIPTOR {
      $$ = create_redirection(REDIR_FD, 0, $2, NULL, -1);
    }

  | GREATER_GREATER WORD {
      int flags = O_WRONLY | O_CREAT | O_APPEND;
      $$ = create_redirection(REDIR_FILE, 1, -1, $2, flags);
    }
  
  | GREATER_GREATER FILE_DESCRIPTOR {
      $$ = create_redirection(REDIR_FD, 1, $2, NULL, -1);
    }

  | LESSER_LESSER WORD {
      int flags = O_RDONLY | O_CREAT | O_APPEND;
      $$ = create_redirection(REDIR_FILE, 0, -1, $2, flags);
    }

  | LESSER_LESSER  FILE_DESCRIPTOR {
      $$ = create_redirection(REDIR_FD, 0, $2, NULL, -1);
    }

  | FD_GREATER WORD {
      int flags = O_WRONLY | O_CREAT | O_TRUNC;
      $$ = create_redirection(REDIR_FILE, $1, -1, $2, flags);
    }

  | FD_GREATER FILE_DESCRIPTOR {
      $$ = create_redirection(REDIR_FD, $1, $2, NULL, -1);
    }

  | FD_GREATER_GREATER  WORD {
      int flags = O_WRONLY | O_CREAT | O_APPEND;
      $$ = create_redirection(REDIR_FILE, $1, -1, $2, flags);
    }
  
  | FD_GREATER_GREATER  FILE_DESCRIPTOR {
      $$ = create_redirection(REDIR_FD, $1, $2, NULL, -1);
    }
  ;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Parser error: %s\n", s);
}