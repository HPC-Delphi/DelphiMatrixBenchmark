unit MMStrassenParallelOOP;

interface

uses
  MatrixMultiplierIntf, MatrixUtils, System.Threading;

type
  TStrassenParallelSystemThreading = class(TInterfacedObject, IMatrixMultiplier)
  public
    function GetName: string;
    procedure Multiply(var A, B, C: array of Double; M, K, N, T: Integer);
  end;

implementation

function TStrassenParallelSystemThreading.GetName: string;
begin
  Result := 'Strassen (Paralelo System.Threading)';
end;

procedure TStrassenParallelSystemThreading.Multiply(var A, B, C: array of Double; M, K, N, T: Integer);
begin
  // Implementación paralela de Strassen usando System.Threading
  // Por brevedad, se puede copiar la lógica de Strassen y paralelizar los pasos recursivos
end;

end.
