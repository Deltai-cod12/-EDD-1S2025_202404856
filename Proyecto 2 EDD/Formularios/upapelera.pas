unit uPapelera;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  DLL_CON, UPila, SLL;

type

  { TfrmPapelera }

  TfrmPapelera = class(TForm)
    lvPapelera: TListView;
    btnEliminar: TButton;
    btnBuscar: TButton;
    edtBuscar: TEdit;
    lblBuscar: TLabel;
    procedure btnBuscarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FPila: PPila;
    FUsuario: TDataUser;
    procedure CargarPapelera;
  public
    procedure SetUsuario(const usuario: TDataUser);
  end;

var
  frmPapelera: TfrmPapelera;

implementation

{$R *.lfm}

procedure TfrmPapelera.SetUsuario(const usuario: TDataUser);
begin
  FUsuario := usuario;
  FPila := FUsuario.Papelera;
  CargarPapelera;
end;

procedure TfrmPapelera.FormCreate(Sender: TObject);
begin
  Caption := 'Papelera';
  lvPapelera.ViewStyle := vsReport;
  lvPapelera.Columns.Add.Caption := 'ID';
  lvPapelera.Columns.Add.Caption := 'Remitente';
  lvPapelera.Columns.Add.Caption := 'Asunto';
  lvPapelera.Columns.Add.Caption := 'Fecha';
end;

procedure TfrmPapelera.CargarPapelera;
var
  actual: PNodoPila;
  item: TListItem;
begin
  lvPapelera.Items.Clear;
  if (FPila = nil) or (FPila^.Top = nil) then Exit;

  actual := FPila^.Top;
  while actual <> nil do
  begin
    item := lvPapelera.Items.Add;
    item.Caption := actual^.correo^.id;
    item.SubItems.Add(actual^.correo^.remitente);
    item.SubItems.Add(actual^.correo^.asunto);
    item.SubItems.Add(actual^.correo^.fecha);
    actual := actual^.Next;
  end;
end;

procedure TfrmPapelera.btnBuscarClick(Sender: TObject);
var
  palabra: string;
  actual: PNodoPila;
  item: TListItem;
begin
  palabra := Trim(edtBuscar.Text);
  lvPapelera.Items.Clear;
  if (FPila = nil) or (FPila^.Top = nil) then Exit;

  actual := FPila^.Top;
  while actual <> nil do
  begin
    if Pos(LowerCase(palabra), LowerCase(actual^.correo^.asunto)) > 0 then
    begin
      item := lvPapelera.Items.Add;
      item.Caption := actual^.correo^.id;
      item.SubItems.Add(actual^.correo^.remitente);
      item.SubItems.Add(actual^.correo^.asunto);
      item.SubItems.Add(actual^.correo^.fecha);
    end;
    actual := actual^.Next;
  end;
end;

procedure TfrmPapelera.btnEliminarClick(Sender: TObject);
var
  correo: PNodeMsg;
begin
  if (FPila = nil) or (FPila^.Top = nil) then
  begin
    ShowMessage('No hay correos para eliminar');
    Exit;
  end;

  correo := Pop(FPila);
  ShowMessage('Correo "' + correo^.asunto + '" eliminado permanentemente.');
  CargarPapelera;
end;

end.

