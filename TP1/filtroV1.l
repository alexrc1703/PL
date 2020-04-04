%option noyywrap

%{
/* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

char* temp="nada";
char* sectemp="nothing";
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
nome \{\%name\%\}
%x DEFmeta


%%
^===[ \t\r\n]meta[ \t\r\n] { 
    BEGIN DEFmeta;
    printf("online mal comeca a sc\n");
    
    
    }
<DEFmeta>^===[ \t\r\n]tree {BEGIN INITIAL;printf("imprimo email: %s nome: %s quando saio de sc\n", (temp),(sectemp));}
<DEFmeta>.* {  
                //temp=strdup(yytext+6);
                //printf("imprimo EMAIL: %s !em livestream\n", (temp));
                //email: sectemp=strdup(yytext);printf("email: %s",sectemp);

                author: {
                        temp=strdup(yytext); 
                        sectemp=strtok(temp+7,".");
                        printf("author: %s",sectemp);
                }
}

{nome} { printf("válido: %s\n", yytext); }


.|\n {}

%%



int main()
{

    yylex();
    return 0;
}