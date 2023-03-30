unit uBanco;

{$mode objfpc}{$H+}

interface

uses
   Classes, SysUtils,db, Forms, Controls, Graphics, Dialogs,ExtCtrls,StdCtrls,Buttons,ZConnection,ZDataset;

type

   { Tfrm_banco }

   Tfrm_banco = class(TForm)
      btn_Connect : TBitBtn;
      BitBtn2 : TBitBtn;
      Button1: TButton;
      edt_User : TEdit;
      edt_Senha : TEdit;
      edt_Banco : TEdit;
      edt_Servidor : TEdit;
      edt_Porta : TEdit;
      lbl_Porta : TLabel;
      lbl_User : TLabel;
      lbl_Senha : TLabel;
      lbl_host : TLabel;
      lbl_DataBase : TLabel;
      pl_Config : TPanel;
      procedure BitBtn2Click(Sender : TObject);
      procedure btn_ConnectClick(Sender : TObject);
      procedure Button1Click(Sender: TObject);
   private

   public

   end;

var
   frm_banco : Tfrm_banco;

implementation
uses
   uDmDados;

{$R *.lfm}

{ Tfrm_banco }

procedure Tfrm_banco.BitBtn2Click(Sender : TObject);
begin
     frm_banco.Close;
end;

procedure Tfrm_banco.btn_ConnectClick(Sender : TObject);
begin
   try
      DmDados.cnx_BD.Disconnect;
      DmDados.cnx_BD.User := edt_User.Text;
      DmDados.cnx_BD.Password := edt_Senha.text;
      DmDados.cnx_BD.Database := edt_Banco.Text;
      DmDados.cnx_BD.HostName := edt_Servidor.Text;
      DmDados.cnx_BD.Port := StrToInt(edt_Porta.Text);
      DmDados.cnx_BD.Connect;
     ShowMessage('Conectado com sucesso');
   except
     ShowMessage('Falha ao conectar');
   end;
end;

procedure Tfrm_banco.Button1Click(Sender: TObject);
var
   v_qry : TZQuery;
begin

end;

end.

