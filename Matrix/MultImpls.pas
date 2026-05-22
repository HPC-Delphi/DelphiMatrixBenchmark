unit MultImpls;

interface

uses
  SysUtils, Diagnostics, Math, Utils, Multiplier,
  MKL, XALGLIB, LinAlg, FMAMatrixMultOperationsx64,
  OffC,
  System.Threading, OTLParallel,
  FMAMatrixMultTransposedOperationsx64, VectorSIMD, vecLib, VDstd, VDmath
{$IFDEF MPI}
    , MPI
{$ENDIF};

type

  // XALGLIB declares a different TMatrix type
  TMatrix = Utils.TMatrix;

  // Base
  TBase = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TOffCBase = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Par
  TPPL = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TOTL = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TOffCOMP = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Vec
  TOptiVecVectorLib = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TIntelSIMD = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TOffCAVX2 = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TASM = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Par+Vec
  // Se elige PPL porque obtiene mejor rendiemiento que OTL
  TPPLIntelSIMD = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TOffCOMPAVX2 = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  // Linear Algebra / Optimized libraries
  TALGLIB = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TLinearAlgebra = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  Tmrmath = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

  TOffCMKL = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;

{$IFDEF MPI}

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

  // MPI+MKL
  TMPIOffCMKL = class(TInterfacedObject, IMultiplier)
  public
    function GetName: string;
    function Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
  end;
{$ENDIF}

implementation

// Base
function TBase.GetName: string;
begin
  Result := 'Base';
end;

function TBase.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  i, j, p: Integer;
  aip: Double;
  Stopwatch: TStopWatch;
begin
  // Compute
  Stopwatch := TStopWatch.StartNew;
  for i := 0 to M - 1 do
  begin
    for p := 0 to K - 1 do
    begin
      aip := A[i * K + p];
      for j := 0 to N - 1 do
      begin
        C[i * N + j] := C[i * N + j] + aip * B[p * N + j];
      end;
    end;
  end;
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

function TOffCBase.GetName: string;
begin
  Result := 'OffC-Base';
end;

function TOffCBase.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  Stopwatch: TStopWatch;
begin
  // Compute
  Stopwatch := TStopWatch.StartNew;
  mm_ikj_seq(@A[0], @B[0], @C[0], M, K, N);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

// Par
function TPPL.GetName: string;
begin
  Result := 'PPL';
end;

function TPPL.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  A_cp, B_cp, C_cp: TMatrix;
  Pool: TThreadPool;
  Stopwatch: TStopWatch;
  RowsPerThread: Integer;
begin
  A_cp := A;
  B_cp := B;
  C_cp := C;

  Stopwatch := TStopWatch.StartNew;
  // Compute
  Pool := TThreadPool.Create;
  Pool.SetMinWorkerThreads(T);
  Pool.SetMaxWorkerThreads(T);

  RowsPerThread := Ceil(M / T);
  TParallel.For(0, T - 1,
    procedure(ThreadID: Integer)
    var
      i, j, p: Integer;
      aip: Double;
      iStart, iEnd: Integer;
    begin
      iStart := ThreadID * RowsPerThread;
      iEnd := Min(iStart + RowsPerThread - 1, M - 1);

      for i := iStart to iEnd do
      begin
        for p := 0 to K - 1 do
        begin
          aip := A_cp[i * K + p];
          for j := 0 to N - 1 do
          begin
            C_cp[i * N + j] := C_cp[i * N + j] + aip * B_cp[p * N + j];
          end;
        end;
      end;
    end, Pool);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

function TOTL.GetName: string;
begin
  Result := 'OTL';
end;

function TOTL.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  A_cp, B_cp, C_cp: TMatrix;
  Stopwatch: TStopWatch;
  RowsPerThread: Integer;
begin
  A_cp := A;
  B_cp := B;
  C_cp := C;

  Stopwatch := TStopWatch.StartNew;
  RowsPerThread := Ceil(M / T);
  // Compute
  Parallel.For(0, T - 1).NumTasks(T).Execute(
    procedure(ThreadID: Integer)
    var
      i, j, p: Integer;
      aip: Double;
      iStart, iEnd: Integer;
    begin
      iStart := ThreadID * RowsPerThread;
      iEnd := Min(iStart + RowsPerThread - 1, M - 1);

      for i := iStart to iEnd do
      begin
        for p := 0 to K - 1 do
        begin
          aip := A_cp[i * K + p];
          for j := 0 to N - 1 do
          begin
            C_cp[i * N + j] := C_cp[i * N + j] + aip * B_cp[p * N + j];
          end;
        end;
      end;
    end);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

function TOffCOMP.GetName: string;
begin
  Result := 'OffC-OMP';
end;

function TOffCOMP.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Compute
  mm_ikj_par(@A[0], @B[0], @C[0], M, K, N, T);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

// Vec
function TOptiVecVectorLib.GetName: string;
begin
  Result := 'OptiVec-VectorLib';
end;

function TOptiVecVectorLib.Multiply(var A, B, C: TMatrix;
M, K, N, T: Integer): Double;
var
  i, j: Integer;
  TmpMul, ArrSum: dVector;
  sum: Double;
  B_t: TMatrix;
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Transform
  SetLength(B_t, N * K);
  TransposeMatrix(B, B_t, K, N);

  TmpMul := VD_Vector(K);
  ArrSum := VD_Vector(K);

  // Compute
  for i := 0 to M - 1 do
    for j := 0 to N - 1 do
    begin
      VD_equC(ArrSum, K, 0);

      // Vectorized compute
      VD_mulV(TmpMul, @A[i * K], @B_t[j * K], K);
      VD_addV(ArrSum, ArrSum, TmpMul, K);

      // Horizontal reduction
      sum := VD_sum(ArrSum, K);

      C[i * N + j] := sum
    end;
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;

  SetLength(B_t, 0);
  V_free(ArrSum);
  V_free(TmpMul);
end;

function TIntelSIMD.GetName: string;
begin
  Result := 'IntelSIMD';
end;

function TIntelSIMD.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  i, j: Integer;
  ArrSum: array of Double;
  B_t: TMatrix;
  sum: Double;
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Transform
  SetLength(B_t, N * K);
  TransposeMatrix(B, B_t, K, N);

  SetLength(ArrSum, K);

  // Compute
  for i := 0 to M - 1 do
    for j := 0 to N - 1 do
    begin
      FillChar(ArrSum[0], K * SizeOf(Double), 0);

      // Vectorized compute
      VectorFMA(@A[i * K], @B_t[j * K], @ArrSum[0], K);

      // Horizontal reduction
      VectorReduce(@ArrSum[0], @sum, K);

      C[i * N + j] := sum
    end;
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;

  SetLength(ArrSum, 0);
end;

function TOffCAVX2.GetName: string;
begin
  Result := 'OffC-AVX2';
end;

function TOffCAVX2.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Transform + Compute
  mm_ijk_vec(@A[0], @B[0], @C[0], M, K, N);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

// Vec
function TASM.GetName: string;
begin
  Result := 'Assembler';
end;

function TASM.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  destLineWidth, lineWidth1, lineWidth2: NativeInt;
  B_t: TMatrix;
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Transform
  SetLength(B_t, N * K);
  TransposeMatrix(B, B_t, K, N);

  destLineWidth := N * SizeOf(Double);
  lineWidth1 := K * SizeOf(Double);
  lineWidth2 := K * SizeOf(Double);

  // Compute
  FMAMatrixMultUnAlignedTransposed(@C[0], NativeInt(destLineWidth), @A[0],
    @B_t[0], K, N, M, K, lineWidth1, lineWidth2);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;

  SetLength(B_t, 0);
end;

// Par+Vec
function TPPLIntelSIMD.GetName: string;
begin
  Result := 'PPL+IntelSIMD';
end;

function TPPLIntelSIMD.Multiply(var A, B, C: TMatrix;
M, K, N, T: Integer): Double;
var
  A_cp, B_t, C_cp: TMatrix;
  Pool: TThreadPool;
  Stopwatch: TStopWatch;
  RowsPerThread: Integer;
begin
  A_cp := A;
  C_cp := C;

  Stopwatch := TStopWatch.StartNew;
  // Transform
  // Si se usa por un proceso MPI, e asume que la
  // matriz B está transpuesta
  SetLength(B_t, N * K);
  TransposeMatrix(B, B_t, K, N);

  // Compute
  Pool := TThreadPool.Create;
  Pool.SetMinWorkerThreads(T);
  Pool.SetMaxWorkerThreads(T);

  RowsPerThread := Ceil(M / T);
  TParallel.For(0, T - 1,
    procedure(ThreadID: Integer)
    var
      i, j: Integer;
      ArrSum: array of Double;
      sum: Double;
      iStart, iEnd: Integer;
    begin
      iStart := ThreadID * RowsPerThread;
      iEnd := Min(iStart + RowsPerThread - 1, M - 1);

      SetLength(ArrSum, K);
      for i := iStart to iEnd do
      begin
        for j := 0 to N - 1 do
        begin
          FillChar(ArrSum[0], K * SizeOf(Double), 0);

          // Vectorized compute
          VectorFMA(@A_cp[i * K], @B_t[j * K], @ArrSum[0], K);

          // Horizontal reduction
          VectorReduce(@ArrSum[0], @sum, K);

          C_cp[i * N + j] := sum
        end;
      end;
      SetLength(ArrSum, 0);
    end, Pool);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;

  SetLength(B_t, 0);
end;

function TOffCOMPAVX2.GetName: string;
begin
  Result := 'OffC-OMP+AVX2';
end;

function TOffCOMPAVX2.Multiply(var A, B, C: TMatrix;
M, K, N, T: Integer): Double;
var
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Transform + Compute
  mm_ikj_parvec(@A[0], @B[0], @C[0], M, K, N, T);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

// Linear Algebra
function TALGLIB.GetName: string;
begin
  Result := 'ALGLIB';
end;

function TALGLIB.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  A_cp, B_cp, C_cp: XALGLIB.TMatrix;
  Stopwatch: TStopWatch;
begin
  XALGLIB.SetGlobalThreading(XALGLIB.AlglibParallel);

  // Transform
  SetLength(A_cp, M, K);
  SetLength(B_cp, K, N);
  SetLength(C_cp, M, N);

  For var i := 0 to M - 1 do
    for var j := 0 to K - 1 do
      A_cp[i, j] := A[i * K + j];

  For var i := 0 to K - 1 do
    for var j := 0 to N - 1 do
      B_cp[i, j] := B[i * N + j];

  Stopwatch := TStopWatch.StartNew;
  // Compute
  XALGLIB.rmatrixgemm(M, N, K, 1.0, A_cp, 0, 0, 0, B_cp, 0, 0, 0, 0.0,
    C_cp, 0, 0);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;

  // Transform
  For var i := 0 to M - 1 do
    for var j := 0 to N - 1 do
      C[i * N + j] := C_cp[i, j];

  SetLength(A_cp, 0);
  SetLength(B_cp, 0);
  SetLength(C_cp, 0);
end;

function TLinearAlgebra.GetName: string;
begin
  Result := 'LINALG';
end;

function TLinearAlgebra.Multiply(var A, B, C: TMatrix;
M, K, N, T: Integer): Double;
var
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Compute
  LinAlg.cblas_dgemm(LinAlg.CblasRowMajor, LinAlg.CblasNoTrans,
    LinAlg.CblasNoTrans, M, N, K, 1.0, @A[0], K, @B[0], N, 0.0, @C[0], N);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

function Tmrmath.GetName: string;
begin
  Result := 'mrmath';
end;

function Tmrmath.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  destLineWidth, lineWidth1, lineWidth2: NativeInt;
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;

  destLineWidth := N * SizeOf(Double);
  lineWidth1 := K * SizeOf(Double);
  lineWidth2 := N * SizeOf(Double);

  // Compute
  FMAMatrixMultUnAligned(@C[0], NativeInt(destLineWidth), @A[0], @B[0], K, N, M,
    K, lineWidth1, lineWidth2);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
  SetLength(B, 0);
end;

function TOffCMKL.GetName: string;
begin
  Result := 'OffC-MKL';
end;

function TOffCMKL.Multiply(var A, B, C: TMatrix; M, K, N, T: Integer): Double;
var
  Stopwatch: TStopWatch;
begin
  Stopwatch := TStopWatch.StartNew;
  // Compute
  MKL.cblas_dgemm(MKL.CBLAS_LAYOUT.CblasRowMajor,
    MKL.CBLAS_TRANSPOSE.CblasNoTrans, MKL.CBLAS_TRANSPOSE.CblasNoTrans, M, N, K,
    1.0, @A[0], K, @B[0], N, 0.0, @C[0], N);
  Stopwatch.Stop;
  Result := Stopwatch.ElapsedMilliseconds / 1000.0;
end;

{$IFDEF MPI}

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
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA, RowsPerProc * K,
    MPI_DOUBLE, 0);

  // Broadcasts matrix B from process 0 to all processes
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TBase.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  // Gathers rows of matrix C from processes
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C, RowsPerProc * N,
    MPI_DOUBLE, 0);

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

function TMPIPPLIntelSIMD.Multiply(var A, B, C: TMatrix;
M, K, N, T: Integer): Double;
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
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA, RowsPerProc * K,
    MPI_DOUBLE, 0);

  { Broadcasts matrix B from process 0 to all processes }
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TPPLIntelSIMD.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  { Gathers rows of matrix C from processes }
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C, RowsPerProc * N,
    MPI_DOUBLE, 0);

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

function TMPIOffCOMPAVX2.Multiply(var A, B, C: TMatrix;
M, K, N, T: Integer): Double;
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
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA, RowsPerProc * K,
    MPI_DOUBLE, 0);

  { Broadcasts matrix B from process 0 to all processes }
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TOffCOMPAVX2.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  { Gathers rows of matrix C from processes }
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C, RowsPerProc * N,
    MPI_DOUBLE, 0);

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

function TMPIOffCMKL.Multiply(var A, B, C: TMatrix;
M, K, N, T: Integer): Double;
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
  MPI_Scatter(A, RowsPerProc * K, MPI_DOUBLE, SubA, RowsPerProc * K,
    MPI_DOUBLE, 0);

  // Broadcasts matrix B from process 0 to all processes
  MPI_Bcast(B, K * N, MPI_DOUBLE, 0);

  TOffCMKL.Create.Multiply(SubA, B, SubC, RowsPerProc, K, N, T);

  // Gathers rows of matrix C from processes
  MPI_Gather(SubC, RowsPerProc * N, MPI_DOUBLE, C, RowsPerProc * N,
    MPI_DOUBLE, 0);

  SetLength(SubA, 0);
  SetLength(SubC, 0);

  MPI_Barrier;

  if Rank = 0 then
  begin
    Stopwatch.Stop;
    Result := Stopwatch.ElapsedMilliseconds / 1000.0;
  end;
end;
{$ENDIF}

end.
