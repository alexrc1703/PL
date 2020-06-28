%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <ctype.h>

#include <sys/stat.h>

extern int yylex();
extern int yylineno;
extern char *yytext;
int yyerror();
int erroSem(char*);


%}
%union{
    char* vstring;
    int vint;
}

%token ERRO tabs string nl id
%type <vstring> LineList Line ClassList PropsList Text Prop Tag string tabs id nl


%%
// gramatica
// falta a cena aninhada !!!!

// Produto final
Pug
    : LineList {printf("%s\n", $1);}
    ;

// Lista de linhas de código
LineList
    : LineList Line { asprintf(&$$,"%s\n%s",$1,$2); }
    | Line { asprintf(&$$,"%s",$1); }
    ;
// Linha de código
Line
    : Tag { asprintf(&$$,"%s",$1); }
    | tabs Tag { asprintf(&$$,"%s%s",$1,$2); }
    | tabs '#' string nl{ asprintf(&$$, "%s<div id=\"%s\">",$1 ,$3); }
    | tabs ClassList nl{ asprintf(&$$, "%s<div class=\"%s\">",$1 ,$2); }
    | tabs '#' string ClassList nl{ asprintf(&$$, "%s<div id=\"%s\" class=\"%s\">",$1 ,$3, $4); }
    | tabs ClassList '#' string { asprintf(&$$, "%s<div id=\"%s\" class=\"%s\">",$1 ,$4, $2); }
    ;

Tag
    : string nl{ asprintf(&$$,"<%s>",$1); }
    | string '#' string nl{ asprintf(&$$,"<%s id=\"%s\">",$1,$3); }
    | string '#' string ClassList '(' PropsList ')' Text nl{ asprintf(&$$, "<%s id=\"%s\" class=\"%s\" %s> %s", $1, $3, $4, $6, $8); }
    | string ClassList '#' string '(' PropsList ')' Text nl{ asprintf(&$$, "<%s id=\"%s\" class=\"%s\" %s> %s", $1, $4, $2, $6, $8); }
    | string Text nl{ asprintf(&$$,"<%s> %s",$1, $2); }
    | string '(' PropsList ')' Text nl{ asprintf(&$$,"<%s %s> %s",$1, $3, $5); }
    ;

ClassList
    : ClassList '.' string { asprintf(&$$,"%s %s",$1, $3); }
    | '.' string { asprintf(&$$,"%s",$2); }
    ;

PropsList
    : PropsList Prop { asprintf(&$$,"%s %s",$1, $2); }
    | Prop { asprintf(&$$,"%s",$1); }
    ;

Prop
    : string '=' '\'' Text '\'' { asprintf(&$$,"%s=\"%s\"",$1, $4); }
    ;

Text
    : Text string { asprintf(&$$,"%s %s",$1, $2); }
    | string { asprintf(&$$,"%s",$1); }
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