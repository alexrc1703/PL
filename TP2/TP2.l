%{
#include "y.tab.h"
%}
%x LIState HeadState TitleState ScriptState DivState PState ContState UState SelfCState
%%

[ \t\n\r]  ;

html {yylval.vstring = strdup(yytext);return html;}

head return hd;

title { BEGIN TitleState; return title;}

script { BEGIN ScriptState; return script;}
<ScriptState>[\(].+ {yylval.vstring = strdup(yytext+1);return text;}
<ScriptState>if[ |\t][^\n]+ {yylval.vstring = strdup(yytext);BEGIN 0;return text;}

<TitleState>[ \t] ;
<TitleState>[^ |\t|\.|\#][^\n]+ {yylval.vstring = strdup(yytext);BEGIN 0;return text;}

body {yylval.vstring = strdup(yytext);return body;}

h[1-5]+ {BEGIN HeadState; yylval.vstring = strdup(yytext); return head;}
<HeadState>[ \t] ;
<HeadState>[^ |\t][^\n]+ {yylval.vstring = strdup(yytext);BEGIN 0;return text;}

# {BEGIN ContState; return divs;}
<ContState>[^ |\t][^\n]+ {yylval.vstring = strdup(yytext);BEGIN 0;return text;}

p {BEGIN PState; return p;}
<PState>.+[^\n] {yylval.vstring = strdup(yytext+1);BEGIN 0; return text;}

ul {BEGIN UState; return ul;}
<UState>.+[^\n] {yylval.vstring = strdup(yytext+1);BEGIN 0; return text;}

li { BEGIN LIState; return li;}
<LIState>[ \t\.\#] { return yytext[0]; }
<LIState>[^ |\t|\.|\#][^\n]+ {yylval.vstring = strdup(yytext);BEGIN 0;return text;}

(img|link|meta) {BEGIN SelfCState;yylval.vstring = strdup(yytext);return selfclose;}
<SelfCState>[ \t\.\#] { return yytext[0]; }
<SelfCState>[^ |\t|\.|\#][^\n]+ {yylval.vstring = strdup(yytext);BEGIN 0;return text;}




. return ERRO;

%%