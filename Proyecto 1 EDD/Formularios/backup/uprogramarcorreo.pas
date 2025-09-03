unit uProgramarCorreo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL, UCola, DLL_CON;

type

  { TfrmProgramarCorreo }

  TfrmProgramarCorreo = class(TForm)
    lblAsunto: TLabel;
    lblMensaje: TLabel;
    lblFecha: TLabel;
    lblHora: TLabel;
    edtAsunto: TEdit;
    memMensaje: TMemo;
    edtFecha: TEdit;
    edtHora: TEdit;
    btnProgramar: TButton;
    procedure btnProgramarClick(Sender: TObject);
  private
    FUsuario: TDataUser;
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

procedure TfrmProgramarCorreo.btnProgramarClick(Sender: TObject);
var
  Dia, Mes, Anio: Word;
  Hora, Minuto: Word;
  FechaStr, HoraStr: string;
  FechaProgramada: TDateTime;
  correo: PNodeMsg;
begin
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

  // Agregar a la cola del usuario
  Enqueue(FUsuario.Programados, correo);

  ShowMessage('Correo programado correctamente para ' + FormatDateTime('dd/mm/yyyy hh:nn', FechaProgramada));

  // Limpiar campos
  edtAsunto.Text := '';
  memMensaje.Lines.Clear;
  edtFecha.Text := '';
  edtHora.Text := '';
end;

end.

