%option noyywrap
%option interactive

%{
    #include "shell.tab.h"
%}

%%

[ \t]+                  ;               
\n                      { return  NEWLINE; }

"|"                     { return PIPE; }

[0-9]+>                 { 
                            char *fd = strdup(yytext);
                            size_t len = strlen(fd);
                            fd[len - 1] = '\0';  
                            long temp = strtol(fd, NULL, 10);
                            int fd_num = (int)temp;
                            yylval.int_val = fd_num;
                            printf("token FD_GREATER\n");
                            return FD_GREATER; 
                            
                        }
[0-9]+>>                { 
                            char *fd = strdup(yytext);
                            size_t len = strlen(fd);
                            fd[len - 2] = '\0';  
                            long temp = strtol(fd, NULL, 10);
                            int fd_num = (int)temp;
                            yylval.int_val = fd_num;
                            return FD_GREATER_GREATER; 
                        }

&[0-9]+                 { 
                            char *fd = strdup(yytext);
                            long temp = strtol(fd + 1, NULL, 10);
                            int fd_num = (int)temp;
                            yylval.int_val = fd_num;
                            printf("token FILE_DESCRIPTOR\n");
                            return FILE_DESCRIPTOR; 
                        }
">"                     { 
                            return GREATER; 
                        }
"<"                     { return LESSER; }
">>"                    { return GREATER_GREATER; }
"<<"                    { return LESSER_LESSER; }
[^ \t\n|<>]+              {
                            yylval.string_val = strdup(yytext);
                            return WORD;
                        }

<<EOF>>                 { return 0; }

%%
