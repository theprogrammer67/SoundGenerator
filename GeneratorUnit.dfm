object Form1: TForm1
  Left = 242
  Top = 134
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1043#1077#1085#1077#1088#1072#1090#1086#1088' '#1089#1080#1075#1085#1072#1083#1072
  ClientHeight = 818
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object btnPlay: TButton
    Left = 8
    Top = 208
    Width = 273
    Height = 25
    Caption = #1055#1091#1089#1082
    TabOrder = 0
    OnClick = btnPlayClick
  end
  object btnStop: TButton
    Left = 288
    Top = 208
    Width = 273
    Height = 25
    Caption = #1057#1090#1086#1087
    TabOrder = 1
    OnClick = btnStopClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 273
    Height = 193
    Caption = ' '#1051#1077#1074#1099#1081' '#1082#1072#1085#1072#1083' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    object Label3: TLabel
      Left = 16
      Top = 128
      Width = 134
      Height = 16
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1080#1075#1085#1072#1083#1072', '#1043#1094':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 16
      Top = 160
      Width = 115
      Height = 16
      Caption = #1059#1088#1086#1074#1077#1085#1100' '#1089#1080#1075#1085#1072#1083#1072':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object seLfreq: TSpinEdit
      Left = 176
      Top = 120
      Width = 81
      Height = 26
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Increment = 10
      MaxValue = 20000
      MinValue = 100
      ParentFont = False
      TabOrder = 0
      Value = 1000
      OnChange = seLfreqChange
    end
    object seLLev: TSpinEdit
      Left = 176
      Top = 152
      Width = 81
      Height = 26
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Increment = 200
      MaxValue = 32767
      MinValue = 0
      ParentFont = False
      TabOrder = 1
      Value = 20000
      OnChange = seLLevChange
    end
    object rgL: TRadioGroup
      Left = 16
      Top = 20
      Width = 241
      Height = 94
      Caption = ' '#1058#1080#1087' '#1089#1080#1075#1085#1072#1083#1072' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        #1090#1080#1096#1080#1085#1072
        #1089#1080#1085#1091#1089
        #1084#1077#1072#1085#1076#1088
        #1042#1086#1083#1085#1072)
      ParentFont = False
      TabOrder = 2
      OnClick = cbLtypChange
    end
  end
  object GroupBox2: TGroupBox
    Left = 288
    Top = 8
    Width = 273
    Height = 193
    Caption = ' '#1055#1088#1072#1074#1099#1081' '#1082#1072#1085#1072#1083' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    object Label6: TLabel
      Left = 16
      Top = 128
      Width = 134
      Height = 16
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1080#1075#1085#1072#1083#1072', '#1043#1094':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label7: TLabel
      Left = 16
      Top = 160
      Width = 115
      Height = 16
      Caption = #1059#1088#1086#1074#1077#1085#1100' '#1089#1080#1075#1085#1072#1083#1072':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object seRfreq: TSpinEdit
      Left = 176
      Top = 120
      Width = 81
      Height = 26
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Increment = 10
      MaxValue = 20000
      MinValue = 100
      ParentFont = False
      TabOrder = 0
      Value = 1000
      OnChange = seRfreqChange
    end
    object seRLev: TSpinEdit
      Left = 176
      Top = 152
      Width = 81
      Height = 26
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Increment = 200
      MaxValue = 32767
      MinValue = 0
      ParentFont = False
      TabOrder = 1
      Value = 20000
      OnChange = seRLevChange
    end
    object rgR: TRadioGroup
      Left = 16
      Top = 20
      Width = 241
      Height = 94
      Caption = ' '#1058#1080#1087' '#1089#1080#1075#1085#1072#1083#1072' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        #1090#1080#1096#1080#1085#1072
        #1089#1080#1085#1091#1089
        #1084#1077#1072#1085#1076#1088
        #1042#1086#1083#1085#1072)
      ParentFont = False
      TabOrder = 2
      OnClick = cbRTypChange
    end
  end
  object pnlWawe: TPanel
    Left = 25
    Top = 250
    Width = 516
    Height = 516
    BorderStyle = bsSingle
    TabOrder = 4
    object pbWave: TPaintBox
      Left = 0
      Top = 0
      Width = 512
      Height = 512
      Color = clWhite
      ParentColor = False
      OnMouseDown = pbWaveMouseDown
      OnMouseMove = pbWaveMouseMove
      OnMouseUp = pbWaveMouseUp
      OnPaint = pbWavePaint
    end
  end
  object btn1: TButton
    Left = 25
    Top = 772
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 5
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 106
    Top = 772
    Width = 75
    Height = 25
    Caption = 'btn2'
    TabOrder = 6
    OnClick = btn2Click
  end
  object statStatus: TStatusBar
    Left = 0
    Top = 799
    Width = 584
    Height = 19
    Panels = <
      item
        Width = 1024
      end>
    ExplicitWidth = 911
  end
end
