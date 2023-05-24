object Form1: TForm1
  Left = 256
  Top = 148
  Width = 924
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 259
    Top = 346
    Width = 75
    Height = 25
    Caption = 'Enviar'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 341
    Top = 346
    Width = 75
    Height = 25
    Caption = 'Anexos'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 908
    Height = 153
    Align = alTop
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Memo_Emails: TMemo
    Left = 0
    Top = 153
    Width = 908
    Height = 159
    Align = alTop
    Lines.Strings = (
      'Memo_Emails')
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 129
    Top = 187
  end
end
