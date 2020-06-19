%{
#include <stdio.h>
extern int yylex();
int yyerror();
%}



%token ERRO


%%



%%

int main(){
    yyparse();
    return 0;
}

int yyerror(){
    printf("Erro sintático...");
    return 0;
}
