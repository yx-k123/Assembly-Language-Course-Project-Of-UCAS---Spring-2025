#include <stdio.h>
extern void bubblesort(int *, int);

#if 1
void bubbleSort(int arr[], int n)
{
	int i,j,temp;

	for(i=0; i<n-1; i++) 
	{
		for(j=0; j<n-i-1; j++)
		{
			if(arr[j] > arr[j+1]) 
			{
				temp = arr[j];
				arr[j] = arr[j+1];
				arr[j+1] = temp;
			}
		}
	}
}
#endif

int main()
{
	int arr[] = { 64, 34, 25, 12, 22, 11, 90};
	int n = sizeof(arr)/sizeof(arr[0]);
	//bubbleSort(arr, n);
	bubblesort(arr, n);
	for(int i=0; i<n; i++)
	{
		printf("%d ", arr[i]);
	}
	return 0;
}
