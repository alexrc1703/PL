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
int posFile = 0; // Posiçao do ficheiro, se -1 entao o ficheiro nao existe
int warnings = 0;

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

void red() {
    printf("\033[1;31m");
}

void blue() {
    printf("\033[1;34m");
}

void green() {
    printf("\033[1;32m");
}

void yellow() {
    printf("\033[1;33m");
}

void cyen() {
    printf("\033[1;36m");
}

void reset() {
    printf("\033[0m");
}

void errorMemory() {
    red();
    printf("ERROR allocating memory! \n");
}

void errorCreatingDir(char* name) {
    red();
    printf("ERROR creating the directory %s !\n", name);
}

void errorCreatingFile(char* name) {
    red();
    printf("ERROR creating the file %s !\n", name);
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

%x DEFmeta DEFtree DEF

%%


^===[ \t\r\n]meta[\n] {BEGIN(DEFmeta); cyen(); printf(" Fetching meta data ... \n");}

<DEFmeta>email: {
    blue();
    printf(" Email ");
    reset();
    printf("=======");


    temp = strdup(yytext+7);
    author.email=strtok(temp,"\n");


    green();
    printf(" %s \n", author.email);
    blue();
}

<DEFmeta>author: {
    printf(" Name  ");
    reset();
    printf("=======");


    temp = strdup(yytext+8);
    author.name=strtok(temp,"\n");


    green();
    printf(" %s \n", author.name);
    blue();
}

<DEFmeta>.|\n {;}

<DEFmeta>^===[ \t\r\n]tree[\n] {BEGIN DEFtree; cyen(); printf("\n Fetching project structure ... \n \n");}

<DEFtree>\{\%name\%\}\/ {
                            blue();
                            printf(" Main directory ");
                            reset();
                            printf("=");

                            char *a = malloc(strlen(nomeDir) + 2);
                            if(a == NULL) {
                                errorMemory();
                                return 0;
                            }

                            printf("=");
                            snprintf(a, sizeof a, "%s/", nomeDir);
                            printf("=");

                            dir[dirLvl] = malloc(strlen(a) + 1);

                            if(dir[dirLvl] == NULL) {
                                errorMemory();
                                return 0;
                            }
                            printf("=");

                            strcpy(dir[dirLvl], a);
                            printf("=");

                            int status = mkdir(nomeDir, 0700);

                            if(status == -1) {
                                errorCreatingDir(nomeDir);
                                return 0;
                            }

                            green();
                            printf(" %s created \n", nomeDir);
                            reset();
                        }

<DEFtree>-+.*\/ {
                    // Acaba em \ logo é uma diretoria

                    blue();
                    printf(" Directory ");
                    reset();
                    printf("=");

                    // Calcula qual é o nivel da diretoria
                    int aux = 0;
                    char *token = strtok(yytext, " ");
                    aux = strlen(token);
                    dirLvl = aux;
                    printf("=");

                    // Guarda o nome da diretoria
                    token = strtok(NULL, " ");
                    char *result = NULL;
                    result = replaceWord(token, "{%name%}", nomeDir);
                    printf("=");

                    // Adicionar a nova diretoria no respetivo nivel
                    dir[dirLvl] = malloc(strlen(result) + 1);
                    if(dir[dirLvl] == NULL) {
                        errorMemory();
                        return 0;
                    }
                    printf("=");

                    strcpy(dir[dirLvl], result);
                    printf("=");

                    // Criar a diretoria
                    int pathTam = 0;
                    for(int i = 0; i<=dirLvl ; i++) {
                        pathTam += strlen(dir[i]);
                    }

                    char *path = malloc(pathTam + 1);
                    if(path == NULL) {
                        errorMemory();
                        return 0;
                    }
                    printf("=");

                    for (int i = 0; i<=dirLvl; i++) {
                        strcat(path,dir[i]);
                    }
                    printf("=");

                    int status = mkdir(path, 0700);

                    if(status == -1) {
                        errorCreatingDir(result);
                        return 0;
                    }

                    green();
                    printf("    %s created in %s \n", result, dir[dirLvl - 1]);
                    reset();
                }

<DEFtree>-+.* {
                blue();
                printf(" File      ");
                reset();
                printf("=");

                // Calcula o nivel da diretoria
                int aux = 0;
                int i = 0;
                char *token = strtok(yytext, " ");
                aux = strlen(token);
                dirLvl = aux;
                printf("=");

                // Guarda o nome do file
                token = strtok(NULL, " ");
                printf("=");

                // Criar e guardar o path do novo ficheiro
                // Recolher tamanho do path
                int total = 0;
                while (i < dirLvl) {
                    total += strlen(dir[i]);
                    i++;
                }
                printf("=");

                char *path0 = malloc(total + 1);
                if (path0 == NULL) {
                    errorMemory();
                    return 0;
                }
                printf("=");

                // Adicionar as diretorias ao path
                i = 0;
                while(i < dirLvl) {
                    strcat(path0,dir[i]);
                    i++;
                }
                printf("=");

                // Verificar se existe variaveis e modificar
                char *result = NULL;
                result = replaceWord(token, "{%name%}", nomeDir);

                // Calcula o tamanho final do path e cria-o
                char *pathFinal = malloc(strlen(path0) + strlen(result) + 1);
                if (pathFinal == NULL) {
                    errorMemory();
                    return 0;
                }
                strcat(pathFinal,path0);
                strcat(pathFinal,result);
                printf("=");

                // Incrementa o numero total de files
                totalFiles++;

                // Guarda o file na estrutrura files
                files[totalFiles-1] = malloc(sizeof(struct File));
                if (files[totalFiles-1] == NULL) {
                    errorMemory();
                }
                files[totalFiles-1] = (createFile(result,pathFinal));
                printf("=");

                // Criar o ficheiro

                FILE *fp = fopen(pathFinal, "w");
                if (fp == NULL) {
                    errorCreatingFile(result);
                    return 0;
                }
                printf("=");
                fclose(fp);

                green();
                printf("  %s created in %s \n", result, path0);
                reset();
              }


<DEFtree>^=== {BEGIN DEF; cyen(); printf("\n Writing templates ... \n \n");}

<DEF>^===.*[\n] {
                            if(posFile == -1){
                                yellow();
                                printf(" 0%c \n",37);
                            }
                            else {
                                green();
                                printf(" 100%c \n",37);
                            }
                            blue();
                            printf(" In File ");
                            // Novo ficheiro
                            // Verificar se existe variaveis a modificar
                            char *result = NULL;
                            result = replaceWord(yytext+4, "{%name%}", nomeDir);

                            // Remover o \n
                            char *token = strtok(result, "\n");
                            printf("%s ", token);
                            reset();

                            // Verificar se existe este ficheiro na tree e definar a sua posicao
                            int i = 0;
                            int f = 0;
                            while ( i < totalFiles) {
                                if(strcmp(files[i]->name, token) == 0){
                                    posFile = i;
                                    f = 1;
                                }
                                i++;
                            }
                            printf("=====");
                            if (f != 1) {
                                yellow();
                                printf(" WARNING this file doesn't exist! \n ");
                                warnings++;
                                posFile = -1;
                            }
                            else {
                                green();
                                printf(" EXISTS \n ");
                            }
                        }

<DEF>.*[\n] {
                if (flag == 0) {
                    blue();
                    printf(" In File ");

                    // Verificar se existe variaveis e modificar
                    char *result = NULL;
                    result = replaceWord(yytext+1, "{%name%}", nomeDir);
                    flag++;

                    // Remover o \n
                    char *token = strtok(result, "\n");
                    printf("%s ", token);
                    reset();

                    // Verificar se existe este ficheiro na tree e definar a sua posicao
                    int i = 0;
                    int f = 0;
                    while ( i < totalFiles) {
                        if(strcmp(files[i]->name, token) == 0){
                            posFile = i;
                            f = 1;
                        }
                        i++;
                    }
                    printf("=====");
                    if (f != 1) {
                        yellow();
                        printf(" WARNING this file doesn't exist! \n ");
                        warnings++;
                        posFile = -1;
                    }
                    else {
                        green();
                        printf(" EXISTS \n ");
                    }
                }
                else {
                    if (posFile == -1){
                        yellow();
                        printf("*");
                    }
                    else {
                        // Verificar se existe variaveis e modificar
                        char *result = NULL;
                        result = replaceWord(yytext, "{%name%}", nomeDir);
                        result = replaceWord(result, "{%email%}", author.email);
                        result = replaceWord(result, "{%author%}", author.name);

                        // Escrever no ficheiro
                        char *filePath = malloc(strlen(files[posFile]->path));
                        if (filePath == NULL) {
                            errorMemory();
                        }
                        strcat(filePath,files[posFile]->path);

                        FILE *fptr;
                        fptr = fopen(filePath,"a");
                        if (fptr == NULL) {
                            red();
                            printf("ERROR writing in file %s !\n", files[posFile]->name);
                            return 0;
                        }
                        fprintf(fptr,"%s",result);
                        fclose(fptr);

                        green();
                        printf("*");
                    }
                }
            }

<*>.[\n] {;}

<<EOF>> { if(posFile == -1){ yellow(); printf(" 0%c \n\n\n",37); } else {printf(" 100%c \n\n\n",37);} if(warnings == 0) { printf("All seems fine!\n");} else { yellow(); printf("Seems that you have some warnings!\n");} return 0;}

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