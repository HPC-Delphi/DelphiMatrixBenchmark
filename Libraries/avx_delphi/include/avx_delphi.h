#pragma once

#ifdef AVX_DELPHI_EXPORTS
#define AVX_DELPHI_API __declspec(dllexport)
#else
#define AVX_DELPHI_API __declspec(dllimport)
#endif

#ifdef __AVX__
  #include <immintrin.h>
  typedef __m256d VDouble;
  #define VDOUBLE_LEN 4
#elif defined(__SSE2__)
  #include <emmintrin.h>
  typedef __m128d VDouble;
  #define VDOUBLE_LEN 2
#else
  typedef struct { double val; } VDouble;
  #define VDOUBLE_LEN 1
#endif

AVX_DELPHI_API int vlength_double();
AVX_DELPHI_API void vadd_double(double* A, double* B, double *C);
AVX_DELPHI_API void vmul_double(double* A, double* B, double *C);