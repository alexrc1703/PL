%option noyywrap

%{
    /* Declaracoes C diversas */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

char* nomeDir;
char* temp;
int flag = 0;
char *dir[100];
struct File *files[100];
int dirLvl = 0;
int totalFiles = 0;
int posFile = 0;

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
                        }

<DEFtree>-+.*\/ {
                    int aux = 0;
                    char *token = strtok(yytext, " ");
                    aux = strlen(token);
                    token = strtok(NULL, " ");
                    dirLvl = aux;
                    dir[dirLvl] = malloc(strlen(token) + 1);
                    char *result = NULL;
                    result = replaceWord(token, "{%name%}", nomeDir);
                    strcpy(dir[dirLvl], result);
                }

<DEFtree>-+.* {
                int aux = 0;
                int i = 0;
                char *token = strtok(yytext, " ");
                aux = strlen(token);
                token = strtok(NULL, " ");
                dirLvl = aux;
                int total = 0;
                while (i < dirLvl) {
                    total += strlen(dir[i]);
                    i++;
                }
                i = 0;
                char *path0 = malloc(total + 1);
                while(i < dirLvl) {
                    strcat(path0,dir[i]);
                    i++;
                }
                char *result = NULL;
                result = replaceWord(token, "{%name%}", nomeDir);
                char *pathFinal = malloc(strlen(path0) + strlen(result) + 1);
                strcat(pathFinal,path0);
                strcat(pathFinal,result);
                totalFiles++;
                files[totalFiles-1] = malloc(sizeof(struct File));
                files[totalFiles-1] = (createFile(result,pathFinal));
              }


<DEFtree>^=== {BEGIN DEF;}

<DEF>^===[ \t\r\n].*[\n] {
                            char *result = NULL;
                            result = replaceWord(yytext+4, "{%name%}", nomeDir);
                            int i = 0;
                            char *token = strtok(result, "\n");
                            while ( i < totalFiles) {
                                printf("ENTAO: %d\n", strcmp(files[i]->name, result));
                                printf("FILES: %s, %s\n", files[i]->name, result);
                                i++;
                            }
                        }

<DEF>.*[\n] {
                if (flag == 0) {
                    char *result = NULL;
                    result = replaceWord(yytext, "{%name%}", nomeDir);
                    result = replaceWord(result, "{%email%}", author.email);
                    result = replaceWord(result, "{%author%}", author.name);
                    flag++;
                    int i = 0;
                    while ( i < totalFiles) {
                        printf("ENTAO: %d\n", strcmp(files[i]->name, result));
                        printf("FILES: %s\n", files[i]->name);
                        i++;
                    }
                }
                else {
                    char *result = NULL;
                    result = replaceWord(yytext, "{%name%}", nomeDir);
                    result = replaceWord(result, "{%email%}", author.email);
                    result = replaceWord(result, "{%author%}", author.name);
                    printf("escreve isto no file %s: %s", files[posFile]->name, result);
                    /* FILE *fptr;
                    fptr = fopen(file[posFile]->path,w);
                    fprintf(fptr,"%s",result);
                    fclose(fptr); */
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