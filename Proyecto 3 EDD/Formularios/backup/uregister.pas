unit uRegister;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL; // lista simple de usuarios

type
  TfrmRegister = class(TForm)
    btnCancelar: TButton;
    btnRegistrar: TButton;
    edtID: TEdit;
    edtNombre: TEdit;
    edtEmail: TEdit;
    edtUsuario: TEdit;
    edtTelefono: TEdit;
    edtPassword: TEdit;
    lblID: TLabel;
    lblNombre: TLabel;
    lblEmail: TLabel;
    lblUsuario: TLabel;
    lblTelefono: TLabel;
    lblPassword: TLabel;
    procedure btnRegistrarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private

  public

  end;

var
  frmRegister: TfrmRegister;

implementation

{$R *.lfm}

uses
  Dialogs;

{ TfrmRegister }

procedure TfrmRegister.btnRegistrarClick(Sender: TObject);
var
  id, nombre, email, usuario, telefono, password: string;
begin
  id := Trim(edtID.Text);
  nombre := Trim(edtNombre.Text);
  email := Trim(edtEmail.Text);
  usuario := Trim(edtUsuario.Text);
  telefono := Trim(edtTelefono.Text);
  password := Trim(edtPassword.Text);

  if (id = '') or (nombre = '') or (email = '') or (usuario = '') or
     (telefono = '') or (password = '') then
  begin
    ShowMessage('Debe llenar todos los campos');
    Exit;
  end;

  if SLL_INSERT(id, nombre, email, usuario, telefono, password) then
  begin
    ShowMessage('Usuario registrado correctamente');
    Close; // cierra formulario y regresa al login
  end
  else
  begin
    ShowMessage('Error: el email o password ya existe');
  end;
end;

procedure TfrmRegister.btnCancelarClick(Sender: TObject);
begin
  Close; // vuelve al login
end;

end.

