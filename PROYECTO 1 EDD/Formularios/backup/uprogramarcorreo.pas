unit uProgramarCorreo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  uListaSimpleUsuarios, uListaCircularContactos, uColaCorreosProgramados;

type

  { TfrmProgramarCorreo }

  TfrmProgramarCorreo = class(TForm)
    btnProgramar: TButton;
    btnCancelar: TButton;
    btnAgregarContacto: TButton;
    cbDestinatario: TComboBox;
    dtpFecha: TDateTimePicker;
    edtAsunto: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MemoMensaje: TMemo;
    StatusBar1: TStatusBar;
    procedure btnAgregarContactoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnProgramarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ListaContactos: TListaCircularContactos;
    ColaProgramados: TColaCorreosProgramados;
    procedure CargarContactos;
    function ValidarDatos: Boolean;
  public
    UsuarioActual: TUsuario;
    ListaUsuarios: TListaUsuarios;
  end;

var
  frmProgramarCorreo: TfrmProgramarCorreo;

implementation

{$R *.lfm}

{ TfrmProgramarCorreo }

procedure TfrmProgramarCorreo.FormCreate(Sender: TObject);
begin
  Caption := 'Programar Correo - ' + UsuarioActual.nombre;

  // Configurar etiquetas
  Label1.Caption := 'Para:';
  Label2.Caption := 'Asunto:';
  Label3.Caption := 'Mensaje:';
  Label4.Caption := 'Fecha y Hora:';
  Label5.Caption := 'Programar envío para:';

  // Configurar botones
  btnProgramar.Caption := 'Programar Envío';
  btnCancelar.Caption := 'Cancelar';
  btnAgregarContacto.Caption := 'Agregar Contacto';

  // Configurar DateTimePicker
  dtpFecha.DateTime := Now + 1; // Mañana por defecto
  dtpFecha.Time := 9; // 9:00 AM por defecto

  // Inicializar estructuras
  ListaContactos := TListaCircularContactos.Create;
  ColaProgramados := TColaCorreosProgramados.Create;

  // Cargar contactos
  CargarContactos;
end;

procedure TfrmProgramarCorreo.FormDestroy(Sender: TObject);
begin
  ListaContactos.Free;
  ColaProgramados.Free;
end;

procedure TfrmProgramarCorreo.CargarContactos;
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

function TfrmProgramarCorreo.ValidarDatos: Boolean;
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

  if dtpFecha.DateTime <= Now then
  begin
    ShowMessage('La fecha y hora deben ser futuras');
    Result := False;
    Exit;
  end;
end;

procedure TfrmProgramarCorreo.btnProgramarClick(Sender: TObject);
var
  destinatario: TUsuario;
  nuevoCorreo: PCorreo;
begin
  if not ValidarDatos then Exit;

  // Verificar que el destinatario existe
  destinatario := ListaUsuarios.ObtenerUsuarioPorEmail(cbDestinatario.Text);
  if destinatario.email = '' then
  begin
    ShowMessage('El destinatario no existe en el sistema');
    Exit;
  end;

  // Crear nuevo correo programado
  New(nuevoCorreo);
  nuevoCorreo^.id := 0; // Se asignará ID al enviar
  nuevoCorreo^.remitente := UsuarioActual.email;
  nuevoCorreo^.destinatario := destinatario.email;
  nuevoCorreo^.estado := 'N';
  nuevoCorreo^.programado := True;
  nuevoCorreo^.asunto := edtAsunto.Text;
  nuevoCorreo^.fecha := dtpFecha.DateTime;
  nuevoCorreo^.mensaje := MemoMensaje.Text;
  nuevoCorreo^.anterior := nil;
  nuevoCorreo^.siguiente := nil;

  // Encolar el correo programado
  ColaProgramados.Encolar(nuevoCorreo);

  ShowMessage('Correo programado para: ' + FormatDateTime('dd/mm/yyyy hh:nn', dtpFecha.DateTime));
  StatusBar1.SimpleText := 'Correo programado exitosamente. Total programados: ' +
                          IntToStr(ColaProgramados.ToString.Count);

  // Limpiar formulario
  edtAsunto.Text := '';
  MemoMensaje.Text := '';
  dtpFecha.DateTime := Now + 1;
end;

procedure TfrmProgramarCorreo.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmProgramarCorreo.btnAgregarContactoClick(Sender: TObject);
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

  // Verificar que no sea el mismo usuario
  if usuario.email = UsuarioActual.email then
  begin
    ShowMessage('No puede agregarse a sí mismo como contacto');
    Exit;
  end;

  // Agregar a contactos
  ListaContactos.Insertar(usuario);
  CargarContactos;

  ShowMessage('Contacto agregado: ' + usuario.nombre);
end;

end.
