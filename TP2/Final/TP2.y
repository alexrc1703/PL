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

}

%token ERRO tabs tag text prop
%type <vstring> LineList Line ClassList PropsList Id


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
    : tag // abre a tag -> <tag>
    | tabs Id // div com id -> <tag id="id"
    | tabs ClassList // div com classes -> <div class="...">
    | tabs Id ClassList // div com id e classes  -> <div id="id" class="...">
    | tabs ClassList Id // div com classes e id (tentar juntar estes 4)  -> <div class="..." id="id">
    | tabs tag Id ClassList PropsList text // tag com id class e props  -> <tag id="id" class="..." href=".." outras="..."> texto
    | tabs tag ClassList Id PropsList text // tag com class id e props  -> <tag class="..." id="id" href=".." outras="..."> texto
    | tabs tag text // tag apenas com texto  -> <tag> texto
    | tabs tag PropsList text // tag com props e texto  -> <tag prop1=".." prop2="..." ...> texto
    ;

ClassList
    : '.' text ClassList //  -> class="text
    | '.' text // tenho de adicionar ao propslist nas classes ja existentes !! ->  text"
    ;

Id
    : '#' text // tenho de adicionar às props <tag props>
    ;

PropsList
    : '(' prop '=' 'p' text 'p' PropsList ')' // varias props para colocar <tag prop1=".." props>
    | prop '=' 'p' text 'p' // prop unica prop="asds"
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