object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'DelphiMatrixBenchmark'
  ClientHeight = 587
  ClientWidth = 804
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
    Width = 337
    Height = 207
    BiDiMode = bdLeftToRight
    Caption = 'Matrix Multiplication'
    ParentBiDiMode = False
    TabOrder = 0
    object Label1: TLabel
      Left = 15
      Top = 105
      Width = 11
      Height = 75
      Alignment = taCenter
      Caption = 'M'#13#10#13#10'K'#13#10#13#10'N'
    end
    object Shape1: TShape
      Left = 173
      Top = 116
      Width = 70
      Height = 70
    end
    object Label4: TLabel
      Left = 149
      Top = 137
      Width = 11
      Height = 15
      Alignment = taCenter
      Caption = 'M'
    end
    object Shape2: TShape
      Left = 249
      Top = 116
      Width = 70
      Height = 70
    end
    object Shape3: TShape
      Left = 249
      Top = 40
      Width = 70
      Height = 70
    end
    object Label5: TLabel
      Left = 205
      Top = 95
      Width = 7
      Height = 15
      Alignment = taCenter
      Caption = 'K'
    end
    object Label6: TLabel
      Left = 236
      Top = 68
      Width = 7
      Height = 15
      Alignment = taCenter
      Caption = 'K'
    end
    object Label7: TLabel
      Left = 280
      Top = 19
      Width = 9
      Height = 15
      Alignment = taCenter
      Caption = 'N'
    end
    object Label8: TLabel
      Left = 236
      Top = 98
      Width = 5
      Height = 15
      Alignment = taCenter
      Caption = 'x'
    end
    object Label9: TLabel
      Left = 15
      Top = 27
      Width = 204
      Height = 45
      Caption = 
        'Matrix Multiplication is a fundamental '#13#10'linear algebra operatio' +
        'n, expressed as:'#13#10'C = A x B'
    end
    object Label10: TLabel
      Left = 201
      Top = 145
      Width = 8
      Height = 15
      Alignment = taCenter
      Caption = 'A'
    end
    object Label11: TLabel
      Left = 280
      Top = 68
      Width = 7
      Height = 15
      Alignment = taCenter
      Caption = 'B'
    end
    object Label12: TLabel
      Left = 281
      Top = 145
      Width = 8
      Height = 15
      Alignment = taCenter
      Caption = 'C'
    end
    object SpinEdit1: TSpinEdit
      Left = 47
      Top = 102
      Width = 69
      Height = 24
      Increment = 32
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 512
    end
    object SpinEdit4: TSpinEdit
      Left = 47
      Top = 132
      Width = 69
      Height = 24
      Increment = 32
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 512
    end
    object SpinEdit5: TSpinEdit
      Left = 47
      Top = 162
      Width = 69
      Height = 24
      Increment = 32
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 512
    end
    object StaticText1: TStaticText
      Left = 15
      Top = 26
      Width = 4
      Height = 4
      TabOrder = 3
    end
  end
  object Button1: TButton
    Left = 8
    Top = 221
    Width = 787
    Height = 34
    Caption = 'Run Benchmark'
    TabOrder = 1
    OnClick = Button1Click
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 263
    Width = 787
    Height = 316
    BiDiMode = bdLeftToRight
    Caption = 'Results'
    Color = clBtnFace
    Ctl3D = True
    ParentBackground = False
    ParentBiDiMode = False
    ParentColor = False
    ParentCtl3D = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object TPageControl1: TPageControl
      Left = 2
      Top = 17
      Width = 783
      Height = 297
      ActivePage = TTabSheet1
      Align = alClient
      TabOrder = 0
      object TTabSheet1: TTabSheet
        Caption = 'Data'
        object StringGrid1: TStringGrid
          Left = 0
          Top = 0
          Width = 775
          Height = 267
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
          Width = 775
          Height = 267
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
  object GroupBox4: TGroupBox
    Left = 351
    Top = 8
    Width = 444
    Height = 207
    BiDiMode = bdLeftToRight
    Caption = 'Implementations'
    ParentBiDiMode = False
    TabOrder = 3
    object Label2: TLabel
      Left = 15
      Top = 171
      Width = 42
      Height = 15
      Caption = 'Threads'
    end
    object Label3: TLabel
      Left = 15
      Top = 27
      Width = 131
      Height = 15
      Caption = 'Executions per algorithm'
    end
    object SpinEdit2: TSpinEdit
      Left = 102
      Top = 168
      Width = 69
      Height = 24
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 4
    end
    object SpinEdit3: TSpinEdit
      Left = 163
      Top = 22
      Width = 69
      Height = 24
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 5
    end
    object CheckListBox2: TCheckListBox
      Left = 15
      Top = 52
      Width = 410
      Height = 104
      ItemHeight = 15
      TabOrder = 2
    end
  end
end
