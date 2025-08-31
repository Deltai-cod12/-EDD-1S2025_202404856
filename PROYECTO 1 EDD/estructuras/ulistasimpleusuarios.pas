unit uListaSimpleUsuarios;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, Dialogs;

type
  PUsuario = ^TUsuario;
  TUsuario = record
    id: Integer;
    nombre: string;
    usuario: string;
    password: string;
    email: string;
    telefono: string;
    siguiente: PUsuario;
  end;

  { TListaUsuarios }

  TListaUsuarios = class
  private
    cabeza: PUsuario;
    ultimo: PUsuario;
    contadorId: Integer;
    function CrearNodo(id: Integer; nombre, usuario, password, email, telefono: string): PUsuario;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Insertar(nombre, usuario, password, email, telefono: string);
    function BuscarPorEmail(email: string): PUsuario;
    function BuscarPorUsuario(usuario: string): PUsuario;
    function Autenticar(usuario, password: string): Boolean;
    procedure CargarDesdeJSON(archivo: string);
    procedure GenerarReporte(ruta: string);
    function ObtenerUsuarioPorEmail(email: string): TUsuario;
    function EsVacia: Boolean;
    function ObtenerSiguienteId: Integer;
    function ToString: string; override;
  end;

implementation

{ TListaUsuarios }

constructor TListaUsuarios.Create;
begin
  cabeza := nil;
  ultimo := nil;
  contadorId := 1;
  // Insertar usuario root por defecto
  Insertar('Administrador', 'root', 'root123', 'root@edd.com', '00000000');
end;

destructor TListaUsuarios.Destroy;
var
  actual, temp: PUsuario;
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

function TListaUsuarios.CrearNodo(id: Integer; nombre, usuario, password, email, telefono: string): PUsuario;
var
  nuevo: PUsuario;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.nombre := nombre;
  nuevo^.usuario := usuario;
  nuevo^.password := password;
  nuevo^.email := email;
  nuevo^.telefono := telefono;
  nuevo^.siguiente := nil;
  Result := nuevo;
end;

procedure TListaUsuarios.Insertar(nombre, usuario, password, email, telefono: string);
var
  nuevo: PUsuario;
begin
  nuevo := CrearNodo(contadorId, nombre, usuario, password, email, telefono);
  Inc(contadorId);

  if cabeza = nil then
  begin
    cabeza := nuevo;
    ultimo := nuevo;
  end
  else
  begin
    ultimo^.siguiente := nuevo;
    ultimo := nuevo;
  end;
end;

function TListaUsuarios.BuscarPorEmail(email: string): PUsuario;
var
  actual: PUsuario;
begin
  actual := cabeza;
  while actual <> nil do
  begin
    if LowerCase(actual^.email) = LowerCase(email) then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function TListaUsuarios.BuscarPorUsuario(usuario: string): PUsuario;
var
  actual: PUsuario;
begin
  actual := cabeza;
  while actual <> nil do
  begin
    if LowerCase(actual^.usuario) = LowerCase(usuario) then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function TListaUsuarios.Autenticar(usuario, password: string): Boolean;
var
  user: PUsuario;
begin
  user := BuscarPorUsuario(usuario);
  if (user <> nil) and (user^.password = password) then
    Result := True
  else
    Result := False;
end;

procedure TListaUsuarios.CargarDesdeJSON(archivo: string);
var
  jsonData: TJSONData;
  jsonArray: TJSONArray;
  i: Integer;
  usuarioObj: TJSONObject;
  fs: TFileStream;
  sl: TStringList;
begin
  if not FileExists(archivo) then
    Exit;

  try
    sl := TStringList.Create;
    sl.LoadFromFile(archivo);
    jsonData := GetJSON(sl.Text);

    if jsonData.JSONType = jtArray then
    begin
      jsonArray := TJSONArray(jsonData);

      for i := 0 to jsonArray.Count - 1 do
      begin
        usuarioObj := jsonArray.Objects[i];
        Insertar(
          usuarioObj.Get('nombre', ''),
          usuarioObj.Get('usuario', ''),
          usuarioObj.Get('password', ''),
          usuarioObj.Get('email', ''),
          usuarioObj.Get('telefono', '')
        );
      end;
    end;

    jsonData.Free;
    sl.Free;
  except
    on E: Exception do
      ShowMessage('Error al cargar JSON: ' + E.Message);
  end;
end;

procedure TListaUsuarios.GenerarReporte(ruta: string);
var
  actual: PUsuario;
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Add('REPORTE DE USUARIOS');
    sl.Add('===================');
    sl.Add('');

    actual := cabeza;
    while actual <> nil do
    begin
      sl.Add('ID: ' + IntToStr(actual^.id));
      sl.Add('Nombre: ' + actual^.nombre);
      sl.Add('Usuario: ' + actual^.usuario);
      sl.Add('Email: ' + actual^.email);
      sl.Add('Teléfono: ' + actual^.telefono);
      sl.Add('----------------------------------');
      actual := actual^.siguiente;
    end;

    ForceDirectories(ExtractFilePath(ruta));
    sl.SaveToFile(ruta);
  finally
    sl.Free;
  end;
end;

function TListaUsuarios.ObtenerUsuarioPorEmail(email: string): TUsuario;
var
  usuario: PUsuario;
begin
  usuario := BuscarPorEmail(email);
  if usuario <> nil then
    Result := usuario^
  else
    FillChar(Result, SizeOf(TUsuario), 0);
end;

function TListaUsuarios.EsVacia: Boolean;
begin
  Result := (cabeza = nil);
end;

function TListaUsuarios.ObtenerSiguienteId: Integer;
begin
  Result := contadorId;
end;

function TListaUsuarios.ToString: string;
var
  actual: PUsuario;
begin
  Result := '';
  actual := cabeza;
  while actual <> nil do
  begin
    Result := Result + actual^.nombre + ' (' + actual^.email + ')' + #13#10;
    actual := actual^.siguiente;
  end;
end;

end.
