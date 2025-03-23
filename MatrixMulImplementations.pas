unit MatrixMulImplementations;

interface

uses
  SysUtils, System.Threading, OpenMPMatrixLib, OtlParallel;

type
  TDoubleArray = array of Double;
  PDoubleArray =  ^TDoubleArray;

  TMatrixMul = procedure(var A, B, C: TDoubleArray; N, T: Integer);

  TMatrixMulImplementation = record
    Name: String;
    Proc: TMatrixMul;
  end;

  procedure MatrixMulNaive(var A, B, C: TDoubleArray; N, T: Integer);
  procedure MatrixMulNaiveSystemThreading(var A, B, C: TDoubleArray; N, T: Integer);
  procedure MatrixMulNaiveOmniThreadLibrary(var A, B, C: TDoubleArray; N, T: Integer);
  procedure MatrixMulNaiveOpenMP(var A, B, C: TDoubleArray; N, T: Integer);
  procedure MatrixMulStrassenOpenMP(var A, B, C: TDoubleArray; N, T: Integer);

const
  AvailableImpl: array[0..4] of TMatrixMulImplementation = (
    (Name: 'Naive'; Proc: MatrixMulNaive),
    (Name: 'Naive (System.Threading)'; Proc: MatrixMulNaiveSystemThreading),
    (Name: 'Naive (OmniThreadLibrary)'; Proc: MatrixMulNaiveOmniThreadLibrary),
    (Name: 'Naive (OpenMPMatrixMul)'; Proc: MatrixMulNaiveOpenMP),
    (Name: 'Strassen (OpenMPMatrixMul)'; Proc: MatrixMulStrassenOpenMP)
  );

implementation

procedure MatrixMulNaive(var A, B, C: TDoubleArray; N, T: Integer);
var
  i, j, k: Integer;
  aik: Double;
begin

  for i := 0 to N - 1 do
  begin
    for k := 0 to N - 1 do
    begin
      aik := A[i * N + k];
      for j := 0 to N - 1 do
      begin
        C[i * N + j] := C[i * N + j] + aik * B[k * N + j];
      end;
    end;
  end;
end;

procedure MatrixMulNaiveOmniThreadLibrary(var A, B, C: TDoubleArray; N, T: Integer);
var
  A_cp, B_cp, C_cp: TDoubleArray;
begin
  A_cp := A;
  B_cp := B;
  C_cp := C;

  Parallel.For(0, N - 1)
    .NumTasks(T)
    .Execute(
    procedure(i: Integer)
    var
      j, k: Integer;
      aik: Double;
    begin
      for k := 0 to N - 1 do
      begin
        aik := A_cp[i * N + k];
        for j := 0 to N - 1 do
        begin
          C_cp[i * N + j] := C_cp[i * N + j] + aik * B_cp[k * N + j];
        end;
      end;
    end
  );
end;

procedure MatrixMulNaiveSystemThreading(var A, B, C: TDoubleArray; N, T: Integer);
var
  A_cp, B_cp, C_cp: TDoubleArray;
begin
  A_cp := A;
  B_cp := B;
  C_cp := C;

  TParallel.For(0, N - 1,
    procedure(i: Integer)
    var
      j, k: Integer;
      aik: Double;
    begin
      for k := 0 to N - 1 do
      begin
        aik := A_cp[i * N + k];
        for j := 0 to N - 1 do
        begin
          C_cp[i * N + j] := C_cp[i * N + j] + aik * B_cp[k * N + j];
        end;
      end;
    end
  );
end;

{ Matrix multiplication using the Naive OpenMP implementation. }
procedure MatrixMulNaiveOpenMP(var A, B, C: TDoubleArray; N, T: Integer);
begin
  MulMatNaive(@A[0], @B[0], @C[0], N, T);
end;

{ Matrix multiplication using the Strassen OpenMP implementation. }
procedure MatrixMulStrassenOpenMP(var A, B, C: TDoubleArray; N, T: Integer);
begin
  MulMatStrassen(@A[0], @B[0], @C[0], N, T);
end;



end.

