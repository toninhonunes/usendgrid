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
    Memo_Emails: TMemo;
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
  i : Integer;
begin
  SendGrid := TSendGrid.Create('yourpasswordapi');
  with SendGrid do
  try
    ToMail := 'test@test.com';
    ToName := 'TO NAME';
    ToSubject := 'Contactando o email corretamente';
    FromMail := 'noreply@youremail.com';
    FromName := 'EMPRESA TESTE';
    ReplyTo  := 'replay@emailreplay.com';
    ReplyToName := 'TESTE RESPOSTA';
    ContentType := 'text/html';
    ContentValue := Memo1.Lines.GetText;
    ContentId := 'logo';
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
