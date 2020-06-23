%{
#include <stdio.h>
extern int yylex();
int yyerror();
%}



%token ERRO


%%

Html
    : Tag
    : PlainText
    : Atribute
    ;

Tag
    :
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
