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

%token ERRO tabs string nl
%type <vstring> LineList Line ClassList PropsList Text Prop Tag string tabs


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
    | tabs '#' Text { asprintf(&$$, "<div id=\"%s\">", $3); }
    | tabs ClassList // div com classes -> <div class="...">
    | tabs '#' Text ClassList // div com id e classes  -> <div id="id" class="...">
    | tabs ClassList '#' string // div com classes e id (tentar juntar estes 4)  -> <div class="..." id="id">
    ;

Tag
    : string nl{ asprintf(&$$,"<%s>",$1); }
    | string '#' string ClassList '(' PropsList ')' Text nl{ asprintf(&$$, "<%s id=\"%s\" class=\"%s\" %s> %s", $1, $3, $4, $6, $8); }
    | string ClassList '#' string '(' PropsList ')' Text nl// tag com class id e props  -> <tag class="..." id="id" href=".." outras="..."> texto
    | string Text nl// tag apenas com texto  -> <tag> texto
    | string '(' PropsList ')' Text nl{ asprintf(&$$,"<%s %s> %s",$1, $3, $5); }
    ;

ClassList
    : ClassList '.' Text //  -> class="text
    | '.' Text // tenho de adicionar ao propslist nas classes ja existentes !! ->  text"
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