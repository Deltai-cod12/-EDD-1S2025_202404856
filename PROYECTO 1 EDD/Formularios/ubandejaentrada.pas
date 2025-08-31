unit uBandejaEntrada;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  Buttons, uListaSimpleUsuarios, uListaDobleCorreos;

type

  { TfrmBandejaEntrada }

  TfrmBandejaEntrada = class(TForm)
    btnOrdenar: TButton;
    btnMarcarLeido: TButton;
    btnEliminar: TButton;
    btnResponder: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    lblNoLeidos: TLabel;
    MemoMensaje: TMemo;
    sgCorreos: TStringGrid;
    procedure btnEliminarClick(Sender: TObject);
    procedure btnMarcarLeidoClick(Sender: TObject);
    procedure btnOrdenarClick(Sender: TObject);
    procedure btnResponderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgCorreosSelection(Sender: TObject; aCol, aRow: Integer);
  private
    ListaCorreos: TListaCorreos;
    CorreoSeleccionado: PCorreo;
    procedure CargarCorreos;
    procedure ActualizarContadorNoLeidos;
    procedure MostrarCorreo(correo: PCorreo);
  public
    UsuarioActual: TUsuario;
  end;

var
  frmBandejaEntrada: TfrmBandejaEntrada;

implementation

{$R *.lfm}

{ TfrmBandejaEntrada }

procedure TfrmBandejaEntrada.FormCreate(Sender: TObject);
begin
  Caption := 'Bandeja de Entrada - ' + UsuarioActual.nombre;
  Label1.Caption := 'Correos recibidos:';

  // Configurar StringGrid
  sgCorreos.ColCount := 4;
  sgCorreos.RowCount := 1;
  sgCorreos.Cells[0, 0] := 'ID';
  sgCorreos.Cells[1, 0] := 'Estado';
  sgCorreos.Cells[2, 0] := 'Asunto';
  sgCorreos.Cells[3, 0] := 'Remitente';
  sgCorreos.Options := sgCorreos.Options + [goRowSelect];

  // Configurar botones
  btnOrdenar.Caption := 'Ordenar por Asunto (A-Z)';
  btnMarcarLeido.Caption := 'Marcar como Leído';
  btnEliminar.Caption := 'Eliminar';
  btnResponder.Caption := 'Responder';

  // Inicializar lista de correos
  ListaCorreos := TListaCorreos.Create;
  CorreoSeleccionado := nil;

  // Cargar algunos correos de ejemplo
  ListaCorreos.InsertarAlFinal('admin@edd.com', UsuarioActual.email, 'N',
    False, 'Bienvenido a EDDMail', Now, 'Bienvenido al sistema de correo EDDMail');
  ListaCorreos.InsertarAlFinal('soporte@edd.com', UsuarioActual.email, 'N',
    False, 'Configuración inicial', Now - 1, 'Complete su perfil para mejores resultados');

  CargarCorreos;
  ActualizarContadorNoLeidos;
end;

procedure TfrmBandejaEntrada.FormDestroy(Sender: TObject);
begin
  ListaCorreos.Free;
end;

procedure TfrmBandejaEntrada.CargarCorreos;
var
  i: Integer;
  correo: PCorreo;
  estadoStr: string;
begin
  // Limpiar grid
  sgCorreos.RowCount := 1;

  // Cargar correos en el grid
  correo := ListaCorreos.ObtenerPrimero;
  i := 1;

  while correo <> nil do
  begin
    if correo^.destinatario = UsuarioActual.email then
    begin
      // Determinar el estado como texto
      if correo^.estado = 'L' then
        estadoStr := 'Leído'
      else
        estadoStr := 'No leído';

      sgCorreos.RowCount := sgCorreos.RowCount + 1;
      sgCorreos.Cells[0, i] := IntToStr(correo^.id);
      sgCorreos.Cells[1, i] := estadoStr;
      sgCorreos.Cells[2, i] := correo^.asunto;
      sgCorreos.Cells[3, i] := correo^.remitente;
      Inc(i);
    end;
    correo := ListaCorreos.ObtenerSiguiente(correo);
  end;
end;

procedure TfrmBandejaEntrada.ActualizarContadorNoLeidos;
begin
  lblNoLeidos.Caption := 'Correos no leídos: ' + IntToStr(ListaCorreos.ContarNoLeidos);
end;

procedure TfrmBandejaEntrada.MostrarCorreo(correo: PCorreo);
begin
  if correo = nil then
  begin
    MemoMensaje.Text := '';
    Exit;
  end;

  MemoMensaje.Text :=
    'De: ' + correo^.remitente + #13#10 +
    'Para: ' + correo^.destinatario + #13#10 +
    'Asunto: ' + correo^.asunto + #13#10 +
    'Fecha: ' + FormatDateTime('dd/mm/yyyy hh:nn', correo^.fecha) + #13#10 +
    #13#10 + correo^.mensaje;

  // Marcar como leído si no lo está
  if correo^.estado = 'N' then
  begin
    correo^.estado := 'L';
    ActualizarContadorNoLeidos;
  end;
end;

procedure TfrmBandejaEntrada.sgCorreosSelection(Sender: TObject; aCol, aRow: Integer);
var
  id: Integer;
begin
  if aRow < 1 then Exit;

  try
    id := StrToInt(sgCorreos.Cells[0, aRow]);
    CorreoSeleccionado := ListaCorreos.BuscarPorId(id);
    MostrarCorreo(CorreoSeleccionado);
  except
    on E: Exception do
      ShowMessage('Error al cargar correo: ' + E.Message);
  end;
end;

procedure TfrmBandejaEntrada.btnOrdenarClick(Sender: TObject);
begin
  ListaCorreos.OrdenarPorAsunto;
  CargarCorreos;
  ShowMessage('Correos ordenados por asunto (A-Z)');
end;

procedure TfrmBandejaEntrada.btnMarcarLeidoClick(Sender: TObject);
begin
  if CorreoSeleccionado <> nil then
  begin
    CorreoSeleccionado^.estado := 'L';
    // Actualizar la visualización
    CargarCorreos;
    ActualizarContadorNoLeidos;
    ShowMessage('Correo marcado como leído');
  end
  else
  begin
    ShowMessage('Seleccione un correo primero');
  end;
end;

procedure TfrmBandejaEntrada.btnEliminarClick(Sender: TObject);
begin
  if CorreoSeleccionado <> nil then
  begin
    if MessageDlg('Confirmar', '¿Está seguro de eliminar este correo?',
       mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      ListaCorreos.Eliminar(CorreoSeleccionado^.id);
      CargarCorreos;
      MemoMensaje.Text := '';
      ShowMessage('Correo eliminado');
    end;
  end
  else
  begin
    ShowMessage('Seleccione un correo primero');
  end;
end;

procedure TfrmBandejaEntrada.btnResponderClick(Sender: TObject);
begin
  if CorreoSeleccionado <> nil then
  begin
    // Aquí se abriría el formulario de enviar correo con los datos prellenados
    ShowMessage('Funcionalidad de respuesta en desarrollo');
  end
  else
  begin
    ShowMessage('Seleccione un correo primero');
  end;
end;

end.
