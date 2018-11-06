//Unit usendgrid
//Autor : Antonio Carlos Nunes Júnior (Toninho Nunes)
//Empresa: Avalue Sistemas LTDA
//Propósito : Usar o módulo Json api V3 do SendGrid
//Falta Implementar Lotes de 1000 emails por envio no registro personalizations
//farei esta adaptação no próximo update, o mesmo envia anexos diversos
//Fiz para funcionar no Delphi 7
//
//Bibliotecas de Terceiros
// - Component Indy 10 - http://indy.fulgan.com/ZIP/
// - gpDelphiUnits para lidar com Unicode - http://17slon.com/gp/gp/gptextstream.htm
//   Existe no github a versão mais atual dessa library, porém não compila certo com o
//   Delphi 7 e baixei desse link que funciona normal.
// - Json Delphi Libray - https://sourceforge.net/projects/lkjson/ - Lidar com Json no
//   Delphi 7

unit usendgrid;

interface

uses
    Forms, Classes, IdHTTP, uLkJSON, GpTextStream, Windows, Dialogs,
    IdCoderMIME, SysUtils;

type
  TSendGrid = class
  private
    fToMail  : String;
    fToName  : String;
    fToSubject : String;
    fSubject: String;
    fContentValue: String;
    fFromName: String;
    fFromMail: String;
    fContentType: String;
    fApiKey: String;
    fIdHTTP : TIdHTTP;
    fFilesName : TStringList;
    fContetTypeFile: string;
    function GetContentType: String;
    function GetContentValue: String;
    function GetFromMail: String;
    function GetFromName: String;
    function GetToMail: String;
    function GetToName: String;
    function GetToEncodeJSON : String;
    function GetToSubject: String;
    function GetJsonMail : String;
    function GetContentTypeFile: string;
    function GetFilesName: TStringList;
    procedure SetFilesName(const Value: TStringList);
  public
    constructor Create(sApiKey : String = '');
    destructor Destroy; override;
    property ApiKey          : String read fApiKey            write fApiKey;
    property ToMail          : String read GetToMail          write fToMail;
    property ToName          : String read GetToName          write fToName;
    property ToSubject       : String read GetToSubject       write fToSubject;
    property FromMail        : String read GetFromMail        write fFromMail;
    property FromName        : String read GetFromName        write fFromName;
    property ContentType     : String read GetContentType     write fContentType;
    property ContentValue    : String read GetContentValue    write fContentValue;
    property FileName        : TStringList read GetFilesName  write SetFilesName;
    property ContentTypeFile : string read GetContentTypeFile write fContetTypeFile;
    function SendMail : Boolean;
  end;

implementation

{ TSendGrid }
constructor TSendGrid.Create(sApiKey : String = '');
begin
  fFilesName := TStringList.Create;
  if sApiKey <> '' then
    fApiKey := sApiKey;

  fIdHTTP := TIdHTTP.Create(Application);
  with fIdHTTP do
  begin
    Request.Clear;
    Request.Method := 'POST';
    Request.CustomHeaders.AddValue('authorization', 'Bearer ' + fApiKey);
    Request.ContentType := 'application/json';
    Request.Accept := 'application/json';
    Request.CharSet := 'utf-8';
    Request.AcceptCharSet := 'utf-8';
    HTTPOptions := [];
  end;
end;

destructor TSendGrid.Destroy;
begin
  if Assigned(fFilesName) then
    fFilesName.Free;
    
  if Assigned(fIdHTTP) then
    fIdHTTP.Free;

  inherited;
end;

function TSendGrid.GetContentType: String;
begin
  Result := fContentType;
end;

function TSendGrid.GetContentTypeFile: string;
begin
  Result := fContetTypeFile;
end;

function TSendGrid.GetContentValue: String;
begin
  Result := fContentValue;
end;

function TSendGrid.GetFilesName: TStringList;
begin
  Result := fFilesName;
end;

function TSendGrid.GetFromMail: String;
begin
  Result := fFromMail;
end;

function TSendGrid.GetFromName: String;
begin
  Result := fFromName;
end;

function TSendGrid.GetJsonMail: String;
begin
  Result := GetToEncodeJSON;
end;

function TSendGrid.GetToEncodeJSON: String;
var
  s, sTo, sFrom,
  sContent, sAttachment,
  sFile64Output : String;
  aFileStream : TFileStream;
  aEncode64 : TIdEncoderMIME;
  js : TlkJSONobject;
  I : integer;
begin
  js := TlkJSONobject.Create;
  js.Add('email', GetToMail);
  js.Add('name', GetToName);
  sTo := UTF8Decode( TlkJSON.GenerateText(js) );
  js.Free;

  s := '"personalizations": [';
  s := s + '{';
  s := s + '"to" : [';
  s := s + sTo;
  s := s + '],';
  s := s + '}';
  s := s + '],';
  s := s + '"from": ';

  js := TlkJSONobject.Create;
  js.Add('email', GetFromMail);
  js.Add('name', GetFromName);
  sFrom := UTF8Decode( TlkJSON.GenerateText(js) );
  js.Free;

  s := s + sFrom + ',';
  s := s + GetToSubject;

  js := TlkJSONobject.Create;
  js.Add('type', GetContentType);
  js.Add('value', GetContentValue);
  sContent := UTF8Decode( TlkJSON.GenerateText(js) );
  js.Free;

  s := s + '"content": [';
  s := s + sContent;
  s := s + '] ';

  if fFilesName.Count > 0 then
  begin
    s := s + ', "attachments": [';
    for I := 0 to fFilesName.Count-1 do
    begin

      try
        aFileStream := TFileStream.Create(fFilesName.Strings[I], fmOpenRead);
        aEncode64 := TIdEncoderMIME.Create(nil);
        sFile64Output := aEncode64.Encode(aFileStream, aFileStream.Size);
      finally
        if Assigned(aFileStream) then
          aFileStream.Free;

        if Assigned(aEncode64) then
          aEncode64.Free;
      end;

      js := TlkJSONobject.Create;
      js.Add('content', sFile64Output);
      js.Add('filename', fFilesName.Strings[I]);
      js.Add('content_id', 'logopara');
      js.Add('disposition', 'inline');

      sAttachment := UTF8Decode(TlkJSON.GenerateText(js));
      js.Free;

      if I > 0 then
        s := s + ', ';

      s := s + sAttachment;
    end;
    s := s + ']';
  end;
  Result := '{' + s + '}';
end;

function TSendGrid.GetToMail: String;
begin
  Result := fToMail;
end;

function TSendGrid.GetToName: String;
begin
  Result := fToName;
end;

function TSendGrid.GetToSubject: String;
begin
  Result := '"subject":' + '"' + fToSubject + '", ';
end;

function TSendGrid.SendMail: Boolean;
var
  RequestUTF8 : TStringStream;
  vGpTextStream : TGpTextStream;
begin
  try
    RequestUTF8 := TStringStream.Create('');
    vGpTextStream := TGpTextStream.Create(RequestUTF8, tsaccWrite,[], CP_UTF8);
    vGpTextStream.WriteString(GetJsonMail);
    fIdHTTP.Post('https://api.sendgrid.com/v3/mail/send', RequestUTF8);
  finally
    RequestUTF8.Free;
    vGpTextStream.Free;
  end;
end;

procedure TSendGrid.SetFilesName(const Value: TStringList);
begin
  fFilesName.AddStrings(Value);
end;

end.
