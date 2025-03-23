unit Benchmark;

interface

uses
  SysUtils, System.Threading,
  Math,
  Diagnostics,
  MatrixMulImplementations,
  OpenMPMatrixLib;

type
  TResult = record
    Name: String;
    TotalTime: Double;
    AvgTime: Double;
    MinTime: Double;
    MaxTime: Double;
  end;

  TBenchmark = class(TObject)

  protected
    A, B, C: TDoubleArray;
    N, T, S: Integer;
    Implementations: TArray<TMatrixMulImplementation>;

  public
    Results: array of TResult;
    constructor Create(const N, T, S: Integer;
      Implementations: array of TMatrixMulImplementation);
    destructor Destroy; override;
    Procedure RunBenchmark;

  private
    Procedure AllocateMatrices;
    Procedure InitializeMatrices;
    Procedure FreeMatrices;
  end;

implementation

// Public
constructor TBenchmark.Create(const N, T, S: Integer;
  Implementations: array of TMatrixMulImplementation);
var
  I: Integer;
begin
  inherited Create;
  Self.N := N;
  Self.T := T;
  Self.S := S;

  SetLength(Self.Implementations, Length(Implementations));
  for I := Low(Implementations) to High(Implementations) do
    Self.Implementations[I] := Implementations[I];

  SetLength(Self.Results, Length(Implementations));

  AllocateMatrices;
  InitializeMatrices;
end;

destructor TBenchmark.Destroy;
begin
  inherited Destroy;

  FreeMatrices;
end;

Procedure TBenchmark.RunBenchmark;
var
  I, j: Integer;
  Stopwatch: TStopwatch;
  ElapsedS, SumElapsedS, AvgElapsedS, MinElapsedS, MaxElapsedS: Double;
begin
  for I := 0 to High(Implementations) do
  begin
    MinElapsedS := Infinity;
    MaxElapsedS := NegInfinity;
    SumElapsedS := 0.0;
    for j := 0 to S - 1 do
    begin
      Stopwatch := Stopwatch.StartNew;
      Implementations[I].Proc(A, B, C, N, T);
      Stopwatch.Stop;
      ElapsedS := Stopwatch.ElapsedMilliseconds / 1000.0;
      SumElapsedS := SumElapsedS + ElapsedS;

      if ElapsedS < MinElapsedS then
        MinElapsedS := ElapsedS;
      if ElapsedS > MaxElapsedS then
        MaxElapsedS := ElapsedS;
    end;

    AvgElapsedS := SumElapsedS / S;

    Results[I].Name := Implementations[I].Name;
    Results[I].TotalTime := SumElapsedS;
    Results[I].AvgTime := AvgElapsedS;
    Results[I].MinTime := MinElapsedS;
    Results[I].MaxTime := MaxElapsedS;
  end;
end;

// Private
Procedure TBenchmark.AllocateMatrices;
begin
  SetLength(A, N * N);
  SetLength(B, N * N);
  SetLength(C, N * N);
end;

Procedure TBenchmark.InitializeMatrices;
var
  I, j: Integer;

begin
  Randomize;

  for I := 0 to N - 1 do
    for j := 0 to N - 1 do
    begin
      A[I * N + j] := Random;
      B[I * N + j] := Random;
      C[I * N + j] := 0;
    end;
end;

Procedure TBenchmark.FreeMatrices;
begin
  SetLength(A, 0);
  SetLength(B, 0);
  SetLength(C, 0);
end;

end.
