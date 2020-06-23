%{
#include "y.tab.h"
%}
%%
[ \t\n\r] ;

[a-zAz][ \t\n\r] {      ;return Pal;}

. return ERRO;

%%