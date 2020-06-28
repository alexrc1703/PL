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

void closeTags(char *t){
    printf("closing Tabs!!\n");
}

void updateTags(char* t){
    printf("Updating tags lvl array with tag %s \n", t);
}


%}
%union{
    char* vstring;
    int vint;
}

%token ERRO tabs string nl
%type <vstring> LineList Line ClassList PropsList Text Prop Tag string tabs nl


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
    | tabs Tag { closeTags($1); asprintf(&$$,"%s%s",$1,$2); }
    | tabs '#' string nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\">",$1 ,$3); }
    | tabs '#' string '(' PropsList ')' nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\" %s>",$1 ,$3, $5); }
    | tabs ClassList nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div class=\"%s\">",$1 ,$2); }
    | tabs ClassList '(' PropsList ')' nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div class=\"%s\" %s>",$1 ,$2, $4); }
    | tabs '#' string ClassList nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\" class=\"%s\">",$1 ,$3, $4); }
    | tabs ClassList '#' string nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\" class=\"%s\">",$1 ,$4, $2); }
    | tabs '#' string ClassList '(' PropsList ')' nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\" class=\"%s\" %s>",$1 ,$3, $4, $6); }
    | tabs ClassList '#' string '(' PropsList ')' nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\" class=\"%s\" %s>",$1 ,$4, $2, $6); }
    | tabs '#' string ClassList '(' PropsList ')' Text nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\" class=\"%s\" %s> %s",$1 ,$3, $4, $6, $8); }
    | tabs ClassList '#' string '(' PropsList ')' Text nl{ closeTags($1); char* div="div"; updateTags(div); asprintf(&$$, "%s<div id=\"%s\" class=\"%s\" %s> %s",$1 ,$4, $2, $6, $8); }
    ;

Tag
    : string nl{ updateTags($1); asprintf(&$$,"<%s>",$1); }
    | string ' ' Text nl{ updateTags($1); asprintf(&$$,"<%s> %s",$1, $3); }
    | string '#' string nl{ updateTags($1); asprintf(&$$,"<%s id=\"%s\">",$1,$3); }
    | string ClassList nl{ updateTags($1); asprintf(&$$,"<%s class=\"%s\">",$1,$2); }
    | string ClassList ' ' Text nl{ updateTags($1); asprintf(&$$,"<%s class=\"%s\"> %s",$1,$2,$4); }
    | string '#' string ClassList '(' PropsList ')' ' ' Text nl{ updateTags($1); asprintf(&$$, "<%s id=\"%s\" class=\"%s\" %s> %s", $1, $3, $4, $6, $9); }
    | string ClassList '#' string '(' PropsList ')' ' ' Text nl{ updateTags($1); asprintf(&$$, "<%s id=\"%s\" class=\"%s\" %s> %s", $1, $4, $2, $6, $9); }
    | string ClassList '(' PropsList ')' ' ' Text nl{ updateTags($1); asprintf(&$$, "<%s class=\"%s\" %s> %s", $1, $2, $4, $7); }
    | string '#' string '(' PropsList ')' ' ' Text nl{ updateTags($1); asprintf(&$$, "<%s id=\"%s\" %s> %s", $1, $3, $5, $8); }
    | string ClassList '(' PropsList ')' nl{ updateTags($1); asprintf(&$$, "<%s class=\"%s\" %s>", $1, $2, $4); }
    | string '#' string '(' PropsList ')' nl{ updateTags($1); asprintf(&$$, "<%s id=\"%s\" %s>", $1, $3, $5); }
    | string '(' PropsList ')' nl{ updateTags($1); asprintf(&$$,"<%s %s>",$1, $3); }
    | string '(' PropsList ')' ' ' Text nl{ updateTags($1); asprintf(&$$,"<%s %s> %s",$1, $3, $6); }
    ;

ClassList
    : ClassList '.' string { asprintf(&$$,"%s %s",$1, $3); }
    | '.' string { asprintf(&$$,"%s",$2); }
    ;

PropsList
    : PropsList ' ' Prop { asprintf(&$$,"%s %s",$1, $3); }
    | Prop { asprintf(&$$,"%s",$1); }
    ;

Prop
    : string '=' '\'' Text '\'' { asprintf(&$$,"%s=\"%s\"",$1, $4); }
    ;

Text
    : Text ' ' string { asprintf(&$$,"%s %s",$1, $3); }
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