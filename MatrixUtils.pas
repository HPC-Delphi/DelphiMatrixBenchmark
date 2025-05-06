unit MatrixUtils;

interface

type
  TMatrix = array of Double;
  PMatrix = ^TMatrix;
  TMM = procedure(var A, B, C: TMatrix; M, K, N, T: Integer);

procedure AddMatrices(var A, B, C: TMatrix;
  Row, Col: Integer);

procedure SubtractMatrices(var A, B, C: TMatrix;
  Row, Col: Integer);

implementation

procedure AddMatrices(var A, B, C: TMatrix;
  Row, Col: Integer);
var
  I, J : Integer;
begin
  for I := 0 to Row - 1 do
    for J := 0 to Col - 1 do
      C[I * Col + J] := A[I * Col + J] + B[I * Col + J];
end;

procedure SubtractMatrices(var A, B, C: TMatrix;
  Row, Col: Integer);
var
  I, J : Integer;
begin
  for I := 0 to Row - 1 do
    for J := 0 to Col - 1 do
      C[I * Col + J] := A[I * Col + J] - B[I * Col + J];
end;

end.
