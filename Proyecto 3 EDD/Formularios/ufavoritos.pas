unit uFavoritos;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  SLL, UBTree, Process; // UBTree: TMail, PNodoB, BuscarB, InOrdenBLista, EliminarBTree

type
  { TfrmFavoritos }
  TfrmFavoritos = class(TForm)
    lblTotal: TLabel;
    lblDetalle: TLabel;
    lblRemitente: TLabel;
    lblAsunto: TLabel;
    lblFecha: TLabel;
    memoMensaje: TMemo;
    gridFavoritos: TStringGrid;
    btnEliminar: TButton;
    btnReporte: TButton;

    procedure FormShow(Sender: TObject);
    procedure gridFavoritosSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnReporteClick(Sender: TObject);

  private
    FUsuario: TDataUser;
    FCorreoSeleccionado: string; // ID del correo seleccionado
    procedure CargarFavoritos;
    procedure MostrarDetalles(const id: string);
    procedure LimpiarDetalles;
  public
    procedure SetUsuarioEmail(const email: string);
  end;

var
  frmFavoritos: TfrmFavoritos;

implementation

{$R *.lfm}

{ TfrmFavoritos }

procedure TfrmFavoritos.SetUsuarioEmail(const email: string);
begin
  FUsuario := SSL_GETBYEMAIL(email);
end;

procedure TfrmFavoritos.CargarFavoritos;
var
  lista: TStringList;
  i: Integer;
  partes: TStringArray;
begin
  gridFavoritos.RowCount := 1;
  lista := TStringList.Create;
  try
    if (FUsuario.Favoritos <> nil) and (FUsuario.Favoritos^.raiz <> nil) then
    begin
      InOrdenBLista(FUsuario.Favoritos^.raiz, lista);

      gridFavoritos.RowCount := lista.Count + 1;
      for i := 0 to lista.Count - 1 do
      begin
        partes := lista[i].Split(['|']);
        if Length(partes) >= 3 then
        begin
          gridFavoritos.Cells[0, i+1] := partes[0];
          gridFavoritos.Cells[1, i+1] := partes[1];
          gridFavoritos.Cells[2, i+1] := partes[2];
        end;
      end;

      lblTotal.Caption := 'Total favoritos: ' + IntToStr(lista.Count);
    end
    else
      lblTotal.Caption := 'Total favoritos: 0';
  finally
    lista.Free;
  end;
end;

procedure TfrmFavoritos.MostrarDetalles(const id: string);
var
  correo: TMail;
begin
  correo := BuscarB(FUsuario.Favoritos^.raiz, id);
  if correo.id <> '' then
  begin
    lblRemitente.Caption := 'Remitente: ' + correo.remitente;
    lblAsunto.Caption := 'Asunto: ' + correo.asunto;
    lblFecha.Caption := 'Fecha: '; // puedes ajustar si tu TMail incluye fecha
    memoMensaje.Text := correo.mensaje;
    FCorreoSeleccionado := correo.id;
  end;
end;

procedure TfrmFavoritos.LimpiarDetalles;
begin
  lblRemitente.Caption := 'Remitente:';
  lblAsunto.Caption := 'Asunto:';
  lblFecha.Caption := 'Fecha:';
  memoMensaje.Clear;
  FCorreoSeleccionado := '';
end;

procedure TfrmFavoritos.FormShow(Sender: TObject);
begin
  gridFavoritos.ColCount := 3;
  gridFavoritos.RowCount := 1;
  gridFavoritos.FixedRows := 1;
  gridFavoritos.Cells[0,0] := 'ID';
  gridFavoritos.Cells[1,0] := 'Asunto';
  gridFavoritos.Cells[2,0] := 'Remitente';

  CargarFavoritos;
  LimpiarDetalles;
end;

procedure TfrmFavoritos.gridFavoritosSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
  id: string;
begin
  if aRow > 0 then
  begin
    id := gridFavoritos.Cells[0,aRow];
    if id <> '' then
      MostrarDetalles(id);
  end;
end;

procedure TfrmFavoritos.btnEliminarClick(Sender: TObject);
begin
  if FCorreoSeleccionado = '' then
  begin
    ShowMessage('Seleccione un correo primero.');
    Exit;
  end;

  EliminarBTree(FUsuario.Favoritos^.raiz, FCorreoSeleccionado);

  ShowMessage('Correo eliminado de favoritos.');
  LimpiarDetalles;
  CargarFavoritos;
end;

// ==================== NUEVO: GENERAR REPORTE ====================
procedure TfrmFavoritos.btnReporteClick(Sender: TObject);
var
  dotFile, pngFile: string;
  Output: AnsiString;
begin
  if (FUsuario.Favoritos = nil) or (FUsuario.Favoritos^.raiz = nil) then
  begin
    ShowMessage('No hay favoritos para graficar.');
    Exit;
  end;

  if not DirectoryExists('Reportes') then
    CreateDir('Reportes');

  dotFile := 'Reportes/Favoritos.dot';
  pngFile := 'Reportes/Favoritos.png';

  GenerarDOTB(FUsuario.Favoritos^.raiz, dotFile);

  if FileExists('/usr/bin/dot') then
  begin
    RunCommand('/usr/bin/dot', ['-Tpng', dotFile, '-o', pngFile], Output);
    ShowMessage('Reporte generado en: ' + pngFile);
  end
  else
    ShowMessage('Graphviz no está instalado o no se encuentra el ejecutable "dot".');
end;

end.

