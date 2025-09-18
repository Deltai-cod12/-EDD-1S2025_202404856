unit uEnviarCorreo;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DLL_CON, SLL, UContactTypes;

type

  { TfrmEnviarCorreo }

  TfrmEnviarCorreo = class(TForm)
    edtDestinatario: TEdit;
    edtAsunto: TEdit;
    memoMensaje: TMemo;
    btnEnviar: TButton;
    procedure btnEnviarClick(Sender: TObject);
  private
    FUsuario: TDataUser;
    function EstaEnContactos(const email: string): Boolean;
  public
    procedure SetUsuarioEmail(const email: string);
  end;

var
  frmEnviarCorreo: TfrmEnviarCorreo;

implementation

{$R *.lfm}

procedure TfrmEnviarCorreo.SetUsuarioEmail(const email: string);
begin
  FUsuario := SSL_GETBYEMAIL(email);
end;

function TfrmEnviarCorreo.EstaEnContactos(const email: string): Boolean;
var
  actual: PContactNode;
begin
  Result := False;

  // Verificar que la lista de contactos exista y no esté vacía
  if (FUsuario.Contacts = nil) or (FUsuario.Contacts^.Head = nil) then
    Exit;

  actual := FUsuario.Contacts^.Head;
  repeat
    if actual^.email = Trim(email) then
    begin
      Result := True;
      Exit;
    end;
    actual := actual^.Next;
  until actual = FUsuario.Contacts^.Head; // por ser lista circular
end;


procedure TfrmEnviarCorreo.btnEnviarClick(Sender: TObject);
var
  destinatarioEmail, idCorreo: string;
  inboxDestinatario: PMsgList;
begin
  destinatarioEmail := Trim(edtDestinatario.Text);
  if destinatarioEmail = '' then
  begin
    ShowMessage('Debe ingresar un correo destinatario.');
    Exit;
  end;

  if not EstaEnContactos(destinatarioEmail) then
  begin
    ShowMessage('El destinatario no está en sus contactos.');
    Exit;
  end;

  // Obtener inbox del destinatario
  inboxDestinatario := SSL_GETBYEMAIL(destinatarioEmail).Inbox;
  if inboxDestinatario = nil then
  begin
    ShowMessage('Error: no se pudo acceder a la bandeja de entrada del destinatario.');
    Exit;
  end;

  // Generar ID de correo
  idCorreo := FormatDateTime('yyyymmddhhnnsszzz', Now);

  // Insertar correo en inbox
  DLL_Insert(inboxDestinatario,
             idCorreo,
             FUsuario.email,
             edtAsunto.Text,
             memoMensaje.Text,
             FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));

  ShowMessage('Correo enviado correctamente.');
  Close;
end;

end.

