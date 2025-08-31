unit uAdminRoot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, uListaSimpleUsuarios;

type

  { TfrmAdminRoot }

  TfrmAdminRoot = class(TForm)
    btnCargarUsuarios: TButton;
    btnReporteUsuarios: TButton;
    btnReporteRelaciones: TButton;
    btnCerrarSesion: TButton;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    procedure btnCargarUsuariosClick(Sender: TObject);
    procedure btnCerrarSesionClick(Sender: TObject);
    procedure btnReporteRelacionesClick(Sender: TObject);
    procedure btnReporteUsuariosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    ListaUsuarios: TListaUsuarios;
  end;

var
  frmAdminRoot: TfrmAdminRoot;

implementation

{$R *.lfm}

{ TfrmAdminRoot }

procedure TfrmAdminRoot.FormCreate(Sender: TObject);
begin
  Caption := 'EDDMail - Panel de Administración';
  Label1.Caption := 'Panel de Administración Root';

  btnCargarUsuarios.Caption := 'Carga Masiva de Usuarios';
  btnReporteUsuarios.Caption := 'Reporte de Usuarios';
  btnReporteRelaciones.Caption := 'Reporte de Relaciones';
  btnCerrarSesion.Caption := 'Cerrar Sesión';
end;

procedure TfrmAdminRoot.btnCargarUsuariosClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    ListaUsuarios.CargarDesdeJSON(OpenDialog1.FileName);
    ShowMessage('Usuarios cargados exitosamente: ' + IntToStr(ListaUsuarios.ObtenerSiguienteId - 1) + ' usuarios en total');
  end;
end;

procedure TfrmAdminRoot.btnReporteUsuariosClick(Sender: TObject);
begin
  ListaUsuarios.GenerarReporte('Root-Reportes/ReporteUsuarios.txt');
  ShowMessage('Reporte de usuarios generado en: Root-Reportes/ReporteUsuarios.txt');
end;

procedure TfrmAdminRoot.btnReporteRelacionesClick(Sender: TObject);
begin
  // Aquí se generaría el reporte de relaciones usando la matriz dispersa
  ShowMessage('Funcionalidad de reporte de relaciones en desarrollo');
end;

procedure TfrmAdminRoot.btnCerrarSesionClick(Sender: TObject);
begin
  Close;
end;

end.

