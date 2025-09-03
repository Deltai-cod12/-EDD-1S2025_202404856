unit uPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uContactos, uVerContactos, uActualizarPerfil, uBandejaEntrada,
  uEnviarCorreo, uProgramarCorreo, uCorreosProgramados, uPapelera, SLL;

type
  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    btnContactos: TButton;
    btnVerContactos: TButton;
    btnActualizarPerfil: TButton;
    btnBandeja: TButton;
    btnEnviarCorreo: TButton;
    btnProgramarCorreo: TButton;
    btnCorreosProgramados: TButton;
    btnPapelera: TButton;
    lblUsuario: TLabel;
    procedure btnContactosClick(Sender: TObject);
    procedure btnVerContactosClick(Sender: TObject);
    procedure btnActualizarPerfilClick(Sender: TObject);
    procedure btnBandejaClick(Sender: TObject);
    procedure btnEnviarCorreoClick(Sender: TObject);
    procedure btnProgramarCorreoClick(Sender: TObject);
    procedure btnCorreosProgramadosClick(Sender: TObject);
    procedure btnPapeleraClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    UsuarioEmail: string; // Email del usuario actual
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.lfm}

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  Caption := 'EDDMail - Usuario';
  lblUsuario.Caption := 'Usuario: ' + UsuarioEmail;

  btnContactos.Caption := 'Agregar Contacto';
  btnVerContactos.Caption := 'Ver Contactos';
  btnActualizarPerfil.Caption := 'Actualizar Perfil';
  btnBandeja.Caption := 'Bandeja de Entrada';
  btnEnviarCorreo.Caption := 'Enviar Correo';
  btnProgramarCorreo.Caption := 'Programar Correo';
  btnCorreosProgramados.Caption := 'Correos Programados';
  btnPapelera.Caption := 'Papelera';
end;

procedure TfrmPrincipal.btnContactosClick(Sender: TObject);
begin
  frmContactos := TfrmContactos.Create(Application);
  try
    frmContactos.UsuarioEmail := UsuarioEmail;
    frmContactos.ShowModal;
  finally
    frmContactos.Free;
  end;
end;

procedure TfrmPrincipal.btnVerContactosClick(Sender: TObject);
begin
  frmVerContactos := TfrmVerContactos.Create(Application);
  try
    frmVerContactos.UsuarioEmail := UsuarioEmail;
    frmVerContactos.InicializarContactos;
    frmVerContactos.ShowModal;
  finally
    frmVerContactos.Free;
  end;
end;

procedure TfrmPrincipal.btnActualizarPerfilClick(Sender: TObject);
begin
  frmActualizarPerfil := TfrmActualizarPerfil.Create(Application);
  try
    frmActualizarPerfil.UsuarioEmail := UsuarioEmail;
    frmActualizarPerfil.ShowModal;
  finally
    frmActualizarPerfil.Free;
  end;
end;

procedure TfrmPrincipal.btnBandejaClick(Sender: TObject);
begin
  frmBandejaEntrada := TfrmBandejaEntrada.Create(Application);
  try
    frmBandejaEntrada.SetUsuarioEmail(UsuarioEmail);
    frmBandejaEntrada.ShowModal;
  finally
    frmBandejaEntrada.Free;
  end;
end;

procedure TfrmPrincipal.btnEnviarCorreoClick(Sender: TObject);
begin
  frmEnviarCorreo := TfrmEnviarCorreo.Create(Application);
  try
    frmEnviarCorreo.SetUsuarioEmail(UsuarioEmail);
    frmEnviarCorreo.ShowModal;
  finally
    frmEnviarCorreo.Free;
  end;
end;

procedure TfrmPrincipal.btnProgramarCorreoClick(Sender: TObject);
var
  usuario: TDataUser;
begin
  usuario := SSL_GETBYEMAIL(UsuarioEmail);
  frmProgramarCorreo := TfrmProgramarCorreo.Create(Application);
  try
    frmProgramarCorreo.SetUsuario(usuario);
    frmProgramarCorreo.ShowModal;
  finally
    frmProgramarCorreo.Free;
  end;
end;

procedure TfrmPrincipal.btnCorreosProgramadosClick(Sender: TObject);
var
  usuario: TDataUser;
begin
  usuario := SSL_GETBYEMAIL(UsuarioEmail);
  frmCorreosProgramados := TfrmCorreosProgramados.Create(Application);
  try
    frmCorreosProgramados.SetUsuario(usuario);
    frmCorreosProgramados.ShowModal;
  finally
    frmCorreosProgramados.Free;
  end;
end;

procedure TfrmPrincipal.btnPapeleraClick(Sender: TObject);
var
  usuario: TDataUser;
begin
  usuario := SSL_GETBYEMAIL(UsuarioEmail);
  frmPapelera := TfrmPapelera.Create(Application);
  try
    frmPapelera.SetUsuario(usuario);
    frmPapelera.ShowModal;
  finally
    frmPapelera.Free;
  end;
end;

end.

