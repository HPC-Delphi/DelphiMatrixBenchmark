unit DelphiStrassen;

interface

uses
  MatrixMultiplierIntf, DelphiBase;

type
  TDelphiStrassen = class(TInterfacedObject, IMatrixMultiplier)
  public
    function GetName: string;
    procedure Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
  end;

const
  THRESHOLD = 64;

implementation

procedure AddMatrices(var A, B, C: TMatrix; Row, Col: Integer);
var
  I, J : Integer;
begin
  for I := 0 to Row - 1 do
    for J := 0 to Col - 1 do
      C[I * Col + J] := A[I * Col + J] + B[I * Col + J];
end;

procedure SubtractMatrices(var A, B, C: TMatrix; Row, Col: Integer);
var
  I, J : Integer;
begin
  for I := 0 to Row - 1 do
    for J := 0 to Col - 1 do
      C[I * Col + J] := A[I * Col + J] - B[I * Col + J];
end;

function TDelphiStrassen.GetName: string;
begin
  Result := 'delphi_strassen';
end;

procedure TDelphiStrassen.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
var
  M2, K2, N2: Integer;
  A11, A12, A21, A22: TMatrix;
  B11, B12, B21, B22: TMatrix;
  M1, M2Arr, M3, M4, M5, M6, M7: TMatrix;
  A11_plus_A22, B11_plus_B22: TMatrix;
  C11, C12, C21, C22: TMatrix;
  i, j: Integer;
  Base: IMatrixMultiplier;
begin
  // Base case: use Gustavson algorithm when dimensions are small
  if (M <= THRESHOLD) or (K <= THRESHOLD) or (N <= THRESHOLD) then
  begin
    Base:= TDelphiBase.Create;
    Base.Multiply(A, B, C, M, K, N, T);
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
  Self.Multiply(A11_plus_A22, B11_plus_B22, M1, M2, K2, N2, T);

  // M2 = (A21 + A22) * B11
  SetLength(A11_plus_A22, (M - M2) * K2);
  AddMatrices(A21, A22, A11_plus_A22, M - M2, K2);
  Self.Multiply(A11_plus_A22, B11, M2Arr, M - M2, K2, N2, T);

  // M3 = A11 * (B12 - B22)
  SetLength(B11_plus_B22, K2 * (N - N2));
  SubtractMatrices(B12, B22, B11_plus_B22, K2, N - N2);
  Self.Multiply(A11, B11_plus_B22, M3, M2, K2, N - N2, T);

  // M4 = A22 * (B21 - B11)
  SetLength(B11_plus_B22, (K - K2) * N2);
  subtractMatrices(B21, B11, B11_plus_B22, K - K2, N2);
  Self.Multiply(A22, B11_plus_B22, M4, M - M2, K - K2, N2, T);

  // M5 = (A11 + A12) * B22
  SetLength(A11_plus_A22, M2 * (K - K2));
  AddMatrices(A11, A12, A11_plus_A22, M2, K - K2);
  Self.Multiply(A11_plus_A22, B22, M5, M2, K - K2, N - N2, T);

  // M6 = (A21 - A11) * (B11 + B12)
  SetLength(A11_plus_A22, (M - M2) * K2);
  subtractMatrices(A21, A11, A11_plus_A22, M - M2, K2);
  SetLength(B11_plus_B22, K2 * (N - N2));
  AddMatrices(B11, B12, B11_plus_B22, K2, N - N2);
  Self.Multiply(A11_plus_A22, B11_plus_B22, M6, M - M2, K2, N - N2, T);

  // M7 = (A12 - A22) * (B21 + B22)
  SetLength(A11_plus_A22, M2 * (K - K2));
  subtractMatrices(A12, A22, A11_plus_A22, M2, K - K2);
  SetLength(B11_plus_B22, (K - K2) * N2);
  AddMatrices(B21, B22, B11_plus_B22, K - K2, N2);
  Self.Multiply(A11_plus_A22, B11_plus_B22, M7, M2, K - K2, N2, T);

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

end.
