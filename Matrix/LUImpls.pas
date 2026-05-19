unit LUImpls;

interface

uses
  SysUtils, Diagnostics, Math,
  Multiplier, Utils,
  MPI;

type
  // LU
  TLU = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // MPI+LU
  TMPILU = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

implementation

function TLU.GetName: string;
begin
  Result := 'LU';
end;

function TLU.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  Stopwatch: TStopWatch;
  MatrixSize: Integer;
  PivotRow: TMatrix;
  Factor: Double;
  P, I, J: Integer;
begin
  MatrixSize := K;

  // PrintMatrix(A, K, K);

  Stopwatch := TStopWatch.StartNew;
  SetLength(PivotRow, MatrixSize);
  for P := 0 to MatrixSize - 1 do
  begin
    for J := 0 to MatrixSize - 1 do
      PivotRow[J] := A[P * MatrixSize + J];

    for I := P + 1 to MatrixSize - 1 do
    begin
      Factor := A[I * MatrixSize + P] / PivotRow[P];
      A[I * MatrixSize + P] := Factor;
      for J := P + 1 to MatrixSize - 1 do
        A[I * MatrixSize + J] := A[I * MatrixSize + J] -
          Factor * PivotRow[J];
    end;
  end;
  SetLength(PivotRow, 0);

  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;

  // PrintMatrix(A, MatrixSize, MatrixSize);
end;

// MPI+LU
function TMPILU.GetName: string;
begin
  Result := 'MPI+LU';
end;

function TMPILU.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  ProcessCount, Rank: Integer;
  SubA: TMatrix;
  Stopwatch: TStopWatch;
  RowsPerProc, MatrixSize, Owner: Integer;
  LocalRowIndex: Integer;
  PivotRow: TMatrix;
  Factor: Double;
  ProcessorName: array [0 .. MPI_MAX_PROCESSOR_NAME - 1] of AnsiChar;
  NameLen: Integer;
  P, I, J: Integer;
begin
  MPI_Get_processor_name(@ProcessorName, @NameLen);
  MPI_Comm_size(@ProcessCount);
  MPI_Comm_rank(@Rank);

  MPI_Barrier;

  // Writeln(Format('< %s >: process %d of %d', [ProcessorName, Rank, ProcessCount]));
  // Flush(Output);

  if Rank = 0 then
  begin
    MatrixSize := K;
    // PrintMatrix(A, MatrixSize, MatrixSize);

    Stopwatch := TStopWatch.StartNew;
  end;

  // Broadcasts MatrixSize from process 0 to all processes
  MPI_Bcast(@MatrixSize, 1, MPI_INT, 0);

  RowsPerProc := MatrixSize div ProcessCount;
  SetLength(SubA, RowsPerProc * MatrixSize);

  // Distributes rows of GlobalMatrix from process 0 to all processes
  MPI_Scatter(A, RowsPerProc * MatrixSize, MPI_DOUBLE, SubA,
    RowsPerProc * MatrixSize, MPI_DOUBLE, 0);

  SetLength(PivotRow, MatrixSize);
  for P := 0 to MatrixSize - 1 do
  begin
    Owner := P div RowsPerProc;
    if Rank = Owner then
    begin
      LocalRowIndex := P mod RowsPerProc;
      for J := 0 to MatrixSize - 1 do
        PivotRow[J] := SubA[LocalRowIndex * MatrixSize + J];
    end;
    MPI_Bcast(PivotRow, MatrixSize, MPI_DOUBLE, Owner);

    for I := 0 to RowsPerProc - 1 do
    begin
      if (Rank * RowsPerProc + I) > P then
      begin
        Factor := SubA[I * MatrixSize + P] / PivotRow[P];
        SubA[I * MatrixSize + P] := Factor;
        for J := P + 1 to MatrixSize - 1 do
          SubA[I * MatrixSize + J] := SubA[I * MatrixSize + J] -
            Factor * PivotRow[J];
      end;
    end;
  end;
  SetLength(PivotRow, 0);

  // Gathers rows of GlobalMatrix from processes
  MPI_Gather(SubA, RowsPerProc * MatrixSize, MPI_DOUBLE, A,
    RowsPerProc * MatrixSize, MPI_DOUBLE, 0);

  MPI_Barrier;
  Result := 0.0;
  if Rank = 0 then
  begin
    Stopwatch.Stop;
    Result := Stopwatch.ElapsedMilliseconds / 1000.0;
    // PrintMatrix(A, MatrixSize, MatrixSize);
  end;
end;

end.
