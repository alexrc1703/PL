%option noyywrap

%{
/* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

char* email;
char* author;
char* progName;
/*

    typedef struct Author {
        char* name;
        char* email;
    }author;

    typedef struct File {
        char* name;
        char* path;
    }file;

    typedef struct Tree {
        char** files;
    }tree;

  

    void initAuthor() {
        author.name = (char*) calloc(64,sizeof(char*));
        author.email = (char*) calloc(128,sizeof(char*));
    }

    void initTree() {
        tree.files = (char**) calloc(1024,sizeof(char**));
    }

    void initFile() {
        (*(&file))->name = (char**) calloc(64,sizeof(char*));
       (*(&file)->path) = (char**) calloc(1024,sizeof(char*));
    }

    */
    char* trim(char *s) {
        while(isspace(*s)) s++;
        char *back = s + strlen(s);
        while(isspace(*--back));
        *(back+1) = '\0';
        return s;
    }
%}

arvore ===[ \t\r\n].+
NAME \{\%name\%\}
%x DEFmeta DEFtree


%%

^===[ \t\r\n]meta[ \t\r\n] { BEGIN DEFmeta;}

<DEFmeta>{
    <*>email:.* {
                    email = strdup(yytext+7);
                    printf("EMAIL: %s\n", email);
                }
    <*>author:.* {
                    author = strdup(yytext+8);
                    printf("AUTHOR: %s\n", author);
                }
}

<DEFmeta>^===[ \t\r\n]tree[ \t\r\n] { printf("GO TREE!\n"); }

%%

int main(int argc, char* argv[]){
    if(argc>1){
        yyin = fopen(argv[2], "r");
        const size_t strLen = strlen(argv[1]) + 1;
        progName = malloc(strLen);
        strncpy(progName, argv[1], strLen);
    }
    else {
        return 1;
    }
    yylex();
    return 0;
}