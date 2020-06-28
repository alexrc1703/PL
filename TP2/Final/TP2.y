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
int lvl = 0;
char *tagsList[100];

char* manageTags(char *tabsR) {
    int newLvl = strlen(tabsR);
    char* close = "";
    if (newLvl <= lvl) {
        char* t = malloc(sizeof('\t')*lvl-newLvl);
        for(int i = lvl; i >= newLvl; i--){
            for(int j = 0; j < i; j++) t[j]='\t';
            t[i] = '\0';
            asprintf(&close,"%s%s</ %s>\n",close,t, tagsList[i]);
        }
    }
    lvl = newLvl;
    return close;
}

char* getTag(char* line) {
    char* token = strtok(line," ");
    token = strtok(token,">");
    return token;
}

char* closeTags() {
    char* t = malloc(sizeof('\t')*lvl);
    char* close = "";
    for(int i = lvl; i >= 0; i--){
        for(int j = 0; j < i; j++) t[j]='\t';
        t[i] = '\0';
        asprintf(&close,"%s%s</ %s>\n",close,t, tagsList[i]);
    }
    return close;
}



%}
%union{
    char* vstring;
    int vint;
}

%token ERRO tabs string nl
%type <vstring> LineList Line ClassList PropsList Text Prop Tag string tabs nl


%%

// Produto final
Pug
    : LineList {printf("%s\n%s\n", $1, closeTags());}
    ;

// Lista de linhas de código
LineList
    : LineList Line { asprintf(&$$,"%s\n%s",$1,$2); }
    | Line { asprintf(&$$,"%s",$1); }
    ;
// Linha de código
Line
    : Tag                                                   { asprintf(&$$,"%s",$1); tagsList[lvl] = strdup(getTag($1+1));}
    | tabs Tag                                              { char* res = manageTags($1); asprintf(&$$, "%s%s%s",res,$1,$2); tagsList[lvl] = strdup(getTag($2+1)); }
    | tabs '#' string nl                                    { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\">",res, $1 ,$3); char* div="div"; tagsList[lvl] = strdup(div);}
    | tabs '#' string '(' PropsList ')' nl                  { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\" %s>",res,$1 ,$3, $5); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs ClassList nl                                     { char* res = manageTags($1); asprintf(&$$, "%s%s<div class=\"%s\">",res,$1 ,$2); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs ClassList '(' PropsList ')' nl                   { char* res = manageTags($1); asprintf(&$$, "%s%s<div class=\"%s\" %s>",res,$1 ,$2, $4); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs '#' string ClassList nl                          { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\" class=\"%s\">",res,$1 ,$3, $4); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs ClassList '#' string nl                          { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\" class=\"%s\">",res,$1 ,$4, $2); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs '#' string ClassList '(' PropsList ')' nl        { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\" class=\"%s\" %s>",res,$1 ,$3, $4, $6); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs ClassList '#' string '(' PropsList ')' nl        { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\" class=\"%s\" %s>",res,$1 ,$4, $2, $6); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs '#' string ClassList '(' PropsList ')' Text nl   { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\" class=\"%s\" %s> %s",res,$1 ,$3, $4, $6, $8); char* div="div"; tagsList[lvl] = strdup(div); }
    | tabs ClassList '#' string '(' PropsList ')' Text nl   { char* res = manageTags($1); asprintf(&$$, "%s%s<div id=\"%s\" class=\"%s\" %s> %s",res,$1 ,$4, $2, $6, $8); char* div="div"; tagsList[lvl] = strdup(div); }
    ;

Tag
    : string nl                                                 {  asprintf(&$$, "<%s>",$1); }
    | string ' ' Text nl                                        {  asprintf(&$$, "<%s> %s",$1, $3);}
    | string '#' string nl                                      {  asprintf(&$$, "<%s id=\"%s\">",$1,$3);}
    | string ClassList nl                                       {  asprintf(&$$, "<%s class=\"%s\">",$1,$2); }
    | string ClassList ' ' Text nl                              {  asprintf(&$$, "<%s class=\"%s\"> %s",$1,$2,$4); }
    | string '#' string ClassList '(' PropsList ')' ' ' Text nl {  asprintf(&$$, "<%s id=\"%s\" class=\"%s\" %s> %s", $1, $3, $4, $6, $9); }
    | string ClassList '#' string '(' PropsList ')' ' ' Text nl {  asprintf(&$$, "<%s id=\"%s\" class=\"%s\" %s> %s", $1, $4, $2, $6, $9);}
    | string ClassList '(' PropsList ')' ' ' Text nl            {  asprintf(&$$, "<%s class=\"%s\" %s> %s", $1, $2, $4, $7); }
    | string '#' string '(' PropsList ')' ' ' Text nl           {  asprintf(&$$, "<%s id=\"%s\" %s> %s", $1, $3, $5, $8); }
    | string ClassList '(' PropsList ')' nl                     {  asprintf(&$$, "<%s class=\"%s\" %s>", $1, $2, $4); }
    | string '#' string '(' PropsList ')' nl                    {  asprintf(&$$, "<%s id=\"%s\" %s>", $1, $3, $5); }
    | string '(' PropsList ')' nl                               {  asprintf(&$$, "<%s %s>",$1, $3); }
    | string '(' PropsList ')' ' ' Text nl                      {  asprintf(&$$, "<%s %s> %s",$1, $3, $6);}
    ;

ClassList
    : ClassList '.' string  { asprintf(&$$,"%s %s",$1, $3); }
    | '.' string            { asprintf(&$$,"%s",$2); }
    ;

PropsList
    : PropsList ' ' Prop    { asprintf(&$$,"%s %s",$1, $3); }
    | Prop                  { asprintf(&$$,"%s",$1); }
    ;

Prop
    : string '=' '\'' Text '\'' { asprintf(&$$,"%s=\"%s\"",$1, $4); }
    ;

Text
    : Text ' ' string   { asprintf(&$$,"%s %s",$1, $3); }
    | string            { asprintf(&$$,"%s",$1); }
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