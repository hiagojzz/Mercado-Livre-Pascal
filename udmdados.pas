unit uDmDados;

{$mode ObjFPC}{$H+}

interface

uses
   Classes, SysUtils, DB,ZConnection, ZDataset, DateUtils, Dialogs, IdHTTP,
   IdSSLOpenSSL, fpjson, jsonparser ;

type

   { TDmDados }

   TDmDados = class(TDataModule)
     ds_clientes: TDataSource;
     ds_dadospgt: TDataSource;
     dsPaiPedidos: TDataSource;
     dsPedidos: TDataSource;
     ds1: TDataSource;
     dsToken: TDataSource;
     qry_clientescli_cidade: TStringField;
     qry_clientescli_estado: TStringField;
     qry_clientescli_id: TLongintField;
     qry_clientescli_nome: TStringField;
     qry_clientescli_payer_id: TStringField;
     qry_clientescli_status: TStringField;
     qry_dadosaccess_token: TStringField;
     qry_dadosclient_id: TLongintField;
     qry_dadosclient_secret: TStringField;
     qry_dadoscode: TStringField;
     qry_dadosContaID: TLongintField;
     qry_dadospgtid: TLongintField;
     qry_dadospgtpgt_name: TStringField;
     qry_dadospgtpgt_order_id: TStringField;
     qry_dadospgtpgt_payer_id: TStringField;
     qry_dadospgtpgt_payment_date: TStringField;
     qry_dadospgtpgt_payment_method: TStringField;
     qry_dadosrefresh_token: TStringField;
     qry_dadosURL: TStringField;
     qry_dadosuser_id: TStringField;
     qry_pai_pedidosped_principal_date_approved: TStringField;
     qry_pai_pedidosped_principal_id: TLongintField;
     qry_pai_pedidosped_principal_nome: TStringField;
     qry_pai_pedidosped_principal_order_id: TStringField;
     qry_pai_pedidosped_principal_order_value: TFloatField;
     qry_pai_pedidosped_principal_pack_id: TStringField;
     qry_pai_pedidosped_principal_payer_id: TStringField;
     qry_pai_pedidosped_principal_payment_method: TStringField;
     qry_pai_pedidosped_principal_shipping_id: TStringField;
     qry_pai_pedidosped_principal_status: TStringField;
     qry_pedidosped_itens_date_approved: TStringField;
     qry_pedidosped_itens_id: TLongintField;
     qry_pedidosped_itens_order_id: TLargeintField;
     qry_pedidosped_itens_pack_id: TStringField;
     qry_pedidosped_itens_reason: TStringField;
     qry_token: TZQuery;
     qry_tokenappid: TStringField;
     qry_tokenclient_id: TStringField;
     qry_tokendthr_geracao: TDateTimeField;
     qry_tokengrant_type: TStringField;
     qry_tokenID: TLongintField;
     qry_tokenreftoken: TStringField;
     qry_tokensecret_key: TStringField;
      cnx_BD : TZConnection;
      qry_dados: TZQuery;
      qry_pedidos: TZQuery;
      qry_pai_pedidos: TZQuery;
      qry_dadospgt: TZQuery;
      qry_clientes: TZQuery;
      procedure qry_pai_pedidosAfterOpen(DataSet: TDataSet);
      procedure qry_pai_pedidosBeforeClose(DataSet: TDataSet);
   private
      function f_cliente_existe(p_id_cli : string) : Boolean;
     procedure p_renova_appid();
     procedure p_renovar_se_necessario();
   public
     procedure p_buscar_cadastrar_cli(p_id_cliente: string);
     function f_buscar_app_id(): string;
   end;

var
   DmDados : TDmDados;

implementation

procedure TDmDados.p_renovar_se_necessario();
var
v_qry : TZQuery;
v_datahora_geracao : TDateTime;
begin

  v_qry := TZQuery.Create(nil);
  try
    v_qry.Connection := cnx_BD;
    v_qry.SQL.Text := 'select dthr_geracao from tab_appid; ';
    v_qry.Open;
    v_datahora_geracao := v_qry.FieldByName('dthr_geracao').AsDateTime;
    v_qry.Close;
   if MinutesBetween(Now,v_datahora_geracao) > 350 then  //renovar antes de 360 minutos
   begin
     p_renova_appid();
   end;

  finally
     v_qry.Free;
  end;
end;

procedure TDmDados.qry_pai_pedidosAfterOpen(DataSet: TDataSet);
begin
  qry_dadospgt.Open;
  qry_pedidos.Open;
end;

procedure TDmDados.qry_pai_pedidosBeforeClose(DataSet: TDataSet);
begin
  qry_dadospgt.Close;
  qry_pedidos.Close;
end;

procedure TDmDados.p_renova_appid();
var
Json : string;
JsonEnvio: TStringStream;
v_metodo: string;
HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_auth_url : string;
v_json_data : TJSONData;
v_novo_reftok, v_novo_appid : string;
begin

  JsonEnvio:= TStringStream.Create(UTF8Encode(Json));


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
        v_metodo := HttpClient.Post(v_auth_url, JsonEnvio);

        v_json_data := TJSONParser.Create(v_metodo).Parse;
        v_novo_reftok := v_json_data.FindPath('refresh_token').AsString;
        v_novo_appid  := v_json_data.FindPath('access_token').AsString;

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

   if not qry_token.Active then
   begin
      qry_token.Open;
   end;

   if qry_token.RecordCount = 0 then
     qry_token.insert
   else
     DmDados.qry_token.edit;

   qry_token.FieldByName('reftoken').AsString := v_novo_reftok;
   qry_token.FieldByName('appid').AsString := v_novo_appid;
   qry_token.FieldByName('dthr_geracao').AsDateTime := Now;
   qry_token.Post;
   qry_token.Close;

end;

function TDmDados.f_buscar_app_id(): string;
var
v_qry : TZQuery;
v_resultado : string;
begin
  v_resultado := '';

  p_renovar_se_necessario();

  v_qry := TZQuery.Create(nil);
  try
    v_qry.Connection := cnx_BD;
    v_qry.SQL.Text := 'select appid from tab_appid; ';
    v_qry.Open;
    v_resultado := v_qry.FieldByName('appid').AsString;
    v_qry.Close;
  finally
     v_qry.Free;
  end;

  result := v_resultado;
end;

function TDmDados.f_cliente_existe(p_id_cli:string):Boolean;
var
v_qry_consulta : TZQuery;
v_ret : Boolean;
v_qtde_rec : integer;
begin
  v_ret := false;
  v_qry_consulta := TZQuery.Create(self);
  try
     v_qry_consulta.Connection := cnx_BD;
     v_qry_consulta.SQL.Text := 'select cli_payer_id from tab_info_clientes where cli_payer_id = ' + QuotedStr(p_id_cli);
     v_qry_consulta.Open;
     v_qtde_rec := v_qry_consulta.RecordCount;
     if v_qtde_rec > 0 then
        v_ret := True;
  finally
     v_qry_consulta.Close;
     v_qry_consulta.Free;
  end;

  Result := v_ret;
end;

procedure TDmDados.p_buscar_cadastrar_cli(p_id_cliente: string);
var
HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_retorno :  TStringStream;
v_json_obj : TJSONObject;
v_json_data : TJSONData;
v_ws, v_idcliente, v_nomecliente, v_status, v_cidade, v_estado, v_teste : string;
begin

   if f_cliente_existe(p_id_cliente) then
      exit;

  v_retorno := TStringStream.Create('');
  v_ws := 'https://api.mercadolibre.com/users/' + p_id_cliente;

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
     HttpClient.Request.Accept := '*/*';
     HttpClient.ConnectTimeout         := 3000;
     HttpClient.ReadTimeout            := 10000;

     IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create( HttpClient );
     IdSSLIOHandlerSocket.SSLOptions.SSLVersions := [sslvTLSv1_2];

     HttpClient.IOHandler := IdSSLIOHandlerSocket;

     try
        HttpClient.Get(v_ws, v_retorno);
        //ShowMessage(v_retorno.DataString);
        v_json_data := TJSONParser.Create(v_retorno.DataString).Parse;
        v_json_obj := TJSONObject(v_json_data);
        ShowMessage(v_json_data.FormatJSON());
        v_idcliente := v_json_obj.FindPath('id').AsJson;
        v_nomecliente := v_json_obj.FindPath('nickname').AsJson;
        v_status  := v_json_obj.FindPath('status').AsJson;
        v_cidade  := v_json_obj.Objects['address'].Strings['city'];
        v_estado  := v_json_obj.Objects['address'].Strings['state'];

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

   if not qry_clientes.Active then
   begin
      qry_clientes.Open;
   end;

   qry_clientes.insert;

   qry_clientes.FieldByName('cli_payer_id').AsString := v_idcliente;
   qry_clientes.FieldByName('cli_nome').AsString := v_nomecliente;
   qry_clientes.FieldByName('cli_status').AsString := v_status;
   qry_clientes.FieldByName('cli_cidade').AsString := v_cidade;
   qry_clientes.FieldByName('cli_estado').AsString := v_estado;
   qry_clientes.Post;
   qry_clientes.Close;

end;

{$R *.lfm}

end.

