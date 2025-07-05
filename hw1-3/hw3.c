#include <stdio.h>

int main()
{   
    int sum = 0;

    for (int i = 1; i<=100; i++){
        sum += 2*i-1;
    }
    printf("%d\n", sum);
    return 0;
}