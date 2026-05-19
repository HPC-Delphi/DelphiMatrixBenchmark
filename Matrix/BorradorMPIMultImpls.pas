unit MPIMultImpls;

interface

uses
  SysUtils, Diagnostics, Math,
  Multiplier, Utils, MultImpls,
  MPI;

type
  // MPI+Linear Algebra
  TMPIALGLIB = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TMPILinearAlgebra = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // MPI+Base
  TMPIBase = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TMPIOffCBase = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Par
  TMPIPPL = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TMPIOTL = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TMPIOffCOMP = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Vec
  TMPIASM = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TMPIIntelSIMD = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TMPIOffCAVX2 = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Par+Vec
  TMPIPPLIntelSIMD = class(TInterfacedObject, IMultiplier)
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
  MPI_Barrier;

  Result := 0.0;

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

  TBase.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  { Gathers rows of matrix C from processes }
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C,
    RowsPerProc * N, MPI_DOUBLE, 0);

  SetLength(SubA, 0);
  SetLength(SubC, 0);

  if Rank = 0 then
  begin
    Stopwatch.Stop;
    Result := Stopwatch.ElapsedMilliseconds / 1000.0;
  end;
end;

function TMPIOffCBase.GetName: string;
begin
  Result := 'MPI+OffC-Base';
end;

function TMPIOffCBase.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TOffCBase.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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

// MPI+Par
function TMPIPPL.GetName: string;
begin
  Result := 'MPI+PPL';
end;

function TMPIPPL.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TPPL.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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

function TMPIOTL.GetName: string;
begin
  Result := 'MPI+OTL';
end;

function TMPIOTL.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TOTL.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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

function TMPIOffCOMP.GetName: string;
begin
  Result := 'MPI+OffC-OMP';
end;

function TMPIOffCOMP.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TOffCOMP.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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

// MPI+Vec
function TMPIASM.GetName: string;
begin
  Result := 'MPI+ASM';
end;

function TMPIASM.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TASM.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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

function TMPIIntelSIMD.GetName: string;
begin
  Result := 'MPI+IntelSIMD';
end;

function TMPIIntelSIMD.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TIntelSIMD.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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

function TMPIOffCAVX2.GetName: string;
begin
  Result := 'MPI+OffC-AVX2';
end;

function TMPIOffCAVX2.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TOffCAVX2.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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
  if Rank <> 0 then
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

// MPI+Linear Algebra
function TMPIALGLIB.GetName: string;
begin
  Result := 'MPI+ALGLIB';
end;

function TMPIALGLIB.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TALGLIB.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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

function TMPILinearAlgebra.GetName: string;
begin
  Result := 'MPI+LINALG';
end;

function TMPILinearAlgebra.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
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

  TLinearAlgebra.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

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


end.
