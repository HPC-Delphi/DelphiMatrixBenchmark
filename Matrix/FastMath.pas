unit FastMath;

interface

uses
  MatrixMultiplierIntf, Neslib.FastMath;

type
  TFastMath = class(TInterfacedObject, IMatrixMultiplier)
  public
    function GetName: string;
    procedure Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
  end;

implementation

function TFastMath.GetName: string;
begin
  Result := 'FastMath';
end;

procedure TransposeMatrix(const B: TMatrix; var B_t: TMatrix; K, N: Integer);
begin
  SetLength(B_t, N * K);
  for var i := 0 to K - 1 do
    for var j := 0 to N - 1 do
      B_t[j * K + i] := B[i * N + j];
end;

procedure TFastMath.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
var
  B_t: TMatrix;
  i, j, p: Integer;
  sum: Single;
  vecSum, vecA, vecB: TVector4;
  idxA, idxB: Integer;
  vlen: Integer;
begin
  TransposeMatrix(B, B_t, K, N);
  vlen := 4;

  for i := 0 to M - 1 do
    for j := 0 to N - 1 do
    begin
      vecSum := TVector4.Zero;

      p := 0;
      while p <= K - vlen do
      begin
        idxA := i * K + p;
        idxB := j * K + p;
        vecA.Init(A[idxA], A[idxA + 1], A[idxA + 2], A[idxA + 3]);
        vecB.Init(B_t[idxB], B_t[idxB + 1], B_t[idxB + 2], B_t[idxB + 3]);
        vecSum := FMA(vecA, vecB, vecSum);
        Inc(p, vlen);
      end;

      sum := vecSum.X + vecSum.Y + vecSum.Z + vecSum.W;

      while p < K do
      begin
        sum := sum + A[i * K + p] * B_t[j * K + p];
        Inc(p);
      end;

      C[i * N + j] := sum;
    end;
end;

end.


