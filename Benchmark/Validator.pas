unit Validator;

interface

uses
  Sysutils, Utils;

type
  TValidator = class(TObject)
  public
    function Validate(var C: TMatrix; const Iteration, M, N, K: Integer): Boolean;
  end;

const
  EPSILON = 1E-6;

implementation

Function TValidator.Validate(var C: TMatrix; const Iteration, M, N, K: Integer): Boolean;
var
  I, j, p: Integer;
  ExpectedValue, ActualValue: Double;
begin
  for I := 0 to M - 1 do
  begin
    for j := 0 to N - 1 do
    begin
      ExpectedValue := 0;
      for p := 0 to K - 1 do
        ExpectedValue := ExpectedValue +
          ((Iteration + I + p) * (Iteration + p - j));

      ActualValue := C[I * N + j];
      if Abs(ExpectedValue - ActualValue) > EPSILON then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
  Result := True;
end;

end.
