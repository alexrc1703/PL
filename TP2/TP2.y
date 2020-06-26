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
    | li '.' text { char*aux=strdup($3); 
                    char* fst=strtok(aux,"(");
                    char* snd=strtok(NULL,"'");
                    char* trd=strtok(NULL,"'");
                    //printf("<li class=\"%s\" %s\"%s\">\n",fst,snd,trd);
                    asprintf(&$$,"<li class=\"%s\" %s\"%s\">\n",fst,snd,trd);}
    | li '#' text { char*aux=strdup($3);
                    char* fst=strtok(aux,".");
                    char* snd=strtok(NULL,"\n");
                  
                    printf("<li id=\"%s\" class=\"%s\"></li>\n",fst,snd);
                     asprintf(&$$,"<li id=\"%s\" class=\"%s\"></li>\n",fst,snd);}
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