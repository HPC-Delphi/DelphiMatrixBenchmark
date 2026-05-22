unit Utils;

interface

uses
  SysUtils;

type
  TMatrix = array of Double;

procedure InitMatrixZero(var M: TMatrix; Size: Integer);
procedure InitMatrix(var M: TMatrix; Size: Integer);
procedure TransposeMatrix(var B: TMatrix; var B_t: TMatrix; K, N: Integer);
procedure PrintMatrix(var M: TMatrix; Rows, Columns: Integer);

implementation

procedure InitMatrixZero(var M: TMatrix; Size: Integer);
begin
  for var i := 0 to Size - 1 do
    M[i] := 0.0;
end;

procedure InitMatrix(var M: TMatrix; Size: Integer);
begin
  Randomize;

  for var i := 0 to Size - 1 do
    M[i] := Random + 1;
end;

procedure TransposeMatrix(var B: TMatrix; var B_t: TMatrix; K, N: Integer);
begin
  for var i := 0 to K - 1 do
    for var j := 0 to N - 1 do
      B_t[j * K + i] := B[i * N + j];
end;

procedure PrintMatrix(var M: TMatrix; Rows, Columns: Integer);
var
  i, j: Integer;
begin
  for i := 0 to Rows - 1 do
  begin
    for j := 0 to Columns - 1 do
      Write(Format('%.4f ', [M[i * Rows + j]]));
    Writeln;
  end;
  Writeln;
  Flush(Output);
end;

end.
