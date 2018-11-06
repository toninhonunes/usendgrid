unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, GpTextStream, fs_synmemo, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdMessageClient, IdSMTPBase, IdSMTP;

type
  TForm1 = class(TForm)
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  usendgrid;

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
var
  SendGrid : TSendGrid;
begin
  SendGrid := TSendGrid.Create('your key here');
  with SendGrid do
  try
    ToMail := 'youremail';
    ToName := 'toname';
    ToSubject := 'Testing';
    FromMail := 'fromemail';
    FromName := 'FromName';
    ContentType := 'text/html';
    ContentValue := Memo1.Lines.GetText;
    FileName.AddStrings(OpenDialog1.Files);
    SendMail;
  finally
    Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  OpenDialog1.Execute;
end;

end.
