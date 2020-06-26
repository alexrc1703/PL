%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno;
extern char *yytext;
int yyerror();
int erroSem(char*);


%}
%union{
    char* vstring;

}

%token ERRO text li
%type <vstring> text li 
%type <vstring> Pug
%type <vstring> SeqTags
%type <vstring> Tag

%%
Pug 
    : SeqTags { printf("%s\n",$1);}
    ;
SeqTags 
        : SeqTags Tag  { asprintf(&$$,"%s\n%s",$1,$2); }
        | Tag          { asprintf(&$$,"%s",$1); }
        ;

Tag 
    : li ' ' text { asprintf(&$$,"<li> %s </li>\n",$3);}
    | li '.' text { asprintf(&$$,"<li> %s ponto </li>\n",$3);}
    | li '#' text { asprintf(&$$,"<li> %s cardi </li>\n",$3);}
    ;
 




%%

int main(){
    yyparse();
    return 0;
}

int erroSem(char *s) {
    printf("Erro Semântico na linha: %d, %s...\n", yylineno, s);
    return 0;
}

int yyerror(){
  printf("Erro Sintático ou Léxico na linha: %d, com o texto: %s\n", yylineno, yytext);;
  return 0;
}