unit uRenovar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls,
  ZConnection, ZDataset, IdHTTP, IdSSLOpenSSL, IdCompressorZLib, fpjson,
  jsonparser, DB;

type

  { TfrmRefreshToken }

  TfrmRefreshToken = class(TForm)
    btnRenovar: TButton;
    btnFechar: TButton;
    edtNovoAppID: TDBEdit;
    edtNovoRefresh: TDBEdit;
    edtClientid: TEdit;
    edtGrantType: TEdit;
    edtSecretKey: TEdit;
    EdtRefresh: TEdit;
    lblAppID: TLabel;
    lblNovoTK: TLabel;
    lblClient: TLabel;
    lblSecret: TLabel;
    lblGrant: TLabel;
    lblRefresh: TLabel;
    procedure btnRenovarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmRefreshToken: TfrmRefreshToken;

implementation
uses
  uDmDados;
{$R *.lfm}

{ TfrmRefreshToken }

procedure TfrmRefreshToken.btnRenovarClick(Sender: TObject);
var
Json : string;
JsonToSend: TStringStream;
responseBody: string;

HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_auth_url : string;
v_json_data : TJSONData;
//v_json_ml : TJSONObject;
v_novo_reftok, v_novo_appid : string;
begin

 Json:= '{"grant_type":"'+edtGrantType.Text+'","client_id":"'+edtClientid.Text+'","client_secret":"'+edtSecretKey.Text+'","refresh_token":"'+EdtRefresh.Text+'"}';
 JsonToSend:= TStringStream.Create(UTF8Encode(Json));


  v_auth_url := 'https://api.mercadolibre.com/oauth/token';
  try
     HttpClient := TIdHTTP.Create(nil);
     HttpClient.Request.Clear;

     HttpClient.Request.ContentType := 'application/json';
     HttpClient.Request.Charset := 'utf-8';
     HttpClient.ProtocolVersion := pv1_1;
     HttpClient.Response.Clear();

     HttpClient.HandleRedirects := true;

     HttpClient.Request.UserAgent := 'Mozilla/5.0 SingleCheff SingleCTR (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36';
     HttpClient.Request.AcceptEncoding := 'gzip, deflate, br';
     HttpClient.Request.AcceptLanguage := 'pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4';
     HttpClient.Request.CacheControl := 'no-cache';
     HttpClient.ConnectTimeout         := 3000;
     HttpClient.ReadTimeout            := 10000;

     IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create( HttpClient );
     IdSSLIOHandlerSocket.SSLOptions.SSLVersions := [sslvTLSv1_2];

     HttpClient.IOHandler := IdSSLIOHandlerSocket;

     try
        responseBody:= HttpClient.Post(v_auth_url, JsonToSend);

        v_json_data := TJSONParser.Create(responseBody).Parse;
        v_novo_reftok := v_json_data.FindPath('refresh_token').AsString;
        v_novo_appid  := v_json_data.FindPath('access_token').AsString;

        //memo1.lines.Clear;
        //memo1.lines.Add(responseBody);
     except
        on e : Exception do
        begin
          //
        end;
     end;

  finally
     HttpClient.Free;
  end;

  //Postar no Banco

   if not DmDados.qry_token.Active then
   begin
      DmDados.qry_token.Open;
   end;

   if DmDados.qry_token.RecordCount = 0 then
     DmDados.qry_token.insert
   else
     DmDados.qry_token.edit;

   DmDados.qry_token.FieldByName('reftoken').AsString := v_novo_reftok;
   DmDados.qry_token.FieldByName('appid').AsString := v_novo_appid;
   DmDados.qry_token.FieldByName('dthr_geracao').AsDateTime := Now;
   DmDados.qry_token.Post;
   ShowMessage('Um novo token foi gerado e registrado no banco de dados com sucesso!');

end;

procedure TfrmRefreshToken.btnFecharClick(Sender: TObject);
begin
  frmRefreshToken.Close;
end;

procedure TfrmRefreshToken.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  DmDados.cnx_BD.Disconnect;
end;

procedure TfrmRefreshToken.FormShow(Sender: TObject);
begin
  //Conexão com banco

  try
      DmDados.cnx_BD.Disconnect;
      DmDados.cnx_BD.User := 'postgres';
      DmDados.cnx_BD.Password := 'postgres';
      DmDados.cnx_BD.Database := 'ml_teste';
      DmDados.cnx_BD.HostName := 'localhost';
      DmDados.cnx_BD.Port := 5433;
      DmDados.cnx_BD.Connect;
   except
     ShowMessage('Falha ao conectar no banco de dados (Resultado não será salvo)');
   end;
end;

end.

