unit OpenMPMatrixLib;

interface

uses
  System.SysUtils;

/// <summary>
/// Performs parallel matrix multiplication using OpenMP.
/// </summary>
/// <remarks>
/// This function multiplies two square matrices of size N x N in parallel using OpenMP,
/// storing the result in the matrix C. The number of threads used for the computation
/// is determined by the parameter T.
/// </remarks>
/// <param name="A">
/// Pointer to the first matrix (input matrix).
/// </param>
/// <param name="B">
/// Pointer to the second matrix (input matrix).
/// </param>
/// <param name="C">
/// Pointer to the result matrix (output matrix).
/// </param>
/// <param name="N">
/// The dimension of the matrices (N x N).
/// </param>
/// <param name="T">
/// Number of threads to use in the parallel computation.
/// </param>
/// <example>
/// <code>
/// var
///   A, B, C: array of Double;
///   T: Integer;
/// begin
///   T := 4; // Use 4 threads
///   MulMatNaive(@A[0], @B[0], @C[0], N, T);
/// end;
/// </code>
/// </example>
procedure MulMatNaive(A, B, C: PDouble; N, T: Integer); cdecl; external 'openmp_matrix_lib.dll' name 'mm_naive';

/// <summary>
/// Performs matrix multiplication using the Strassen algorithm with OpenMP.
/// </summary>
/// <remarks>
/// This function multiplies two square matrices of size N x N using the Strassen algorithm,
/// with parallelization provided by OpenMP. It is assumed that N is a power of 2.
/// </remarks>
/// <param name="A">
/// Pointer to the first matrix (input matrix).
/// </param>
/// <param name="B">
/// Pointer to the second matrix (input matrix).
/// </param>
/// <param name="C">
/// Pointer to the result matrix (output matrix).
/// </param>
/// <param name="N">
/// The dimension of the matrices (N x N). Must be a power of 2.
/// </param>
/// <param name="T">
/// Number of threads to use in the parallel computation.
/// </param>
/// <example>
/// <code>
/// var
///   A, B, C: array of Double;
///   T: Integer;
/// begin
///   T := 8; // Use 8 threads
///   MulMatStrassen(@A[0], @B[0], @C[0], N, T);
/// end;
/// </code>
/// </example>
procedure MulMatStrassen(A, B, C: PDouble; N, T: Integer); cdecl; external 'openmp_matrix_lib.dll' name 'mm_strassen';

implementation

end.

