import time
import random

def matrix_multiplication(A, B):
    nrows, ncols = len(A), len(B[0])
    C = [[0] * ncols for _ in range(nrows)]
    for i in range(nrows):
        for j in range(ncols):
            for k in range(len(B)):
                C[i][j] += A[i][k] * B[k][j]
    return C

def main():
    size = 1024
    A = [[random.randint(0, 100) for _ in range(size)] for _ in range(size)]
    B = [[random.randint(0, 100) for _ in range(size)] for _ in range(size)]

    start = time.time()
    C = matrix_multiplication(A, B)
    end = time.time()

    print(f"Matrix multiplication of {size}x{size} matrices took {end - start:.2f} seconds.")

if __name__ == "__main__":
    main()