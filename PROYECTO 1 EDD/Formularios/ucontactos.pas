unit uContactos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uListaSimpleUsuarios, uListaCircularContactos;

type

  { TfrmContactos }

  TfrmContactos = class(TForm)
    btnAgregar: TButton;
    btnSiguiente: TButton;
    btnAnterior: TButton;
    btnEliminar: TButton;
    btnCerrar: TButton;
    edtEmail: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblNombre: TLabel;
    lblUsuario: TLabel;
    lblEmail: TLabel;
    lblTelefono: TLabel;
    procedure btnAgregarClick(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnSiguienteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ListaContactos: TListaCircularContactos;
    procedure MostrarContactoActual;
    procedure ActualizarLista;
  public
    UsuarioActual: TUsuario;
    ListaUsuarios: TListaUsuarios;
  end;

var
  frmContactos: TfrmContactos;

implementation

{$R *.lfm}

{ TfrmContactos }

procedure TfrmContactos.FormCreate(Sender: TObject);
begin
  Caption := 'Gestión de Contactos - ' + UsuarioActual.nombre;

  // Configurar labels y botones
  Label1.Caption := 'Agregar Contacto:';
  Label2.Caption := 'Email del contacto:';
  btnAgregar.Caption := 'Agregar';

  Label3.Caption := 'Contacto Actual:';
  lblNombre.Caption := 'Nombre:';
  lblUsuario.Caption := 'Usuario:';
  lblEmail.Caption := 'Email:';
  lblTelefono.Caption := 'Teléfono:';

  btnSiguiente.Caption := 'Siguiente →';
  btnAnterior.Caption := '← Anterior';
  btnEliminar.Caption := 'Eliminar';
  btnCerrar.Caption := 'Cerrar';

  // Inicializar lista de contactos
  ListaContactos := TListaCircularContactos.Create;

  // Cargar algunos contactos de ejemplo
  ActualizarLista;
end;

procedure TfrmContactos.FormDestroy(Sender: TObject);
begin
  ListaContactos.Free;
end;

procedure TfrmContactos.MostrarContactoActual;
var
  contacto: TUsuario;
begin
  if ListaContactos.EsVacia then
  begin
    lblNombre.Caption := 'Nombre: [No hay contactos]';
    lblUsuario.Caption := 'Usuario:';
    lblEmail.Caption := 'Email:';
    lblTelefono.Caption := 'Teléfono:';
    Exit;
  end;

  contacto := ListaContactos.ObtenerPrimero;
  lblNombre.Caption := 'Nombre: ' + contacto.nombre;
  lblUsuario.Caption := 'Usuario: ' + contacto.usuario;
  lblEmail.Caption := 'Email: ' + contacto.email;
  lblTelefono.Caption := 'Teléfono: ' + contacto.telefono;
end;

procedure TfrmContactos.ActualizarLista;
begin
  MostrarContactoActual;
end;

procedure TfrmContactos.btnAgregarClick(Sender: TObject);
var
  email: string;
  usuario: TUsuario;
begin
  email := Trim(edtEmail.Text);

  if email = '' then
  begin
    ShowMessage('Ingrese el email del contacto');
    Exit;
  end;

  // Verificar que el usuario existe
  usuario := ListaUsuarios.ObtenerUsuarioPorEmail(email);
  if usuario.email = '' then
  begin
    ShowMessage('El usuario con email ' + email + ' no existe');
    Exit;
  end;

  // Verificar que no sea el mismo usuario
  if usuario.email = UsuarioActual.email then
  begin
    ShowMessage('No puede agregarse a sí mismo como contacto');
    Exit;
  end;

  // Agregar a contactos
  ListaContactos.Insertar(usuario);
  ActualizarLista;

  ShowMessage('Contacto agregado: ' + usuario.nombre);
  edtEmail.Text := '';
end;

procedure TfrmContactos.btnSiguienteClick(Sender: TObject);
var
  contacto: TUsuario;
begin
  if ListaContactos.EsVacia then
  begin
    ShowMessage('No hay contactos en la lista');
    Exit;
  end;

  contacto := ListaContactos.ObtenerSiguiente;
  lblNombre.Caption := 'Nombre: ' + contacto.nombre;
  lblUsuario.Caption := 'Usuario: ' + contacto.usuario;
  lblEmail.Caption := 'Email: ' + contacto.email;
  lblTelefono.Caption := 'Teléfono: ' + contacto.telefono;
end;

procedure TfrmContactos.btnAnteriorClick(Sender: TObject);
var
  contacto: TUsuario;
begin
  if ListaContactos.EsVacia then
  begin
    ShowMessage('No hay contactos en la lista');
    Exit;
  end;

  contacto := ListaContactos.ObtenerAnterior;
  lblNombre.Caption := 'Nombre: ' + contacto.nombre;
  lblUsuario.Caption := 'Usuario: ' + contacto.usuario;
  lblEmail.Caption := 'Email: ' + contacto.email;
  lblTelefono.Caption := 'Teléfono: ' + contacto.telefono;
end;

procedure TfrmContactos.btnEliminarClick(Sender: TObject);
var
  contactoActual: TUsuario;
begin
  if ListaContactos.EsVacia then
  begin
    ShowMessage('No hay contactos para eliminar');
    Exit;
  end;

  contactoActual := ListaContactos.ObtenerPrimero;
  if MessageDlg('Confirmar',
                '¿Está seguro de eliminar a ' + contactoActual.nombre + ' de sus contactos?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    ListaContactos.Eliminar(contactoActual.email);
    ActualizarLista;
    ShowMessage('Contacto eliminado');
  end;
end;

procedure TfrmContactos.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
