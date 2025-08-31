unit uEnviarCorreo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  uListaSimpleUsuarios, uListaDobleCorreos, uListaCircularContactos;

type

  { TfrmEnviarCorreo }

  TfrmEnviarCorreo = class(TForm)
    btnEnviar: TButton;
    btnCancelar: TButton;
    btnAgregarContacto: TButton;
    cbDestinatario: TComboBox;
    edtAsunto: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MemoMensaje: TMemo;
    StatusBar1: TStatusBar;
    procedure btnAgregarContactoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ListaContactos: TListaCircularContactos;
    procedure CargarContactos;
    function ValidarDatos: Boolean;
  public
    UsuarioActual: TUsuario;
    ListaUsuarios: TListaUsuarios;
  end;

var
  frmEnviarCorreo: TfrmEnviarCorreo;

implementation

{$R *.lfm}

{ TfrmEnviarCorreo }

procedure TfrmEnviarCorreo.FormCreate(Sender: TObject);
begin
  Caption := 'Enviar Correo - ' + UsuarioActual.nombre;
  Label1.Caption := 'Para:';
  Label2.Caption := 'Asunto:';
  Label3.Caption := 'Mensaje:';
  btnEnviar.Caption := 'Enviar';
  btnCancelar.Caption := 'Cancelar';
  btnAgregarContacto.Caption := 'Agregar Contacto';

  // Inicializar lista de contactos
  ListaContactos := TListaCircularContactos.Create;

  // Cargar contactos del usuario (en una app real se cargarían de archivo)
  CargarContactos;
end;

procedure TfrmEnviarCorreo.FormDestroy(Sender: TObject);
begin
  ListaContactos.Free;
end;

procedure TfrmEnviarCorreo.CargarContactos;
var
  contacto: TUsuario;
begin
  cbDestinatario.Clear;

  if not ListaContactos.EsVacia then
  begin
    contacto := ListaContactos.ObtenerPrimero;
    cbDestinatario.Items.Add(contacto.email);

    while contacto.email <> '' do
    begin
      contacto := ListaContactos.ObtenerSiguiente;
      if contacto.email <> '' then
        cbDestinatario.Items.Add(contacto.email);
    end;
  end;

  if cbDestinatario.Items.Count > 0 then
    cbDestinatario.ItemIndex := 0;
end;

function TfrmEnviarCorreo.ValidarDatos: Boolean;
begin
  Result := True;

  if cbDestinatario.Text = '' then
  begin
    ShowMessage('Seleccione un destinatario');
    Result := False;
    Exit;
  end;

  if edtAsunto.Text = '' then
  begin
    ShowMessage('Ingrese un asunto');
    Result := False;
    Exit;
  end;

  if MemoMensaje.Text = '' then
  begin
    ShowMessage('Escriba un mensaje');
    Result := False;
    Exit;
  end;
end;

procedure TfrmEnviarCorreo.btnEnviarClick(Sender: TObject);
var
  destinatario: TUsuario;
begin
  if not ValidarDatos then Exit;

  // Verificar que el destinatario existe
  destinatario := ListaUsuarios.ObtenerUsuarioPorEmail(cbDestinatario.Text);
  if destinatario.email = '' then
  begin
    ShowMessage('El destinatario no existe en el sistema');
    Exit;
  end;

  // Aquí se guardaría el correo en el sistema
  // Por ahora solo mostramos un mensaje
  ShowMessage('Correo enviado a: ' + destinatario.nombre);

  // Limpiar formulario
  edtAsunto.Text := '';
  MemoMensaje.Text := '';
  StatusBar1.SimpleText := 'Correo enviado exitosamente';
end;

procedure TfrmEnviarCorreo.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEnviarCorreo.btnAgregarContactoClick(Sender: TObject);
var
  email: string;
  usuario: TUsuario;
begin
  email := InputBox('Agregar Contacto', 'Ingrese el email del contacto:', '');

  if email = '' then Exit;

  // Verificar que el usuario existe
  usuario := ListaUsuarios.ObtenerUsuarioPorEmail(email);
  if usuario.email = '' then
  begin
    ShowMessage('El usuario no existe en el sistema');
    Exit;
  end;

  // Agregar a contactos
  ListaContactos.Insertar(usuario);
  CargarContactos;

  ShowMessage('Contacto agregado: ' + usuario.nombre);
end;

end.
