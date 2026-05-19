unit MPIMultImpls;

interface

uses
  SysUtils, Diagnostics, Math,
  Multiplier, Utils, MultImpls,
  MPI;

type

  // MPI+Base
  TMPIBase = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // MPI+Par+Vec
  TMPIPPLIntelSIMD = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TMPIOffCOMPAVX2 = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Linear Algebra
  TMPIOffCMKL = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

implementation

// MPI+Base
function TMPIBase.GetName: string;
begin
  Result := 'MPI+Base';
end;

function TMPIBase.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  ProcessCount, RowsPerProc, Rank: Integer;
  SubA, SubC: TMatrix;
  Stopwatch: TStopWatch;
begin
  Result := 0.0;

  MPI_Barrier;
  MPI_Comm_size(@ProcessCount);
  MPI_Comm_rank(@Rank);
  MPI_Barrier;

  if Rank = 0 then
  begin
    // Compute
    Stopwatch := TStopWatch.StartNew;
  end;

  // Broadcasts M, N, K from process 0 to all processes
  MPI_Bcast(@M, 1, MPI_INT, 0);
  MPI_Bcast(@N, 1, MPI_INT, 0);
  MPI_Bcast(@K, 1, MPI_INT, 0);
  MPI_Bcast(@T, 1, MPI_INT, 0);

  RowsPerProc := M div ProcessCount;
  SetLength(SubA, RowsPerProc * K);
  if Rank <> 0 then
    SetLength(B, K * N);
  SetLength(SubC, RowsPerProc * N);

  InitMatrixZero(SubC, RowsPerProc * N);

  // Distributes rows of matrix A from process 0 to all processes
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA,
    RowsPerProc * K, MPI_DOUBLE, 0);

  // Broadcasts matrix B from process 0 to all processes
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TBase.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  // Gathers rows of matrix C from processes
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C,
    RowsPerProc * N, MPI_DOUBLE, 0);

  SetLength(SubA, 0);
  SetLength(SubC, 0);

  MPI_Barrier;

  if Rank = 0 then
  begin
    Stopwatch.Stop;
    Result := Stopwatch.ElapsedMilliseconds / 1000.0;
  end;
end;

// MPI-ParVec
function TMPIPPLIntelSIMD.GetName: string;
begin
  Result := 'MPI+PPL+IntelSIMD';
end;

function TMPIPPLIntelSIMD.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  ProcessCount, RowsPerProc, Rank: Integer;
  SubA, SubC: TMatrix;
  Stopwatch: TStopWatch;
begin
  MPI_Barrier;

  MPI_Comm_size(@ProcessCount);
  MPI_Comm_rank(@Rank);

  if Rank = 0 then
  begin
    // Compute
    Stopwatch := TStopWatch.StartNew;
  end;

  { Broadcasts M, N, K from process 0 to all processes }
  MPI_Bcast(@M, 1, MPI_INT, 0);
  MPI_Bcast(@N, 1, MPI_INT, 0);
  MPI_Bcast(@K, 1, MPI_INT, 0);
  MPI_Bcast(@T, 1, MPI_INT, 0);

  RowsPerProc := M div ProcessCount;
  SetLength(SubA, RowsPerProc * K);
  if rank <> 0 then
    SetLength(B, K * N);
  SetLength(SubC, RowsPerProc * N);

  InitMatrixZero(SubC, RowsPerProc * N);

  { Distributes rows of matrix A from process 0 to all processes }
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA,
    RowsPerProc * K, MPI_DOUBLE, 0);

  { Broadcasts matrix B from process 0 to all processes }
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TPPLIntelSIMD.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  { Gathers rows of matrix C from processes }
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C,
    RowsPerProc * N, MPI_DOUBLE, 0);

  SetLength(SubA, 0);
  SetLength(SubC, 0);

  Result := 0.0;
  if Rank = 0 then
  begin
    Stopwatch.Stop;
    Result := Stopwatch.ElapsedMilliseconds / 1000.0;
  end;
end;

function TMPIOffCOMPAVX2.GetName: string;
begin
  Result := 'MPI+OffC-OMP+AVX2';
end;

function TMPIOffCOMPAVX2.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  ProcessCount, RowsPerProc, Rank: Integer;
  SubA, SubC: TMatrix;
  Stopwatch: TStopWatch;
begin
  MPI_Barrier;

  MPI_Comm_size(@ProcessCount);
  MPI_Comm_rank(@Rank);

  if Rank = 0 then
  begin
    // Compute
    Stopwatch := TStopWatch.StartNew;
  end;

  { Broadcasts M, N, K from process 0 to all processes }
  MPI_Bcast(@M, 1, MPI_INT, 0);
  MPI_Bcast(@N, 1, MPI_INT, 0);
  MPI_Bcast(@K, 1, MPI_INT, 0);
  MPI_Bcast(@T, 1, MPI_INT, 0);

  RowsPerProc := M div ProcessCount;
  SetLength(SubA, RowsPerProc * K);
  if Rank <> 0 then
    SetLength(B, K * N);
  SetLength(SubC, RowsPerProc * N);

  InitMatrixZero(SubC, RowsPerProc * N);

  { Distributes rows of matrix A from process 0 to all processes }
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA,
    RowsPerProc * K, MPI_DOUBLE, 0);

  { Broadcasts matrix B from process 0 to all processes }
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TOffCOMPAVX2.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  { Gathers rows of matrix C from processes }
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C,
    RowsPerProc * N, MPI_DOUBLE, 0);

  SetLength(SubA, 0);
  SetLength(SubC, 0);

  Result := 0.0;
  if Rank = 0 then
  begin
    Stopwatch.Stop;
    Result := Stopwatch.ElapsedMilliseconds / 1000.0;
  end;
end;


// Linear Algebra
function TMPIOffCMKL.GetName: string;
begin
  Result := 'MPI+OffC-MKL';
end;

function TMPIOffCMKL.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  ProcessCount, RowsPerProc, Rank: Integer;
  SubA, SubC: TMatrix;
  Stopwatch: TStopWatch;
begin
  Result := 0.0;

  MPI_Barrier;
  MPI_Comm_size(@ProcessCount);
  MPI_Comm_rank(@Rank);
  MPI_Barrier;

  if Rank = 0 then
  begin
    // Compute
    Stopwatch := TStopWatch.StartNew;
  end;

  // Broadcasts M, N, K from process 0 to all processes
  MPI_Bcast(@M, 1, MPI_INT, 0);
  MPI_Bcast(@N, 1, MPI_INT, 0);
  MPI_Bcast(@K, 1, MPI_INT, 0);
  MPI_Bcast(@T, 1, MPI_INT, 0);

  RowsPerProc := M div ProcessCount;
  SetLength(SubA, RowsPerProc * K);
  if Rank <> 0 then
    SetLength(B, K * N);
  SetLength(SubC, RowsPerProc * N);

  InitMatrixZero(SubC, RowsPerProc * N);

  // Distributes rows of matrix A from process 0 to all processes
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA,
    RowsPerProc * K, MPI_DOUBLE, 0);

  // Broadcasts matrix B from process 0 to all processes
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TOffCMKL.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  // Gathers rows of matrix C from processes
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C,
    RowsPerProc * N, MPI_DOUBLE, 0);

  SetLength(SubA, 0);
  SetLength(SubC, 0);

  MPI_Barrier;

  if Rank = 0 then
  begin
    Stopwatch.Stop;
    Result := Stopwatch.ElapsedMilliseconds / 1000.0;
  end;
end;

end.
