object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Form4'
  ClientHeight = 447
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 525
    Height = 406
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 406
    Width = 525
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Edit1: TEdit
      Left = 11
      Top = 13
      Width = 184
      Height = 21
      TabOrder = 0
      Text = '10.0.0.1'
    end
    object Button1: TButton
      Left = 201
      Top = 9
      Width = 75
      Height = 25
      Caption = 'tracert'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object Tracert1: TTracert
    MaxJumpsCount = 30
    AttemptsCount = 3
    Timeout = 5000
    OnBeforeTraceJumpX = Tracert1BeforeTraceJumpX
    OnTraceAttempt = Tracert1TraceAttempt
    OnAfterTraceJumpX = Tracert1AfterTraceJumpX
    OnTraceFinish = Tracert1TraceFinish
    Left = 151
    Top = 362
  end
end
