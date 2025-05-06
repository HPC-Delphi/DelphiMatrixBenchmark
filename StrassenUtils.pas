unit StrassenUtils;

interface

uses
  MatrixUtils;

procedure AddMatrices(var A, B, C: TDoubleArray;
  Row, Col: Integer);

procedure SubtractMatrices(var A, B, C: TDoubleArray;
  Row, Col: Integer);

const
  THRESHOLD : Integer = 64;

implementation

procedure AddMatrices(var A, B, C: TDoubleArray;
  Row, Col: Integer);
var
  I, J : Integer;
begin
  for I := 0 to Row - 1 do
    for J := 0 to Col - 1 do
      C[I * Col + J] := A[I * Col + J] + B[I * Col + J];
end;

procedure SubtractMatrices(var A, B, C: TDoubleArray;
  Row, Col: Integer);
var
  I, J : Integer;
begin
  for I := 0 to Row - 1 do
    for J := 0 to Col - 1 do
      C[I * Col + J] := A[I * Col + J] - B[I * Col + J];
end;

end.
