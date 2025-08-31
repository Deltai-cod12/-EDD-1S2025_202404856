unit uPilaPapelera;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uListaDobleCorreos;

type
  PNodoPila = ^TNodoPila;
  TNodoPila = record
    correo: PCorreo;
    siguiente: PNodoPila;
  end;

  { TPilaPapelera }

  TPilaPapelera = class
  private
    tope: PNodoPila;
    function CrearNodo(correo: PCorreo): PNodoPila;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Push(correo: PCorreo);
    function Pop: PCorreo;
    function Top: PCorreo;
    function EsVacia: Boolean;
    function ToString: string; override;
    function BuscarPorAsunto(asunto: string): PCorreo;
    procedure GenerarReporte(ruta: string);
  end;

implementation

{ TPilaPapelera }

constructor TPilaPapelera.Create;
begin
  tope := nil;
end;

destructor TPilaPapelera.Destroy;
begin
  while not EsVacia do
    Pop;
  inherited Destroy;
end;

function TPilaPapelera.CrearNodo(correo: PCorreo): PNodoPila;
var
  nuevo: PNodoPila;
begin
  New(nuevo);
  nuevo^.correo := correo;
  nuevo^.siguiente := nil;
  Result := nuevo;
end;

procedure TPilaPapelera.Push(correo: PCorreo);
var
  nuevo: PNodoPila;
begin
  nuevo := CrearNodo(correo);
  nuevo^.siguiente := tope;
  tope := nuevo;
end;

function TPilaPapelera.Pop: PCorreo;
var
  temp: PNodoPila;
begin
  if EsVacia then
    Exit(nil);

  temp := tope;
  Result := temp^.correo;
  tope := tope^.siguiente;
  Dispose(temp);
end;

function TPilaPapelera.Top: PCorreo;
begin
  if not EsVacia then
    Result := tope^.correo
  else
    Result := nil;
end;

function TPilaPapelera.EsVacia: Boolean;
begin
  Result := (tope = nil);
end;

function TPilaPapelera.ToString: string;
var
  actual: PNodoPila;
begin
  Result := '';
  actual := tope;
  while actual <> nil do
  begin
    Result := Result + actual^.correo^.asunto + #13#10;
    actual := actual^.siguiente;
  end;
end;

function TPilaPapelera.BuscarPorAsunto(asunto: string): PCorreo;
var
  actual: PNodoPila;
begin
  actual := tope;
  while actual <> nil do
  begin
    if Pos(LowerCase(asunto), LowerCase(actual^.correo^.asunto)) > 0 then
      Exit(actual^.correo);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

procedure TPilaPapelera.GenerarReporte(ruta: string);
var
  actual: PNodoPila;
  sl: TStringList;
  estadoStr, programadoStr: string;
begin
  sl := TStringList.Create;
  try
    sl.Add('REPORTE DE PAPELERA');
    sl.Add('===================');
    sl.Add('');

    actual := tope;
    while actual <> nil do
    begin
      // Convertir valores a texto
      if actual^.correo^.estado = 'L' then
        estadoStr := 'Leído'
      else
        estadoStr := 'No leído';

      if actual^.correo^.programado then
        programadoStr := 'Sí'
      else
        programadoStr := 'No';

      sl.Add('ID: ' + IntToStr(actual^.correo^.id));
      sl.Add('Remitente: ' + actual^.correo^.remitente);
      sl.Add('Destinatario: ' + actual^.correo^.destinatario);
      sl.Add('Estado: ' + estadoStr);
      sl.Add('Programado: ' + programadoStr);
      sl.Add('Asunto: ' + actual^.correo^.asunto);
      sl.Add('Fecha: ' + FormatDateTime('yyyy-mm-dd hh:nn', actual^.correo^.fecha));
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

end.
