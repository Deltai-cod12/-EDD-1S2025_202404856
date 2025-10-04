unit uActualizarPerfil;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SLL;

type

  { TfrmActualizarPerfil }

  TfrmActualizarPerfil = class(TForm)
    btnActualizar: TButton;
    edtUsuario: TEdit;
    edtTelefono: TEdit;
    lblUsuario: TLabel;
    lblTelefono: TLabel;
    procedure btnActualizarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FEmail: string; // Email fijo del usuario logueado
  public
    property UsuarioEmail: string read FEmail write FEmail;
  end;

var
  frmActualizarPerfil: TfrmActualizarPerfil;

implementation

{$R *.lfm}

{ TfrmActualizarPerfil }

procedure TfrmActualizarPerfil.FormShow(Sender: TObject);
var
  Data: TDataUser;
begin
  // Recuperamos datos actuales para mostrarlos al usuario
  Data := SSL_GETBYEMAIL(FEmail);

  if Data.email <> '' then
  begin
    edtUsuario.Text := Data.user;
    edtTelefono.Text := Data.phone;
  end;
end;

procedure TfrmActualizarPerfil.btnActualizarClick(Sender: TObject);
begin
  if (edtUsuario.Text = '') or (edtTelefono.Text = '') then
  begin
    ShowMessage('Por favor, complete todos los campos.');
    Exit;
  end;

  if SLL_actualizarPerfil(FEmail, edtUsuario.Text, edtTelefono.Text) then
    ShowMessage('Perfil actualizado correctamente.')
  else
    ShowMessage('Error: no se pudo actualizar el perfil.');
end;

end.

