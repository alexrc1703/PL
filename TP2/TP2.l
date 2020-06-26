%{
#include "y.tab.h"
%}
%x LIState
%%
[ \t\n\r] ;



li { BEGIN LIState; return li;}
<LIState>[ \t\.\#] { return yytext[0]; }

<LIState>[^ |\t|\.|\#][^\n]+ {yylval.vstring = strdup(yytext);BEGIN 0;return text;}





. return ERRO;

%%