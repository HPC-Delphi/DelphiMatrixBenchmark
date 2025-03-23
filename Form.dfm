object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'DelphiMatrixBenchmark'
  ClientHeight = 620
  ClientWidth = 647
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 393
    Height = 137
    BiDiMode = bdLeftToRight
    Caption = 'Parameters'
    ParentBiDiMode = False
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 75
      Height = 15
      Caption = 'Matrix Size (n)'
    end
    object Label2: TLabel
      Left = 16
      Top = 73
      Width = 56
      Height = 15
      Caption = 'Threads (t)'
    end
    object Label3: TLabel
      Left = 176
      Top = 22
      Width = 60
      Height = 15
      Caption = 'Samples (s)'
    end
    object SpinEdit1: TSpinEdit
      Left = 16
      Top = 43
      Width = 121
      Height = 24
      Increment = 32
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 1024
    end
    object SpinEdit2: TSpinEdit
      Left = 16
      Top = 94
      Width = 121
      Height = 24
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 4
    end
    object SpinEdit3: TSpinEdit
      Left = 176
      Top = 43
      Width = 121
      Height = 24
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 10
    end
  end
  object GroupBox2: TGroupBox
    Left = 407
    Top = 8
    Width = 225
    Height = 137
    Caption = 'Parallel Implementations'
    TabOrder = 1
    object CheckListBox1: TCheckListBox
      Left = 16
      Top = 24
      Width = 193
      Height = 97
      ItemHeight = 15
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 8
    Top = 151
    Width = 624
    Height = 25
    Caption = 'Run Benchmark'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 8
    Top = 182
    Width = 310
    Height = 58
    TabOrder = 3
    object Label4: TLabel
      Left = 1
      Top = 1
      Width = 308
      Height = 56
      Align = alClient
      ExplicitWidth = 3
      ExplicitHeight = 15
    end
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 246
    Width = 624
    Height = 17
    TabOrder = 4
  end
  object Panel2: TPanel
    Left = 324
    Top = 182
    Width = 310
    Height = 58
    TabOrder = 5
    object Label5: TLabel
      Left = 1
      Top = 1
      Width = 308
      Height = 56
      Align = alClient
      ExplicitWidth = 3
      ExplicitHeight = 15
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 269
    Width = 626
    Height = 340
    Caption = 'Results'
    TabOrder = 6
    object TPageControl1: TPageControl
      Left = 1
      Top = 16
      Width = 623
      Height = 321
      ActivePage = TTabSheet1
      TabOrder = 0
      object TTabSheet1: TTabSheet
        Caption = 'Data'
        object StringGrid1: TStringGrid
          Left = 0
          Top = 0
          Width = 615
          Height = 291
          Align = alClient
          ColCount = 1
          FixedCols = 0
          RowCount = 1
          FixedRows = 0
          TabOrder = 0
          ColWidths = (
            64)
        end
      end
      object TTabSheet2: TTabSheet
        Caption = 'Plot'
        ImageIndex = 1
        object Chart1: TChart
          Left = 0
          Top = 0
          Width = 615
          Height = 291
          BackWall.Pen.Visible = False
          BottomWall.Brush.Gradient.EndColor = clSilver
          BottomWall.Brush.Gradient.StartColor = clGray
          BottomWall.Brush.Gradient.Visible = True
          BottomWall.Pen.Color = clGray
          BottomWall.Size = 4
          Gradient.Direction = gdFromTopLeft
          Gradient.EndColor = clWhite
          Gradient.StartColor = clSilver
          Gradient.Visible = True
          LeftWall.Brush.Gradient.EndColor = clSilver
          LeftWall.Brush.Gradient.StartColor = clGray
          LeftWall.Brush.Gradient.Visible = True
          LeftWall.Color = clWhite
          LeftWall.Pen.Color = clGray
          LeftWall.Size = 4
          Legend.Symbol.Gradient.EndColor = 2413052
          Title.Text.Strings = (
            'TChart')
          BottomAxis.Grid.Color = 14540253
          BottomAxis.LabelsFormat.Font.Color = clGray
          BottomAxis.LabelsFormat.Font.Height = -9
          BottomAxis.LabelStyle = talText
          Frame.Visible = False
          LeftAxis.Grid.Color = 14540253
          LeftAxis.LabelsFormat.Font.Color = clGray
          LeftAxis.LabelsFormat.Font.Height = -9
          LeftAxis.LabelStyle = talValue
          View3D = False
          Zoom.Animated = True
          Align = alClient
          BevelWidth = 2
          Color = clWhite
          TabOrder = 0
          DefaultCanvas = 'TGDIPlusCanvas'
          ColorPaletteIndex = 9
          object Series1: TBarSeries
            HoverElement = []
            XValues.Name = 'X'
            XValues.Order = loAscending
            YValues.Name = 'Bar'
            YValues.Order = loNone
          end
        end
      end
    end
  end
end
