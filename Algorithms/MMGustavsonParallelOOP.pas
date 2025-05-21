unit MMGustavsonParallelOOP;

interface

uses
  MatrixMultiplierIntf, MatrixUtils, System.Threading;

type
  TGustavsonParallelSystemThreading = class(TInterfacedObject, IMatrixMultiplier)
  public
    function GetName: string;
    procedure Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
  end;

implementation

function TGustavsonParallelSystemThreading.GetName: string;
begin
  Result := 'Gustavson (Paralelo System.Threading)';
end;

procedure TGustavsonParallelSystemThreading.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer);
var
  A_cp, B_cp, C_cp: TMatrix;
begin
  A_cp := A;
  B_cp := B;
  C_cp := C;

  TParallel.For(0, M - 1,
    procedure(i: Integer)
    var
      j, p: Integer;
      aip: Double;
    begin
      for p := 0 to K - 1 do
      begin
        aip := A_cp[i * K + p];
        for j := 0 to N - 1 do
        begin
          C_cp[i * N + j] := C_cp[i * N + j] + aip * B_cp[p * N + j];
        end;
      end;
    end);
end;


end.
