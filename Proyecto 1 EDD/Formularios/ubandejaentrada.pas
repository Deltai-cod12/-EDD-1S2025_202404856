unit uBandejaEntrada;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  DLL_CON, SLL, UPila;

type
  { TfrmBandejaEntrada }
  TfrmBandejaEntrada = class(TForm)
    lvCorreos: TListView;
    btnOrdenar: TButton;
    btnEliminar: TButton;
    lblNoLeidos: TLabel;
    memoMensaje: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure lvCorreosSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btnOrdenarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
  private
    FListaInbox: PMsgList;
    FCorreoActual: PNodeMsg;
    FUsuarioEmail: string;
    procedure CargarCorreos;
    procedure MostrarCorreo;
    procedure ActualizarNoLeidos;
  public
    procedure SetUsuarioEmail(const email: string);
  end;

var
  frmBandejaEntrada: TfrmBandejaEntrada;

implementation

{$R *.lfm}

procedure TfrmBandejaEntrada.SetUsuarioEmail(const email: string);
begin
  FUsuarioEmail := email;
  FListaInbox := SSL_GETBYEMAIL(FUsuarioEmail).Inbox;
  CargarCorreos;
end;

procedure TfrmBandejaEntrada.FormCreate(Sender: TObject);
begin
  Caption := 'Bandeja de Entrada';
  lvCorreos.ViewStyle := vsReport;
  lvCorreos.Columns.Clear;
  lvCorreos.Columns.Add.Caption := 'Estado';
  lvCorreos.Columns.Add.Caption := 'Asunto';
  lvCorreos.Columns.Add.Caption := 'Remitente';
  lvCorreos.Columns[0].Width := 50;
  lvCorreos.Columns[1].Width := 200;
  lvCorreos.Columns[2].Width := 150;
  memoMensaje.Clear;
  lblNoLeidos.Caption := 'No Leídos: 0';
end;

procedure TfrmBandejaEntrada.CargarCorreos;
var
  actual: PNodeMsg;
  item: TListItem;
begin
  lvCorreos.Items.Clear;
  if (FListaInbox = nil) or (FListaInbox^.Head = nil) then Exit;

  actual := FListaInbox^.Head;
  while actual <> nil do
  begin
    item := lvCorreos.Items.Add;
    item.Caption := actual^.estado;
    item.SubItems.Add(actual^.asunto);
    item.SubItems.Add(actual^.remitente);
    item.Data := actual;
    actual := actual^.Next;
  end;
  ActualizarNoLeidos;
end;

procedure TfrmBandejaEntrada.MostrarCorreo;
begin
  if FCorreoActual = nil then
  begin
    memoMensaje.Clear;
    Exit;
  end;
  memoMensaje.Text := FCorreoActual^.mensaje;
  if FCorreoActual^.estado = 'NL' then
  begin
    FCorreoActual^.estado := 'L';
    lvCorreos.Items[lvCorreos.ItemIndex].Caption := 'L';
    ActualizarNoLeidos;
  end;
end;

procedure TfrmBandejaEntrada.lvCorreosSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if not Selected then Exit;
  FCorreoActual := PNodeMsg(Item.Data);
  MostrarCorreo;
end;

procedure TfrmBandejaEntrada.ActualizarNoLeidos;
var
  count: Integer;
  actual: PNodeMsg;
begin
  count := 0;
  if (FListaInbox <> nil) then
  begin
    actual := FListaInbox^.Head;
    while actual <> nil do
    begin
      if actual^.estado = 'NL' then Inc(count);
      actual := actual^.Next;
    end;
  end;
  lblNoLeidos.Caption := 'No Leídos: ' + IntToStr(count);
end;

procedure TfrmBandejaEntrada.btnOrdenarClick(Sender: TObject);
var
  i, j: Integer;
  Correos: array of PNodeMsg;
  temp: PNodeMsg;
  actual: PNodeMsg; //declaramos el nodo
begin
  if (FListaInbox = nil) or (FListaInbox^.Head = nil) then Exit;

  // Pasar la lista a un arreglo para ordenar
  SetLength(Correos, 0);
  actual := FListaInbox^.Head;
  while actual <> nil do
  begin
    SetLength(Correos, Length(Correos)+1);
    Correos[High(Correos)] := actual;
    actual := actual^.Next;
  end;

  // Bubble sort por asunto (ascendente)         //Modificacion de ordenar de Z - A
  for i := 0 to High(Correos)-1 do
    for j := 0 to High(Correos)-i-1 do
      if CompareText(Correos[j]^.asunto, Correos[j+1]^.asunto) < 0 then //Modificacion pacambiar la comparacion y odenar de Z a A
      begin
        temp := Correos[j];
        Correos[j] := Correos[j+1];
        Correos[j+1] := temp;
      end;

  // Reconstruir la lista doble
  FListaInbox^.Head := Correos[0];
  FListaInbox^.Head^.Prev := nil;
  for i := 1 to High(Correos) do
  begin
    Correos[i]^.Prev := Correos[i-1];
    Correos[i-1]^.Next := Correos[i];
  end;
  Correos[High(Correos)]^.Next := nil;

  // Recargar lista visual
  CargarCorreos;
end;


procedure TfrmBandejaEntrada.btnEliminarClick(Sender: TObject);
var
  item: TListItem;
  nodo: PNodeMsg;
  usuario: TDataUser;
begin
  if lvCorreos.ItemIndex = -1 then Exit;
  item := lvCorreos.Items[lvCorreos.ItemIndex];
  nodo := PNodeMsg(item.Data);

  // Obtener datos del usuario
  usuario := SSL_GETBYEMAIL(FUsuarioEmail);

  // Agregar a la pila de Papelera
  if usuario.Papelera = nil then
    New(usuario.Papelera);
  Push(usuario.Papelera, nodo);

  // Remover del DLL (Inbox)
  if nodo^.Prev <> nil then nodo^.Prev^.Next := nodo^.Next;
  if nodo^.Next <> nil then nodo^.Next^.Prev := nodo^.Prev;
  if nodo = FListaInbox^.Head then FListaInbox^.Head := nodo^.Next;
  if nodo = FListaInbox^.Last then FListaInbox^.Last := nodo^.Prev;

  // No hacer Dispose, la pila mantiene la referencia

  CargarCorreos;
end;


end.

