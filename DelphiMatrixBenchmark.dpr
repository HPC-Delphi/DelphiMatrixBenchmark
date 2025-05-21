program DelphiMatrixBenchmark;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Form in 'Form.pas' {Form1},
  MatrixMultiplierFactory in 'Algorithms\MatrixMultiplierFactory.pas',
  MatrixMultiplierIntf in 'Algorithms\MatrixMultiplierIntf.pas',
  AVX in 'Libraries\avx_delphi\wrappers\AVX.pas',
  OMP in 'Libraries\omp_delphi\wrappers\OMP.pas',
  MPI in 'Libraries\mpi_delphi\wrappers\MPI.pas',
  BenchmarkConfig in 'Benchmark\BenchmarkConfig.pas',
  BenchmarkResult in 'Benchmark\BenchmarkResult.pas',
  BenchmarkRunner in 'Benchmark\BenchmarkRunner.pas',
  ResultValidator in 'Benchmark\ResultValidator.pas',
  MMGustavsonOOP in 'Algorithms\MMGustavsonOOP.pas';

{$R *.res}

var
  rank: integer;
begin
  MPI_Init;
  MPI_Comm_rank(@rank);

  if rank = 0 then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
  end;

end.
