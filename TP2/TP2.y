%{
#include <stdio.h>
extern int yylex();
int yyerror();
%}

%union{
    string vstring;
}

%token ERRO pal
%type <vstring> pal


%%



Tag
    : pal text
    : pal
    ;

PlainText
         :
         ;

Atribute
        :
        ;





%%

int main(){
    yyparse();
    return 0;
}

int yyerror(){
    printf("Erro sintático...");
    return 0;
}
