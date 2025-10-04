unit uBorradores;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL, UAVL, DLL_CON, UContactTypes;

type

  { TfrmBorradores }

  TfrmBorradores = class(TForm)
    btnPreOrden: TButton;
    btnInOrden: TButton;
    btnPostOrden: TButton;
    btnEnviarSeleccionado: TButton;
    btnEnviarTodos: TButton;
    lstBorradores: TListBox;
    edtAsunto: TEdit;
    edtDestinatario: TEdit;
    memoMensaje: TMemo;
    lblDestinatario: TLabel;
    lblAsunto: TLabel;
    lblMensaje: TLabel;

    procedure btnPreOrdenClick(Sender: TObject);
    procedure btnInOrdenClick(Sender: TObject);
    procedure btnPostOrdenClick(Sender: TObject);
    procedure lstBorradoresClick(Sender: TObject);
    procedure btnEnviarSeleccionadoClick(Sender: TObject);
    procedure btnEnviarTodosClick(Sender: TObject);

  private
    FUsuario: TDataUser;
    procedure MostrarRecorrido(orden: string);
    procedure CargarCorreoSeleccionado(const id: string);
    // recorridos locales que trabajan con PNodoAVL
    procedure RecorrerPreOrden(nodo: PNodoAVL; list: TStringList);
    procedure RecorrerInOrden(nodo: PNodoAVL; list: TStringList);
    procedure RecorrerPostOrden(nodo: PNodoAVL; list: TStringList);
  public
    procedure SetUsuarioEmail(const email: string);
  end;

var
  frmBorradores: TfrmBorradores;

implementation

{$R *.lfm}

{ TfrmBorradores }

procedure TfrmBorradores.SetUsuarioEmail(const email: string);
begin
  FUsuario := SSL_GETBYEMAIL(email);
end;

procedure TfrmBorradores.RecorrerPreOrden(nodo: PNodoAVL; list: TStringList);
begin
  if nodo = nil then Exit;
  // agregamos el id para la visualización (puedes cambiar a formato que prefieras)
  list.Add(nodo^.mail.id);
  RecorrerPreOrden(nodo^.izquierda, list);
  RecorrerPreOrden(nodo^.derecha, list);
end;

procedure TfrmBorradores.RecorrerInOrden(nodo: PNodoAVL; list: TStringList);
begin
  if nodo = nil then Exit;
  RecorrerInOrden(nodo^.izquierda, list);
  list.Add(nodo^.mail.id);
  RecorrerInOrden(nodo^.derecha, list);
end;

procedure TfrmBorradores.RecorrerPostOrden(nodo: PNodoAVL; list: TStringList);
begin
  if nodo = nil then Exit;
  RecorrerPostOrden(nodo^.izquierda, list);
  RecorrerPostOrden(nodo^.derecha, list);
  list.Add(nodo^.mail.id);
end;

procedure TfrmBorradores.MostrarRecorrido(orden: string);
var
  lista: TStringList;
begin
  lstBorradores.Clear;
  lista := TStringList.Create;
  try
    if (FUsuario.Drafts <> nil) and (FUsuario.Drafts^.raiz <> nil) then
    begin
      if orden = 'pre' then
        RecorrerPreOrden(FUsuario.Drafts^.raiz, lista)
      else if orden = 'in' then
        RecorrerInOrden(FUsuario.Drafts^.raiz, lista)
      else if orden = 'post' then
        RecorrerPostOrden(FUsuario.Drafts^.raiz, lista);

      // Opcional: mostrar id + asunto en la lista en vez de solo id
      // Aquí dejamos la lista con IDs para que al hacer click cargue por id.
      lstBorradores.Items.Assign(lista);
    end
    else
      ShowMessage('No hay borradores guardados.');
  finally
    lista.Free;
  end;
end;

procedure TfrmBorradores.CargarCorreoSeleccionado(const id: string);
var
  nodo: PNodoAVL;
  correo: TMail;
begin
  if (FUsuario.Drafts = nil) or (FUsuario.Drafts^.raiz = nil) then Exit;

  nodo := BuscarAVL(FUsuario.Drafts^.raiz, id); // devuelve PNodoAVL (o nil)
  if nodo <> nil then
  begin
    correo := nodo^.mail;
    edtDestinatario.Text := correo.destinatario;
    edtAsunto.Text := correo.asunto;
    memoMensaje.Text := correo.mensaje;
  end
  else
  begin
    ShowMessage('No se encontró el borrador seleccionado.');
  end;
end;

procedure TfrmBorradores.lstBorradoresClick(Sender: TObject);
var
  seleccion: string;
begin
  if lstBorradores.ItemIndex <> -1 then
  begin
    seleccion := lstBorradores.Items[lstBorradores.ItemIndex];
    CargarCorreoSeleccionado(seleccion);
  end;
end;

procedure TfrmBorradores.btnPreOrdenClick(Sender: TObject);
begin
  MostrarRecorrido('pre');
end;

procedure TfrmBorradores.btnInOrdenClick(Sender: TObject);
begin
  MostrarRecorrido('in');
end;

procedure TfrmBorradores.btnPostOrdenClick(Sender: TObject);
begin
  MostrarRecorrido('post');
end;

procedure TfrmBorradores.btnEnviarSeleccionadoClick(Sender: TObject);
var
  idCorreo: string;
  nodo: PNodoAVL;
  correo: TMail;
  inboxDestinatario: PMsgList;
begin
  if lstBorradores.ItemIndex = -1 then
  begin
    ShowMessage('Seleccione un borrador primero.');
    Exit;
  end;

  idCorreo := lstBorradores.Items[lstBorradores.ItemIndex];

  nodo := BuscarAVL(FUsuario.Drafts^.raiz, idCorreo);
  if nodo = nil then
  begin
    ShowMessage('No se encontró el borrador seleccionado.');
    Exit;
  end;

  correo := nodo^.mail;

  if Trim(correo.destinatario) = '' then
  begin
    ShowMessage('El borrador no tiene destinatario.');
    Exit;
  end;

  inboxDestinatario := SSL_GETBYEMAIL(correo.destinatario).Inbox;
  if inboxDestinatario = nil then
  begin
    ShowMessage('No se pudo acceder a la bandeja de entrada del destinatario.');
    Exit;
  end;

  DLL_Insert(inboxDestinatario,
             correo.id,
             correo.remitente,
             correo.asunto,
             correo.mensaje,
             FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));

  FUsuario.Drafts^.raiz := EliminarAVL(FUsuario.Drafts^.raiz, correo.ID);

  ShowMessage('Correo enviado y eliminado de borradores.');
  MostrarRecorrido('in'); // refresca lista
end;

procedure TfrmBorradores.btnEnviarTodosClick(Sender: TObject);
var
  enviados: TStringList;

  procedure RecorrerYEnviar(nodo: PAVLNode);
  begin
    if nodo = nil then Exit;

    RecorrerYEnviar(nodo^.izq);

    if nodo^.correo.Destinatario <> '' then
    begin
      var inboxDestinatario := SSL_GETBYEMAIL(nodo^.correo.Destinatario).Inbox;
      if inboxDestinatario <> nil then
      begin
        DLL_Insert(inboxDestinatario,
                   nodo^.correo.ID,
                   nodo^.correo.Remitente,
                   nodo^.correo.Asunto,
                   nodo^.correo.Mensaje,
                   FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));
        enviados.Add(nodo^.correo.ID); // guardar id para borrar después
      end;
    end;

    RecorrerYEnviar(nodo^.der);
  end;

var
  i: Integer;
begin
  if (FUsuario.Drafts = nil) or (FUsuario.Drafts^.raiz = nil) then
  begin
    ShowMessage('No hay correos en borradores.');
    Exit;
  end;

  enviados := TStringList.Create;
  try
    RecorrerYEnviar(FUsuario.Drafts^.raiz);

    // eliminar después de recorrer
    for i := 0 to enviados.Count - 1 do
      FUsuario.Drafts^.raiz := EliminarAVL(FUsuario.Drafts^.raiz, enviados[i]);
  finally
    enviados.Free;
  end;

  ShowMessage('Todos los correos en borradores fueron enviados y eliminados.');
  MostrarRecorrido('in'); // refresca lista
end;

end.

