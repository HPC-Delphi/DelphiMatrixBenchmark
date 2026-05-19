unit Multiplier;

interface

uses
  Utils;

type
  IMultiplier = interface
    ['{A1B2C3D4-E5F6-47A8-9B0C-1D2E3F4A5B6C}']
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

implementation

end.
