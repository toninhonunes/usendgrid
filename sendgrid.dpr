program sendgrid;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  usendgrid in 'usendgrid.pas',
  uLkJSON in '..\lkJSON\uLkJSON.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
