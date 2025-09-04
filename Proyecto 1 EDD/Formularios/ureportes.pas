unit uReportes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL, DLL_CON, UPila, UCola, UContactTypes;

type
  TfrmReportes = class(TForm)
    btnReporteCorreos: TButton;
    btnReportePapelera: TButton;
    btnReporteProgramados: TButton;
    btnReporteContactos: TButton;
    btnCerrar: TButton;

    procedure btnCerrarClick(Sender: TObject);
    procedure btnReporteCorreosClick(Sender: TObject);
    procedure btnReportePapeleraClick(Sender: TObject);
    procedure btnReporteProgramadosClick(Sender: TObject);
    procedure btnReporteContactosClick(Sender: TObject);

  private
    FUsuario: TDataUser;

  public
    procedure SetUsuario(AUser: TDataUser);
    procedure GenerarReporteCorreos;
    procedure GenerarReportePapelera;
    procedure GenerarReporteProgramados;
    procedure GenerarReporteContactos;

  end;

var
  frmReportes: TfrmReportes;

implementation

{$R *.lfm}

{ TfrmReportes }

procedure TfrmReportes.SetUsuario(AUser: TDataUser);
begin
  FUsuario := AUser;
end;

procedure TfrmReportes.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmReportes.btnReporteCorreosClick(Sender: TObject);
begin
  GenerarReporteCorreos;
end;

procedure TfrmReportes.btnReportePapeleraClick(Sender: TObject);
begin
  GenerarReportePapelera;
end;

procedure TfrmReportes.btnReporteProgramadosClick(Sender: TObject);
begin
  GenerarReporteProgramados;
end;

procedure TfrmReportes.btnReporteContactosClick(Sender: TObject);
begin
  GenerarReporteContactos;
end;
procedure TfrmReportes.GenerarReporteCorreos;
var
  DotFile, PNGFile, CarpetaReportes: string;
begin
  if FUsuario.Inbox = nil then
  begin
    ShowMessage('El usuario no tiene correos.');
    Exit;
  end;

  // Crear carpeta de reportes si no existe
  CarpetaReportes := LowerCase(FUsuario.user) + '-reportes';
  if not DirectoryExists(CarpetaReportes) then
    CreateDir(CarpetaReportes);

  DotFile := CarpetaReportes + PathDelim + 'Bandeja_' + FUsuario.email + '.dot';
  PNGFile := CarpetaReportes + PathDelim + 'Bandeja_' + FUsuario.email + '.png';

  GenerateDotBandeja(FUsuario.Inbox, DotFile, PNGFile);

  ShowMessage('Reporte de Correos Recibidos generado en: ' + PNGFile);
end;

procedure TfrmReportes.GenerarReportePapelera;
var
  DotFile, PNGFile, CarpetaReportes: string;
begin
  if (FUsuario.Papelera = nil) or (FUsuario.Papelera^.Top = nil) then
  begin
    ShowMessage('La Papelera del usuario está vacía.');
    Exit;
  end;

  CarpetaReportes := LowerCase(FUsuario.user) + '-reportes';
  if not DirectoryExists(CarpetaReportes) then
    CreateDir(CarpetaReportes);

  DotFile := CarpetaReportes + PathDelim + 'Papelera_' + FUsuario.email + '.dot';
  PNGFile := CarpetaReportes + PathDelim + 'Papelera_' + FUsuario.email + '.png';

  GenerateDotPapelera(FUsuario.Papelera, DotFile, PNGFile);

  ShowMessage('Reporte de la Papelera generado en: ' + PNGFile);
end;

procedure TfrmReportes.GenerarReporteProgramados;
var
  DotFile, PNGFile, CarpetaReportes: string;
begin
  if (FUsuario.Programados = nil) or (FUsuario.Programados^.Top = nil) then
  begin
    ShowMessage('No hay correos programados para este usuario.');
    Exit;
  end;

  CarpetaReportes := LowerCase(FUsuario.user) + '-reportes';
  if not DirectoryExists(CarpetaReportes) then
    CreateDir(CarpetaReportes);

  DotFile := CarpetaReportes + PathDelim + 'Programados_' + FUsuario.email + '.dot';
  PNGFile := CarpetaReportes + PathDelim + 'Programados_' + FUsuario.email + '.png';

  GenerateDotProgramados(FUsuario.Programados, DotFile, PNGFile);

  ShowMessage('Reporte de Correos Programados generado en: ' + PNGFile);
end;

procedure TfrmReportes.GenerarReporteContactos;
var
  DotFile, PNGFile, CarpetaReportes: string;
begin
  if (FUsuario.Contacts = nil) or (FUsuario.Contacts^.Head = nil) then
  begin
    ShowMessage('El usuario no tiene contactos.');
    Exit;
  end;

  CarpetaReportes := LowerCase(FUsuario.user) + '-reportes';
  if not DirectoryExists(CarpetaReportes) then
    CreateDir(CarpetaReportes);

  DotFile := CarpetaReportes + PathDelim + 'Contactos_' + FUsuario.email + '.dot';
  PNGFile := CarpetaReportes + PathDelim + 'Contactos_' + FUsuario.email + '.png';

  GenerateDotContactos(FUsuario.Contacts, DotFile, PNGFile);

  ShowMessage('Reporte de Contactos generado en: ' + PNGFile);
end;

end.

