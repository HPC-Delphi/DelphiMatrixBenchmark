unit Runner;

interface

uses
  SysUtils, System.Generics.Collections, Math,
  Config, Result, Validator,
  Multiplier, Utils,
  MPI;

type
  TRunner = class
  private
    FConfig: TBenchmarkConfig;
    FMultipliers: TList<IMultiplier>;
    FValidator: TValidator;
  public
    constructor Create(const Config: TBenchmarkConfig;
      Multipliers: TList<IMultiplier>);
    destructor Destroy; override;
    function Run: TArray<TBenchmarkResult>;
  end;

implementation

procedure InitA(var A: TMatrix; M, K, Iteration: Integer);
begin
  for var i := 0 to M - 1 do
    for var p := 0 to K - 1 do
      A[i * K + p] := Iteration + i + p;
end;

procedure InitB(var B: TMatrix; K, N, Iteration: Integer);
begin
  for var p := 0 to K - 1 do
    for var j := 0 to N - 1 do
      B[p * N + j] := Iteration + p - j;
end;

constructor TRunner.Create(const Config: TBenchmarkConfig;
  Multipliers: TList<IMultiplier>);
begin
  FConfig := Config;
  FMultipliers := Multipliers;
  FValidator := TValidator.Create;
end;

destructor TRunner.Destroy;
begin
  FMultipliers.Free;
  inherited;
end;

function TRunner.Run: TArray<TBenchmarkResult>;
var
  i, s: Integer;
  A, B, C, Expected: TMatrix;
  ResultItem: TBenchmarkResult;
  Elapsed, MinElapsed, MaxElapsed, SumElapsed: Double;
  IsValid: Boolean;
  AlgName: AnsiString;
  Buffer: PAnsiChar;
  StrLen: Integer;
begin
  SetLength(Result, FMultipliers.Count);
  for i := 0 to FMultipliers.Count - 1 do
  begin
    MinElapsed := MaxDouble;
    MaxElapsed := -MaxDouble;
    SumElapsed := 0.0;
    isValid := True;
    for s := 0 to FConfig.s - 1 do
    begin
      // Allocate and initialize matrices
      SetLength(A, FConfig.M * FConfig.K);
      SetLength(B, FConfig.K * FConfig.N);
      SetLength(C, FConfig.M * FConfig.N);

      var iter := i * FConfig.S + s;
{$IFDEF LU$}
      InitMatrix(A, FConfig.M * FConfig.K);
{$ELSE$}
      InitA(A, FConfig.M, FConfig.K, iter);
      InitB(B, FConfig.K, FConfig.N, iter);
      InitMatrixZero(C, FConfig.M * FConfig.N);
{$ENDIF$}

      //for var idx := 0 to High(C) do
        //C[idx] := 0.0;

      // Compute
{$IFDEF MPI}
      AlgName := AnsiString(FMultipliers[i].GetName);
      StrLen := Length(FMultipliers[i].GetName);

      GetMem(Buffer, StrLen + 1);
      Move(AlgName[1], Buffer^, StrLen);
      Buffer[StrLen] := #0;

      MPI_Bcast(@StrLen, 1, MPI_INT, 0);
      MPI_Bcast(Buffer, StrLen + 1, MPI_CHAR, 0);

      FreeMem(Buffer);
{$ENDIF}
      Elapsed := FMultipliers[i].Multiply(A, B, C, FConfig.M, FConfig.K, FConfig.N, FConfig.T);
      SumElapsed := SumElapsed + Elapsed;
      if Elapsed < MinElapsed then MinElapsed := Elapsed;
      if Elapsed > MaxElapsed then MaxElapsed := Elapsed;

      // Free matrices
      SetLength(A, 0);
      SetLength(B, 0);

      // Validate
{$IFNDEF LU$}
      IsValid := FValidator.Validate(C, iter, FConfig.M, FConfig.N, FConfig.K);
{$ENDIF$}
      // Free matrices
      SetLength(C, 0);
      SetLength(Expected, 0);

      if not IsValid then
        Break;
    end;

    ResultItem.Name := FMultipliers[i].GetName;
    if IsValid then
    begin
      ResultItem.TotalTime := SumElapsed;
      ResultItem.AvgTime := SumElapsed / FConfig.s;
      ResultItem.MinTime := MinElapsed;
      ResultItem.MaxTime := MaxElapsed;
    end
    else
    begin
      ResultItem.TotalTime := NegInfinity;
      ResultItem.AvgTime := NegInfinity;
      ResultItem.MinTime := NegInfinity;
      ResultItem.MaxTime := NegInfinity;
    end;
    Result[i] := ResultItem;
  end;
end;

end.
