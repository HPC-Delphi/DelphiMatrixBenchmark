unit Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Samples.Spin, Vcl.CheckLst, Vcl.ExtCtrls, Vcl.Tabs, Vcl.Grids,
  VclTee.TeeGDIPlus, VclTee.TeEngine, VclTee.TeeProcs,
  VclTee.Chart, VclTee.Series, Vcl.Styles, Vcl.Themes, VclTee.TeCanvas,
  Config, Result, Validator, Runner,
  Multiplier, Factory,
  System.Generics.Collections;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    Button1: TButton;
    GroupBox3: TGroupBox;
    TTabSheet1: TTabSheet;
    StringGrid1: TStringGrid;
    TPageControl1: TPageControl;
    TTabSheet2: TTabSheet;
    Chart1: TChart;
    Series1: TBarSeries;
    Shape1: TShape;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    Label4: TLabel;
    Shape2: TShape;
    Shape3: TShape;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    StaticText1: TStaticText;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    GroupBox4: TGroupBox;
    Label2: TLabel;
    SpinEdit2: TSpinEdit;
    Label3: TLabel;
    SpinEdit3: TSpinEdit;
    CheckListBox2: TCheckListBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    function GetParameters(out Config: TBenchmarkConfig): Boolean;
    procedure ShowResults(const Results: TArray<TBenchmarkResult>);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ Initialize some components }
procedure TForm1.FormCreate(Sender: TObject);
var
  Names: TArray<string>;
  i: Integer;
begin
  Self.Caption := 'DelphiMatrixBenchmark';

  { Parameters }
  SpinEdit1.Value := 512;
  SpinEdit4.Value := 512;
  SpinEdit5.Value := 512;

  SpinEdit2.Value := 4;
  SpinEdit3.Value := 5;

  { Parallel Implementations }
  CheckListBox2.Clear;
  CheckListBox2.Font.Name := 'Courier New';
  Names := TFactory.GetAvailable;
  for i := 0 to High(Names) do
    CheckListBox2.Items.Add(Names[i]);

  { Results }
  TPageControl1.Visible := False;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Config: TBenchmarkConfig;
  MultList: TList<IMultiplier>;
  Runner: TRunner;
  Results: TArray<TBenchmarkResult>;
  i: Integer;
begin
  Button1.Enabled := False;
  try
    if not GetParameters(Config) then
      Exit;

    MultList := TList<IMultiplier>.Create;
    try
      for i := 0 to CheckListBox2.Items.Count - 1 do
        if CheckListBox2.Checked[i] then
          MultList.Add(TFactory.CreateByName(CheckListBox2.Items[i]));

      Runner := TRunner.Create(Config, MultList);
      try
        Results := Runner.Run;
        ShowResults(Results);
      finally
        Runner.Free;
      end;
    except
      MultList.Free;
      raise;
    end;
  finally
    Button1.Enabled := True;
  end;
end;

function TForm1.GetParameters(out Config: TBenchmarkConfig): Boolean;
begin
  Config.M := SpinEdit1.Value;
  Config.K := SpinEdit4.Value;
  Config.N := SpinEdit5.Value;
  Config.T := SpinEdit2.Value;
  Config.S := SpinEdit3.Value;

  if Config.M <= 0 then
  begin
    ShowMessage('Error: matrix size (M) must be a positive integer');
    Result := False;
    Exit;
  end;

  if Config.K <= 0 then
  begin
    ShowMessage('Error: matrix size (K) must be a positive integer');
    Result := False;
    Exit;
  end;

  if Config.N <= 0 then
  begin
    ShowMessage('Error: matrix size (N) must be a positive integer');
    Result := False;
    Exit;
  end;

  if Config.T <= 0 then
  begin
    ShowMessage('Error: threads (T) must be a positive integer');
    Result := False;
    Exit;
  end;

  Result := True;
end;

procedure TForm1.ShowResults(const Results: TArray<TBenchmarkResult>);
var
  i: Integer;
const
  Metrics: array [0 .. 3] of string = ('Total (s)', 'Avg (s)', 'Min (s)',
    'Max (s)');
begin
  // Data
  StringGrid1.ColCount := 5;
  StringGrid1.RowCount := 1 + Length(Results);

  StringGrid1.Cells[0, 0] := 'Function';
  StringGrid1.Cells[1, 0] := 'Total (s)';
  StringGrid1.Cells[2, 0] := 'Avg (s)';
  StringGrid1.Cells[3, 0] := 'Min (s)';
  StringGrid1.Cells[4, 0] := 'Max (s)';

  StringGrid1.RowHeights[0] := 30;
  StringGrid1.ColWidths[0] := 250;
  StringGrid1.ColWidths[1] := 100;
  StringGrid1.ColWidths[2] := 100;
  StringGrid1.ColWidths[3] := 100;
  StringGrid1.ColWidths[4] := 100;

  for i := 0 to High(Results) do
  begin
    StringGrid1.Cells[0, i + 1] := Results[i].Name;
    StringGrid1.Cells[1, i + 1] := Results[i].TotalTime.ToString;
    StringGrid1.Cells[2, i + 1] := Results[i].AvgTime.ToString;
    StringGrid1.Cells[3, i + 1] := Results[i].MinTime.ToString;
    StringGrid1.Cells[4, i + 1] := Results[i].MaxTime.ToString;
  end;

  // Plot
  Chart1.Title.Text.Text := 'Benchmark Results Comparison';
  Chart1.View3D := False;
  Chart1.Legend.Visible := True;
  Chart1.Legend.LegendStyle := lsSeries;
  Chart1.RemoveAllSeries;

  for i := 0 to High(Results) do
  begin
    Series1 := TBarSeries.Create(Chart1);
    Chart1.AddSeries(Series1);
    Series1.Title := Results[i].Name;
    Series1.MultiBar := mbSide;
    Series1.Marks.Visible := False;

    Series1.Add(Results[i].TotalTime, Metrics[0]);
    Series1.Add(Results[i].AvgTime, Metrics[1]);
    Series1.Add(Results[i].MinTime, Metrics[2]);
    Series1.Add(Results[i].MaxTime, Metrics[3]);
  end;

  Chart1.LeftAxis.Title.Caption := 'Time (s)';
  Chart1.LeftAxis.LabelsFont.Size := 10;
  Chart1.BottomAxis.Title.Caption := 'Metrics';
  Chart1.BottomAxis.LabelStyle := talText;
  Chart1.BottomAxis.LabelsFont.Size := 10;
  Chart1.BottomAxis.Items.Clear;
  for i := 0 to High(Metrics) do
  begin
    Chart1.BottomAxis.Items.Add(i, Metrics[i]);
  end;

  TPageControl1.Visible := True;
end;

end.
