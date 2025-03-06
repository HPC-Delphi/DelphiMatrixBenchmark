program DelphiMatrixBenchmark;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Math,
  Diagnostics,
  MatrixOperations;

type
  TMatrixBenchmark = reference to procedure(MatrixOps: TMatrixOps);

{ Executes the benchmark:
  - Creates an instance of TMatrixOps with the given parameters (n, rowsPerThread, threads).
  - Starts and stops the stopwatch while executing the operation.
  - Calculates and displays the elapsed time and Mflops. }
procedure RunBenchmark(n, f, t: Integer; const BenchmarkProc: TMatrixBenchmark);
var
  Stopwatch: TStopwatch;
  MatrixOps: TMatrixOps;
  ElapsedS, MFlops: Double;
begin
  Stopwatch := TStopwatch.Create;
  MatrixOps := TMatrixOps.Create(n, f, t);
  try
    Stopwatch.Start;
    BenchmarkProc(MatrixOps);
    Stopwatch.Stop;
    ElapsedS := Stopwatch.ElapsedMilliseconds / 1000;
    MFlops := ((2.0 * n * n) / ElapsedS) / 1000000;
    WriteLn(Format('  Threads %d, size %d', [t, n]));
    WriteLn(Format('    seconds: %.6f, Mflops: %.6f, Mflops per thread: %.6f',
      [ElapsedS, Mflops, Mflops / t]));
  finally
    MatrixOps.Free;
  end;
end;

{ Displays the usage help in case of invalid input parameters. }
procedure PrintUsage(const ProgName, ErrorMsg: string);
begin
  Writeln('Error: ', ErrorMsg);
  Writeln('Usage: ', ProgName, ' <n> <ldn> <F> <t>');
  Writeln('Description:');
  Writeln('Multiplies two square matrices (A and B) of size n x n and stores the result in matrix C.');
  Writeln('The matrices are stored in row-major order with a leading dimension of ldn.');
  Writeln('Parameters:');
  Writeln('  <n>    : The size of the square matrices (n x n), must be a positive integer.');
  Writeln('  <ldn>  : The leading dimension of the matrices, must be greater than or equal to n.');
  Writeln('  <F>    : The number of consecutive rows of matrix C to be assigned to each thread,');
  Writeln('           must divide n evenly and be greater than 0.');
  Writeln('  <t>    : The total number of threads to be used for parallel execution, must be a');
  Writeln('           positive integer.');
  Writeln('Example:');
  Writeln('  ', ProgName, ' 100 110 10 4');
end;

{ Displays the available implementation options. }
procedure PrintOptions();
const
  Implementations: array[0..3] of string = (
    'MultMatSeqDelphi',
    'MultMatParDelphi',
    'MultMatNaiveOpenMP',
    'MultMatStrassenOpenMP'
  );
var
  i : Integer;
begin
  Writeln('Select an implementation to run:');
  for i := Low(Implementations) to High(Implementations) do
  begin
    Writeln(i + 1 , ': ',Implementations[i]);
  end;
  Writeln('0: Exit');
end;

{ Displays the program parameters. }
procedure PrintParams(n, ldn, f, t : Integer);
begin
  Writeln('Program parameters:');
  Writeln('  Matrix size (n)         : ', n);
  Writeln('  Leading dimension (ldn) : ', ldn);
  Writeln('  Rows per thread         : ', f);
  Writeln('  Threads                 : ', t);
end;

var
  n, ldn, f, t : Integer;
  Option : Integer;
begin
  try
    if ParamCount < 4 then
      begin
        PrintUsage(ExtractFileName(ParamStr(0)), 'Insufficient arguments provided');
        Readln;
        ExitCode := -1 ;
        Exit;
      end;

    n   := ParamStr(1).ToInteger;
    ldn := ParamStr(2).ToInteger;
    f   := ParamStr(3).ToInteger;
    t  := ParamStr(4).ToInteger;

    if n <= 0 then
      begin
        PrintUsage(ExtractFileName(ParamStr(0)), '<n> must be a positive integer');
        Readln;
        ExitCode := -1 ;
        Exit;
      end;

    if ldn < n then
      begin
        PrintUsage(ExtractFileName(ParamStr(0)), '<ldn> must be a positive integer greater than or equal to <n>');
        Readln;
        ExitCode := -1 ;
        Exit;
      end;

    if (f <= 0) or (n mod f <> 0) then
      begin
        PrintUsage(ExtractFileName(ParamStr(0)), '<f> must be a positive integer greater than 0 and divide <n> evenly');
        Readln;
        ExitCode := -1 ;
        Exit;
      end;

    if (t <= 0) or (n mod f <> 0) then
      begin
        PrintUsage(ExtractFileName(ParamStr(0)), '<t> must be a positive integer');
        Readln;
        ExitCode := -1 ;
        Exit;
      end;

    PrintParams(n, ldn, f, t);
    Writeln;

    while True do
    begin
      PrintOptions();
      Readln(Option);
      Writeln;
      case Option of
        1:
          RunBenchmark(n, f, t,
            procedure(MatrixOps: TMatrixOps)
            begin
              MatrixOps.MultMatSeqDelphi;
            end);
        2:
          RunBenchmark(n, f, t,
            procedure(MatrixOps: TMatrixOps)
            begin
              MatrixOps.MultMatParDelphi;
            end);
        3:
          RunBenchmark(n, f, t,
            procedure(MatrixOps: TMatrixOps)
            begin
              MatrixOps.MultMatNaiveOpenMP;
            end);
        4:
          RunBenchmark(n, f, t,
            procedure(MatrixOps: TMatrixOps)
            begin
              MatrixOps.MultMatStrassenOpenMP;
            end);
        0:
        begin
          Writeln('Exiting...');
          Sleep(500);
          Break;
        end;
      else
        Writeln('Invalid option, try again.');
      end;

      Writeln;
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

