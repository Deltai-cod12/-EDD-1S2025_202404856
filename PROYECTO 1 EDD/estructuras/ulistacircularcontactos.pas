unit uListaCircularContactos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uListaSimpleUsuarios;

type
  PContacto = ^TContacto;
  TContacto = record
    usuario: TUsuario;
    siguiente: PContacto;
  end;

  { TListaCircularContactos }

  TListaCircularContactos = class
  private
    cabeza: PContacto;
    actual: PContacto;
    function CrearNodo(usuario: TUsuario): PContacto;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Insertar(usuario: TUsuario);
    procedure Eliminar(email: string);
    function Buscar(email: string): PContacto;
    function EsVacia: Boolean;
    function ToString: string; override;
    // Para navegación circular
    function ObtenerPrimero: TUsuario;
    function ObtenerSiguiente: TUsuario;
    function ObtenerAnterior: TUsuario;
    procedure ReiniciarCursor;
    procedure GenerarReporte(ruta: string; propietario: string);
  end;

implementation

{ TListaCircularContactos }

constructor TListaCircularContactos.Create;
begin
  cabeza := nil;
  actual := nil;
end;

destructor TListaCircularContactos.Destroy;
var
  temp, siguiente: PContacto;
begin
  if not EsVacia then
  begin
    temp := cabeza^.siguiente;
    while temp <> cabeza do
    begin
      siguiente := temp^.siguiente;
      Dispose(temp);
      temp := siguiente;
    end;
    Dispose(cabeza);
  end;
  inherited Destroy;
end;

function TListaCircularContactos.CrearNodo(usuario: TUsuario): PContacto;
var
  nuevo: PContacto;
begin
  New(nuevo);
  nuevo^.usuario := usuario;
  nuevo^.siguiente := nil;
  Result := nuevo;
end;

procedure TListaCircularContactos.Insertar(usuario: TUsuario);
var
  nuevo, temp: PContacto;
begin
  nuevo := CrearNodo(usuario);

  if cabeza = nil then
  begin
    cabeza := nuevo;
    cabeza^.siguiente := cabeza; // Circular
    actual := cabeza;
  end
  else
  begin
    // Insertar al final
    temp := cabeza;
    while temp^.siguiente <> cabeza do
      temp := temp^.siguiente;

    temp^.siguiente := nuevo;
    nuevo^.siguiente := cabeza;
  end;
end;

procedure TListaCircularContactos.Eliminar(email: string);
var
  temp, anterior: PContacto;
begin
  if EsVacia then Exit;

  // Caso especial: eliminar cabeza
  if LowerCase(cabeza^.usuario.email) = LowerCase(email) then
  begin
    if cabeza^.siguiente = cabeza then
    begin
      Dispose(cabeza);
      cabeza := nil;
      actual := nil;
    end
    else
    begin
      temp := cabeza;
      while temp^.siguiente <> cabeza do
        temp := temp^.siguiente;

      temp^.siguiente := cabeza^.siguiente;
      Dispose(cabeza);
      cabeza := temp^.siguiente;
    end;
    Exit;
  end;

  // Buscar nodo a eliminar
  anterior := cabeza;
  temp := cabeza^.siguiente;

  while (temp <> cabeza) and (LowerCase(temp^.usuario.email) <> LowerCase(email)) do
  begin
    anterior := temp;
    temp := temp^.siguiente;
  end;

  if temp <> cabeza then
  begin
    anterior^.siguiente := temp^.siguiente;
    Dispose(temp);
  end;
end;

function TListaCircularContactos.Buscar(email: string): PContacto;
var
  temp: PContacto;
begin
  if EsVacia then Exit(nil);

  temp := cabeza;
  repeat
    if LowerCase(temp^.usuario.email) = LowerCase(email) then
      Exit(temp);
    temp := temp^.siguiente;
  until temp = cabeza;

  Result := nil;
end;

function TListaCircularContactos.EsVacia: Boolean;
begin
  Result := (cabeza = nil);
end;

function TListaCircularContactos.ToString: string;
var
  temp: PContacto;
begin
  Result := '';
  if EsVacia then Exit;

  temp := cabeza;
  repeat
    Result := Result + temp^.usuario.nombre + ' (' + temp^.usuario.email + ')' + #13#10;
    temp := temp^.siguiente;
  until temp = cabeza;
end;

function TListaCircularContactos.ObtenerPrimero: TUsuario;
begin
  if not EsVacia then
  begin
    actual := cabeza;
    Result := cabeza^.usuario;
  end
  else
    FillChar(Result, SizeOf(TUsuario), 0);
end;

function TListaCircularContactos.ObtenerSiguiente: TUsuario;
begin
  if not EsVacia then
  begin
    actual := actual^.siguiente;
    Result := actual^.usuario;
  end
  else
    FillChar(Result, SizeOf(TUsuario), 0);
end;

function TListaCircularContactos.ObtenerAnterior: TUsuario;
var
  temp: PContacto;
begin
  if EsVacia then
  begin
    FillChar(Result, SizeOf(TUsuario), 0);
    Exit;
  end;

  // Encontrar el nodo anterior
  temp := cabeza;
  while temp^.siguiente <> actual do
    temp := temp^.siguiente;

  actual := temp;
  Result := actual^.usuario;
end;

procedure TListaCircularContactos.ReiniciarCursor;
begin
  actual := cabeza;
end;

procedure TListaCircularContactos.GenerarReporte(ruta: string; propietario: string);
var
  temp: PContacto;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Add('REPORTE DE CONTACTOS - ' + propietario);
    sl.Add('==============================');
    sl.Add('');

    if not EsVacia then
    begin
      temp := cabeza;
      repeat
        sl.Add('ID: ' + IntToStr(temp^.usuario.id));
        sl.Add('Nombre: ' + temp^.usuario.nombre);
        sl.Add('Usuario: ' + temp^.usuario.usuario);
        sl.Add('Email: ' + temp^.usuario.email);
        sl.Add('Teléfono: ' + temp^.usuario.telefono);
        sl.Add('----------------------------------');
        temp := temp^.siguiente;
      until temp = cabeza;
    end
    else
    begin
      sl.Add('No hay contactos en la lista.');
    end;

    ForceDirectories(ExtractFilePath(ruta));
    sl.SaveToFile(ruta);
  finally
    sl.Free;
  end;
end;

end.
