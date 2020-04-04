

%{
/* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

char* temp="nada";
char* sectemp="nothing";

char* email;
char* author;
char* progName;
char** files;
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
%x DEFmeta DEFtree


%%
<*>.|\n
^===[ \t\r\n]meta[ \t\r\n] { BEGIN DEFmeta;printf("online mal comeca a sc\n");}

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

<DEFmeta>^===[ \t\r\n]tree[ \t\r\n] { BEGIN INITIAL;printf("saiu de sc"); printf("GO TREE!\n");printf("EMAIL: %s\n", email); printf("AUTHOR: %s\n", author);}



^===[ \t\r\n]tree[ \t\r\n] { BEGIN DEFtree; printf("online mal comeca a tree\n");}
<DEFtree>{
    <*>[ \t\r\n].* {
        /* fazer esta parte */
                    temp = trim(strdup(yytext));
                    printf("string: %s\n", temp);
                    
                    *files=strdup(strtok(temp,"\n"));
                    int i=1;
                    while(temp!=NULL){
                        
                        *(files+i)=strdup(strtok(NULL,"\n"));
                        i++;
                    }
                    
                }

}
<DEFtree>^[ \t\r\n]===[ \t\r\n]Makefile[ \t\r\n] { BEGIN INITIAL;printf("saiu de tree %s",temp);}


{nome} { printf("válido: %s\n", yytext); }




<<EOF>>   { return 0 ; } 

%%

int yywrap(){
    return(1);
}


int main()
{

    yylex();
    return 0;
}