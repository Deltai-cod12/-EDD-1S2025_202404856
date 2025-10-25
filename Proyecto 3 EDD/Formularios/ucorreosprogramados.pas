unit uCorreosProgramados;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  SLL, DLL_CON, UCola, UContactTypes;

type
  { TfrmCorreosProgramados }

  TfrmCorreosProgramados = class(TForm)
    lvProgramados: TListView;
    btnEnviarAhora: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnEnviarAhoraClick(Sender: TObject);
  private
    FUsuario: TDataUser;
    procedure CargarProgramados;
  public
    procedure SetUsuario(const usuario: TDataUser);
  end;

var
  frmCorreosProgramados: TfrmCorreosProgramados;

implementation

{$R *.lfm}

procedure TfrmCorreosProgramados.FormCreate(Sender: TObject);
begin
  Caption := 'Correos Programados';
  btnEnviarAhora.Caption := 'Enviar Ahora';
end;

procedure TfrmCorreosProgramados.SetUsuario(const usuario: TDataUser);
begin
  FUsuario := usuario;
  CargarProgramados;
end;

procedure TfrmCorreosProgramados.CargarProgramados;
var
  nodo: PNodoCola;
  item: TListItem;
begin
  lvProgramados.Items.Clear;
  if (FUsuario.Programados = nil) or (FUsuario.Programados^.Top = nil) then Exit;

  nodo := FUsuario.Programados^.Top;
  while nodo <> nil do
  begin
    item := lvProgramados.Items.Add;
    item.Caption := nodo^.correo^.remitente;
    item.SubItems.Add(nodo^.correo^.asunto);
    item.SubItems.Add(nodo^.correo^.fecha);
    nodo := nodo^.Next;
  end;
end;

procedure TfrmCorreosProgramados.btnEnviarAhoraClick(Sender: TObject);
var
  nodo, siguiente: PNodoCola;
  destinatario: TDataUser;
begin
  nodo := FUsuario.Programados^.Top;
  while nodo <> nil do
  begin
    siguiente := nodo^.Next;
    // Buscar usuario destino
    destinatario := SSL_GETBYEMAIL(nodo^.correo^.remitente);
    // Insertar en bandeja de entrada
    DLL_Insert(destinatario.Inbox, nodo^.correo^.id, nodo^.correo^.remitente,
      nodo^.correo^.asunto, nodo^.correo^.mensaje, nodo^.correo^.fecha);
    // Sacar de la cola
    Dequeue(FUsuario.Programados);
    nodo := siguiente;
  end;
  CargarProgramados;
  ShowMessage('Correos enviados.');
end;

end.

