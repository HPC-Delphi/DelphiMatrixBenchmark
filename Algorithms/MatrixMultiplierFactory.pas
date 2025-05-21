unit MatrixMultiplierFactory;

interface

uses
  System.Generics.Collections, MatrixMultiplierIntf, MMGustavsonOOP;

type
  TMatrixMultiplierFactory = class
  public
    class function GetAvailable: TArray<string>;
    class function CreateByName(const Name: string): IMatrixMultiplier;
  end;

implementation

class function TMatrixMultiplierFactory.GetAvailable: TArray<string>;
begin
  Result := [
    'Gustavson (Secuencial)'
  ];
end;

class function TMatrixMultiplierFactory.CreateByName(const Name: string): IMatrixMultiplier;
begin
  if Name = 'Gustavson (Secuencial)' then
    Result := TGustavsonSequential.Create
  else
    Result := nil;
end;

end.
