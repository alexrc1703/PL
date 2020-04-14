%option noyywrap

%{
    /* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <sys/stat.h>

char* nomeDir; // Nome do Projecto
char* temp;
int flag = 0;   // flag que permite saber se é o primeiro file ou nao
char *dir[100]; // Array de diretorias que formam o path de cada ficheiro
struct File *files[100]; // lista de ficheiros
int dirLvl = 0; // Nivel das diretorias
int totalFiles = 0; // Numero total de ficheiros
int posFile = 0; // Posiçao do ficheiro

struct Author {
        char* name;
        char* email;
    }author;

struct File {
        char* name;
        char* path;
    }file;

struct File * createFile(char * name, char * path) {
    struct File *a = malloc(sizeof(struct File));
    a->name = name;
    a->path = path;
    return a;
}

void initAuthor() {
    author.name = (char*) calloc(64,sizeof(char*));
    author.email = (char*) calloc(128,sizeof(char*));
}

// Função auxiliar filtar as variaveis
char *replaceWord(const char *s, const char *oldW, const char *newW)
{
    char *result;
    int i, cnt = 0;
    int newWlen = strlen(newW);
    int oldWlen = strlen(oldW);

    // Counting the number of times old word
    // occur in the string
    for (i = 0; s[i] != '\0'; i++)
    {
        if (strstr(&s[i], oldW) == &s[i])
        {
            cnt++;

            // Jumping to index after the old word.
            i += oldWlen - 1;
        }
    }

    // Making new string of enough length
    result = (char *)malloc(i + cnt * (newWlen - oldWlen) + 1);

    i = 0;
    while (*s)
    {
        // compare the substring with the result
        if (strstr(s, oldW) == s)
        {
            strcpy(&result[i], newW);
            i += newWlen;
            s += oldWlen;
        }
        else
            result[i++] = *s++;
    }
    result[i] = '\0';
    return result;
}

%}

nome \{\%name\%\}
%x DEFmeta DEFtree DEF

%%


^===[ \t\r\n]meta[\n] {BEGIN(DEFmeta);}

<DEFmeta>email: {
     temp = strdup(yytext+7);
     author.email=strtok(temp,"\n");
}

<DEFmeta>author: {
     temp = strdup(yytext+8);
     author.name=strtok(temp,"\n");
}

<DEFmeta>^===[ \t\r\n]tree[\n] {BEGIN DEFtree;}

<DEFmeta>.|\n {;}

<DEFtree>\{\%name\%\}\/ {
                            char *a = malloc(strlen(nomeDir) + 2);
                            snprintf(a, sizeof a, "%s/", nomeDir);
                            dir[dirLvl] = malloc(strlen(a) + 1);
                            strcpy(dir[dirLvl], a);
                            mkdir(nomeDir, 0700);
                        }

<DEFtree>-+.*\/ {
                    // Acaba em \ logo é uma diretoria
                    int aux = 0;
                    char *token = strtok(yytext, " ");
                    aux = strlen(token);
                    token = strtok(NULL, " ");
                    dirLvl = aux;

                    // Adicionar a nova diretoria no respetivo nivel
                    dir[dirLvl] = malloc(strlen(token) + 1);
                    char *result = NULL;
                    result = replaceWord(token, "{%name%}", nomeDir);
                    strcpy(dir[dirLvl], result);

                    // Criar a diretoria
                    int pathTam = 0;
                    for(int i = 0; i<=dirLvl ; i++) {
                        pathTam += strlen(dir[i]);
                    }
                    char *path = malloc(pathTam + 1);
                    for (int i = 0; i<=dirLvl; i++) {
                        strcat(path,dir[i]);
                    }
                    // controlo erros !!!
                    mkdir(path, 0700);
                }

<DEFtree>-+.* {
                int aux = 0;
                int i = 0;
                char *token = strtok(yytext, " ");
                aux = strlen(token);
                token = strtok(NULL, " ");
                dirLvl = aux;
                int total = 0;

                // Criar e guardar o path do novo ficheiro
                // Recolher tamanho do path
                while (i < dirLvl) {
                    total += strlen(dir[i]);
                    i++;
                }
                i = 0;
                char *path0 = malloc(total + 1);

                // Adicionar as diretorias ao path
                while(i < dirLvl) {
                    strcat(path0,dir[i]);
                    i++;
                }

                // Verificar se existe variaveis e modificar
                char *result = NULL;
                result = replaceWord(token, "{%name%}", nomeDir);
                char *pathFinal = malloc(strlen(path0) + strlen(result) + 1);
                strcat(pathFinal,path0);
                strcat(pathFinal,result);
                totalFiles++;
                files[totalFiles-1] = malloc(sizeof(struct File));
                files[totalFiles-1] = (createFile(result,pathFinal));

                // Criar o ficheiro
                // Controlo erros!!!
                FILE *fp = fopen(pathFinal, "w");
                fclose(fp);
              }


<DEFtree>^=== {BEGIN DEF;}

<DEF>^===.*[\n] {
                            // Verificar se existe variaveis e modificar
                            char *result = NULL;
                            result = replaceWord(yytext+4, "{%name%}", nomeDir);
                            int i = 0;

                            // Remover o \n
                            char *token = strtok(result, "\n");

                            // Verificar se existe este ficheiro na tree e definar a sua posicao
                            while ( i < totalFiles) {
                                if(strcmp(files[i]->name, result) == 0){
                                    posFile = i;
                                }
                                i++;
                            }
                        }

<DEF>.*[\n] {
                if (flag == 0) {

                    // Verificar se existe variaveis e modificar
                    char *result = NULL;
                    result = replaceWord(yytext+1, "{%name%}", nomeDir);
                    flag++;
                    int i = 0;

                    // Remover o \n
                    char *token = strtok(result, "\n");

                    // Verificar se existe este ficheiro na tree e definar a sua posicao
                    while ( i < totalFiles) {
                        if(strcmp(files[i]->name, token) == 0){
                            posFile = i;
                        }
                        i++;
                    }
                }
                else {

                    // Verificar se existe variaveis e modificar
                    char *result = NULL;
                    result = replaceWord(yytext, "{%name%}", nomeDir);
                    result = replaceWord(result, "{%email%}", author.email);
                    result = replaceWord(result, "{%author%}", author.name);

                    // Escrever no ficheiro
                    printf("escreve isto no file %s: %s", files[posFile]->name, result);
                    char *filePath = malloc(strlen(files[posFile]->path));
                    strcat(filePath,files[posFile]->path);
                    FILE *fptr;
                    fptr = fopen(filePath,"a");
                    fprintf(fptr,"%s",result);
                    fclose(fptr);
                }
            }


<*>.|\n {;}

<<EOF>> {return 0;}

%%
int main(int argc, char** argv)
{
   if(argc>1){

        nomeDir=strdup(argv[1]);
        yyin = fopen(argv[2], "r");
        yylex();
        fclose(yyin);
    }
    else {
        return -1;
    }
    return 1;
}