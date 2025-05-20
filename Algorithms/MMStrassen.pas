unit MMStrassen;

interface

uses
  System.Threading, OtlParallel, System.Generics.Collections,
  MatrixUtils, MMGustavson, OMPDelphi;

  {NativeDelphi}
procedure SeqStrassenNativeDelphi(var A, B, C: TMatrix;
  M, K, N, T: Integer); { No usa T }

  {System.Threading}
procedure ParStrassenSystemThreading(var A, B, C: TMatrix;
  M, K, N, T: Integer);

  { OpenMPMatrix }
procedure SeqStrassenOpenMPMatrix(var A, B, C: TMatrix;
  M, K, N, T: Integer); { No usa T }
procedure ParStrassenOpenMPMatrix(var A, B, C: TMatrix;
  M, K, N, T: Integer);

const
  THRESHOLD : Integer = 64;

implementation

  {Native Delphi}
procedure SeqStrassenNativeDelphi(var A, B, C: TMatrix;
  M, K, N, T: Integer); { No usa T }
var
  M2, K2, N2: Integer;
  A11, A12, A21, A22: TMatrix;
  B11, B12, B21, B22: TMatrix;
  M1, M2Arr, M3, M4, M5, M6, M7: TMatrix;
  A11_plus_A22, B11_plus_B22: TMatrix;
  C11, C12, C21, C22: TMatrix;
  i, j: Integer;
begin
  // Base case: use Gustavson algorithm when dimensions are small
  if (M <= THRESHOLD) or (K <= THRESHOLD) or (N <= THRESHOLD) then
  begin
    SeqGustavsonNativeDelphi(A, B, C, M, K, N, T);
    Exit;
  end;

  // Compute midpoints for splitting
  M2 := M div 2;
  K2 := K div 2;
  N2 := N div 2;

  // Allocate submatrices of A
  SetLength(A11, M2 * K2);
  SetLength(A12, M2 * (K - K2));
  SetLength(A21, (M - M2) * K2);
  SetLength(A22, (M - M2) * (K - K2));

  // Allocate submatrices of B
  SetLength(B11, K2 * N2);
  SetLength(B12, K2 * (N - N2));
  SetLength(B21, (K - K2) * N2);
  SetLength(B22, (K - K2) * (N - N2));

  // Extract submatrices from A
  for i := 0 to M2 - 1 do
    for j := 0 to K2 - 1 do
      A11[i*K2 + j] := A[i*K + j];

  for i := 0 to M2 - 1 do
    for j := 0 to (K - K2) - 1 do
      A12[i*(K - K2) + j] := A[i*K + K2 + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to K2 - 1 do
      A21[i*K2 + j] := A[(M2 + i)*K + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to (K - K2) - 1 do
      A22[i*(K - K2) + j] := A[(M2 + i)*K + K2 + j];

  // Extract submatrices from B
  for i := 0 to K2 - 1 do
    for j := 0 to N2 - 1 do
      B11[i*N2 + j] := B[i*N + j];

  for i := 0 to K2 - 1 do
    for j := 0 to (N - N2) - 1 do
      B12[i*(N - N2) + j] := B[i*N + N2 + j];

  for i := 0 to (K - K2) - 1 do
    for j := 0 to N2 - 1 do
      B21[i*N2 + j] := B[(K2 + i)*N + j];

  for i := 0 to (K - K2) - 1 do
    for j := 0 to (N - N2) - 1 do
      B22[i*(N - N2) + j] := B[(K2 + i)*N + N2 + j];

  // Allocate result blocks
  SetLength(M1,  M2 * N2);
  SetLength(M2Arr, M2 * (N - N2));
  SetLength(M3,  (M - M2) * N2);
  SetLength(M4,  (M - M2) * (N - N2));
  SetLength(M5,  M2 * (N - N2));
  SetLength(M6,  (M - M2) * N2);
  SetLength(M7,  (M - M2) * (N - N2));

  // M1 = (A11 + A22) * (B11 + B22)
  SetLength(A11_plus_A22, M2 * K2);
  SetLength(B11_plus_B22, K2 * N2);
  AddMatrices(A11, A22, A11_plus_A22, M2, K2);
  AddMatrices(B11, B22, B11_plus_B22, K2, N2);
  SeqStrassenNativeDelphi(A11_plus_A22, B11_plus_B22, M1, M2, K2, N2, T);

  // M2 = (A21 + A22) * B11
  SetLength(A11_plus_A22, (M - M2) * K2);
  AddMatrices(A21, A22, A11_plus_A22, M - M2, K2);
  SeqStrassenNativeDelphi(A11_plus_A22, B11, M2Arr, M - M2, K2, N2, T);

  // M3 = A11 * (B12 - B22)
  SetLength(B11_plus_B22, K2 * (N - N2));
  SubtractMatrices(B12, B22, B11_plus_B22, K2, N - N2);
  SeqStrassenNativeDelphi(A11, B11_plus_B22, M3, M2, K2, N - N2, T);

  // M4 = A22 * (B21 - B11)
  SetLength(B11_plus_B22, (K - K2) * N2);
  subtractMatrices(B21, B11, B11_plus_B22, K - K2, N2);
  SeqStrassenNativeDelphi(A22, B11_plus_B22, M4, M - M2, K - K2, N2, T);

  // M5 = (A11 + A12) * B22
  SetLength(A11_plus_A22, M2 * (K - K2));
  AddMatrices(A11, A12, A11_plus_A22, M2, K - K2);
  SeqStrassenNativeDelphi(A11_plus_A22, B22, M5, M2, K - K2, N - N2, T);

  // M6 = (A21 - A11) * (B11 + B12)
  SetLength(A11_plus_A22, (M - M2) * K2);
  subtractMatrices(A21, A11, A11_plus_A22, M - M2, K2);
  SetLength(B11_plus_B22, K2 * (N - N2));
  AddMatrices(B11, B12, B11_plus_B22, K2, N - N2);
  SeqStrassenNativeDelphi(A11_plus_A22, B11_plus_B22, M6, M - M2, K2, N - N2, T);

  // M7 = (A12 - A22) * (B21 + B22)
  SetLength(A11_plus_A22, M2 * (K - K2));
  subtractMatrices(A12, A22, A11_plus_A22, M2, K - K2);
  SetLength(B11_plus_B22, (K - K2) * N2);
  AddMatrices(B21, B22, B11_plus_B22, K - K2, N2);
  SeqStrassenNativeDelphi(A11_plus_A22, B11_plus_B22, M7, M2, K - K2, N2, T);

  // Combine results into C blocks
  SetLength(C11, M2 * N2);
  AddMatrices(M1, M4, C11, M2, N2);
  subtractMatrices(C11, M5, C11, M2, N2);
  AddMatrices(C11, M7, C11, M2, N2);

  SetLength(C12, M2 * (N - N2));
  AddMatrices(M3, M5, C12, M2, N - N2);

  SetLength(C21, (M - M2) * N2);
  AddMatrices(M2Arr, M4, C21, M - M2, N2);

  SetLength(C22, (M - M2) * (N - N2));
  AddMatrices(M1, M6, C22, M - M2, N - N2);
  subtractMatrices(C22, M2Arr, C22, M - M2, N - N2);
  AddMatrices(C22, M3, C22, M - M2, N - N2);

  // Store combined blocks back into C
  for i := 0 to M2 - 1 do
    for j := 0 to N2 - 1 do
      C[i*N + j] := C11[i*N2 + j];

  for i := 0 to M2 - 1 do
    for j := 0 to (N - N2) - 1 do
      C[i*N + N2 + j] := C12[i*(N - N2) + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to N2 - 1 do
      C[(M2 + i)*N + j] := C21[i*N2 + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to (N - N2) - 1 do
      C[(M2 + i)*N + N2 + j] := C22[i*(N - N2) + j];
end;

procedure ParStrassenSystemThreading(var A, B, C: TMatrix;
  M, K, N, T: Integer);
var
  M2, K2, N2: Integer;
  A11, A12, A21, A22: TMatrix;
  B11, B12, B21, B22: TMatrix;
  M1, M2Arr, M3, M4, M5, M6, M7: TMatrix;
  C11, C12, C21, C22: TMatrix;
  i, j: Integer;
  Task : ITask;
  TaskList : TList<ITask>;
begin
  // Base case: small matrices
  if (M <= THRESHOLD) or (K <= THRESHOLD) or (N <= THRESHOLD) then
  begin
    SeqGustavsonNativeDelphi(A, B, C, M, K, N, T);
    Exit;
  end;

  // Compute midpoints for splitting
  M2 := M div 2;
  K2 := K div 2;
  N2 := N div 2;

  // Allocate submatrices of A
  SetLength(A11, M2 * K2);
  SetLength(A12, M2 * (K - K2));
  SetLength(A21, (M - M2) * K2);
  SetLength(A22, (M - M2) * (K - K2));

  // Allocate submatrices of B
  SetLength(B11, K2 * N2);
  SetLength(B12, K2 * (N - N2));
  SetLength(B21, (K - K2) * N2);
  SetLength(B22, (K - K2) * (N - N2));

  // Extract submatrices from A
  for i := 0 to M2 - 1 do
    for j := 0 to K2 - 1 do
      A11[i*K2 + j] := A[i*K + j];

  for i := 0 to M2 - 1 do
    for j := 0 to (K - K2) - 1 do
      A12[i*(K - K2) + j] := A[i*K + K2 + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to K2 - 1 do
      A21[i*K2 + j] := A[(M2 + i)*K + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to (K - K2) - 1 do
      A22[i*(K - K2) + j] := A[(M2 + i)*K + K2 + j];

  // Extract submatrices from B
  for i := 0 to K2 - 1 do
    for j := 0 to N2 - 1 do
      B11[i*N2 + j] := B[i*N + j];

  for i := 0 to K2 - 1 do
    for j := 0 to (N - N2) - 1 do
      B12[i*(N - N2) + j] := B[i*N + N2 + j];

  for i := 0 to (K - K2) - 1 do
    for j := 0 to N2 - 1 do
      B21[i*N2 + j] := B[(K2 + i)*N + j];

  for i := 0 to (K - K2) - 1 do
    for j := 0 to (N - N2) - 1 do
      B22[i*(N - N2) + j] := B[(K2 + i)*N + N2 + j];

  // Allocate result blocks
  SetLength(M1,  M2 * N2);
  SetLength(M2Arr, M2 * (N - N2));
  SetLength(M3,  (M - M2) * N2);
  SetLength(M4,  (M - M2) * (N - N2));
  SetLength(M5,  M2 * (N - N2));
  SetLength(M6,  (M - M2) * N2);
  SetLength(M7,  (M - M2) * (N - N2));

      // Create tasks list
  TaskList := TList<ITask>.Create;
  try
    // M1 = (A11 + A22) * (B11 + B22)
    TaskList.Add(TTask.Run(procedure
      var A11_plus_A22, B11_plus_B22: TMatrix;
      begin
        SetLength(A11_plus_A22, m2 * k2);
        SetLength(B11_plus_B22, k2 * n2);
        AddMatrices(A11, A22, A11_plus_A22, m2, k2);
        AddMatrices(B11, B22, B11_plus_B22, k2, n2);
        ParStrassenSystemThreading(A11_plus_A22, B11_plus_B22, M1, m2, k2, n2, T);
        SetLength(A11_plus_A22, 0);
        SetLength(B11_plus_B22, 0);
      end));

    // M2 = (A21 + A22) * B11
    TaskList.Add(TTask.Run(procedure
      var A21_plus_A22: TMatrix;
      begin
        SetLength(A21_plus_A22, (m - m2) * k2);
        AddMatrices(A21, A22, A21_plus_A22, m - m2, k2);
        ParStrassenSystemThreading(A21_plus_A22, B11, M2Arr, m - m2, k2, n2, T);
        SetLength(A21_plus_A22, 0);
      end));

    // M3 = A11 * (B12 - B22)
    TaskList.Add(TTask.Run(procedure
      var B12_minus_B22: TMatrix;
      begin
        SetLength(B12_minus_B22, k2 * (n - n2));
        SubtractMatrices(B12, B22, B12_minus_B22, k2, n - n2);
        ParStrassenSystemThreading(A11, B12_minus_B22, M3, m2, k2, n - n2, T);
        SetLength(B12_minus_B22, 0);
      end));

    // M4 = A22 * (B21 - B11)
    TaskList.Add(TTask.Run(procedure
      var B21_minus_B11: TMatrix;
      begin
        SetLength(B21_minus_B11, (k - k2) * n2);
        SubtractMatrices(B21, B11, B21_minus_B11, k - k2, n2);
        ParStrassenSystemThreading(A22, B21_minus_B11, M4, m - m2, k - k2, n2, T);
        SetLength(B21_minus_B11, 0);
      end));

    // M5 = (A11 + A12) * B22
    TaskList.Add(TTask.Run(procedure
      var A11_plus_A12: TMatrix;
      begin
        SetLength(A11_plus_A12, m2 * (k - k2));
        AddMatrices(A11, A12, A11_plus_A12, m2, k - k2);
        ParStrassenSystemThreading(A11_plus_A12, B22, M5, m2, k - k2, n - n2, T);
        SetLength(A11_plus_A12, 0);
      end));

    // M6 = (A21 - A11) * (B11 + B12)
    TaskList.Add(TTask.Run(procedure
      var A21_minus_A11, B11_plus_B12: TMatrix;
      begin
        SetLength(A21_minus_A11, (m - m2) * k2);
        SetLength(B11_plus_B12, k2 * (n - n2));
        SubtractMatrices(A21, A11, A21_minus_A11, m - m2, k2);
        AddMatrices(B11, B12, B11_plus_B12, k2, n - n2);
        ParStrassenSystemThreading(A21_minus_A11, B11_plus_B12, M6, m - m2, k2, n - n2, T);
        SetLength(A21_minus_A11, 0);
        SetLength(B11_plus_B12, 0);
      end));

    // M7 = (A12 - A22) * (B21 + B22)
    TaskList.Add(TTask.Run(procedure
      var A12_minus_A22, B21_plus_B22: TMatrix;
      begin
        SetLength(A12_minus_A22, m2 * (k - k2));
        SetLength(B21_plus_B22, (k - k2) * n2);
        SubtractMatrices(A12, A22, A12_minus_A22, m2, k - k2);
        AddMatrices(B21, B22, B21_plus_B22, k - k2, n2);
        ParStrassenSystemThreading(A12_minus_A22, B21_plus_B22, M7, m2, k - k2, n2, T);
        SetLength(A12_minus_A22, 0);
        SetLength(B21_plus_B22, 0);
      end));

    // Wait for tasks
    for Task in TaskList do
      Task.Wait;
  finally
    TaskList.Free;
  end;

  // Combine results into C blocks
  SetLength(C11, M2 * N2);
  AddMatrices(M1, M4, C11, M2, N2);
  subtractMatrices(C11, M5, C11, M2, N2);
  AddMatrices(C11, M7, C11, M2, N2);

  SetLength(C12, M2 * (N - N2));
  AddMatrices(M3, M5, C12, M2, N - N2);

  SetLength(C21, (M - M2) * N2);
  AddMatrices(M2Arr, M4, C21, M - M2, N2);

  SetLength(C22, (M - M2) * (N - N2));
  AddMatrices(M1, M6, C22, M - M2, N - N2);
  subtractMatrices(C22, M2Arr, C22, M - M2, N - N2);
  AddMatrices(C22, M3, C22, M - M2, N - N2);

  // Store combined blocks back into C
  for i := 0 to M2 - 1 do
    for j := 0 to N2 - 1 do
      C[i*N + j] := C11[i*N2 + j];

  for i := 0 to M2 - 1 do
    for j := 0 to (N - N2) - 1 do
      C[i*N + N2 + j] := C12[i*(N - N2) + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to N2 - 1 do
      C[(M2 + i)*N + j] := C21[i*N2 + j];

  for i := 0 to (M - M2) - 1 do
    for j := 0 to (N - N2) - 1 do
      C[(M2 + i)*N + N2 + j] := C22[i*(N - N2) + j];
end;

procedure SeqStrassenOpenMPMatrix(var A, B, C: TMatrix;
M, K, N, T: Integer);
begin
  MMSeqStrassen(@A[0], @B[0], @C[0], M, K, N);
end;

procedure ParStrassenOpenMPMatrix(var A, B, C: TMatrix;
M, K, N, T: Integer);
begin
  MMParStrassen(@A[0], @B[0], @C[0], M, K, N, T);
end;

end.

