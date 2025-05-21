unit MMGustavsonOOP;

interface

uses
  MatrixMultiplierIntf;

type
  TGustavsonSequential = class(TInterfacedObject, IMatrixMultiplier)
  public
    function GetName: string;
    procedure Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
  end;

implementation

function TGustavsonSequential.GetName: string;
begin
  Result := 'Gustavson (Secuencial)';
end;

procedure TGustavsonSequential.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
var
  i, j, p: Integer;
  aip: Double;
begin
  for i := 0 to M - 1 do
    for p := 0 to K - 1 do
    begin
      aip := A[i * K + p];
      for j := 0 to N - 1 do
        C[i * N + j] := C[i * N + j] + aip * B[p * N + j];
    end;
end;

end.
