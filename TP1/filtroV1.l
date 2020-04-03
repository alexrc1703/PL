%option noyywrap

%{
/* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

/*

    struct Author {
        char* name;
        char* email;
    }author;

    struct Tree {
        char** files;
    }tree;

    typedef struct file {
        char* name;
        char* path;
    } *File;

    void initAuthor() {
        author.name = (char*) calloc(64,sizeof(char*));
        author.email = (char*) calloc(128,sizeof(char*));
    }

    void initTree() {
        tree.files = (char**) calloc(1024,sizeof(char**));
    }

    void initFile() {
        file->name = (char**) calloc(64,sizeof(char*));
        file->path = (char**) calloc(1024,sizeof(char*));
    }


*/
%}

/* Abreviaturas de ER */
HEADERS ^===\s\S+$

NAME \{\%name\%\}

%%

{HEADERS}+  {
            printf("Header: %s", yytext);
            }
%%
int main(int argc, char *argv[]){

    if(argc>1)
    {
        yylex();
    }

    else {
        return -1;
    }

    return 1;
}