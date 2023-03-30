unit uConta;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBCtrls, opensslsockets, jsonparser, fpjson, Jsons, jsonscanner;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    btnSalvar: TButton;
    btnFechar: TButton;
    btnBanco: TButton;
    btnNovo: TButton;
    btnEditar: TButton;
    btnBuscarCode: TButton;
    btnBusca: TButton;
    edtBusca: TEdit;
    edtURL: TDBEdit;
    edtClientID: TDBEdit;
    edtSecretKey: TDBEdit;
    edtCode: TDBEdit;
    edtRefToken: TDBEdit;
    edtAccess: TDBEdit;
    edtUserID: TDBEdit;
    lblBusca: TLabel;
    lblURL: TLabel;
    lblClientID: TLabel;
    lblSecretKey: TLabel;
    lblCode: TLabel;
    lblAccessToken: TLabel;
    lblUserID: TLabel;
    lblRefToken: TLabel;
    pnlConta: TPanel;
    procedure btnBancoClick(Sender: TObject);
    procedure btnBuscaClick(Sender: TObject);
    procedure btnBuscarCodeClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    function FormatarJSON(const aJSON: String): String;
  end;

var
  frmLogin: TfrmLogin;
  contaid: Integer;
  buffer: string;

implementation
uses
  uDmDados, uBanco;
{$R *.lfm}

{ TfrmLogin }

procedure TfrmLogin.btnBancoClick(Sender: TObject);
begin
  frm_banco := tfrm_banco.Create(self);
  frm_banco.ShowModal;
end;

function TfrmLogin.FormatarJSON(const aJSON: String): String;
var
  jpar: TJSONParser;
  j: TJSONObject;
begin
   Result := aJSON;
   try
      j := TJSONObject.Create();
      try
         Result := j.Decode(Result);
      finally
         j.Free;
      end;
      jpar := TJSONParser.Create(Result, [joUTF8]);
      try
         Result := jpar.Parse.FormatJSON([], 2);
      finally
         jpar.Free;
      end;
   except
      Result := aJSON;
   end;
end;

procedure TfrmLogin.btnBuscaClick(Sender: TObject);
begin
  if edtBusca.Text <> '' then
  begin
    DmDados.qry_dados.SQL.Clear;
    DmDados.qry_dados.SQL.Add('SELECT * from tbldados where contaid = :pcontaid');
    DmDados.qry_dados.ParamByName('pcontaid').AsInteger := StrToInt(edtBusca.Text);
    DmDados.qry_dados.Open;
    edtBusca.Clear;
    btnEditar.Enabled:= True;
  end
  else
  ShowMessage('Por favor preencher o campo de Busca');
end;

procedure TfrmLogin.btnBuscarCodeClick(Sender: TObject);
begin
  if edtClientID.Text <> '' then
  begin
   buffer := 'https://auth.mercadolivre.com.br/authorization?response_type=code&client_id='+edtClientID.Text+'&redirect_uri=http://localhost:80';
  end
  else
  ShowMessage('É necessário se cadastrar ou buscar antes de clickar em "Code"');
end;

procedure TfrmLogin.btnFecharClick(Sender: TObject);
begin
  frmLogin.Close;
end;

procedure TfrmLogin.btnNovoClick(Sender: TObject);
begin
  edtAccess.Clear;
  edtUserID.Clear;
  edtURL.Clear;
  edtSecretKEY.Clear;
  edtRefToken.Clear;
  edtCode.Clear;
  edtClientID.Clear;
  btnNovo.Enabled:= false;
  btnEditar.Enabled:= false;
  btnSalvar.Enabled:= true;
  btnFechar.Enabled:= true;
  //
  edtAccess.Enabled:= true;
  edtUserID.Enabled:= true;
  edtURL.Enabled:= true;
  edtSecretKEY.Enabled:= true;
  edtRefToken.Enabled:= true;
  edtCode.Enabled:= true;
  edtClientID.Enabled:= true;
  //
  if not DmDados.qry_dados.Active then
    begin
      DmDados.qry_dados.Open;
    end;

     DmDados.qry_dados.Insert;
     edtURL.SetFocus;
end;

procedure TfrmLogin.btnSalvarClick(Sender: TObject);
begin
    DmDados.qry_dados.Post;
    ShowMessage('Dados Inseridos com sucesso!');
    DmDados.qry_dados.Close;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin

  //
  btnEditar.Enabled:= false;
  btnSalvar.Enabled:= false;
  btnFechar.Enabled:= true;
end;

end.

