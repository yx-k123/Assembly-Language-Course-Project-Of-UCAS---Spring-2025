#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int findfirst1(char* str);
int main()
{
    int c;
    char *str = (char*)malloc(100 * sizeof(char));
    while((c = getchar()) != EOF && c != '\n')
    {
        str[strlen(str)] = c;
    }
    str[strlen(str)] = '\0';

    int result = findfirst1(str);
    // printf("%s\n", str);
    printf("%d\n", result);
    free(str);
    return 0;
}