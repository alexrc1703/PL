%option noyywrap

%{
    /* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

char* nomeDir;
char* temp;

struct Author {
        char* name;
        char* email;
    }author;

struct File {
        char* name;
        char* path;
    }file;

struct Tree {
        char** files;
    }tree;

    void initAuthor() {
        author.name = (char*) calloc(64,sizeof(char*));
        author.email = (char*) calloc(128,sizeof(char*));
    }

%}

nome \{\%name\%\}
%x DEFmeta DEFtree

%%
<*>.|\n
^===[ \t\r\n]meta[ \t\r\n] { BEGIN DEFmeta;}

<DEFmeta>{
    <*>email:.* {
                    author.email = strdup(yytext+7);
                }
    <*>author:.* {
                    author.name= strdup(yytext+8);
                }
}

<DEFmeta>^===[ \t\r\n]tree[ \t\r\n] {
                                        BEGIN INITIAL;
                                        printf("%s\n", author.email);
                                        printf("%s\n", author.name);
                                    }


^===[ \t\r\n]tree[ \t\r\n] { BEGIN DEFtree; }
<DEFtree>{
    <*>^-[a-zA-Z] {printf("file\n");}
    <*>^--[a-zA-Z] {printf("file in folder\n");}
}

<DEFtree>^[ \t\r\n]===[ \t\r\n] { BEGIN INITIAL;printf("sai da tree");}

%%
int main(int argc, char** argv)
{
   if(argc>1){

        nomeDir=strdup(argv[1]);
        printf("nome do diretorio %s\n",nomeDir);
        yyin = fopen(argv[2], "r");

        yylex();


        fclose(yyin);
    }
    else {
        return -1;
    }
    return 1;
}