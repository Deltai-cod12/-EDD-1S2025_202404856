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
    edtFecha: TEdit;
    edtHora: TEdit;
    edtAsunto: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
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
    function ObtenerFechaHora: TDateTime;
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
var
  fechaActual: TDateTime;
begin
  Caption := 'Programar Correo - ' + UsuarioActual.nombre;

  // Configurar etiquetas
  Label1.Caption := 'Para:';
  Label2.Caption := 'Asunto:';
  Label3.Caption := 'Mensaje:';
  Label4.Caption := 'Programar envío para:';
  Label5.Caption := 'Fecha (dd/mm/aaaa):';
  Label6.Caption := 'Hora (hh:nn):';

  // Configurar botones
  btnProgramar.Caption := 'Programar Envío';
  btnCancelar.Caption := 'Cancelar';
  btnAgregarContacto.Caption := 'Agregar Contacto';

  // Configurar valores por defecto
  fechaActual := Now + 1; // Mañana
  edtFecha.Text := FormatDateTime('dd/mm/yyyy', fechaActual);
  edtHora.Text := '09:00';

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
var
  fechaHora: TDateTime;
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

  try
    fechaHora := ObtenerFechaHora;
    if fechaHora <= Now then
    begin
      ShowMessage('La fecha y hora deben ser futuras');
      Result := False;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Formato de fecha/hora inválido. Use dd/mm/aaaa y hh:nn');
      Result := False;
    end;
  end;
end;

function TfrmProgramarCorreo.ObtenerFechaHora: TDateTime;
var
  fechaStr, horaStr: string;
begin
  fechaStr := Trim(edtFecha.Text);
  horaStr := Trim(edtHora.Text);

  if (fechaStr = '') or (horaStr = '') then
    raise Exception.Create('Fecha u hora vacías');

  Result := StrToDateTime(fechaStr + ' ' + horaStr);
end;

procedure TfrmProgramarCorreo.btnProgramarClick(Sender: TObject);
var
  destinatario: TUsuario;
  nuevoCorreo: PCorreo;
  fechaHora: TDateTime;
begin
  if not ValidarDatos then Exit;

  // Verificar que el destinatario existe
  destinatario := ListaUsuarios.ObtenerUsuarioPorEmail(cbDestinatario.Text);
  if destinatario.email = '' then
  begin
    ShowMessage('El destinatario no existe en el sistema');
    Exit;
  end;

  try
    fechaHora := ObtenerFechaHora;

    // Crear nuevo correo programado
    New(nuevoCorreo);
    nuevoCorreo^.id := 0; // Se asignará ID al enviar
    nuevoCorreo^.remitente := UsuarioActual.email;
    nuevoCorreo^.destinatario := destinatario.email;
    nuevoCorreo^.estado := 'N';
    nuevoCorreo^.programado := True;
    nuevoCorreo^.asunto := edtAsunto.Text;
    nuevoCorreo^.fecha := fechaHora;
    nuevoCorreo^.mensaje := MemoMensaje.Text;
    nuevoCorreo^.anterior := nil;
    nuevoCorreo^.siguiente := nil;

    // Encolar el correo programado
    ColaProgramados.Encolar(nuevoCorreo);

    ShowMessage('Correo programado para: ' + FormatDateTime('dd/mm/yyyy hh:nn', fechaHora));
    StatusBar1.SimpleText := 'Correo programado exitosamente';

    // Limpiar formulario
    edtAsunto.Text := '';
    MemoMensaje.Text := '';
    edtFecha.Text := FormatDateTime('dd/mm/yyyy', Now + 1);
    edtHora.Text := '09:00';

  except
    on E: Exception do
      ShowMessage('Error al programar: ' + E.Message);
  end;
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
