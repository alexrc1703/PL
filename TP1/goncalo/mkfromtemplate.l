%option noyywrap
%{
    #include <string.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>

    /* struct Author {
        char* name;
        char* email;
    }author;

    struct Tree {
        char** files;
    }tree;

    typedef struct file {
        char* name;
        char* path;
    } *File

    void initAuthor() {
        author.name = (char*) calloc(64,sizeof(char*));
        author.email = (char*) calloc(128,sizeof(char*));
    }

    void initTree() {
        tree.files = noticia.text = (char**) calloc(1024,sizeof(char**));
    }

    void initFile() {
        file.name = (char*) calloc(64,sizeof(char*));
        file.path = (char*) calloc(1024,sizeof(char*));
    } */

    char* progName;
%}

%x METADATA
/* Abreviaturas de ER */
/* HEADERS ===.* */

/* LINE [^.\n].* */

/* NAME \{\%name\%\} */

%%

===  {BEGIN METADATA;}

<METADATA> { printf("-------- cenas");}

%%

int main(int argc, char* argv[]){
    if(argc>1){
        yyin = fopen(argv[2], "r");
        const size_t strLen = strlen(argv[1]) + 1;
        progName = malloc(strLen);
        strncpy(progName, argv[1], strLen);
        printf("%s --------------------------- progName \n", progName);
    }
    else {
        return 1;
    }
    yylex();
    return 0;
}