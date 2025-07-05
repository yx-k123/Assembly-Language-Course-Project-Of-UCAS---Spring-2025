#include <stdio.h>
#include <stdlib.h>

extern void reverse(int *p, int len);
int main()
{   
    int len = 0;
    scanf("%d", &len);
    int *p = (int *)malloc(len * sizeof(int));
    if (p == NULL)
    {
        printf("Memory allocation failed\n");
        return 1;
    }
    for (int i = 0; i < len; i++)
    {
        scanf("%d", &p[i]);
    }

    reverse(p, len);
    for (int i = 0; i < len; i++)
    {
        printf("%d ", p[i]);
    }
    printf("\n");
    free(p);
    return 0;
}