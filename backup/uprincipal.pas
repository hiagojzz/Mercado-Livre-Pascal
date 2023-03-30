unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ACBrAAC, ACBrCalculadora, IdHTTP, IdSSLOpenSSL, IdCompressorZLib, fpjson,
  jsonparser, jsonscanner, ZConnection, DBCtrls, DB, ZDataset;

type

  { TfrmPrincipall }

  TfrmPrincipall = class(TForm)
    btnPOST: TButton;
    btnProdutos: TButton;
    btnConfig: TButton;
    BtnRenovar: TButton;
    btnSair: TButton;
    btnUserID: TButton;
    btnBuscarP: TButton;
    edtNovoRefresh: TEdit;
    EdtAccessToken: TEdit;
    edtAppID: TEdit;
    edtSecretKey: TEdit;
    edtURI: TEdit;
    edtCode: TEdit;
    edtGrantType: TEdit;
    EdtRefresh: TEdit;
    lblNovoRefresh: TLabel;
    lblSecretKey: TLabel;
    lblURI: TLabel;
    lblCode: TLabel;
    lblGrant: TLabel;
    lblRefresh: TLabel;
    lblAccess: TLabel;
    lblAppID: TLabel;
    Memo1: TMemo;
    pnlPrincipal: TPanel;
    procedure btnBuscarPClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnPOSTClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure BtnRenovarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure btnUserIDClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
      v_str_json_cadastro : string;
      function f_busca_token(p_client_id: string): string;
      function f_verificar_expiracao(v_date: TDateTime): string;
  public

  end;

var
  frmPrincipall: TfrmPrincipall;

implementation
uses
  uProdutos, uConta, uDmDados, uRenovar, ubuscaorders;
{$R *.lfm}

{ TfrmPrincipall }

procedure TfrmPrincipall.btnConfigClick(Sender: TObject);
begin
   frmLogin := TfrmLogin.Create(self);
   frmLogin.ShowModal;
end;

procedure TfrmPrincipall.btnBuscarPClick(Sender: TObject);
begin
  frmBuscarPedidos := TfrmBuscarPedidos.Create(self);
  frmBuscarPedidos.ShowModal;
end;

function TfrmPrincipall.f_verificar_expiracao(v_date: TDateTime): string;
var
  //v_comparacao : String;
  datahora : TDateTime;
begin
   datahora := DmDados.qry_token.FieldByName('dthr_geracao').AsDateTime + 6;
   if datahora > Now then
   begin
     ShowMessage('Oi, estou funcionando')
   end;
end;

function TfrmPrincipall.f_busca_token(p_client_id:string):string;
var
HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_JsonStreamRetorno :  TStringStream;
v_resultAPI, v_ws_ml_auth : string;
IdCompressorZLib : TIdCompressorZLib;
begin

  v_JsonStreamRetorno := TStringStream.Create('');
  v_ws_ml_auth := 'https://auth.mercadolivre.com.br/authorization?response_type=code&client_id='+p_client_id+'&redirect_uri=http://localhost:80';

  try
       HttpClient := TIdHTTP.Create(nil);
       HttpClient.Request.Clear;
       HttpClient.ProtocolVersion := pv1_1;

       HttpClient.Response.Clear();

       HttpClient.HandleRedirects := true;

       HttpClient.Request.ContentType := '*';
       HttpClient.Request.Charset := 'UTF-8';
       HttpClient.ProtocolVersion := pv1_1;
       HttpClient.HandleRedirects := true;
       HttpClient.Request.UserAgent := 'Mozilla/5.0 SingleCheff SingleCTR (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.84 Safari/537.36';
       HttpClient.Request.AcceptEncoding := '*';
       HttpClient.Request.CacheControl := 'no-cache';
       HttpClient.ConnectTimeout         := 3000;
       HttpClient.ReadTimeout            := 10000;

       IdCompressorZLib := TIdCompressorZLib.Create(nil);
       HttpClient.Compressor := IdCompressorZLib;

       IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create( HttpClient );
       IdSSLIOHandlerSocket.SSLOptions.SSLVersions := [sslvTLSv1_2];
       HttpClient.IOHandler := IdSSLIOHandlerSocket;

       try
          HttpClient.GET(v_ws_ml_auth, v_JsonStreamRetorno );
          v_resultAPI := v_JsonStreamRetorno.DataString;

       except
          on e : Exception do
          begin
            //
          end;
       end;

    finally
       HttpClient.Free;
    end;
    Result := v_resultAPI;

end;

procedure TfrmPrincipall.btnPOSTClick(Sender: TObject);
var
HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_JsonStreamEnvio, v_JsonStreamRetorno :  TStringStream;
v_resultAPI : string;
v_ws_ml_cad_prod : string;
v_header_auth : string;
begin

  v_JsonStreamEnvio := TStringStream.Create(v_str_json_cadastro);
  v_JsonStreamRetorno := TStringStream.Create('');
  v_ws_ml_cad_prod := 'https://api.mercadolibre.com/items';

try
     HttpClient := TIdHTTP.Create(nil);
     HttpClient.Request.Clear;

     HttpClient.Request.ContentType := 'application/json';
     HttpClient.Request.Charset := 'utf-8';
     HttpClient.ProtocolVersion := pv1_1;
     v_header_auth := 'Bearer APP_USR-2470080450506772-012409-164aa545459811427226bc718783aa24-1245397018';
     HttpClient.Request.CustomHeaders.AddValue('Authorization', v_header_auth);
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
        HttpClient.Post(v_ws_ml_cad_prod, v_JsonStreamEnvio, v_JsonStreamRetorno );
        v_resultAPI := v_JsonStreamRetorno.DataString;
        memo1.lines.Clear;
        memo1.lines.Add(v_resultAPI);
     except
        on e : Exception do
        begin
          //
        end;
     end;

  finally
     HttpClient.Free;
  end;

end;

procedure TfrmPrincipall.btnProdutosClick(Sender: TObject);
begin
  frmProduto := TfrmProduto.Create(self);
  frmProduto.ShowModal;
end;

procedure TfrmPrincipall.BtnRenovarClick(Sender: TObject);
begin
     frmRefreshToken := TfrmRefreshToken.Create(self);
     frmRefreshToken.EdtRefresh.Text := EdtRefresh.Text;
     frmRefreshToken.ShowModal;

end;

procedure TfrmPrincipall.btnSairClick(Sender: TObject);
begin
  frmPrincipall.Close;
end;

procedure TfrmPrincipall.btnUserIDClick(Sender: TObject);
var
Json : string;
JsonToSend: TStringStream;
responseBody: string;

HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_auth_url : string;
v_json_data : TJSONData;
//v_json_ml : TJSONObject;
begin

Json:= '{"grant_type":"'+edtGrantType.Text+'","client_id":"'+edtAppID.Text+'","client_secret":"'+edtSecretKey.Text+'","code":"'+edtCode.Text+'","redirect_uri":"'+edtURI.Text+'"}';
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

        v_json_data := TJSONParser(responseBody).Parse;
        EdtAccessToken.Text := v_json_data.FindPath('access_token').AsString;
        EdtRefresh.Text := v_json_data.FindPath('refresh_token').AsString;

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

end;

procedure TfrmPrincipall.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  DmDados.cnx_BD.Disconnect;
end;

procedure TfrmPrincipall.FormShow(Sender: TObject);
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

  v_str_json_cadastro := '{ ' +
                         '     "title":"Pulseira Grumet LAZARUS - Não Ofertar",  '+
                         '     "category_id":"MLB1434",                          '+
                         '     "price":2700,                                     '+
                         '     "currency_id":"BRL",                              '+
                         '     "available_quantity":10,                          '+
                         '     "buying_mode":"buy_it_now",                       '+
                         '     "condition":"new",                                '+
                         '     "listing_type_id":"gold_pro",                     '+
                         '     "sale_terms":[                                    '+
                         '        {                                              '+
                         '               "id": "WARRANTY_TIME",                  '+
                         '               "name": "Tempo de garantia",            '+
                         '               "value_id": null,                       '+
                         '               "value_name": "30 dias",                '+
                         '               "value_struct": {                       '+
                         '                   "number": 30,                       '+
                         '                   "unit": "dias"                      '+
                         '               },                                      '+
                         '               "values": [                             '+
                         '                   {                                   '+
                         '                       "id": null,                     '+
                         '                       "name": "30 dias",              '+
                         '                       "struct": {                     '+
                         '                           "number": 30,               '+
                         '                           "unit": "dias"              '+
                         '                       }                               '+
                         '                   }                                   '+
                         '               ],                                      '+
                         '               "value_type": "number_unit"             '+
                         '           },                                                                           '+
                         '        {                                                                               '+
                         '           "id": "WARRANTY_TYPE",                                                       '+
                         '               "name": "Tipo de garantia",                                              '+
                         '               "value_id": "2230280",                                                   '+
                         '               "value_name": "Garantia do vendedor",                                    '+
                         '               "value_struct": null,                                                    '+
                         '               "values": [                                                              '+
                         '                   {                                                                    '+
                         '                       "id": "2230280",                                                 '+
                         '                       "name": "Garantia do vendedor",                                  '+
                         '                       "struct": null                                                   '+
                         '                   }                                                                    '+
                         '               ],                                                                       '+
                         '               "value_type": "list"                                                     '+
                         '           }                                                                            '+
                         '       ],                                                                               '+
                         '       "accepts_mercadopago": true,                                                     '+
                         '       "non_mercado_pago_payment_methods": [],                                          '+
                         '       "shipping": {                                                                    '+
                         '           "mode": "me2",                                                               '+
                         '           "methods": [],                                                               '+
                         '           "tags": [                                                                    '+
                         '               "mandatory_free_shipping"                                                '+
                         '           ],                                                                           '+
                         '           "dimensions": null,                                                          '+
                         '           "local_pick_up": false,                                                      '+
                         '           "free_shipping": true,                                                       '+
                         '           "store_pick_up": false                                                       '+
                         '       },                                                                               '+
                         '     "pictures":[                                                                       '+
                         '        {                                                                               '+
                         '           "source":"https://http2.mlstatic.com/D_865762-MLB51020516037_082022-O.jpg"   '+
                         '        },                                                                              '+
                         '        {                                                                               '+
                         '           "source":"http://http2.mlstatic.com/D_907546-MLB51064214973_082022-O.jpg"    '+
                         '        },                                                                              '+
                         '        {                                                                               '+
                         '           "source":"http://http2.mlstatic.com/D_892670-MLB51064220948_082022-O.jpg"    '+
                         '        },                                                                              '+
                         '        {                                                                               '+
                         '           "source":"http://http2.mlstatic.com/D_604172-MLB51064354142_082022-O.jpg"    '+
                         '        },                                                                              '+
                         '        {                                                                               '+
                         '           "source":"http://http2.mlstatic.com/D_724995-MLB51020515042_082022-O.jpg"    '+
                         '        },                                                                              '+
                         '        {                                                                               '+
                         '           "source":"http://singlesistemas.com.br/wp-content/uploads/2018/04/Single-Control-300x172.png"    '+
                         '        }                                '+
                         '     ],                                  '+
                         '     "attributes":[                      '+
                         '        {                                '+
                         '           "id":"BRAND",                 '+
                         '           "value_name":"Majorica"       '+
                         '        },                               '+
                         '        {                                '+
                         '           "id":"MODEL",                 '+
                         '           "value_name":"508647"         '+
                         '        },                               '+
                         '        {                                '+
                         '           "id":"GENDER",                '+
                         '           "value_name":"Mulher"         '+
                         '        },                               '+
                         '        {                                '+
                         '           "id":"COLOR",                 '+
                         '           "value_name":"Dourado"        '+
                         '        },                               '+
                         '        {                                '+
                         '           "id":"MATERIALS",             '+
                         '           "value_name":"Banhado a ouro" '+
                         '        }  '+
                         '     ]'+
                         '   }';
end;

end.

