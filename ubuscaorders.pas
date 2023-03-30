unit ubuscaorders;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBGrids, DateTimePicker, IdHTTP, IdSSLOpenSSL, fpjson, jsonparser, db,
  Variants, ZConnection, ZDataset;

type

  { TfrmBuscarPedidos }

  TfrmBuscarPedidos = class(TForm)
    btnFiltrar: TButton;
    btnPesquisar: TButton;
    btnFechar: TButton;
    cbxtype: TComboBox;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    edtAppID: TEdit;
    EdtDataFin: TDateTimePicker;
    EdtDataIni: TDateTimePicker;
    edtseller_id: TEdit;
    Label4: TLabel;
    lblAppID: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbljsonres: TLabel;
    lblSellerid: TLabel;
    Memo1: TMemo;
    pnldados: TPanel;
    pnllistagem: TPanel;
    procedure btnFecharClick(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmBuscarPedidos: TfrmBuscarPedidos;

implementation
uses
  uDmDados;
{$R *.lfm}

{ TfrmBuscarPedidos }

procedure TfrmBuscarPedidos.btnPesquisarClick(Sender: TObject);
var
HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_retorno :  TStringStream;
v_json_data, v_itens_arr: TJSONData;
v_json_obj, v_obj_result, v_teste  : TJSONObject;
v_json_sel_arr : TJSONArray;
v_results_arr, v_payments_arr  : TJSONArray;
//v_resultAPI : string;
v_header_auth, v_url_atributos, v_app_id,v_id_shipping, v_pack_id: string;
i : integer;
v_exist : Boolean;
v_qry_temp1 : TZQuery;
begin
  v_retorno := TStringStream.Create('');
  v_url_atributos := 'https://api.mercadolibre.com/orders/search?seller='+edtseller_id.Text+'&order.status='+cbxtype.Text;

try
     v_app_id := edtAppID.Text;

     HttpClient := TIdHTTP.Create(nil);
     HttpClient.Request.Clear;

     HttpClient.Request.ContentType := 'application/json';
     HttpClient.Request.Charset := 'utf-8';
     HttpClient.ProtocolVersion := pv1_1;
     HttpClient.Request.Accept  :=  '*/*';
     HttpClient.Request.Connection := 'keep-alive';
     v_header_auth := 'Bearer ' + v_app_id;
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
        HttpClient.Get(v_url_atributos, v_retorno);
        v_json_data := TJSONParser.Create(v_retorno.DataString).Parse;
        v_json_obj := TJSONObject(v_json_data);
        if HttpClient.Response.ResponseCode <> 200 then
           ShowMessage(IntToStr(HttpClient.Response.ResponseCode));
        memo1.lines.Add(v_json_data.FormatJSON());
        memo1.lines.Add('');
        memo1.lines.Add('---------------------------------------');
        memo1.lines.Add('');

        v_json_sel_arr := TJSONArray(v_json_obj);
        v_results_arr := v_json_obj.Arrays['results'];

        if not DmDados.qry_pedidos.Active then
        begin
          DmDados.qry_pedidos.Open;
        end;

        if not DmDados.qry_dadospgt.Active then
        begin
          DmDados.qry_dadospgt.Open;
        end;

        for i := 0 to v_results_arr.Count - 1 do
        begin
           v_obj_result := v_results_arr.Objects[i];

           v_payments_arr := v_obj_result.Arrays['payments'];
           v_itens_arr := v_payments_arr.Items[0] as TJSONData;
           DmDados.p_buscar_cadastrar_cli(v_itens_arr.FindPath('payer_id').AsString);
           v_exist := false;
           v_qry_temp1 := TZQuery.Create(nil);
           try
              v_qry_temp1.Connection := DmDados.cnx_BD;
              v_qry_temp1.SQL.Text := 'select * from tab_pedidos_dadospgt where pgt_order_id = ' + QuotedStr(v_itens_arr.FindPath('order_id').AsString);
              //ShowMessage(v_qry_temp1.SQL.Text);
              v_qry_temp1.Open;
              if v_qry_temp1.RecordCount > 0 then
                v_exist := true;
           finally
              v_qry_temp1.Free;
           end;

           if not v_exist then
           begin
             DmDados.qry_dadospgt.Append;
             DmDados.qry_dadospgtpgt_payer_id.AsString := v_itens_arr.FindPath('payer_id').AsString;
             DmDados.qry_dadospgtpgt_name.AsString := v_itens_arr.FindPath('reason').AsString;
             DmDados.qry_dadospgtpgt_order_id.AsString := v_itens_arr.FindPath('order_id').AsString;
             DmDados.qry_dadospgtpgt_payment_date.AsString := v_itens_arr.FindPath('date_approved').AsString;
             DmDados.qry_dadospgtpgt_payment_method.AsString := v_itens_arr.FindPath('payment_type').AsString;
             DmDados.qry_dadospgt.Post;
           end;


           if not DmDados.qry_pai_pedidos.Locate('ped_principal_order_id',v_itens_arr.FindPath('order_id').AsString,[]) then
           begin
               DmDados.qry_pai_pedidos.Append;

               if not v_obj_result.FindPath('pack_id').IsNull then
                DmDados.qry_pai_pedidosped_principal_pack_id.AsString := v_obj_result.FindPath('pack_id').AsString;

               DmDados.qry_pai_pedidosped_principal_order_id.AsString := v_itens_arr.FindPath('order_id').AsString;
               DmDados.qry_pai_pedidosped_principal_nome.AsString := v_itens_arr.FindPath('reason').value;
               DmDados.qry_pai_pedidosped_principal_order_value.Value := v_itens_arr.FindPath('total_paid_amount').AsFloat;
               DmDados.qry_pai_pedidosped_principal_payment_method.AsString := v_itens_arr.FindPath('payment_type').AsString;
               DmDados.qry_pai_pedidosped_principal_status.AsString := v_itens_arr.FindPath('status').AsString;
               DmDados.qry_pai_pedidosped_principal_payer_id.AsString := v_itens_arr.FindPath('payer_id').AsString;
               DmDados.qry_pai_pedidosped_principal_date_approved.AsString := v_itens_arr.FindPath('date_approved').AsString;
               //DmDados.qry_pai_pedidosped_principal_pack_id.AsString := v_obj_result.FindPath('pack_id').AsString;
               DmDados.qry_pai_pedidosped_principal_shipping_id.AsString := v_obj_result.Objects['shipping'].Strings['id'];
               //try
               //    v_id_shipping := v_obj_result.Objects['shipping'].Strings['id'];
               //    ShowMessage(v_id_shipping);
               //except
               //    v_id_shipping := '';
               //end;
               DmDados.qry_pai_pedidos.Post;
           end;

           if not DmDados.qry_pedidos.Locate('ped_itens_order_id',v_itens_arr.FindPath('order_id').AsString,[]) then
           begin
               DmDados.qry_pedidos.Append;

               if not v_obj_result.FindPath('pack_id').IsNull then
                DmDados.qry_pedidosped_itens_pack_id.AsString := v_obj_result.FindPath('pack_id').AsString;

               DmDados.qry_pedidosped_itens_order_id.AsString := v_itens_arr.FindPath('order_id').AsString;
               DmDados.qry_pedidosped_itens_reason.AsString := v_itens_arr.FindPath('reason').value;
               DmDados.qry_pedidosped_itens_date_approved.AsString := v_itens_arr.FindPath('date_approved').AsString;
               //DmDados.qry_pedidosped_itens_pack_id.AsString := v_obj_result.FindPath('pack_id').AsString;
               DmDados.qry_pedidos.Post;
           end

        end;
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

procedure TfrmBuscarPedidos.FormShow(Sender: TObject);
begin
    DmDados.qry_pai_pedidos.Open;
end;

procedure TfrmBuscarPedidos.btnFecharClick(Sender: TObject);
begin
  frmBuscarPedidos.Close;
end;

end.

