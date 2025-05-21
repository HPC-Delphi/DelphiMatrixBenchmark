unit MMGustavsonOmniOOP;

interface

uses
  MatrixMultiplierIntf, MatrixUtils, OtlParallel;

type
  TGustavsonParallelOmni = class(TInterfacedObject, IMatrixMultiplier)
  public
    function GetName: string;
    procedure Multiply(var A, B, C: array of Double; M, K, N, T: Integer);
  end;

implementation

function TGustavsonParallelOmni.GetName: string;
begin
  Result := 'Gustavson (Paralelo OmniThreadLibrary)';
end;

procedure TGustavsonParallelOmni.Multiply(var A, B, C: array of Double; M, K, N, T: Integer);
begin
  Parallel.For(0, M - 1).NumTasks(T).Execute(
    procedure(i: Integer)
    var
      j, p: Integer;
      aip: Double;
    begin
      for p := 0 to K - 1 do
      begin
        aip := A[i * K + p];
        for j := 0 to N - 1 do
          C[i * N + j] := C[i * N + j] + aip * B[p * N + j];
      end;
    end);
end;

end.
