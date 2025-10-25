unit uActualizarPerfil;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SLL;

type
  TfrmActualizarPerfil = class(TForm)
    btnActualizar: TButton;
    btnCancelar: TButton;
    edtEmail: TEdit;
    edtUsuario: TEdit;
    edtTelefono: TEdit;
    lblEmail: TLabel;
    lblUsuario: TLabel;
    lblTelefono: TLabel;
    procedure btnActualizarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmActualizarPerfil: TfrmActualizarPerfil;

implementation

{$R *.lfm}

procedure TfrmActualizarPerfil.FormCreate(Sender: TObject);
begin
  // Aquí podrías cargar el usuario logueado automáticamente si guardas sesión.
  edtEmail.Text := '';
  edtUsuario.Text := '';
  edtTelefono.Text := '';
end;

procedure TfrmActualizarPerfil.btnActualizarClick(Sender: TObject);
var
  email, usuario, telefono: string;
  actualizado: Boolean;
begin
  email := Trim(edtEmail.Text);
  usuario := Trim(edtUsuario.Text);
  telefono := Trim(edtTelefono.Text);

  if (email = '') or ((usuario = '') and (telefono = '')) then
  begin
    ShowMessage('Debe ingresar un correo válido y al menos un campo a actualizar');
    Exit;
  end;

  actualizado := SLL_actualizarPerfil(email, usuario, telefono);

  if actualizado then
    ShowMessage('Perfil actualizado correctamente')
  else
    ShowMessage('No se encontró el usuario con ese correo');
end;

procedure TfrmActualizarPerfil.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

end.

