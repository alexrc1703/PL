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
char* temp2;
char* temp3;
char* temp4;
int count_line;

struct Author {
        char* name;
        char* email;
    }author;

struct File {
        char* name;
        char* path;
    }file;

struct Direct {
        char* name;
        char* path;
    }direct;

struct Tree {
        char** files;
    }tree;

    void initAuthor() {
        author.name = (char*) calloc(64,sizeof(char*));
        author.email = (char*) calloc(128,sizeof(char*));
    }

%}

nome \{\%name\%\}
%x DEFmeta DEFtree DEF

%%


^===[ \t\r\n]meta[\n] {BEGIN(DEFmeta);}

<DEFmeta>email: {
     temp = strdup(yytext+7);
     author.email=strtok(temp,"\n");
     printf("Este é o EMAIL: %s\n", author.email);
     free(temp);
}

<DEFmeta>author: {
     temp = strdup(yytext+8);
     author.name=strtok(temp,"\n");
     printf("Este é o author: %s\n", author.name);
}

<DEFmeta>^===[ \t\r\n]tree[\n] {BEGIN DEFtree;}

<DEFmeta>.|\n {;}

<DEFtree>\{\%name\%\} {printf("%s", nomeDir);}

<DEFtree>-+.*\\ {printf("Dir: %s\n", yytext);}

<DEFtree>-+.* {printf("file: %s\n", yytext);}


<DEFtree>^=== {BEGIN DEF;}

<DEF>^===.*[\n] {printf("NOVO FILE: %s\n", yytext);}

<DEF>.*[\n] {printf("Cenas novas: %s\n", yytext);}


<*>.|\n {;}

<<EOF>> {return 0;}

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