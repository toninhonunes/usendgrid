//Unit usendgrid
//Autor : Antonio Carlos Nunes Júnior (Toninho Nunes)
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
    IdCoderMIME, SysUtils, StrUtils;

type

  TParams = array of String;

  TSendGrid = class
  private
    fToMail  : String;
    //fToMail: TStringList;
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
    fTobcc : TStringList;
    fContetTypeFile: string;
    fLimit: Integer;
    fContentId: string;
    fFileStream: TList;
    fReplayTo: String;
    fReplayToName: string;
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
    function GetTobcc: TStringList;
    procedure SetTobcc(const Value: TStringList);
    function DecodeParams(FParams: String): TParams;
    function GetContentId: string;
    function GetReplyTo: String;
    function GetReplyToName: string;
    //function GetToMail: TStringList;
    //procedure SetToMail(const Value: TStringList);
  public
    constructor Create(sApiKey : String = '');
    destructor Destroy; override;
    property ApiKey          : String read fApiKey            write fApiKey;
    property ToMail          : String read GetToMail          write fToMail;
    //property ToMail          : TStringList read GetToMail     write SetToMail;
    property Tobcc           : TStringList read GetTobcc      write SetTobcc;
    property ToName          : String read GetToName          write fToName;
    property ToSubject       : String read GetToSubject       write fToSubject;
    property FromMail        : String read GetFromMail        write fFromMail;
    property FromName        : String read GetFromName        write fFromName;
    property ReplyTo         : String read GetReplyTo         write fReplayTo;
    property ReplyToName     : string read GetReplyToName     write fReplayToName;
    property ContentType     : String read GetContentType     write fContentType;
    property ContentValue    : String read GetContentValue    write fContentValue;
    property FileName        : TStringList read GetFilesName  write SetFilesName;
    property FileStream      : TList read fFileStream write fFileStream;
    property ContentTypeFile : string read GetContentTypeFile write fContetTypeFile;
    property ContentId       : string read GetContentId       write fContentId;
    property Limit           : Integer read fLimit write fLimit default 999;
    function SendMail        : Boolean;
  end;

implementation

{ TSendGrid }
constructor TSendGrid.Create(sApiKey : String = '');
begin
  fContentId := '';
  fFilesName := TStringList.Create;
  fFileStream:= TList.Create;
  fTobcc     := TStringList.Create;
  //fToMail    := TStringList.Create;
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
var
  I : Integer;
begin
  if Assigned(fFilesName) then
    fFilesName.Free;

  if Assigned(fFileStream) then
  begin
    fFileStream.Free;
  end;

  if Assigned( fTobcc ) then
    fTobcc.Free;

  //if Assigned( fToMail ) then
  //  fToMail.Free;

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
  s, sTo, sTobcc, sFrom, sReply_To,
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

  //s := s + '"to" : [{';
  //s := s + sTo;
  //s := s + '}],';

  s := s + '"to" : [';
  s := s + sTo;
  s := s + '],';


  if fTobcc.Count > 0 then
  begin
    s := s + '"bcc" : [';
    for I := 0 to fTobcc.Count-1 do
    begin
      js := TlkJSONobject.Create;
      js.Add('email', DecodeParams(fTobcc.Strings[I])[0] );
      js.Add('name', DecodeParams(fTobcc.Strings[I])[1] );
      sTobcc := sTobcc + UTF8Decode( TlkJSON.GenerateText(js) ) + ifThen( I < fTobcc.Count-1, ',', '');
      js.Free;
    end;
    s := s + sTobcc + '],';
  end;

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

  //ReplyTo
  if GetReplyTo <> '' then
  begin
    s := s + '"reply_to": ';
    js := TlkJSONobject.Create;
    js.Add('email', GetReplyTo);
    js.Add('name', GetFromName);
    sReply_To := UTF8Decode( TlkJSON.GenerateText(js) );
    js.Free;
    s := s + sReply_To + ',';
  end;

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
        if fFileStream.Count <= 0 then
        begin
          aFileStream := TFileStream.Create(fFilesName.Strings[I], fmOpenRead);
          aEncode64 := TIdEncoderMIME.Create(nil);
          sFile64Output := aEncode64.Encode(aFileStream, aFileStream.Size);
        end
        else
        begin
          aEncode64 := TIdEncoderMIME.Create(nil);
          TStream(fFileStream[i]).Position := 0;
          sFile64Output := aEncode64.Encode( TStream(fFileStream[i]), TStream(fFileStream[i]).Size );
        end;
      finally
        if Assigned(aFileStream) then
          aFileStream.Free;

        if Assigned(aEncode64) then
          aEncode64.Free;
      end;

      js := TlkJSONobject.Create;
      js.Add('content', sFile64Output);
      js.Add('filename', fFilesName.Strings[I]);
      js.Add('content_id', fContentId);
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
  Response : TIdHTTPResponse;
begin
  if fTobcc.Count > 999+1 then
  begin
    Application.MessageBox('Cada lote de envio deve ter no máximo 999 emails,'
      + #13#10 + 'faça um loop no seu código para criar lotes nessa ' + #13#10
      + 'quantidade para enviar!', 'Aviso !', MB_OK + MB_ICONSTOP +
      MB_DEFBUTTON2);
    SysUtils.Abort;
  end;

  try
    RequestUTF8 := TStringStream.Create('');
    vGpTextStream := TGpTextStream.Create(RequestUTF8, tsaccWrite,[], CP_UTF8);
    vGpTextStream.WriteString(GetJsonMail);
    fIdHTTP.Post('https://api.sendgrid.com/v3/mail/send', RequestUTF8);
    Result := Pos('202',fIdHTTP.ResponseText) > 0;
  finally
    RequestUTF8.Free;
    vGpTextStream.Free;
  end;
end;

procedure TSendGrid.SetFilesName(const Value: TStringList);
begin
  fFilesName.AddStrings(Value);
end;

function TSendGrid.GetTobcc: TStringList;
begin
  Result := fTobcc;
end;

procedure TSendGrid.SetTobcc(const Value: TStringList);
begin
  fTobcc.AddStrings(Value);
end;

function TSendGrid.DecodeParams( FParams : String ) : TParams;
var
  FParam : TParams;
  S : String;
  I,J,K : Integer;
begin
  J := 0;
  for I := 1 to Length(FParams) do
    if Pos(';',FParams[I]) > 0 then
      Inc(J,1);

  SetLength(FParam, J+1);
  J := 0;
  K := 0;

  for I := 1 to Length(FParams) do
  begin
    K := Pos(';', FParams[I]);

    if K > 0 then
    begin
      FParam[J] := S;
      S := '';
      Inc(J,1);
    end
    else
      S := S + FParams[I];
  end;
  FParam[J] := S;
  Result := FParam;
end;

function TSendGrid.GetContentId: string;
begin
  Result := fContentId;
end;

function TSendGrid.GetReplyTo: String;
begin
  Result := fReplayTo;
end;

function TSendGrid.GetReplyToName: string;
begin
  Result := fReplayToName;
end;

{
function TSendGrid.GetToMail: TStringList;
begin
  Result := fToMail;
end;

procedure TSendGrid.SetToMail(const Value: TStringList);
begin
  fToMail.AddStrings(Value);
end;}

end.
