program ProjetoML;

{$mode objfpc}{$H+}

uses
   {$IFDEF UNIX}{$IFDEF UseCThreads}
   cthreads,
   {$ENDIF}{$ENDIF}
   Interfaces, // this includes the LCL widgetset
   Forms,runtimetypeinfocontrols,datetimectrls,uPrincipal,uDmDados,uConta,ubuscaorders,uBanco,uProdutos,uRefresh,uRenovar,zcomponent,rxnew,indylaz;

{$R *.res}

begin
   RequireDerivedFormResource := True;
   Application.Scaled := True;
   Application.Initialize;
   Application.CreateForm(TDmDados, DmDados);
   Application.CreateForm(TfrmPrincipall, frmPrincipall);
   Application.CreateForm(TfrmLogin, frmLogin);
   Application.CreateForm(TfrmTokenPrincipal, frmTokenPrincipal);
   Application.CreateForm(TfrmBuscarPedidos, frmBuscarPedidos);
   Application.Run;
end.

