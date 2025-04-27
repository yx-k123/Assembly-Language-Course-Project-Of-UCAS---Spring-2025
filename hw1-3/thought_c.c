#include<stdio.h>

int is_prime(int n);

int main()
{
    int sum = 0;
    int i = 1;
    while (i <= 1000){
        if(is_prime(i)){
            sum += i;
            printf("%d ", i);
        }
        i++;
    }
    printf("\n%d\n", sum);
    return 0;
}

int is_prime(int n)
{
    if (n <= 1){
        return 0;
    }
    for (int i = 2; i < n; i++){
        if (n % i == 0){
            return 0;
        }
    }
    return 1;
}