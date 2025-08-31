unit uListaDobleCorreos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, Dialogs, StrUtils;

type
  PCorreo = ^TCorreo;
  TCorreo = record
    id: Integer;
    remitente: string;
    destinatario: string;
    estado: Char; // 'L' = Leído, 'N' = No leído
    programado: Boolean;
    asunto: string;
    fecha: TDateTime;
    mensaje: string;
    anterior, siguiente: PCorreo;
  end;

  { TListaCorreos }

  TListaCorreos = class
  private
    cabeza, cola: PCorreo;
    contadorId: Integer;
    function CrearNodo(id: Integer; remitente, destinatario: string; estado: Char;
      programado: Boolean; asunto: string; fecha: TDateTime; mensaje: string): PCorreo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InsertarAlFinal(remitente, destinatario: string; estado: Char;
      programado: Boolean; asunto: string; fecha: TDateTime; mensaje: string);
    procedure Eliminar(id: Integer);
    function BuscarPorId(id: Integer): PCorreo;
    function BuscarPorAsunto(asunto: string): PCorreo;
    procedure OrdenarPorAsunto;
    function ContarNoLeidos: Integer;
    procedure GenerarReporte(ruta: string; usuario: string);
    function EsVacia: Boolean;
    function ObtenerSiguienteId: Integer;
    function ToString: string; override;
    // Para iteración
    function ObtenerPrimero: PCorreo;
    function ObtenerSiguiente(actual: PCorreo): PCorreo;
  end;

implementation

{ TListaCorreos }

constructor TListaCorreos.Create;
begin
  cabeza := nil;
  cola := nil;
  contadorId := 1;
end;

destructor TListaCorreos.Destroy;
var
  actual, temp: PCorreo;
begin
  actual := cabeza;
  while actual <> nil do
  begin
    temp := actual;
    actual := actual^.siguiente;
    Dispose(temp);
  end;
  inherited Destroy;
end;

function TListaCorreos.CrearNodo(id: Integer; remitente, destinatario: string;
  estado: Char; programado: Boolean; asunto: string; fecha: TDateTime;
  mensaje: string): PCorreo;
var
  nuevo: PCorreo;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.remitente := remitente;
  nuevo^.destinatario := destinatario;
  nuevo^.estado := estado;
  nuevo^.programado := programado;
  nuevo^.asunto := asunto;
  nuevo^.fecha := fecha;
  nuevo^.mensaje := mensaje;
  nuevo^.anterior := nil;
  nuevo^.siguiente := nil;
  Result := nuevo;
end;

procedure TListaCorreos.InsertarAlFinal(remitente, destinatario: string;
  estado: Char; programado: Boolean; asunto: string; fecha: TDateTime;
  mensaje: string);
var
  nuevo: PCorreo;
begin
  nuevo := CrearNodo(contadorId, remitente, destinatario, estado, programado, asunto, fecha, mensaje);
  Inc(contadorId);

  if cabeza = nil then
  begin
    cabeza := nuevo;
    cola := nuevo;
  end
  else
  begin
    cola^.siguiente := nuevo;
    nuevo^.anterior := cola;
    cola := nuevo;
  end;
end;

procedure TListaCorreos.Eliminar(id: Integer);
var
  actual: PCorreo;
begin
  actual := BuscarPorId(id);
  if actual = nil then Exit;

  if actual^.anterior <> nil then
    actual^.anterior^.siguiente := actual^.siguiente;
  if actual^.siguiente <> nil then
    actual^.siguiente^.anterior := actual^.anterior;
  if actual = cabeza then
    cabeza := actual^.siguiente;
  if actual = cola then
    cola := actual^.anterior;

  Dispose(actual);
end;

function TListaCorreos.BuscarPorId(id: Integer): PCorreo;
var
  actual: PCorreo;
begin
  actual := cabeza;
  while actual <> nil do
  begin
    if actual^.id = id then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function TListaCorreos.BuscarPorAsunto(asunto: string): PCorreo;
var
  actual: PCorreo;
begin
  actual := cabeza;
  while actual <> nil do
  begin
    if Pos(LowerCase(asunto), LowerCase(actual^.asunto)) > 0 then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

procedure TListaCorreos.OrdenarPorAsunto;
// Implementación de ordenamiento por burbuja (se puede mejorar)
var
  actual, siguiente: PCorreo;
  temp: TCorreo;
  huboIntercambio: Boolean;
begin
  if (cabeza = nil) or (cabeza^.siguiente = nil) then Exit;

  repeat
    huboIntercambio := False;
    actual := cabeza;

    while actual^.siguiente <> nil do
    begin
      siguiente := actual^.siguiente;

      if CompareText(actual^.asunto, siguiente^.asunto) > 0 then
      begin
        // Intercambiar datos
        temp := actual^;
        actual^ := siguiente^;
        siguiente^ := temp;

        // Mantener punteros correctos
        siguiente^.siguiente := actual^.siguiente;
        siguiente^.anterior := actual^.anterior;
        actual^.siguiente := temp.siguiente;
        actual^.anterior := temp.anterior;

        huboIntercambio := True;
      end;

      actual := actual^.siguiente;
    end;
  until not huboIntercambio;
end;

function TListaCorreos.ContarNoLeidos: Integer;
var
  actual: PCorreo;
begin
  Result := 0;
  actual := cabeza;
  while actual <> nil do
  begin
    if actual^.estado = 'N' then
      Inc(Result);
    actual := actual^.siguiente;
  end;
end;

procedure TListaCorreos.GenerarReporte(ruta: string; usuario: string);
var
  actual: PCorreo;
  sl: TStringList;
  estadoStr, programadoStr: string;
begin
  sl := TStringList.Create;
  try
    sl.Add('REPORTE DE CORREOS RECIBIDOS - ' + usuario);
    sl.Add('==========================================');
    sl.Add('');

    actual := cabeza;
    while actual <> nil do
    begin
      if actual^.destinatario = usuario then
      begin
        // Convertir valores booleanos a texto
        if actual^.estado = 'L' then
          estadoStr := 'Leído'
        else
          estadoStr := 'No leído';

        if actual^.programado then
          programadoStr := 'Sí'
        else
          programadoStr := 'No';

        sl.Add('ID: ' + IntToStr(actual^.id));
        sl.Add('Remitente: ' + actual^.remitente);
        sl.Add('Estado: ' + estadoStr);
        sl.Add('Programado: ' + programadoStr);
        sl.Add('Asunto: ' + actual^.asunto);
        sl.Add('Fecha: ' + FormatDateTime('yyyy-mm-dd hh:nn', actual^.fecha));
        sl.Add('Mensaje: ' + actual^.mensaje);
        sl.Add('----------------------------------');
      end;
      actual := actual^.siguiente;
    end;

    ForceDirectories(ExtractFilePath(ruta));
    sl.SaveToFile(ruta);
  finally
    sl.Free;
  end;
end;

function TListaCorreos.EsVacia: Boolean;
begin
  Result := (cabeza = nil);
end;

function TListaCorreos.ObtenerSiguienteId: Integer;
begin
  Result := contadorId;
end;

function TListaCorreos.ToString: string;
var
  actual: PCorreo;
begin
  Result := '';
  actual := cabeza;
  while actual <> nil do
  begin
    Result := Result + actual^.asunto + ' (' + FormatDateTime('dd/mm', actual^.fecha) + ')' + #13#10;
    actual := actual^.siguiente;
  end;
end;

function TListaCorreos.ObtenerPrimero: PCorreo;
begin
  Result := cabeza;
end;

function TListaCorreos.ObtenerSiguiente(actual: PCorreo): PCorreo;
begin
  if actual <> nil then
    Result := actual^.siguiente
  else
    Result := nil;
end;

end.
