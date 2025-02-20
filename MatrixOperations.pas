unit MatrixOperations;

interface

uses
  SysUtils, System.Threading, OpenMPMatrixLib;

type
  TMatrixOps = class(TObject)

    protected
      A, B, C : array of Double;
      N, F, T : Integer;

    public
      constructor Create(N, F, T : Integer);
      destructor Destroy; override;
      Procedure PrintMatrices;
      Procedure MultMatSeqDelphi;
      Procedure MultMatParDelphi;
      Procedure MultMatNaiveOpenMP;
      Procedure MultMatStrassenOpenMP;

    private
      Procedure AllocateMatrices;
      Procedure InitializeMatrices;
      Procedure FreeMatrices;
  end;

implementation

// Private
Procedure TMatrixOps.AllocateMatrices;
begin
  SetLength(A, N * N);
  SetLength(B, N * N);
  SetLength(C, N * N);
end;

Procedure TMatrixOps.InitializeMatrices;
var
  i, j: Integer;

begin
  Randomize;

  for i  := 0 to N - 1 do
    for j := 0 to N - 1 do
    begin
      A[i * N + j] := Random;
      B[i * N + j] := Random;
      C[i * N + j] := 0;
    end;
end;

Procedure TMatrixOps.FreeMatrices;
begin
  SetLength(A, 0);
  SetLength(B, 0);
  SetLength(C, 0);
end;

// Public
constructor TMatrixOps.Create(N, F, T : Integer);
begin
  inherited Create;
  Self.N := N;
  Self.F := F;
  Self.T := T;

  AllocateMatrices;
  InitializeMatrices;
end;

destructor TMatrixOps.Destroy;
begin
  FreeMatrices;
  inherited Destroy;
end;

Procedure TMatrixOps.PrintMatrices;
var
  i, j : Integer;
  LineA, LineB, LineC : string;
begin
  LineA := '';
  LineB := '';
  LineC := '';

  for i := 0 to n - 1 do
  begin
    for j := 0 to n - 1 do
    begin
      LineA := LineA + Format('%.4f', [A[i * N + j]]) + ' ';
      LineB := LineB + Format('%.4f', [B[i * N + j]]) + ' ';
      LineC := LineC + Format('%.4f', [C[i * N + j]]) + ' ';
    end;
    LineA := LineA + sLineBreak;
    LineB := LineB + sLineBreak;
    LineC := LineC + sLineBreak;
  end;

  Writeln(LineA);
  Writeln(LineB);
  Writeln(LineC);
end;

procedure TMatrixOps.MultMatSeqDelphi;
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

procedure TMatrixOps.MultMatParDelphi;
var
  i, j, k: Integer;
  aik: Double;
begin
  TParallel.For(0, N - 1,
    procedure(i: Integer)
    var
      k, j: Integer;
      aik: Double;
    begin
      for k := 0 to N - 1 do
      begin
        aik := A[i * N + k];
        for j := 0 to N - 1 do
        begin
          C[i * N + j] := C[i * N + j] + aik * B[k * N + j];
        end;
      end;
    end
  );
end;

procedure TMatrixOps.MultMatNaiveOpenMP;
begin
  MulMatNaive(@Self.A[0], @Self.B[0], @Self.C[0], N, T);
end;

procedure TMatrixOps.MultMatStrassenOpenMP;
begin
  MulMatStrassen(@Self.A[0], @Self.B[0], @Self.C[0], N, T);
end;

end.
