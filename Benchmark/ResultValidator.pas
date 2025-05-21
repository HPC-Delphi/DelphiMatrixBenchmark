unit ResultValidator;

interface

uses
  Sysutils;

type
  TResultValidator = class(TObject)
  public
    function Validate(const C, Expected: array of Double): Boolean;
  end;

const
  EPSILON = 1E-6;

implementation

function TResultValidator.Validate(const C, Expected: array of Double): Boolean;
var
  i: Integer;
begin
  Result := Length(C) = Length(Expected);
  if not Result then Exit;
  for i := 0 to High(C) do
    if Abs(C[i] - Expected[i]) > EPSILON then
    begin
      Result := False;
      Exit;
    end;
end;

end.
