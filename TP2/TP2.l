%{
#include "y.tab.h"
%}
%%
[ \t\n\r] ;

[a-zA-Z]+[ \t\n\r][a-zA-Z]* { yylval.vstring = strdup(yytext); return text;}



. return ERRO;

%%