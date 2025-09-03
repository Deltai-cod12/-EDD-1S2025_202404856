unit uContactos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SLL, UContactTypes;

type

  { TfrmContactos }

  TfrmContactos = class(TForm)
    btnAgregarContacto: TButton;
    edtCorreo: TEdit;
    lblCorreo: TLabel;
    procedure btnAgregarContactoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    UsuarioEmail: string; // Email del usuario actual
  end;

var
  frmContactos: TfrmContactos;

implementation

{$R *.lfm}

{ TfrmContactos }

procedure TfrmContactos.FormCreate(Sender: TObject);
begin
  Caption := 'Agregar Contacto';
  lblCorreo.Caption := 'Correo del Contacto:';
  btnAgregarContacto.Caption := 'Agregar Contacto';
end;

procedure TfrmContactos.btnAgregarContactoClick(Sender: TObject);
var
  correo: string;
  usuarioActual, contactoExistente: TDataUser;
  contacto: PContactNode;
begin
  correo := Trim(edtCorreo.Text);

  if correo = '' then
  begin
    ShowMessage('Debe ingresar un correo válido.');
    Exit;
  end;

  // Verificar que el correo exista en la lista de usuarios
  if not ValidatePassAndEmail(correo, '') then
  begin
    ShowMessage('El correo no existe en el sistema.');
    Exit;
  end;

  usuarioActual := SSL_GETBYEMAIL(UsuarioEmail);

  // Verificar que no esté agregado previamente
  contacto := SearchContact(usuarioActual.Contacts, correo);
  if contacto <> nil then
  begin
    ShowMessage('El contacto ya existe en su lista.');
    Exit;
  end;

  // Agregar contacto
  contactoExistente := SSL_GETBYEMAIL(correo);
  InsertContact(usuarioActual.Contacts, contactoExistente.email, contactoExistente.name);

  ShowMessage('Contacto agregado correctamente.');
  edtCorreo.Clear;
end;


end.
