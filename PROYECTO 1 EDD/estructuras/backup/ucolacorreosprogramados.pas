unit uColaCorreosProgramados;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uListaDobleCorreos;

type
  PNodoCola = ^TNodoCola;
  TNodoCola = record
    correo: PCorreo;
    siguiente: PNodoCola;
  end;

  { TColaCorreosProgramados }

  TColaCorreosProgramados = class
  private
    frente, final: PNodoCola;
    function CrearNodo(correo: PCorreo): PNodoCola;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Encolar(correo: PCorreo);
    function Desencolar: PCorreo;
    function Frente: PCorreo;
    function EsVacia: Boolean;
    function ToString: string; override;
    procedure GenerarReporte(ruta: string);
    procedure ProcesarCola; // Para enviar correos programados
  end;

implementation

{ TColaCorreosProgramados }

constructor TColaCorreosProgramados.Create;
begin
  frente := nil;
  final := nil;
end;

destructor TColaCorreosProgramados.Destroy;
begin
  while not EsVacia do
    Desencolar;
  inherited Destroy;
end;

function TColaCorreosProgramados.CrearNodo(correo: PCorreo): PNodoCola;
var
  nuevo: PNodoCola;
begin
  New(nuevo);
  nuevo^.correo := correo;
  nuevo^.siguiente := nil;
  Result := nuevo;
end;

procedure TColaCorreosProgramados.Encolar(correo: PCorreo);
var
  nuevo: PNodoCola;
begin
  nuevo := CrearNodo(correo);

  if EsVacia then
    frente := nuevo
  else
    final^.siguiente := nuevo;

  final := nuevo;
end;

function TColaCorreosProgramados.Desencolar: PCorreo;
var
  temp: PNodoCola;
begin
  if EsVacia then
    Exit(nil);

  temp := frente;
  Result := temp^.correo;
  frente := frente^.siguiente;

  if frente = nil then
    final := nil;

  Dispose(temp);
end;

function TColaCorreosProgramados.Frente: PCorreo;
begin
  if not EsVacia then
    Result := frente^.correo
  else
    Result := nil;
end;

function TColaCorreosProgramados.EsVacia: Boolean;
begin
  Result := (frente = nil);
end;

function TColaCorreosProgramados.ToString: string;
var
  actual: PNodoCola;
begin
  Result := '';
  actual := frente;
  while actual <> nil do
  begin
    Result := Result + actual^.correo^.asunto + ' -> ';
    actual := actual^.siguiente;
  end;
  Result := Result + 'NIL';
end;

procedure TColaCorreosProgramados.GenerarReporte(ruta: string);
var
  actual: PNodoCola;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Add('REPORTE DE CORREOS PROGRAMADOS');
    sl.Add('==============================');
    sl.Add('');

    actual := frente;
    while actual <> nil do
    begin
      sl.Add('ID: ' + IntToStr(actual^.correo^.id));
      sl.Add('Remitente: ' + actual^.correo^.remitente);
      sl.Add('Destinatario: ' + actual^.correo^.destinatario);
      sl.Add('Asunto: ' + actual^.correo^.asunto);
      sl.Add('Fecha programada: ' + FormatDateTime('yyyy-mm-dd hh:nn', actual^.correo^.fecha));
      sl.Add('Mensaje: ' + actual^.correo^.mensaje);
      sl.Add('----------------------------------');
      actual := actual^.siguiente;
    end;

    ForceDirectories(ExtractFilePath(ruta));
    sl.SaveToFile(ruta);
  finally
    sl.Free;
  end;
end;

procedure TColaCorreosProgramados.ProcesarCola;
var
  ahora: TDateTime;
  correo: PCorreo;
begin
  ahora := Now;
  while (not EsVacia) and (Frente^.correo^.fecha <= ahora) do
  begin
    correo := Desencolar;
    // Aquí iría la lógica para enviar el correo
    // Por ahora solo lo liberamos
    Dispose(correo);
  end;
end;

end.
