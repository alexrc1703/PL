%option noyywrap

%{
/* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>


struct Author{
    char* name;
    char* email;
}author;

struct File{
    char* name;
    char* path;
}*file;

struct Tree{
    char** file;
}tree;
%}




/* Abreviaturas de ER */

headers ^===\s\S+$

name \{\%name\%\}

/* MAIN */

int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
}