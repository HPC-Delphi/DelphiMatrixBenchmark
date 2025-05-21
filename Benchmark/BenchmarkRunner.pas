unit BenchmarkRunner;

interface

uses
  System.Generics.Collections, BenchmarkConfig, BenchmarkResult, MatrixMultiplierIntf, ResultValidator, Math, Diagnostics;

type
  TBenchmarkRunner = class
  private
    FConfig: TBenchmarkConfig;
    FMultipliers: TList<IMatrixMultiplier>;
    FValidator: TResultValidator;
  public
    constructor Create(const Config: TBenchmarkConfig; Multipliers: TList<IMatrixMultiplier>);
    destructor Destroy; override;
    function Run: TArray<TBenchmarkResult>;
  end;

implementation

constructor TBenchmarkRunner.Create(const Config: TBenchmarkConfig; Multipliers: TList<IMatrixMultiplier>);
begin
  FConfig := Config;
  FMultipliers := Multipliers;
  FValidator := TResultValidator.Create;
end;

destructor TBenchmarkRunner.Destroy;
begin
  FMultipliers.Free;
  inherited;
end;

function TBenchmarkRunner.Run: TArray<TBenchmarkResult>;
var
  i, s: Integer;
  A, B, C, Expected: TMatrix;
  Stopwatch: TStopWatch;
  ResultItem: TBenchmarkResult;
  Elapsed, MinElapsed, MaxElapsed, SumElapsed: Double;
  IsValid: Boolean;
begin
  SetLength(Result, FMultipliers.Count);
  for i := 0 to FMultipliers.Count - 1 do
  begin
    // Inicializar matrices
    SetLength(A, FConfig.M * FConfig.K);
    SetLength(B, FConfig.K * FConfig.N);
    SetLength(C, FConfig.M * FConfig.N);
    SetLength(Expected, FConfig.M * FConfig.N);
    // Inicialización simple (puede mejorarse)
    for s := 0 to High(A) do A[s] := 1.0;
    for s := 0 to High(B) do B[s] := 1.0;
    for s := 0 to High(C) do C[s] := 0.0;
    for s := 0 to High(Expected) do Expected[s] := 0.0;
    // Calcular resultado esperado con el primer algoritmo
    if i = 0 then
      FMultipliers[0].Multiply(A, B, Expected, FConfig.M, FConfig.K, FConfig.N, FConfig.T);
    MinElapsed := MaxDouble;
    MaxElapsed := -MaxDouble;
    SumElapsed := 0.0;
    for s := 1 to FConfig.S do
    begin
      for var idx := 0 to High(C) do C[idx] := 0.0;
      Stopwatch := TStopwatch.StartNew;
      FMultipliers[i].Multiply(A, B, C, FConfig.M, FConfig.K, FConfig.N, FConfig.T);
      Stopwatch.Stop;
      Elapsed := Stopwatch.ElapsedMilliseconds / 1000.0;
      SumElapsed := SumElapsed + Elapsed;
      if Elapsed < MinElapsed then MinElapsed := Elapsed;
      if Elapsed > MaxElapsed then MaxElapsed := Elapsed;
    end;
    IsValid := FValidator.Validate(C, Expected);
    ResultItem.Name := FMultipliers[i].GetName;
    ResultItem.TotalTime := SumElapsed;
    ResultItem.AvgTime := SumElapsed / FConfig.S;
    ResultItem.MinTime := MinElapsed;
    ResultItem.MaxTime := MaxElapsed;
    ResultItem.IsValid := IsValid;
    Result[i] := ResultItem;
  end;
end;

end.
