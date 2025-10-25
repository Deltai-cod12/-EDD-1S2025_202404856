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

// -----------------------
// Genera reporte de Correos Recibidos del usuario actual
procedure TfrmReportes.GenerarReporteCorreos;
var
  DotFile, PNGFile: string;
begin
  if FUsuario.Inbox = nil then
  begin
    ShowMessage('El usuario no tiene correos.');
    Exit;
  end;

  DotFile := 'Bandeja_' + FUsuario.email + '.dot';
  PNGFile := 'Bandeja_' + FUsuario.email + '.png';

  // Llama a la función en DLL_CON que genera el .dot y el .png
  GenerateDotBandeja(FUsuario.Inbox, DotFile, PNGFile);

  ShowMessage('Reporte de Correos Recibidos generado en: ' + PNGFile);
end;

procedure TfrmReportes.GenerarReportePapelera;
var
  DotFile, PNGFile: string;
begin
  if (FUsuario.Papelera = nil) or (FUsuario.Papelera^.Top = nil) then
  begin
    ShowMessage('La Papelera del usuario está vacía.');
    Exit;
  end;

  DotFile := 'Papelera_' + FUsuario.email + '.dot';
  PNGFile := 'Papelera_' + FUsuario.email + '.png';

  // Llama a la función en UPila que genera el .dot y .png
  GenerateDotPapelera(FUsuario.Papelera, DotFile, PNGFile);
end;

procedure TfrmReportes.GenerarReporteProgramados;
var
  DotFile, PNGFile: string;
begin
  // Validamos que el usuario tenga correos programados
  if (FUsuario.Programados = nil) or (FUsuario.Programados^.Top = nil) then
  begin
    ShowMessage('No hay correos programados para este usuario.');
    Exit;
  end;

  // Definimos los nombres de archivo .dot y .png
  DotFile := 'Programados_' + FUsuario.email + '.dot';
  PNGFile := 'Programados_' + FUsuario.email + '.png';

  // Llamamos al procedimiento que genera el .dot y .png
  GenerateDotProgramados(FUsuario.Programados, DotFile, PNGFile);

  // Mensaje opcional
  ShowMessage('Reporte de Correos Programados generado en: ' + PNGFile);
end;


procedure TfrmReportes.GenerarReporteContactos;
var
  DotFile, PNGFile: string;
begin
  if (FUsuario.Contacts = nil) or (FUsuario.Contacts^.Head = nil) then
  begin
    ShowMessage('El usuario no tiene contactos.');
    Exit;
  end;

  DotFile := 'Contactos_' + FUsuario.email + '.dot';
  PNGFile := 'Contactos_' + FUsuario.email + '.png';

  // Llama a la función en UContactTypes que genera el .dot y .png
  GenerateDotContactos(FUsuario.Contacts, DotFile, PNGFile);
end;

end.

