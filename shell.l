

%{
    #include "shell.tab.h"
%}

%%

[ \t]+           ;               
\n               { return  NEWLINE; }

"|"              { return PIPE; }

[^ \t\n|]+       {
                    yylval.string_val = strdup(yytext);
                    return WORD;
                }

%%
