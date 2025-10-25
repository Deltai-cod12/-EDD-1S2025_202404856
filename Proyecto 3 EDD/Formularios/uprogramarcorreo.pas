unit uProgramarCorreo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL, UCola, DLL_CON, UContactTypes;

type

  { TfrmProgramarCorreo }

  TfrmProgramarCorreo = class(TForm)
    lblDestinatario: TLabel;
    lblAsunto: TLabel;
    lblMensaje: TLabel;
    lblFecha: TLabel;
    lblHora: TLabel;
    edtDestinatario: TEdit;
    edtAsunto: TEdit;
    memMensaje: TMemo;
    edtFecha: TEdit;
    edtHora: TEdit;
    btnProgramar: TButton;
    procedure btnProgramarClick(Sender: TObject);
  private
    FUsuario: TDataUser;
    function EstaEnContactos(const email: string): Boolean;
  public
    procedure SetUsuario(usuario: TDataUser);
  end;

var
  frmProgramarCorreo: TfrmProgramarCorreo;

implementation

{$R *.lfm}

procedure TfrmProgramarCorreo.SetUsuario(usuario: TDataUser);
begin
  FUsuario := usuario;
end;

// Función para validar si un correo está en los contactos
function TfrmProgramarCorreo.EstaEnContactos(const email: string): Boolean;
var
  actual: PContactNode;
begin
  Result := False;
  if FUsuario.Contacts = nil then Exit;
  actual := FUsuario.Contacts^.Head;
  if actual = nil then Exit;

  repeat
    if actual^.email = Trim(email) then
    begin
      Result := True;
      Exit;
    end;
    actual := actual^.Next;
  until actual = FUsuario.Contacts^.Head;
end;

procedure TfrmProgramarCorreo.btnProgramarClick(Sender: TObject);
var
  Dia, Mes, Anio: Word;
  Hora, Minuto: Word;
  FechaStr, HoraStr, Destinatario: string;
  FechaProgramada: TDateTime;
  correo: PNodeMsg;
begin
  Destinatario := Trim(edtDestinatario.Text);

  // Validar destinatario
  if Destinatario = '' then
  begin
    ShowMessage('Debe ingresar un destinatario');
    Exit;
  end;

  if not EstaEnContactos(Destinatario) then
  begin
    ShowMessage('El destinatario no está en sus contactos');
    Exit;
  end;

  FechaStr := Trim(edtFecha.Text); // formato dd/mm/yyyy
  HoraStr := Trim(edtHora.Text);   // formato hh:nn

  // Validar fecha
  if Length(FechaStr) <> 10 then
  begin
    ShowMessage('Fecha inválida. Formato: dd/mm/yyyy');
    Exit;
  end;

  try
    Dia := StrToInt(Copy(FechaStr, 1, 2));
    Mes := StrToInt(Copy(FechaStr, 4, 2));
    Anio := StrToInt(Copy(FechaStr, 7, 4));
    FechaProgramada := EncodeDate(Anio, Mes, Dia);
  except
    ShowMessage('Fecha inválida. Formato: dd/mm/yyyy');
    Exit;
  end;

  // Validar hora
  if Length(HoraStr) <> 5 then
  begin
    ShowMessage('Hora inválida. Formato: hh:nn (24h)');
    Exit;
  end;

  try
    Hora := StrToInt(Copy(HoraStr, 1, 2));
    Minuto := StrToInt(Copy(HoraStr, 4, 2));
    if (Hora > 23) or (Minuto > 59) then
      raise Exception.Create('Hora fuera de rango');
    FechaProgramada := FechaProgramada + EncodeTime(Hora, Minuto, 0, 0);
  except
    ShowMessage('Hora inválida. Formato: hh:nn (24h)');
    Exit;
  end;

  // Crear correo
  New(correo);
  correo^.id := IntToStr(Random(1000000));
  correo^.remitente := FUsuario.email;
  correo^.asunto := edtAsunto.Text;
  correo^.mensaje := memMensaje.Text;
  correo^.fecha := DateTimeToStr(FechaProgramada);
  correo^.estado := 'NL';
  correo^.Prev := nil;
  correo^.Next := nil;

  // Agregar destinatario como campo adicional si lo deseas
  correo^.remitente := Destinatario; // o crear campo "destinatario" en PNodeMsg si quieres

  // Agregar a la cola del usuario
  Enqueue(FUsuario.Programados, correo);

  ShowMessage('Correo programado correctamente para ' + FormatDateTime('dd/mm/yyyy hh:nn', FechaProgramada));

  // Limpiar campos
  edtDestinatario.Text := '';
  edtAsunto.Text := '';
  memMensaje.Lines.Clear;
  edtFecha.Text := '';
  edtHora.Text := '';
end;

end.

