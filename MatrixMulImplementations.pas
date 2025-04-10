unit MatrixMulImplementations;

interface

uses
  SysUtils, System.Threading, OpenMPMatrix, OtlParallel,
  ShellAPI, Windows;

type
  TDoubleArray = array of Double;
  PDoubleArray = ^TDoubleArray;

  TMatrixMul = procedure(var A, B, C: TDoubleArray; M, K, N, T: Integer);

  TMatrixMulImplementation = record
    Name: String;
    Proc: TMatrixMul;
  end;

  { Gustavson }
procedure SeqGustavsonNativeDelphi(var A, B, C: TDoubleArray;
  M, K, N, T: Integer); { No usa T }
procedure ParGustavsonSystemThreading(var A, B, C: TDoubleArray;
  M, K, N, T: Integer); { No permite usar T }
procedure ParGustavsonOmniThreadLibrary(var A, B, C: TDoubleArray;
  M, K, N, T: Integer);
procedure SeqGustavsonOpenMPMatrix(var A, B, C: TDoubleArray;
  M, K, N, T: Integer); { No usa T }
procedure ParGustavsonOpenMPMatrix(var A, B, C: TDoubleArray;
  M, K, N, T: Integer);

{ Strassen }
procedure SeqStrassenOpenMPMatrix(var A, B, C: TDoubleArray;
  M, K, N, T: Integer); { No usa T }
procedure ParStrassenOpenMPMatrix(var A, B, C: TDoubleArray;
  M, K, N, T: Integer);

const
  AvailableImpl: array [0 .. 6] of TMatrixMulImplementation =
    ((Name: '[Native Delphi]     Gustavson (Sequential)';
    Proc: SeqGustavsonNativeDelphi),
    (Name: '[System.Threading]  Gustavson (Parallel)';
    Proc: ParGustavsonSystemThreading),
    (Name: '[OmniThreadLibrary] Gustavson (Parallel)';
    Proc: ParGustavsonOmniThreadLibrary),
    (Name: '[OpenMPMatrix]      Gustavson (Sequential)';
    Proc: SeqGustavsonOpenMPMatrix),
    (Name: '[OpenMPMatrix]      Gustavson (Parallel)';
    Proc: ParGustavsonOpenMPMatrix),
    (Name: '[OpenMPMatrix]      Strassen  (Sequential)';
    Proc: SeqStrassenOpenMPMatrix),
    (Name: '[OpenMPMatrix]      Strassen  (Parallel)';
    Proc: ParStrassenOpenMPMatrix));

implementation

procedure SeqGustavsonNativeDelphi(var A, B, C: TDoubleArray;
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

procedure ParGustavsonOmniThreadLibrary(var A, B, C: TDoubleArray;
  M, K, N, T: Integer);
var
  A_cp, B_cp, C_cp: TDoubleArray;
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

procedure ParGustavsonSystemThreading(var A, B, C: TDoubleArray;
M, K, N, T: Integer);
var
  A_cp, B_cp, C_cp: TDoubleArray;
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

procedure SeqGustavsonOpenMPMatrix(var A, B, C: TDoubleArray;
M, K, N, T: Integer);
begin
  MMSeqGustavson(@A[0], @B[0], @C[0], M, K, N);
end;

procedure ParGustavsonOpenMPMatrix(var A, B, C: TDoubleArray;
M, K, N, T: Integer);
begin
  MMParGustavson(@A[0], @B[0], @C[0], M, K, N, T);
end;

procedure SeqStrassenOpenMPMatrix(var A, B, C: TDoubleArray;
M, K, N, T: Integer);
begin
  MMSeqStrassen(@A[0], @B[0], @C[0], M, K, N);
end;

procedure ParStrassenOpenMPMatrix(var A, B, C: TDoubleArray;
M, K, N, T: Integer);
begin
  MMParStrassen(@A[0], @B[0], @C[0], M, K, N, T);
end;

end.
