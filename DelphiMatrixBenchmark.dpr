program DelphiMatrixBenchmark;

uses
  Vcl.Forms,
  Form in 'Form.pas' {Form1},
  Benchmark in 'Benchmark.pas',
  Vcl.Themes,
  Vcl.Styles,
  OMPDelphi,
  MMGustavson in 'Algorithms\MMGustavson.pas',
  MMStrassen in 'Algorithms\MMStrassen.pas',
  MMImplementations in 'Algorithms\MMImplementations.pas',
  MatrixUtils in 'MatrixUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
