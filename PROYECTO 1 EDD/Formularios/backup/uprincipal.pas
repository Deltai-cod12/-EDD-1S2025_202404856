unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, uListaSimpleUsuarios, uBandejaEntrada, uEnviarCorreo, uContactos,
  uProgramarCorreo, uPapelera, uPerfil, uReportes;

type                                                                     sssss

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    btnBandejaEntrada: TButton;
    btnContactos: TButton;
    btnEnviarCorreo: TButton;
    btnProgramarCorreo: TButton;
    btnPapelera: TButton;
    btnActualizarPerfil: TButton;
    btnReportes: TButton;
    btnCerrarSesion: TButton;
    Image1: TImage;
    Label1: TLabel;
    lblUsuario: TLabel;
    procedure btnActualizarPerfilClick(Sender: TObject);
    procedure btnBandejaEntradaClick(Sender: TObject);
    procedure btnCerrarSesionClick(Sender: TObject);
    procedure btnContactosClick(Sender: TObject);
    procedure btnEnviarCorreoClick(Sender: TObject);
    procedure btnPapeleraClick(Sender: TObject);
    procedure btnProgramarCorreoClick(Sender: TObject);
    procedure btnReportesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    UsuarioActual: TUsuario;
    ListaUsuarios: TListaUsuarios;
    // Aquí agregarías las demás estructuras de datos
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  Caption := 'EDDMail - Correo Electrónico';
  lblUsuario.Caption := 'Usuario: ' + UsuarioActual.nombre;

  // Configurar botones
  btnBandejaEntrada.Caption := 'Bandeja de Entrada';
  btnEnviarCorreo.Caption := 'Enviar Correo';
  btnContactos.Caption := 'Contactos';
  btnProgramarCorreo.Caption := 'Programar Correo';
  btnPapelera.Caption := 'Papelera';
  btnActualizarPerfil.Caption := 'Actualizar Perfil';
  btnReportes.Caption := 'Reportes';
  btnCerrarSesion.Caption := 'Cerrar Sesión';
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  // Liberar recursos aquí si es necesario
end;

procedure TfrmPrincipal.btnBandejaEntradaClick(Sender: TObject);
begin
  frmBandejaEntrada := TfrmBandejaEntrada.Create(Application);
  try
    frmBandejaEntrada.UsuarioActual := UsuarioActual;
    frmBandejaEntrada.ShowModal;
  finally
    frmBandejaEntrada.Free;
  end;
end;

procedure TfrmPrincipal.btnEnviarCorreoClick(Sender: TObject);
begin
  frmEnviarCorreo := TfrmEnviarCorreo.Create(Application);
  try
    frmEnviarCorreo.UsuarioActual := UsuarioActual;
    frmEnviarCorreo.ListaUsuarios := ListaUsuarios;
    frmEnviarCorreo.ShowModal;
  finally
    frmEnviarCorreo.Free;
  end;
end;

procedure TfrmPrincipal.btnContactosClick(Sender: TObject);
begin
  frmContactos := TfrmContactos.Create(Application);
  try
    frmContactos.UsuarioActual := UsuarioActual;
    frmContactos.ListaUsuarios := ListaUsuarios;
    frmContactos.ShowModal;
  finally
    frmContactos.Free;
  end;
end;

procedure TfrmPrincipal.btnProgramarCorreoClick(Sender: TObject);
begin
  frmProgramarCorreo := TfrmProgramarCorreo.Create(Application);
  try
    frmProgramarCorreo.UsuarioActual := UsuarioActual;
    frmProgramarCorreo.ListaUsuarios := ListaUsuarios;
    frmProgramarCorreo.ShowModal;
  finally
    frmProgramarCorreo.Free;
  end;
end;

procedure TfrmPrincipal.btnPapeleraClick(Sender: TObject);
begin
  frmPapelera := TfrmPapelera.Create(Application);
  try
    frmPapelera.UsuarioActual := UsuarioActual;
    frmPapelera.ShowModal;
  finally
    frmPapelera.Free;
  end;
end;

procedure TfrmPrincipal.btnActualizarPerfilClick(Sender: TObject);
begin
  frmPerfil := TfrmPerfil.Create(Application);
  try
    frmPerfil.UsuarioActual := UsuarioActual;
    frmPerfil.ListaUsuarios := ListaUsuarios;
    frmPerfil.ShowModal;

    // Actualizar label de usuario si cambió el nombre
    if frmPerfil.PerfilActualizado then
      lblUsuario.Caption := 'Usuario: ' + UsuarioActual.nombre;

  finally
    frmPerfil.Free;
  end;
end;

procedure TfrmPrincipal.btnReportesClick(Sender: TObject);
begin
  frmReportes := TfrmReportes.Create(Application);
  try
    frmReportes.UsuarioActual := UsuarioActual;
    frmReportes.ShowModal;
  finally
    frmReportes.Free;
  end;
end;

procedure TfrmPrincipal.btnCerrarSesionClick(Sender: TObject);
begin
  Close;
end;

end.

