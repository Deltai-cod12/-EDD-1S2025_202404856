unit uVerContactos;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, UContactTypes, SLL;

type

  { TfrmVerContactos }

  TfrmVerContactos = class(TForm)
    btnSiguiente: TButton;
    btnAnterior: TButton;
    lblNombre: TLabel;
    lblUsuario: TLabel;
    lblEmail: TLabel;
    lblTelefono: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnSiguienteClick(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
  private
    FContactoActual: PContactNode;
    FListaContactos: PContactList;
    procedure MostrarContacto;
  public
    UsuarioEmail: string;
  end;

var
  frmVerContactos: TfrmVerContactos;

implementation

{$R *.lfm}

procedure TfrmVerContactos.FormCreate(Sender: TObject);
var
  Data: TDataUser;
begin
  Caption := 'Contactos';
  Data := SSL_GETBYEMAIL(UsuarioEmail);
  FListaContactos := Data.Contacts;
  FContactoActual := nil;

  if (FListaContactos <> nil) and (FListaContactos^.Head <> nil) then
    FContactoActual := FListaContactos^.Head;

  MostrarContacto;
end;

procedure TfrmVerContactos.MostrarContacto;
begin
  if (FContactoActual = nil) then
  begin
    lblNombre.Caption := 'Nombre: ---';
    lblUsuario.Caption := 'Usuario: ---';
    lblEmail.Caption := 'Email: ---';
    lblTelefono.Caption := 'Teléfono: ---';
    Exit;
  end;

  lblNombre.Caption := 'Nombre: ' + FContactoActual^.name;
  lblUsuario.Caption := 'Usuario: ' + FContactoActual^.user;
  lblEmail.Caption := 'Email: ' + FContactoActual^.email;
  lblTelefono.Caption := 'Teléfono: ' + FContactoActual^.phone;
end;

procedure TfrmVerContactos.btnSiguienteClick(Sender: TObject);
begin
  if FContactoActual <> nil then
    FContactoActual := FContactoActual^.Next;
  MostrarContacto;
end;

procedure TfrmVerContactos.btnAnteriorClick(Sender: TObject);
var
  Actual: PContactNode;
begin
  if (FListaContactos = nil) or (FListaContactos^.Head = nil) then Exit;

  Actual := FListaContactos^.Head;
  if FContactoActual = nil then
  begin
    FContactoActual := Actual;
    MostrarContacto;
    Exit;
  end;

  // buscar el nodo anterior
  while Actual^.Next <> FContactoActual do
  begin
    Actual := Actual^.Next;
    if Actual = FListaContactos^.Head then Break; // ciclo completo
  end;
  FContactoActual := Actual;
  MostrarContacto;
end;

end.

