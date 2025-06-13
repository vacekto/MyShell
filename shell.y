%code requires {
    #include "main.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "main.h"


void execute_pipeline(Command **commands);
int command_index = 0;
Command *commands[20];  

int yylex();         
void yyerror(const char *s); 
%}

%union {
    char *string_val;
    char **string_list; 
    Command *cmd;
}

%token <string_val> WORD
%token PIPE NEWLINE
%type <cmd> command
%%

input:
      /* empty */
    | input line
    ;

line:
      pipeline NEWLINE              { 
                                        commands[command_index] = NULL;
                                        execute_pipeline(commands);
                                        command_index = 0;
                                    }
    ;

pipeline:
      command                       { 
                                        commands[command_index++] = $1;
                                        commands[command_index] = NULL;
                                    }
    | pipeline PIPE command         { 
                                        commands[command_index++] = $3; 
                                        commands[command_index] = NULL;
                                    }
    ;



command:
      WORD                          {
                                        Command *cmd = malloc(sizeof(Command));
                                        cmd->args = malloc(sizeof(char *) * 20);  
                                        cmd->args[0] = strdup($1);
                                        cmd->args[1] = NULL;
                                        $$=cmd;
                                    }
    | command WORD                  {
                                        int i = 0;
                                        while ($1->args[i] != NULL) i++;
                                        $1->args[i] = strdup($2);
                                        $1->args[i+1] = NULL;
                                        $$ = $1;
                                    }
    ;

%%
void yyerror(const char *s) {
    fprintf(stderr, "Parser error: %s\n", s);
}