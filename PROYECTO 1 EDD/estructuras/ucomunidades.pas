unit uComunidades;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uListaSimpleUsuarios;

type
  PComunidad = ^TComunidad;
  TComunidad = record
    id: Integer;
    nombre: string;
    siguiente: PComunidad;
  end;

  PMiembroComunidad = ^TMiembroComunidad;
  TMiembroComunidad = record
    usuario: TUsuario;
    siguiente: PMiembroComunidad;
  end;

  { TListaComunidades }

  TListaComunidades = class
  private
    cabezaComunidades: PComunidad;
    listasMiembros: array of PMiembroComunidad; // Lista de listas
    contadorId: Integer;
    function CrearNodoComunidad(id: Integer; nombre: string): PComunidad;
    function CrearNodoMiembro(usuario: TUsuario): PMiembroComunidad;
    function BuscarComunidadPorId(id: Integer): PComunidad;
    function BuscarComunidadPorNombre(nombre: string): PComunidad;
    function ObtenerIndiceComunidad(id: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CrearComunidad(nombre: string);
    procedure AgregarUsuarioAComunidad(idComunidad: Integer; usuario: TUsuario);
    procedure EliminarUsuarioDeComunidad(idComunidad: Integer; email: string);
    function ObtenerComunidadesPorUsuario(email: string): TStringList;
    function ObtenerUsuariosPorComunidad(idComunidad: Integer): TStringList;
    function ExisteUsuarioEnComunidad(idComunidad: Integer; email: string): Boolean;
    procedure GenerarReporte(ruta: string);
    function ToString: string; override;
  end;

implementation

{ TListaComunidades }

constructor TListaComunidades.Create;
begin
  cabezaComunidades := nil;
  contadorId := 1;
  SetLength(listasMiembros, 0);
end;

destructor TListaComunidades.Destroy;
var
  i: Integer;
  actualCom, tempCom: PComunidad;
  actualMiembro, tempMiembro: PMiembroComunidad;
begin
  // Liberar lista de comunidades
  actualCom := cabezaComunidades;
  while actualCom <> nil do
  begin
    tempCom := actualCom;
    actualCom := actualCom^.siguiente;
    Dispose(tempCom);
  end;

  // Liberar listas de miembros
  for i := 0 to High(listasMiembros) do
  begin
    actualMiembro := listasMiembros[i];
    while actualMiembro <> nil do
    begin
      tempMiembro := actualMiembro;
      actualMiembro := actualMiembro^.siguiente;
      Dispose(tempMiembro);
    end;
  end;

  SetLength(listasMiembros, 0);
  inherited Destroy;
end;

function TListaComunidades.CrearNodoComunidad(id: Integer; nombre: string): PComunidad;
var
  nuevo: PComunidad;
begin
  New(nuevo);
  nuevo^.id := id;
  nuevo^.nombre := nombre;
  nuevo^.siguiente := nil;
  Result := nuevo;
end;

function TListaComunidades.CrearNodoMiembro(usuario: TUsuario): PMiembroComunidad;
var
  nuevo: PMiembroComunidad;
begin
  New(nuevo);
  nuevo^.usuario := usuario;
  nuevo^.siguiente := nil;
  Result := nuevo;
end;

function TListaComunidades.BuscarComunidadPorId(id: Integer): PComunidad;
var
  actual: PComunidad;
begin
  actual := cabezaComunidades;
  while actual <> nil do
  begin
    if actual^.id = id then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function TListaComunidades.BuscarComunidadPorNombre(nombre: string): PComunidad;
var
  actual: PComunidad;
begin
  actual := cabezaComunidades;
  while actual <> nil do
  begin
    if LowerCase(actual^.nombre) = LowerCase(nombre) then
      Exit(actual);
    actual := actual^.siguiente;
  end;
  Result := nil;
end;

function TListaComunidades.ObtenerIndiceComunidad(id: Integer): Integer;
var
  i: Integer;
  actual: PComunidad;
begin
  actual := cabezaComunidades;
  i := 0;
  while actual <> nil do
  begin
    if actual^.id = id then
      Exit(i);
    Inc(i);
    actual := actual^.siguiente;
  end;
  Result := -1;
end;

procedure TListaComunidades.CrearComunidad(nombre: string);
var
  nuevo, actual: PComunidad;
  nuevoIndice: Integer;
begin
  if BuscarComunidadPorNombre(nombre) <> nil then
    Exit; // La comunidad ya existe

  nuevo := CrearNodoComunidad(contadorId, nombre);
  Inc(contadorId);

  if cabezaComunidades = nil then
    cabezaComunidades := nuevo
  else
  begin
    actual := cabezaComunidades;
    while actual^.siguiente <> nil do
      actual := actual^.siguiente;
    actual^.siguiente := nuevo;
  end;

  // Crear nueva lista de miembros para esta comunidad
  nuevoIndice := Length(listasMiembros);
  SetLength(listasMiembros, nuevoIndice + 1);
  listasMiembros[nuevoIndice] := nil;
end;

procedure TListaComunidades.AgregarUsuarioAComunidad(idComunidad: Integer; usuario: TUsuario);
var
  indice: Integer;
  nuevo, actual: PMiembroComunidad;
begin
  indice := ObtenerIndiceComunidad(idComunidad);
  if indice = -1 then
    Exit; // Comunidad no existe

  // Verificar si el usuario ya está en la comunidad
  if ExisteUsuarioEnComunidad(idComunidad, usuario.email) then
    Exit;

  nuevo := CrearNodoMiembro(usuario);

  if listasMiembros[indice] = nil then
    listasMiembros[indice] := nuevo
  else
  begin
    actual := listasMiembros[indice];
    while actual^.siguiente <> nil do
      actual := actual^.siguiente;
    actual^.siguiente := nuevo;
  end;
end;

procedure TListaComunidades.EliminarUsuarioDeComunidad(idComunidad: Integer; email: string);
var
  indice: Integer;
  actual, anterior: PMiembroComunidad;
begin
  indice := ObtenerIndiceComunidad(idComunidad);
  if indice = -1 then
    Exit;

  actual := listasMiembros[indice];
  anterior := nil;

  while actual <> nil do
  begin
    if actual^.usuario.email = email then
    begin
      if anterior = nil then
        listasMiembros[indice] := actual^.siguiente
      else
        anterior^.siguiente := actual^.siguiente;

      Dispose(actual);
      Exit;
    end;

    anterior := actual;
    actual := actual^.siguiente;
  end;
end;

function TListaComunidades.ObtenerComunidadesPorUsuario(email: string): TStringList;
var
  i: Integer;
  actualCom: PComunidad;
  actualMiembro: PMiembroComunidad;
begin
  Result := TStringList.Create;
  actualCom := cabezaComunidades;
  i := 0;

  while actualCom <> nil do
  begin
    actualMiembro := listasMiembros[i];
    while actualMiembro <> nil do
    begin
      if actualMiembro^.usuario.email = email then
      begin
        Result.Add(actualCom^.nombre);
        Break;
      end;
      actualMiembro := actualMiembro^.siguiente;
    end;

    Inc(i);
    actualCom := actualCom^.siguiente;
  end;
end;

function TListaComunidades.ObtenerUsuariosPorComunidad(idComunidad: Integer): TStringList;
var
  indice: Integer;
  actual: PMiembroComunidad;
begin
  Result := TStringList.Create;
  indice := ObtenerIndiceComunidad(idComunidad);

  if indice = -1 then
    Exit;

  actual := listasMiembros[indice];
  while actual <> nil do
  begin
    Result.Add(actual^.usuario.nombre + ' (' + actual^.usuario.email + ')');
    actual := actual^.siguiente;
  end;
end;

function TListaComunidades.ExisteUsuarioEnComunidad(idComunidad: Integer; email: string): Boolean;
var
  indice: Integer;
  actual: PMiembroComunidad;
begin
  indice := ObtenerIndiceComunidad(idComunidad);
  if indice = -1 then
    Exit(False);

  actual := listasMiembros[indice];
  while actual <> nil do
  begin
    if actual^.usuario.email = email then
      Exit(True);
    actual := actual^.siguiente;
  end;

  Result := False;
end;

procedure TListaComunidades.GenerarReporte(ruta: string);
var
  sl: TStringList;
  actualCom: PComunidad;
  actualMiembro: PMiembroComunidad;
  i: Integer;
begin
  sl := TStringList.Create;
  try
    sl.Add('REPORTE DE COMUNIDADES');
    sl.Add('=====================');
    sl.Add('');

    actualCom := cabezaComunidades;
    i := 0;

    while actualCom <> nil do
    begin
      sl.Add('Comunidad: ' + actualCom^.nombre + ' (ID: ' + IntToStr(actualCom^.id) + ')');
      sl.Add('Miembros:');

      actualMiembro := listasMiembros[i];
      if actualMiembro = nil then
        sl.Add('  No hay miembros')
      else
      begin
        while actualMiembro <> nil do
        begin
          sl.Add('  - ' + actualMiembro^.usuario.nombre + ' (' + actualMiembro^.usuario.email + ')');
          actualMiembro := actualMiembro^.siguiente;
        end;
      end;

      sl.Add('----------------------------------');
      actualCom := actualCom^.siguiente;
      Inc(i);
    end;

    ForceDirectories(ExtractFilePath(ruta));
    sl.SaveToFile(ruta);
  finally
    sl.Free;
  end;
end;

function TListaComunidades.ToString: string;
var
  actualCom: PComunidad;
  actualMiembro: PMiembroComunidad;
  i: Integer;
begin
  Result := 'Comunidades:' + #13#10;
  actualCom := cabezaComunidades;
  i := 0;

  while actualCom <> nil do
  begin
    Result := Result + '• ' + actualCom^.nombre + ':' + #13#10;

    actualMiembro := listasMiembros[i];
    while actualMiembro <> nil do
    begin
      Result := Result + '  - ' + actualMiembro^.usuario.nombre + #13#10;
      actualMiembro := actualMiembro^.siguiente;
    end;

    actualCom := actualCom^.siguiente;
    Inc(i);
  end;
end;

end.
