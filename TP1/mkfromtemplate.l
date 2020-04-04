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
                    author.email = strdup(yytext+6);
                    
                }
    <*>author:.* {
                    author.name= strdup(yytext+8);
                    
                }
}

<DEFmeta>^===[ \t\r\n]tree[ \t\r\n] { 
                                        BEGIN INITIAL; 
                                        printf("EMAIL: %s\n", author.email); 
                                        printf("AUTHOR: %s\n", author.name);
                                    }


^===[ \t\r\n]tree[ \t\r\n] { BEGIN DEFtree; }
<DEFtree>{
    <*>temp:.* {
        /* apanha a seguir ao espaco*/
                    temp = (strdup(yytext));
                    printf("string: %s\n", temp);
                    
                    mkdir("~/Makefile", 0700);
                    
                }

}
<DEFtree>^[ \t\r\n]===[ \t\r\n]Makefile[ \t\r\n] { BEGIN INITIAL;}

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