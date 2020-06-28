%{
#include "y.tab.h"
%}
%option yylineno
%%
[ ] ;

([\t]|\ \ \ \ )+ {yylval.vstring = strdup(yytext); return tabs;}

[\n\r] {return nl;}

[\(\)\=\'#\.] {return yytext[0];}

[a-zA-Z0-9]+ {yylval.vstring = strdup(yytext); return string;}

. return ERRO;

%%