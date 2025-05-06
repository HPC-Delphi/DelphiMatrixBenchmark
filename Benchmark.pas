unit Benchmark;

interface

uses
  SysUtils, System.Threading,
  Math,
  Diagnostics,
  MatrixUtils,
  MatrixMulImplementations,
  OpenMPMatrix;

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
    M, K, N: Integer;
    T, S: Integer;
    Implementations: TArray<TMatrixMulImplementation>;

  public
    Results: array of TResult;
    constructor Create(const M, K, N, T, S: Integer;
      Implementations: array of TMatrixMulImplementation);
    destructor Destroy; override;
    Procedure RunBenchmark;

  private
    Procedure AllocateMatrices;
    Procedure InitializeMatrices(const Iteration: Integer);
    Procedure FreeMatrices;
    Function CheckResult(const Iteration: Integer): Boolean;
  end;

const
  EPSILON: Double = 1E-6;

implementation

// Public
constructor TBenchmark.Create(const M, K, N, T, S: Integer;
  Implementations: array of TMatrixMulImplementation);
var
  I: Integer;
begin
  inherited Create;
  Self.M := M;
  Self.K := K;
  Self.N := N;
  Self.T := T;
  Self.S := S;

  SetLength(Self.Implementations, Length(Implementations));
  for I := Low(Implementations) to High(Implementations) do
    Self.Implementations[I] := Implementations[I];

  SetLength(Self.Results, Length(Implementations));
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
  CheckOK: Boolean;
begin
  for I := 0 to High(Implementations) do
  begin
    MinElapsedS := Infinity;
    MaxElapsedS := NegInfinity;
    SumElapsedS := 0.0;
    CheckOK := True;
    for j := 0 to S - 1 do
    begin
      AllocateMatrices;
      InitializeMatrices(I * j);

      Stopwatch := Stopwatch.StartNew;
      Implementations[I].Proc(A, B, C, M, K, N, T);
      Stopwatch.Stop;
      ElapsedS := Stopwatch.ElapsedMilliseconds / 1000.0;
      SumElapsedS := SumElapsedS + ElapsedS;

      // Verificar el resultado usando CheckResult
      if not CheckResult(I * j) then
      begin
        CheckOK := False;
        FreeMatrices;
        Break; // Si falla la comprobación, salimos del bucle de iteraciones
      end;

      if ElapsedS < MinElapsedS then
        MinElapsedS := ElapsedS;
      if ElapsedS > MaxElapsedS then
        MaxElapsedS := ElapsedS;

      FreeMatrices;
    end;

    Results[I].Name := Implementations[I].Name;
    if not CheckOK then
    begin
      Results[I].TotalTime := Infinity;
      Results[I].AvgTime := Infinity;
      Results[I].MinTime := Infinity;
      Results[I].MaxTime := Infinity;
    end
    else
    begin
      AvgElapsedS := SumElapsedS / S;
      Results[I].TotalTime := SumElapsedS;
      Results[I].AvgTime := AvgElapsedS;
      Results[I].MinTime := MinElapsedS;
      Results[I].MaxTime := MaxElapsedS;
    end;
  end;
end;

// Private
Procedure TBenchmark.AllocateMatrices;
begin
  SetLength(A, M * K);
  SetLength(B, K * N);
  SetLength(C, M * N);
end;

Procedure TBenchmark.InitializeMatrices(const Iteration: Integer);
var
  I, j: Integer;
begin
  for I := 0 to M - 1 do
    for j := 0 to K - 1 do
      A[I * K + j] := Iteration + I + j;

  for I := 0 to K - 1 do
    for j := 0 to N - 1 do
      B[I * N + j] := Iteration + I - j;

  for I := 0 to M - 1 do
    for j := 0 to N - 1 do
      C[I * N + j] := 0;
end;

Procedure TBenchmark.FreeMatrices;
begin
  SetLength(A, 0);
  SetLength(B, 0);
  SetLength(C, 0);
end;

Function TBenchmark.CheckResult(const Iteration: Integer): Boolean;
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
