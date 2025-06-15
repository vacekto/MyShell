all: shell.l shell.y main.c
	bison -d shell.y
	flex shell.l
	gcc -o mysh shell.tab.c lex.yy.c main.c util.c -lfl