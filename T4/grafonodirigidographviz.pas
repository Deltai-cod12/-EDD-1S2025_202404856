program GrafoNoDirigidoGraphviz;

{$mode objfpc}{$H+}

uses
  SysUtils;

type
  TGrafo = record
    ciudades: array of string;
    adj: array of array of Integer; // 0 o 1
    function indiceCiudad(const nombre: string): Integer;
    procedure agregarCiudad(const nombre: string);
    procedure agregarAristaPorNombres(const a, b: string);
    procedure agregarAristaPorIndices(i, j: Integer);
    procedure escribirDot(const nombreArchivo: string);
  end;

{ Devuelve el índice de la ciudad si existe o -1 si no existe }
function TGrafo.indiceCiudad(const nombre: string): Integer;
var
  i: Integer;
begin
  for i := 0 to Length(ciudades) - 1 do
    if ciudades[i] = nombre then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

{ Agrega una ciudad si no existe }
procedure TGrafo.agregarCiudad(const nombre: string);
var
  n, i: Integer;
begin
  if indiceCiudad(nombre) <> -1 then Exit; // ya existe
  n := Length(ciudades);
  SetLength(ciudades, n + 1);
  ciudades[n] := nombre;

  { redimensionar matriz de adyacencia }
  for i := 0 to n do
    SetLength(adj[i], n + 1);
  SetLength(adj, n + 1);

  { inicializar nuevas entradas en 0 }
  for i := 0 to n do
  begin
    adj[n][i] := 0;
    adj[i][n] := 0;
  end;
end;

{ Agrega una arista usando nombres de ciudades. Crea ciudad si no existe }
procedure TGrafo.agregarAristaPorNombres(const a, b: string);
var
  ia, ib: Integer;
begin
  if a = b then Exit; // evitar bucle auto
  if indiceCiudad(a) = -1 then agregarCiudad(a);
  if indiceCiudad(b) = -1 then agregarCiudad(b);
  ia := indiceCiudad(a);
  ib := indiceCiudad(b);
  agregarAristaPorIndices(ia, ib);
end;

{ Agrega una arista por índices (no dirigida) }
procedure TGrafo.agregarAristaPorIndices(i, j: Integer);
begin
  if (i < 0) or (j < 0) or (i >= Length(ciudades)) or (j >= Length(ciudades)) then Exit;
  adj[i][j] := 1;
  adj[j][i] := 1;
end;

{ Escribe archivo dot para Graphviz }
procedure TGrafo.escribirDot(const nombreArchivo: string);
var
  f: TextFile;
  i, j: Integer;
  safeName: string;
begin
  AssignFile(f, nombreArchivo);
  Rewrite(f);
  try
    Writeln(f, 'graph G {');
    Writeln(f, '  rankdir=LR;'); // opcional dirección izquierda a derecha
    Writeln(f, '  node [shape=circle style=filled fillcolor=lightgrey];');

    { definir nodos con etiquetas }
    for i := 0 to Length(ciudades) - 1 do
    begin
      { escapar comillas si es necesario }
      safeName := StringReplace(ciudades[i], '"', '\"', [rfReplaceAll]);
      Writeln(f, Format('  %d [label="%s"];', [i, safeName]));
    end;

    { escribir aristas sin duplicados }
    for i := 0 to Length(ciudades) - 1 do
      for j := i + 1 to Length(ciudades) - 1 do
        if adj[i][j] <> 0 then
          Writeln(f, Format('  %d -- %d;', [i, j]));

    { leyenda que mapea índices a nombres }
    Writeln(f);
    Writeln(f, '  subgraph cluster_legend {');
    Writeln(f, '    label="Leyenda";');
    Writeln(f, '    fontsize=10;');
    for i := 0 to Length(ciudades) - 1 do
      Writeln(f, Format('    "%d = %s";', [i, ciudades[i]]));
    Writeln(f, '    color=white;');
    Writeln(f, '  }');

    Writeln(f, '}');
  finally
    CloseFile(f);
  end;
end;

{ Programa principal con ejemplo de ciudades }
var
  g: TGrafo;
begin
  { inicializar estructuras vacías }
  SetLength(g.ciudades, 0);
  SetLength(g.adj, 0);

  { agregar algunas ciudades de ejemplo }
  g.agregarCiudad('Ciudad de Guatemala');
  g.agregarCiudad('Antigua Guatemala');
  g.agregarCiudad('Quetzaltenango');
  g.agregarCiudad('Escuintla');
  g.agregarCiudad('Puerto Barrios');

  { agregar conexiones bidireccionales ejemplo }
  g.agregarAristaPorNombres('Ciudad de Guatemala', 'Antigua Guatemala');
  g.agregarAristaPorNombres('Ciudad de Guatemala', 'Quetzaltenango');
  g.agregarAristaPorNombres('Antigua Guatemala', 'Escuintla');
  g.agregarAristaPorNombres('Escuintla', 'Puerto Barrios');
  g.agregarAristaPorNombres('Quetzaltenango', 'Puerto Barrios');

  { escribir archivo dot }
  g.escribirDot('grafo.dot');

  Writeln('Archivo grafo.dot creado con éxito');
  Writeln('Compilar con: fpc grafo.pas');
  Writeln('Generar imagen con: dot -Tpng grafo.dot -o grafo.png');
end.

