// main.c
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <immintrin.h>
#include <malloc.h>  // for _aligned_malloc and _aligned_free on Windows

/**
 * @brief Reduce the packed single-precision (32-bit) floating-point elements in a by addition. Returns the sum of all elements in a.
 */
float _mm256_reduce_add_ps(__m256 a)
{
    a = _mm256_add_ps(a, _mm256_permute2f128_ps(a, a, 1));
    a = _mm256_hadd_ps(a, a);
    a = _mm256_hadd_ps(a, a);

    return _mm256_cvtss_f32(a);
}

// Your AVX-optimized matmul + bias
void linear_vec(const float *A, const float *B_t, float *C, const float *bias, int M, int K, int N)
{
    assert(((uintptr_t)A   % 32 == 0) &&
           ((uintptr_t)B_t % 32 == 0) &&
           ((uintptr_t)C   % 32 == 0) &&
           ((uintptr_t)bias% 32 == 0));

    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            __m256 vecSum = _mm256_setzero_ps();
            int k = 0;
            for (; k <= K - 8; k += 8) {
                __m256 vecA = _mm256_loadu_ps(&A[i*K + k]);
                __m256 vecB = _mm256_loadu_ps(&B_t[j*K + k]);
                vecSum = _mm256_add_ps(vecSum, _mm256_mul_ps(vecA, vecB));
            }
            float sum = _mm256_reduce_add_ps(vecSum);
            for (; k < K; k++)
                sum += A[i*K + k] * B_t[j*K + k];
            C[i*N + j] = sum + bias[j];
        }
    }
}

// Helper to print a matrix in row-major
void print_mat(const char* name, const float* M, int rows, int cols) {
    printf("%s =\n", name);
    for (int i = 0; i < rows; i++) {
        printf(" [");
        for (int j = 0; j < cols; j++) {
            printf(" %6.2f", M[i*cols + j]);
            if (j < cols-1) printf(",");
        }
        printf(" ]\n");
    }
    printf("\n");
}

int main(void)
{
    // Dimensions
    const int M = 3;
    const int K = 5;
    const int N = 4;

    // Allocate aligned memory (32-byte) for A, B, B_t, C, bias
    float *A    = (float*)_aligned_malloc(sizeof(float)*M*K,   32);
    float *B    = (float*)_aligned_malloc(sizeof(float)*K*N,   32);
    float *B_t  = (float*)_aligned_malloc(sizeof(float)*N*K,   32);
    float *C    = (float*)_aligned_malloc(sizeof(float)*M*N,   32);
    float *bias = (float*)_aligned_malloc(sizeof(float)*N,     32);

    if (!A||!B||!B_t||!C||!bias) {
        fprintf(stderr, "Allocation failed\n");
        return 1;
    }

    // Initialize A and B with some values
    for (int i = 0; i < M*K; i++)
        A[i] = (float)(i+1);           // 1,2,3,...
    for (int i = 0; i < K*N; i++)
        B[i] = (float)(i+1) * 0.5f;    // 0.5,1.0,1.5,...

    // Initialize bias
    for (int j = 0; j < N; j++)
        bias[j] = 1.0f;  // bias = [1,1,1,1]

    // Transpose B → B_t
    for (int i = 0; i < K; i++)
        for (int j = 0; j < N; j++)
            B_t[j*K + i] = B[i*N + j];

    // Print A, B, bias
    print_mat("A",    A,    M, K);
    print_mat("B",    B,    K, N);
    print_mat("bias", bias, 1, N);

    // Compute C = A * B + bias
    linear_vec(A, B_t, C, bias, M, K, N);

    // Print result
    print_mat("C", C, M, N);

    // Cleanup
    _aligned_free(A);
    _aligned_free(B);
    _aligned_free(B_t);
    _aligned_free(C);
    _aligned_free(bias);

    return 0;
}
