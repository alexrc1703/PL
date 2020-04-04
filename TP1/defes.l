
filtroV1 pre intro da experiencia do goncalo
%%
^===[ \t\r\n]meta[ \t\r\n] {
    BEGIN DEFmeta;
    printf("online mal comeca a sc\n");


    }
<DEFmeta>^===[ \t\r\n]tree {BEGIN INITIAL;printf("imprimo email: %s nome: %s quando saio de sc\n", (temp),(sectemp));}
<DEFmeta>.* {
                //temp=strdup(yytext+6);
                //printf("imprimo EMAIL: %s !em livestream\n", (temp));
                email: sectemp=strdup(yytext+6);printf("EMAIL: %s\n",sectemp);

                author: temp=strdup(yytext+7); printf("AUTHOR: %s\n",temp);
            fazer com tokens
}

{nome} { printf("válido: %s\n", yytext); }


.|\n {}

%%