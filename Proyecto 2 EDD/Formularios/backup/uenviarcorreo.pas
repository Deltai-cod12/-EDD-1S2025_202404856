unit uEnviarCorreo;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DLL_CON, SLL, UContactTypes, UAVL;

type

  { TfrmEnviarCorreo }

  TfrmEnviarCorreo = class(TForm)
    edtDestinatario: TEdit;
    edtAsunto: TEdit;
    memoMensaje: TMemo;
    btnEnviar: TButton;
    btnBorrador: TButton;
    procedure btnEnviarClick(Sender: TObject);
    procedure btnBorradorClick(Sender: TObject);
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
  until actual = FUsuario.Contacts^.Head;
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

  inboxDestinatario := SSL_GETBYEMAIL(destinatarioEmail).Inbox;
  if inboxDestinatario = nil then
  begin
    ShowMessage('Error: no se pudo acceder a la bandeja de entrada del destinatario.');
    Exit;
  end;

  idCorreo := FormatDateTime('yyyymmddhhnnsszzz', Now);

  DLL_Insert(inboxDestinatario,
             idCorreo,
             FUsuario.email,
             edtAsunto.Text,
             memoMensaje.Text,
             FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));

  ShowMessage('Correo enviado correctamente.');
  Close;
end;

procedure TfrmEnviarCorreo.btnBorradorClick(Sender: TObject);
var
  idCorreo: string;
  borrador: TCorreo;
begin
  idCorreo := FormatDateTime('yyyymmddhhnnsszzz', Now);

  borrador.ID := idCorreo;
  borrador.Remitente := FUsuario.email;
  borrador.Destinatario := Trim(edtDestinatario.Text);
  borrador.Asunto := edtAsunto.Text;
  borrador.Mensaje := memoMensaje.Text;

  if FUsuario.Drafts <> nil then
  begin
    FUsuario.Drafts^.raiz := Insertar(FUsuario.Drafts^.raiz, borrador);
    ShowMessage('Correo guardado en borradores.');
  end
  else
    ShowMessage('Error: no se pudo acceder a los borradores.');
end;

end.

