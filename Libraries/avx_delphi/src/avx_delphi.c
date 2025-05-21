#include "..\include\avx_delphi.h"

AVX_DELPHI_API int vlength_double(){ return VDOUBLE_LEN;}

AVX_DELPHI_API void vadd_double(double* A, double* B, double* C)
{
#if defined(__AVX__)
    __m256d vecA = _mm256_loadu_pd(A);
    __m256d vecB = _mm256_loadu_pd(B);
    __m256d result = _mm256_add_pd(vecA, vecB);
    _mm256_storeu_pd(C, result);
#elif defined(__SSE2__)
    __m128d vecA = _mm_loadu_pd(A);
    __m128d vecB = _mm_loadu_pd(B);
    __m128d result = _mm_add_pd(vecA, vecB);
    _mm_storeu_pd(C, result);
#else
    for (int i = 0; i < VDOUBLE_LEN; ++i)
        C[i] = A[i] + B[i];
#endif
}

AVX_DELPHI_API void vmul_double(double* A, double* B, double* C)
{
#if defined(__AVX__)
    __m256d vecA = _mm256_loadu_pd(A);
    __m256d vecB = _mm256_loadu_pd(B);
    __m256d result = _mm256_mul_pd(vecA, vecB);
    _mm256_storeu_pd(C, result);
#elif defined(__SSE2__)
    __m128d vecA = _mm_loadu_pd(A);
    __m128d vecB = _mm_loadu_pd(B);
    __m128d result = _mm_mul_pd(vecA, vecB);
    _mm_storeu_pd(C, result);
#else
    for (int i = 0; i < VDOUBLE_LEN; ++i)
        C[i] = A[i] * B[i];
#endif
}