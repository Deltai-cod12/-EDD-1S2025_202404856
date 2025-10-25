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
    btnEliminar: TButton;
    lblNombre: TLabel;
    lblUsuario: TLabel;
    lblEmail: TLabel;
    lblTelefono: TLabel;
    procedure btnSiguienteClick(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
  private
    FContactoActual: PContactNode;
    FListaContactos: PContactList;
    procedure MostrarContacto;
  public
    UsuarioEmail: string;
    procedure InicializarContactos;
  end;

var
  frmVerContactos: TfrmVerContactos;

implementation

{$R *.lfm}

procedure TfrmVerContactos.InicializarContactos;
var
  Data: TDataUser;
begin
  Caption := 'Contactos';
  Data := SSL_GETBYEMAIL(UsuarioEmail);
  if Data.Contacts <> nil then
    FListaContactos := Data.Contacts
  else
    FListaContactos := nil;

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
  while (Actual^.Next <> FContactoActual) and (Actual^.Next <> nil) do
    Actual := Actual^.Next;

  FContactoActual := Actual;
  MostrarContacto;
end;

procedure TfrmVerContactos.btnEliminarClick(Sender: TObject);
var
  Prev, Actual: PContactNode;
begin
  if (FListaContactos = nil) or (FContactoActual = nil) then
  begin
    ShowMessage('No hay contacto seleccionado para eliminar.');
    Exit;
  end;

  Actual := FListaContactos^.Head;
  Prev := nil;

  // buscar el nodo actual en la lista
  while (Actual <> nil) and (Actual <> FContactoActual) do
  begin
    Prev := Actual;
    Actual := Actual^.Next;
  end;

  if Actual = nil then Exit; // no se encontró

  // caso: es el primer nodo
  if Prev = nil then
    FListaContactos^.Head := Actual^.Next
  else
    Prev^.Next := Actual^.Next;

  // mover el puntero actual al siguiente
  FContactoActual := Actual^.Next;

  Dispose(Actual);

  ShowMessage('Contacto eliminado.');

  MostrarContacto;
end;

end.

