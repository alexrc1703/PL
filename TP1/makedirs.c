// C program to create a folder 

#include <stdlib.h>
#include <stdio.h> 
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
int main() 
{ 
struct stat st = {0};

if (stat("/Users/alexandre.costa/PL_Projectos/directory", &st) == -1) {
    mkdir("/Users/alexandre.costa/PL_Projectos/directory", 0700);
}
printf("good\n");
FILE *fp;
fp = fopen ("~/PL_Projectos/directory/teste.c", " O_RDWR");
fclose (fp);

return 0;
} 