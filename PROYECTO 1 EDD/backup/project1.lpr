program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, uListaSimpleUsuarios, uListaDobleCorreos, uListaCircularContactos,
  uColaCorreosProgramados, uPilaPapelera, uMatrizDispersa, uComunidades, uLogin,
  uPrincipal, uBandejaEntrada, uEnviarCorreo, uAdminRoot, uContactos, uProgramarCorreo;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.

