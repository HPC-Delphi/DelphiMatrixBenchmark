program DelphiMatrixBenchmark;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Form in 'Form.pas' {Form1},
  Config in 'Benchmark\Config.pas',
  Result in 'Benchmark\Result.pas',
  Runner in 'Benchmark\Runner.pas',
  Validator in 'Benchmark\Validator.pas',
  Utils in 'Matrix\Utils.pas',
  Factory in 'Matrix\Factory.pas',
  Multiplier in 'Matrix\Multiplier.pas',
  MultImpls in 'Matrix\MultImpls.pas',
  MPIMultImpls in 'Matrix\MPIMultImpls.pas',
  MPI,
  LUImpls in 'Matrix\LUImpls.pas';

{$R *.res}

{$IFDEF MPI}

var
  Rank: Integer;
  Algorithm: IMultiplier;
  Buffer: PAnsiChar;
  StrLen: Integer;
  AlgName: AnsiString;
  A, B, C: TMatrix;
{$ENDIF}

begin
{$IFDEF MPI}
  MPI_Init;
  MPI_Comm_rank(@Rank);

  MPI_Barrier;

  if Rank = 0 then
  begin
{$ENDIF}
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TForm1, Form1);
  Application.Run;
{$IFDEF MPI}
    StrLen := -1;
    MPI_Bcast(@StrLen, 1, MPI_Int, 0);
  end
  else
  begin
    While True do
    begin
      MPI_Bcast(@StrLen, 1, MPI_Int, 0);
      if StrLen = -1 then
        Break;
      GetMem(Buffer, StrLen + 1);
      try
        Buffer[StrLen] := #0;
        MPI_Bcast(Buffer, StrLen + 1, MPI_CHAR, 0);
        AlgName := AnsiString(Buffer);

        Algorithm := TFactory.CreateByName(string(AlgName));
        A := nil;
        B := nil;
        C := nil;
        Algorithm.Multiply(A, B, C, 0, 0, 0, 0);
      finally
        FreeMem(Buffer);
      end;
    end;
  end;
  MPI_Finalize;
{$ENDIF}

end.
