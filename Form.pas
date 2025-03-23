unit Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Samples.Spin, Vcl.CheckLst, Vcl.ExtCtrls, Vcl.Tabs, Vcl.Grids,
  Benchmark,
  MatrixMulImplementations, VclTee.TeeGDIPlus, VclTee.TeEngine, VclTee.TeeProcs,
  VclTee.Chart, VclTee.Series,
  Vcl.Styles, Vcl.Themes;

type
  TForm1 = class(TForm)
    { Parameters }
    GroupBox1: TGroupBox;
    Label1: TLabel; // Matrix Size
    Label2: TLabel; // Threads
    Label3: TLabel; // Samples
    SpinEdit1: TSpinEdit; // N
    SpinEdit3: TSpinEdit; // S
    SpinEdit2: TSpinEdit; // T
    { Parallel Implementations }
    GroupBox2: TGroupBox;
    CheckListBox1: TCheckListBox; // Implementations
    { Run Benchmark }
    Button1: TButton;
    ProgressBar1: TProgressBar;
    { Benchmark Parameters }
    Panel1: TPanel;
    Panel2: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    { Results }
    GroupBox3: TGroupBox;
    TTabSheet1: TTabSheet;
    StringGrid1: TStringGrid;
    TPageControl1: TPageControl;
    TTabSheet2: TTabSheet;
    Chart1: TChart;
    Series1: TBarSeries;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    function GetParameters: Boolean;
    procedure ShowBenchmarkInfo;
    procedure ShowResults;
  private
    { Private declarations }

  public
    { Public declarations }

  end;

var
  Form1: TForm1;
  Benchmark: TBenchmark;
  N, T, S: Integer;
  SelectedImpl: array of TMatrixMulImplementation;

implementation

{$R *.dfm}

{ Initialize some components }
procedure TForm1.FormCreate(Sender: TObject);
var
  Impl: Integer;
begin
  Self.Caption := 'DelphiMatrixBenchmark';

  { Parameters }
  SpinEdit1.Value := 512;
  SpinEdit2.Value := 4;
  SpinEdit3.Value := 5;

  { Parallel Implementations }
  CheckListBox1.Clear;
  for Impl := 0 to High(AvailableImpl) do
  begin
    CheckListBox1.Items.Add(AvailableImpl[Impl].Name);
  end;

  { Results }
  TPageControl1.Visible := False;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i: Integer;
begin
  Button1.Enabled := False;

  if not GetParameters then
  begin
    Button1.Enabled := True;
    Exit;
  end;

  ShowBenchmarkInfo;

  ProgressBar1.Min := 0;
  ProgressBar1.Max := Length(SelectedImpl) * S;

  ProgressBar1.Position := 0;
  Benchmark := TBenchmark.Create(N, T, S, SelectedImpl);
  Benchmark.RunBenchmark;
  ProgressBar1.Position := Length(SelectedImpl) * S;

  ShowResults;

  Benchmark.Destroy;

  Button1.Enabled := True;
end;

function TForm1.GetParameters: Boolean;
var
  i, count: Integer;
begin
  // Parameters
  N := SpinEdit1.Value;
  T := SpinEdit2.Value;
  S := SpinEdit3.Value;

  if N <= 0 then
  begin
    ShowMessage('Error: matrix size (n) must be a positive integer');
    Result := False;
    Exit;
  end;

  if T <= 0 then
  begin
    ShowMessage('Error: threads (t) must be a positive integer');
    Result := False;
    Exit;
  end;

  // Implementations
  SetLength(SelectedImpl, CheckListBox1.Items.count);
  count := 0;
  for i := 0 to CheckListBox1.Items.count - 1 do
    if CheckListBox1.Checked[i] then
    begin
      SelectedImpl[count] := AvailableImpl[i];
      Inc(count);
    end;

  if count = 0 then
  begin
    ShowMessage('Error: no parallel implementation is selected. ' +
      'Mark one at least');
    Result := False;
    Exit;
  end;

  SetLength(SelectedImpl, count);

  Result := True;
end;

procedure TForm1.ShowBenchmarkInfo;
var
  i: Integer;
begin
  Label4.Caption := Format('Benchmarking GEMM [%d,%d] x [%d,%d]', [N, N, N, N])
    + sLineBreak + Format('Threads: %d', [T]) + sLineBreak +
    Format('Samples: %d', [S]);

  Label5.Caption := SelectedImpl[0].Name;
  for i := 1 to High(SelectedImpl) do
  begin
    Label5.Caption := Label5.Caption + sLineBreak + SelectedImpl[i].Name;
  end;
end;

procedure TForm1.ShowResults;
var
  i: Integer;
const
  Metrics: array [0 .. 3] of string = ('Total (s)', 'Avg (s)', 'Min (s)',
    'Max (s)');
begin
  // Data
  StringGrid1.ColCount := 5;
  StringGrid1.RowCount := 1 + Length(Benchmark.Results);

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

  for i := 0 to High(Benchmark.Results) do
  begin
    StringGrid1.Cells[0, i + 1] := Benchmark.Results[i].Name;
    StringGrid1.Cells[1, i + 1] := Benchmark.Results[i].TotalTime.ToString;
    StringGrid1.Cells[2, i + 1] := Benchmark.Results[i].AvgTime.ToString;
    StringGrid1.Cells[3, i + 1] := Benchmark.Results[i].MinTime.ToString;
    StringGrid1.Cells[4, i + 1] := Benchmark.Results[i].MaxTime.ToString;
  end;

  // Plot
  Chart1.Title.Text.Text := 'Benchmark Results Comparison';
  Chart1.View3D := False;
  Chart1.Legend.Visible := True;
  Chart1.Legend.LegendStyle := lsSeries;
  Chart1.RemoveAllSeries;

  for i := 0 to High(Benchmark.Results) do
  begin
    Series1 := TBarSeries.Create(Chart1);
    Chart1.AddSeries(Series1);
    Series1.Title := Benchmark.Results[i].Name;
    Series1.MultiBar := mbSide;
    Series1.Marks.Visible := False;

    Series1.Add(Benchmark.Results[i].TotalTime, Metrics[0]);
    Series1.Add(Benchmark.Results[i].AvgTime, Metrics[1]);
    Series1.Add(Benchmark.Results[i].MinTime, Metrics[2]);
    Series1.Add(Benchmark.Results[i].MaxTime, Metrics[3]);
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
