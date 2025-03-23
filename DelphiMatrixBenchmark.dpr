program DelphiMatrixBenchmark;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Benchmark in 'Benchmark.pas',
  MatrixMulImplementations in 'MatrixMulImplementations.pas',
  OpenMPMatrixLib in 'OpenMPMatrixLib.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
