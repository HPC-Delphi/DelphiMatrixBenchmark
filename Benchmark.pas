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
    Procedure InitializeMatrices(const Iteration: Integer);
    Procedure FreeMatrices;
    Function CheckResult(const Iteration: Integer): Boolean;
  end;

  const
    EPSILON : Double = 1e-6;

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
      InitializeMatrices(j);

      Stopwatch := Stopwatch.StartNew;
      Implementations[I].Proc(A, B, C, N, T);
      Stopwatch.Stop;
      ElapsedS := Stopwatch.ElapsedMilliseconds / 1000.0;
      SumElapsedS := SumElapsedS + ElapsedS;

      // Verificar el resultado usando CheckResult
      if not CheckResult(j) then
      begin
        CheckOK := False;
        FreeMatrices;
        Break;  // Si falla la comprobación, salimos del bucle de iteraciones
      end;

      if ElapsedS < MinElapsedS then
        MinElapsedS := ElapsedS;
      if ElapsedS > MaxElapsedS then
        MaxElapsedS := ElapsedS;

      FreeMatrices;
    end;

    AvgElapsedS := SumElapsedS / S;

    Results[I].Name := Implementations[I].Name;
    if not CheckOK then
    begin
      Results[I].TotalTime := Infinity;
      Results[I].AvgTime   := Infinity;
      Results[I].MinTime   := Infinity;
      Results[I].MaxTime   := Infinity;
    end
    else
    begin
      AvgElapsedS := SumElapsedS / S;
      Results[I].TotalTime := SumElapsedS;
      Results[I].AvgTime   := AvgElapsedS;
      Results[I].MinTime   := MinElapsedS;
      Results[I].MaxTime   := MaxElapsedS;
    end;
  end;
end;

// Private
Procedure TBenchmark.AllocateMatrices;
begin
  SetLength(A, N * N);
  SetLength(B, N * N);
  SetLength(C, N * N);
end;

Procedure TBenchmark.InitializeMatrices(const Iteration: Integer);
var
  I, j: Integer;

begin
  for I := 0 to N - 1 do
    for j := 0 to N - 1 do
    begin
      A[I * N + j] := Iteration + i + j;
      B[I * N + j] := Iteration + i - j;
      C[I * N + j] := 0;
    end;
end;

Procedure TBenchmark.FreeMatrices;
begin
  SetLength(A, 0);
  SetLength(B, 0);
  SetLength(C, 0);
end;

Function TBenchmark.CheckResult(const Iteration: Integer): Boolean;
var
  i, j, k: Integer;
  ExpectedValue, ActualValue: Double;
begin
  for i := 0 to N - 1 do
  begin
    for j := 0 to N - 1 do
    begin
      ExpectedValue := 0;
      for k := 0 to N - 1 do
        ExpectedValue := ExpectedValue + ((Iteration + i + k) * (Iteration + k - j));

      ActualValue := C[i * N + j];
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
