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
.|\n {}
^===[ \t\r\n]meta[\n] {BEGIN(DEFmeta);}

<DEFmeta>email: {     
     temp = strdup(yytext+7);
     author.email=strtok(temp,"\n");
     printf("Este é o EMAIL: %s\n", author.email);
     
     

}
<DEFmeta>author: {     
     temp = strdup(yytext+8);
     author.name=strtok(temp,"\n");
     printf("Este é o author: %s\n", author.name);
}
<DEFmeta>.|\n {}


corrigir a partir daqui
^===[ \t\r\n]tree[\n] {BEGIN(DEFtree);}
<DEFtree>name {temp = strdup(yytext+8);file.name=strtok(temp,"\n");
     printf("Este é o author: %s\n", file.name); }
<DEFtree>===[ \t\r\n]Makefile[\n] {
    BEGIN(0);
    printf("saiu de sc\n"); 
    printf("GO make!\n");}

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