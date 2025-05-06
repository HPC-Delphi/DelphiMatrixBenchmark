unit MMGustavson;

interface

uses
  System.Threading, OtlParallel,
  MatrixUtils, OpenMPMatrix;

  {NativeDelphi}
procedure SeqGustavsonNativeDelphi(var A, B, C: TMatrix;
  M, K, N, T: Integer); { No usa T }

  {System.Threading}
procedure ParGustavsonSystemThreading(var A, B, C: TMatrix;
  M, K, N, T: Integer); { No permite usar T }

  {OmniThreadLibrary}
procedure ParGustavsonOmniThreadLibrary(var A, B, C: TMatrix;
  M, K, N, T: Integer);

  { OpenMPMatrix }
procedure SeqGustavsonOpenMPMatrix(var A, B, C: TMatrix;
  M, K, N, T: Integer); { No usa T }
procedure ParGustavsonOpenMPMatrix(var A, B, C: TMatrix;
  M, K, N, T: Integer);

implementation

  {Native Delphi}
procedure SeqGustavsonNativeDelphi(var A, B, C: TMatrix;
  M, K, N, T: Integer);
var
  i, j, p: Integer;
  aip: Double;
begin

  for i := 0 to M - 1 do
  begin
    for p := 0 to K - 1 do
    begin
      aip := A[i * K + p];
      for j := 0 to N - 1 do
      begin
        C[i * N + j] := C[i * N + j] + aip * B[p * N + j];
      end;
    end;
  end;
end;

  {OmniThreadLibrary}
procedure ParGustavsonOmniThreadLibrary(var A, B, C: TMatrix;
  M, K, N, T: Integer);
var
  A_cp, B_cp, C_cp: TMatrix;
begin
  A_cp := A;
  B_cp := B;
  C_cp := C;

  Parallel.For(0, M - 1).NumTasks(T).Execute(
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

  {System.Threading}
procedure ParGustavsonSystemThreading(var A, B, C: TMatrix;
M, K, N, T: Integer);
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

  {OpenMPMatrix}
procedure SeqGustavsonOpenMPMatrix(var A, B, C: TMatrix;
M, K, N, T: Integer);
begin
  MMSeqGustavson(@A[0], @B[0], @C[0], M, K, N);
end;

procedure ParGustavsonOpenMPMatrix(var A, B, C: TMatrix;
M, K, N, T: Integer);
begin
  MMParGustavson(@A[0], @B[0], @C[0], M, K, N, T);
end;


end.

