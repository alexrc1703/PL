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

%token ERRO text li num head html hd title script body p
%type <vstring> text li head html  title Tag Pug SeqTags script body p


%%
Pug 
    : SeqTags  { printf("%s\n",$1);}
    ;
SeqTags 
        : SeqTags Tag  { asprintf(&$$,"%s\n%s",$1,$2); }
        | Tag          { asprintf(&$$,"%s",$1); }
        ;

Tag 
    : html  {char* aux=strdup($1);asprintf(&$$,"<%s lang=\"en\"></%s>\n",aux,aux);}
    | hd    {asprintf(&$$,"<head> </head>\n"); }
    | title text {asprintf(&$$,"<title>%s</title>\n", $2); }
    | script text text { char* fst = strtok($2,"'");
                    char* snd =strtok(NULL,"'");
                    asprintf(&$$,"<script %s\"%s\"> %s </script>\n" ,fst, snd, $3);}
    | body  {char* aux=strdup($1);asprintf(&$$,"<%s></%s>\n",aux,aux);}
    | head text { char* aux=strdup($2);
                  char* aux2=strdup($1);
                  asprintf(&$$,"<%s>%s</>",$1,aux);}
    | p text {asprintf(&$$,"<p>%s</p>",$2);}
    | li ' ' text { asprintf(&$$,"<li> %s </li>\n",$3);}
    | li '.' text { char*aux=strdup($3); 
                    char* fst=strtok(aux,"(");
                    char* snd=strtok(NULL,"'");
                    char* trd=strtok(NULL,"'");
                    //printf("<li class=\"%s\" %s\"%s\">\n",fst,snd,trd);
                    asprintf(&$$,"<li class=\"%s\" %s\"%s\">\n",fst,snd,trd);}
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