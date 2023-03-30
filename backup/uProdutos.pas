unit uProdutos;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, memds, Forms, Controls, Graphics, Dialogs, DBCtrls,
  ExtCtrls, DBGrids, StdCtrls, RTTICtrls, IdHTTP,
  IdSSLOpenSSL, fpjson, jsonparser, StrUtils;

type

  { TfrmProduto }

  TfrmProduto = class(TForm)
    btnPublicar: TButton;
    btnJSON: TButton;
    btnAtributos: TButton;
    cbxTipos: TComboBox;
    cbxGender: TComboBox;
    cbxMoeda: TComboBox;
    LcbxCategorias: TDBLookupComboBox;
    DsCat: TDataSource;
    edtAPPID: TEdit;
    edtTitulo: TEdit;
    edtImagem_1: TEdit;
    edtImagem_2: TEdit;
    edtImagem_3: TEdit;
    edtModelo: TEdit;
    edtMarca: TEdit;
    edtPreco: TEdit;
    edtQuantidade: TEdit;
    edtModoCompra: TEdit;
    edtCondicaoItem: TEdit;
    edtGarantia: TEdit;
    edtTempoGarantia: TEdit;
    lblGender: TLabel;
    lblAppID: TLabel;
    lblResultado: TLabel;
    lblMarca: TLabel;
    lblModelo: TLabel;
    lblImagens: TLabel;
    lblTempoGarantia: TLabel;
    lblGarantia: TLabel;
    lblTitulo: TLabel;
    lblCategoria: TLabel;
    lblPreco: TLabel;
    lblMoeda: TLabel;
    lblQuantidade: TLabel;
    lblModoCompra: TLabel;
    lblCondicaoItem: TLabel;
    lblListaTipo: TLabel;
    MemCategorias: TMemDataset;
    Memo1: TMemo;
    procedure btnAtributosClick(Sender: TObject);
    procedure btnJSONClick(Sender: TObject);
    procedure btnPublicarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    v_str_json_cadastro : string;
  public
  end;


var
  frmProduto: TfrmProduto;

implementation
uses uDmDados;
{$R *.lfm}

{ TfrmProduto }

procedure TfrmProduto.btnPublicarClick(Sender: TObject);
var
HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_JsonStreamEnvio, v_JsonStreamRetorno :  TStringStream;
v_resultAPI : string;
v_url_api : string;
v_header_auth : string;
begin

  v_JsonStreamEnvio := TStringStream.Create(v_str_json_cadastro);
  v_JsonStreamRetorno := TStringStream.Create('');
  v_url_api := 'https://api.mercadolibre.com/items';

try
     HttpClient := TIdHTTP.Create(nil);
     HttpClient.Request.Clear;

     HttpClient.Request.ContentType := 'application/json';
     HttpClient.Request.Charset := 'utf-8';
     HttpClient.ProtocolVersion := pv1_1;
     v_header_auth := 'Bearer APP_USR-2470080450506772-020107-2c44bed8dfc6ba12c83022cadfa466fa-1245397018';
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
        HttpClient.Post(v_url_api, v_JsonStreamEnvio, v_JsonStreamRetorno );
        v_resultAPI := v_JsonStreamRetorno.DataString;
        memo1.lines.Clear;
        //ShowMessage(v_resultAPI);
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

procedure TfrmProduto.FormShow(Sender: TObject);
begin
  MemCategorias.Open;
  MemCategorias.AppendRecord(['MLB5672','Acessórios para Veículos']);
  MemCategorias.AppendRecord(['MLB271599','Agro']);
  MemCategorias.AppendRecord(['MLB1403','Alimentos e Bebidas']);
  MemCategorias.AppendRecord(['MLB1071','Animais']);
  MemCategorias.AppendRecord(['MLB1367','Antiguidades e Coleções']);
  MemCategorias.AppendRecord(['MLB1368','Arte, Papelaria e Armarinho']);
  MemCategorias.AppendRecord(['MLB1384','Bebês']);
  MemCategorias.AppendRecord(['MLB1246','Beleza e Cuidado Pessoal']);
  MemCategorias.AppendRecord(['MLB1132','Brinquedos e Hobbies']);
  MemCategorias.AppendRecord(['MLB1430','Calçados, Roupas e Bolsas']);
  MemCategorias.AppendRecord(['MLB1039','Câmeras e Acessórios']);
  MemCategorias.AppendRecord(['MLB1743','Carros, Motos e Outros']);
  MemCategorias.AppendRecord(['MLB1574','Casa, Móveis e Decoração']);
  MemCategorias.AppendRecord(['MLB1051','Celulares e Telefones']);
  MemCategorias.AppendRecord(['MLB1500','Construção']);
  MemCategorias.AppendRecord(['MLB5726','Eletrodomésticos']);
  MemCategorias.AppendRecord(['MLB1000','Eletrônicos, Áudio e Vídeo']);
  MemCategorias.AppendRecord(['MLB1276','Esportes e Fitness']);
  MemCategorias.AppendRecord(['MLB263532','Ferramentas']);
  MemCategorias.AppendRecord(['MLB12404','Festas e Lembrancinhas']);
  MemCategorias.AppendRecord(['MLB1144','Games']);
  MemCategorias.AppendRecord(['MLB1459','Imóveis']);
  MemCategorias.AppendRecord(['MLB1499','Indústria e Comércio']);
  MemCategorias.AppendRecord(['MLB1648','Informática']);
  MemCategorias.AppendRecord(['MLB218519','Ingressos']);
  MemCategorias.AppendRecord(['MLB1182','Instrumentos Musicais']);
  MemCategorias.AppendRecord(['MLB3937','Joias e Relógios']);
  MemCategorias.AppendRecord(['MLB1196','Livros, Revistas e Comics']);
  MemCategorias.AppendRecord(['MLB1168','Música, Filmes e Seriados']);
  MemCategorias.AppendRecord(['MLB264586','Saúde']);
  MemCategorias.AppendRecord(['MLB1540','Serviços']);
  MemCategorias.AppendRecord(['MLB1953','Mais Categorias']);
  MemCategorias.Refresh;
end;

procedure TfrmProduto.btnJSONClick(Sender: TObject);
var
   main_obj, saleterms_obj : TJSONObject;
begin
   main_obj := TJSONObject.Create;
   main_obj.Add('title', edtTitulo.Text);
   main_obj.Add('category_id', LcbxCategorias.Text);
   main_obj.Add('price', edtPreco.Text);
   main_obj.Add('currency_id', cbxMoeda.Text);
   main_obj.Add('available_quantity', edtQuantidade.Text);
   main_obj.Add('buying_mode', edtModoCompra.Text);
   main_obj.Add('condition', edtCondicaoItem.Text);
   main_obj.Add('listing_type_id', cbxTipos.Text);
   main_obj.add('sale_terms', TJSONArray.Create);
   //
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('id', 'WARRANTY_TYPE');
   saleterms_obj.Add('value_name', edtGarantia.Text);
   main_obj.Arrays['sale_terms'].Add(saleterms_obj);
   //
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('id', 'WARRANTY_TIME');
   saleterms_obj.Add('value_name', edtTempoGarantia.Text);
   main_obj.Arrays['sale_terms'].Add(saleterms_obj);
   //
   main_obj.add('pictures', TJSONArray.Create);
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('source', edtImagem_1.Text);
   main_obj.Arrays['pictures'].Add(saleterms_obj);
   //
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('source', edtImagem_2.Text);
   main_obj.Arrays['pictures'].Add(saleterms_obj);
   //
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('source', edtImagem_3.Text);
   main_obj.Arrays['pictures'].Add(saleterms_obj);
   //
   main_obj.add('attributes', TJSONArray.Create);
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('id', 'BRAND');
   saleterms_obj.Add('value_name', edtMarca.Text);
   main_obj.Arrays['attributes'].Add(saleterms_obj);
   //
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('id', 'MODEL');
   saleterms_obj.Add('value_name', edtModelo.Text);
   main_obj.Arrays['attributes'].Add(saleterms_obj);
   //
   saleterms_obj := TJSONObject.Create;
   saleterms_obj.Add('id', 'GENDER');
   saleterms_obj.Add('value_name', cbxGender.Text);
   main_obj.Arrays['attributes'].Add(saleterms_obj);
   //
   //saleterms_obj := TJSONObject.Create;
   //saleterms_obj.Add('id', 'STRAP_COLOR');
   //saleterms_obj.Add('value_name', 'Plateado');
   //main_obj.Arrays['attributes'].Add(saleterms_obj);
   //
   //saleterms_obj := TJSONObject.Create;
   //saleterms_obj.Add('id', 'BEZEL_COLOR');
   //saleterms_obj.Add('value_name', 'Rolex');
   //main_obj.Arrays['attributes'].Add(saleterms_obj);
   //
   //saleterms_obj := TJSONObject.Create;
   //saleterms_obj.Add('id', 'BACKGROUND_COLOR');
   //saleterms_obj.Add('value_name', 'Verde');
   //main_obj.Arrays['attributes'].Add(saleterms_obj);
   //
   //saleterms_obj := TJSONObject.Create;
   //saleterms_obj.Add('id', 'CASE_COLOR');
   //saleterms_obj.Add('value_name', 'Plateado');
   //main_obj.Arrays['attributes'].Add(saleterms_obj);
   //
   //main_obj.add('attributes', TJSONArray.Create);
   //saleterms_obj := TJSONObject.Create;
   //saleterms_obj.Add('id1', 'BRAND');
   //saleterms_obj.Add('id2', 'MODEL');
   //saleterms_obj.Add('a', 'https://content.rolex.com//dam/2022/presentation-box-hr/m126200-0020.jpg');
   //saleterms_obj.Add('b', 'https://content.rolex.com//dam/2022/presentation-tray/m126200-0020.jpg');
   //main_obj.Arrays['attributes'].Add(saleterms_obj);

   Memo1.Lines.Add(main_obj.FormatJSON());
end;

procedure TfrmProduto.btnAtributosClick(Sender: TObject);
var
HttpClient: TIdHTTP;
IdSSLIOHandlerSocket : TIdSSLIOHandlerSocketOpenSSL;
v_retorno :  TStringStream;
//v_resultAPI : string;
v_url_atributos, v_keyatributes : string;
v_header_auth : string;
v_json_data, v_tag_data : TJSONData;
v_json_cat, v_json_obj: TJSONObject;
v_json_cats_arr : TJSONArray;
i, v_relev : integer;
v_id, v_name, v_app_id : string;
v_required, v_catalog_required : Boolean;
begin
  v_keyatributes := LcbxCategorias.KeyValue;
  v_retorno := TStringStream.Create('');
  v_url_atributos := 'https://api.mercadolibre.com/categories/'+v_keyatributes+'/attributes';

try
     v_app_id := DmDados.f_buscar_app_id();

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
        memo1.lines.Clear;
        HttpClient.Get(v_url_atributos, v_retorno);
        ShowMessage(IntToStr(HttpClient.Response.ResponseCode));
        v_json_data := TJSONParser.Create(v_retorno.DataString).Parse;
        v_json_obj := TJSONObject(v_json_data);
        memo1.lines.Add(v_json_data.FormatJSON());
        memo1.lines.Add('');
        memo1.lines.Add('---------------------------------------');
        memo1.lines.Add('');

        v_json_cats_arr := TJSONArray(v_json_obj);
            //Filtragem de dados do jSON
            for i := 0 to v_json_cats_arr.Count - 1 do
            begin
               try
                 v_json_cat := v_json_cats_arr.Objects[i];
                 v_tag_data := v_json_cat.FindPath('tags');
                 //ShowMessage(v_tag_data.FormatJSON());
                 //v_required := v_tag_data.FindPath('required').AsBoolean;
                 v_catalog_required := v_tag_data.FindPath('catalog_required').AsBoolean;
               except
                    v_required := false;
                    v_catalog_required := false;
               end;

               //if v_required then
               //ShowMessage('requerido')
               //else
               //ShowMessage('nao requerido');

               v_json_cat := v_json_cats_arr.Objects[i];
               v_id := v_json_cat.FindPath('id').AsString;
               v_name :=  v_json_cat.Strings['name'];
               v_relev :=  v_json_cat.Integers['relevance'];
               memo1.lines.Add('ID: ' + v_id + ' - ' + 'Name: ' + v_name + ' - ' + 'Relevancia: ' + IntToStr(v_relev) + ' - ' + 'Tags: ' + BoolToStr(v_required) + ' - ' + 'Catalog: ' + BoolToStr(v_catalog_required));
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

end.

