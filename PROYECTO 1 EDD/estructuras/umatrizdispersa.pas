unit uMatrizDispersa;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uListaSimpleUsuarios;

type
  PNodoMatriz = ^TNodoMatriz;
  TNodoMatriz = record
    fila, columna: Integer;
    cantidad: Integer;
    siguienteFila, siguienteColumna: PNodoMatriz;
  end;

  { TMatrizDispersa }

  TMatrizDispersa = class
  private
    filas, columnas: Integer;
    cabecerasFilas, cabecerasColumnas: array of PNodoMatriz;
    listaUsuarios: TListaUsuarios;
    function ObtenerIndiceFila(email: string): Integer;
    function ObtenerIndiceColumna(email: string): Integer;
    function ObtenerEmailPorIndiceFila(indice: Integer): string;
    function ObtenerEmailPorIndiceColumna(indice: Integer): string;
    function CrearNodo(fila, columna, cantidad: Integer): PNodoMatriz;
    procedure InsertarNodo(nodo: PNodoMatriz);
  public
    constructor Create(usuarios: TListaUsuarios); // Cambié el nombre del parámetro
    destructor Destroy; override;
    procedure RegistrarEnvio(remitente, destinatario: string);
    function ObtenerCantidad(remitente, destinatario: string): Integer;
    procedure GenerarReporte(ruta: string);
    procedure GenerarReporteGraphviz(ruta: string);
    function ToString: string; override;
    function ObtenerTotalEnvios(usuario: string): Integer;
    function ObtenerTotalRecepciones(usuario: string): Integer;
  end;

implementation

{ TMatrizDispersa }

constructor TMatrizDispersa.Create(usuarios: TListaUsuarios); // Usar nombre diferente
var
  i, count: Integer;
  usuario: PUsuario;
begin
  Self.listaUsuarios := usuarios; // Asignar al campo de clase

  // Contar usuarios para dimensionar la matriz
  count := 0;
  usuario := listaUsuarios.BuscarPorUsuario('root'); // Empezar desde root
  while usuario <> nil do
  begin
    Inc(count);
    usuario := usuario^.siguiente;
  end;

  filas := count;
  columnas := count;

  // Inicializar cabeceras
  SetLength(cabecerasFilas, filas);
  SetLength(cabecerasColumnas, columnas);

  for i := 0 to filas - 1 do
  begin
    cabecerasFilas[i] := nil;
    cabecerasColumnas[i] := nil;
  end;
end;

destructor TMatrizDispersa.Destroy;
var
  i: Integer;
  actual, temp: PNodoMatriz;
begin
  for i := 0 to filas - 1 do
  begin
    actual := cabecerasFilas[i];
    while actual <> nil do
    begin
      temp := actual;
      actual := actual^.siguienteFila;
      Dispose(temp);
    end;
  end;

  inherited Destroy;
end;

function TMatrizDispersa.ObtenerIndiceFila(email: string): Integer;
var
  usuario: PUsuario;
  index: Integer;
begin
  index := 0;
  usuario := listaUsuarios.BuscarPorUsuario('root');

  while usuario <> nil do
  begin
    if usuario^.email = email then
      Exit(index);
    Inc(index);
    usuario := usuario^.siguiente;
  end;

  Result := -1;
end;

function TMatrizDispersa.ObtenerIndiceColumna(email: string): Integer;
begin
  Result := ObtenerIndiceFila(email); // Misma lógica para filas y columnas
end;

function TMatrizDispersa.ObtenerEmailPorIndiceFila(indice: Integer): string;
var
  usuario: PUsuario;
  i: Integer;
begin
  if (indice < 0) or (indice >= filas) then
    Exit('');

  usuario := listaUsuarios.BuscarPorUsuario('root');
  i := 0;

  while (usuario <> nil) and (i < indice) do
  begin
    usuario := usuario^.siguiente;
    Inc(i);
  end;

  if usuario <> nil then
    Result := usuario^.email
  else
    Result := '';
end;

function TMatrizDispersa.ObtenerEmailPorIndiceColumna(indice: Integer): string;
begin
  Result := ObtenerEmailPorIndiceFila(indice); // Misma lógica
end;

function TMatrizDispersa.CrearNodo(fila, columna, cantidad: Integer): PNodoMatriz;
var
  nuevo: PNodoMatriz;
begin
  New(nuevo);
  nuevo^.fila := fila;
  nuevo^.columna := columna;
  nuevo^.cantidad := cantidad;
  nuevo^.siguienteFila := nil;
  nuevo^.siguienteColumna := nil;
  Result := nuevo;
end;

procedure TMatrizDispersa.InsertarNodo(nodo: PNodoMatriz);
var
  actual: PNodoMatriz;
begin
  // Insertar en la fila
  if cabecerasFilas[nodo^.fila] = nil then
    cabecerasFilas[nodo^.fila] := nodo
  else
  begin
    actual := cabecerasFilas[nodo^.fila];
    while (actual^.siguienteFila <> nil) and (actual^.siguienteFila^.columna < nodo^.columna) do
      actual := actual^.siguienteFila;

    if actual^.columna > nodo^.columna then
    begin
      nodo^.siguienteFila := actual;
      cabecerasFilas[nodo^.fila] := nodo;
    end
    else
    begin
      nodo^.siguienteFila := actual^.siguienteFila;
      actual^.siguienteFila := nodo;
    end;
  end;

  // Insertar en la columna
  if cabecerasColumnas[nodo^.columna] = nil then
    cabecerasColumnas[nodo^.columna] := nodo
  else
  begin
    actual := cabecerasColumnas[nodo^.columna];
    while (actual^.siguienteColumna <> nil) and (actual^.siguienteColumna^.fila < nodo^.fila) do
      actual := actual^.siguienteColumna;

    if actual^.fila > nodo^.fila then
    begin
      nodo^.siguienteColumna := actual;
      cabecerasColumnas[nodo^.columna] := nodo;
    end
    else
    begin
      nodo^.siguienteColumna := actual^.siguienteColumna;
      actual^.siguienteColumna := nodo;
    end;
  end;
end;

procedure TMatrizDispersa.RegistrarEnvio(remitente, destinatario: string);
var
  fila, columna: Integer;
  actual: PNodoMatriz;
  encontrado: Boolean;
begin
  fila := ObtenerIndiceFila(remitente);
  columna := ObtenerIndiceColumna(destinatario);

  if (fila = -1) or (columna = -1) then
    Exit;

  // Buscar si ya existe un nodo para esta relación
  actual := cabecerasFilas[fila];
  encontrado := False;

  while (actual <> nil) and (actual^.columna <= columna) do
  begin
    if actual^.columna = columna then
    begin
      Inc(actual^.cantidad);
      encontrado := True;
      Break;
    end;
    actual := actual^.siguienteFila;
  end;

  // Si no existe, crear nuevo nodo
  if not encontrado then
    InsertarNodo(CrearNodo(fila, columna, 1));
end;

function TMatrizDispersa.ObtenerCantidad(remitente, destinatario: string): Integer;
var
  fila, columna: Integer;
  actual: PNodoMatriz;
begin
  fila := ObtenerIndiceFila(remitente);
  columna := ObtenerIndiceColumna(destinatario);

  if (fila = -1) or (columna = -1) then
    Exit(0);

  actual := cabecerasFilas[fila];
  while (actual <> nil) and (actual^.columna <= columna) do
  begin
    if actual^.columna = columna then
      Exit(actual^.cantidad);
    actual := actual^.siguienteFila;
  end;

  Result := 0;
end;

procedure TMatrizDispersa.GenerarReporte(ruta: string);
var
  sl: TStringList;
  i, j: Integer;
  remitente, destinatario: string;
  cantidad: Integer;
begin
  sl := TStringList.Create;
  try
  sl.Add('REPORTE DE RELACIONES - MATRIZ DISPERSA');
  sl.Add('=======================================');
  sl.Add('');
  sl.Add('Formato: Remitente ++ Destinatario ++ Cantidad');
  sl.Add('');

  for i := 0 to filas - 1 do
  begin
    remitente := ObtenerEmailPorIndiceFila(i);
    if remitente = '' then Continue;

    for j := 0 to columnas - 1 do
    begin
      cantidad := ObtenerCantidad(remitente, ObtenerEmailPorIndiceColumna(j));
      if cantidad > 0 then
      begin
        destinatario := ObtenerEmailPorIndiceColumna(j);
        sl.Add(remitente + ' ++ ' + destinatario + ' ++ ' + IntToStr(cantidad));
      end;
    end;
  end;

  ForceDirectories(ExtractFilePath(ruta));
  sl.SaveToFile(ruta);
  finally
    sl.Free;
  end;
end;

procedure TMatrizDispersa.GenerarReporteGraphviz(ruta: string);
var
  sl: TStringList;
  i, j: Integer;
  remitente, destinatario: string;
  cantidad: Integer;
begin
  sl := TStringList.Create;
  try
    sl.Add('digraph relaciones {');
    sl.Add('  node [shape=rectangle, style=filled, fillcolor=lightblue];');
    sl.Add('  rankdir=LR;');
    sl.Add('');

    // Agregar nodos
    for i := 0 to filas - 1 do
    begin
      remitente := ObtenerEmailPorIndiceFila(i);
      if remitente <> '' then
        sl.Add('  "' + remitente + '" [label="' + remitente + '"];');
    end;

    sl.Add('');

    // Agregar relaciones
    for i := 0 to filas - 1 do
    begin
      remitente := ObtenerEmailPorIndiceFila(i);
      if remitente = '' then Continue;

      for j := 0 to columnas - 1 do
      begin
        cantidad := ObtenerCantidad(remitente, ObtenerEmailPorIndiceColumna(j));
        if cantidad > 0 then
        begin
          destinatario := ObtenerEmailPorIndiceColumna(j);
          sl.Add('  "' + remitente + '" -> "' + destinatario +
                 '" [label="' + IntToStr(cantidad) + '"];');
        end;
      end;
    end;

    sl.Add('}');

    ForceDirectories(ExtractFilePath(ruta));
    sl.SaveToFile(ruta);
  finally
    sl.Free;
  end;
end;

function TMatrizDispersa.ToString: string;
var
  i, j: Integer;
  remitente, destinatario: string;
  cantidad: Integer;
begin
  Result := 'Matriz Dispersa:' + #13#10;
  Result := Result + 'Remitente -> Destinatario: Cantidad' + #13#10;

  for i := 0 to filas - 1 do
  begin
    remitente := ObtenerEmailPorIndiceFila(i);
    if remitente = '' then Continue;

    for j := 0 to columnas - 1 do
    begin
      cantidad := ObtenerCantidad(remitente, ObtenerEmailPorIndiceColumna(j));
      if cantidad > 0 then
      begin
        destinatario := ObtenerEmailPorIndiceColumna(j);
        Result := Result + remitente + ' -> ' + destinatario + ': ' + IntToStr(cantidad) + #13#10;
      end;
    end;
  end;
end;

function TMatrizDispersa.ObtenerTotalEnvios(usuario: string): Integer;
var
  fila, j: Integer;
  actual: PNodoMatriz;
begin
  Result := 0;
  fila := ObtenerIndiceFila(usuario);

  if fila = -1 then
    Exit;

  actual := cabecerasFilas[fila];
  while actual <> nil do
  begin
    Result := Result + actual^.cantidad;
    actual := actual^.siguienteFila;
  end;
end;

function TMatrizDispersa.ObtenerTotalRecepciones(usuario: string): Integer;
var
  columna, i: Integer;
  actual: PNodoMatriz;
begin
  Result := 0;
  columna := ObtenerIndiceColumna(usuario);

  if columna = -1 then
    Exit;

  for i := 0 to filas - 1 do
  begin
    actual := cabecerasFilas[i];
    while actual <> nil do
    begin
      if actual^.columna = columna then
        Result := Result + actual^.cantidad;
      actual := actual^.siguienteFila;
    end;
  end;
end;

end.
