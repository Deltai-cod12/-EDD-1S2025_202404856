unit UBTree;

{$mode delphi}

interface

uses
  Classes, SysUtils;

const
  ORDEN = 5;
  MAX_CLAVES = ORDEN - 1; // 4
  MIN_CLAVES = ORDEN div 2 - 1; // 2

type
  // Registro para correos favoritos (tal como lo tenías)
  TMail = record
    id: string;
    remitente: string;
    destinatario: string;
    asunto: string;
    mensaje: string;
    // fecha: TDateTime; // si quieres fecha, agrégala aquí y ajústalo en uFavoritos
  end;

  // Nodo del Árbol B
  PNodoB = ^TNodoB;
  TNodoB = record
    n: Integer; // cantidad de claves
    claves: array[0..MAX_CLAVES-1] of string;  // IDs de correos
    valores: array[0..MAX_CLAVES-1] of TMail;  // correos completos
    hijos: array[0..ORDEN-1] of PNodoB;        // hasta 5 hijos
    esHoja: Boolean;
  end;

  TBTree = record
    raiz: PNodoB;
  end;
  PBTree = ^TBTree;

function CrearNodoB(esHoja: Boolean): PNodoB;
function CrearBTree: PBTree;
procedure InsertarB(var raiz: PNodoB; correo: TMail);
function BuscarB(nodo: PNodoB; id: string): TMail;
procedure InOrdenB(nodo: PNodoB);
procedure InOrdenBLista(nodo: PNodoB; lista: TStrings); // <-- agregado
procedure GenerarDOTB(raiz: PNodoB; const nombreArchivo: String);

procedure EliminarBTree(var raiz: PNodoB; const id: string); // <-- agregado

implementation

// =============================================================
// Crear nodo y árbol
// =============================================================

function CrearNodoB(esHoja: Boolean): PNodoB;
var
  nuevo: PNodoB;
  i: Integer;
begin
  New(nuevo);
  nuevo^.n := 0;
  nuevo^.esHoja := esHoja;
  for i := 0 to ORDEN-1 do
    nuevo^.hijos[i] := nil;
  CrearNodoB := nuevo;
end;

function CrearBTree: PBTree;
var
  nuevo: PBTree;
begin
  New(nuevo);
  nuevo^.raiz := nil;
  CrearBTree := nuevo;
end;

// =============================================================
// Buscar (devuelve TMail; si no existe, devuelve registro con id = '')
// =============================================================

function BuscarB(nodo: PNodoB; id: string): TMail;
var
  i: Integer;
  vacio: TMail;
begin
  vacio.id := '';
  if nodo = nil then Exit(vacio);

  i := 0;
  while (i < nodo^.n) and (id > nodo^.claves[i]) do
    Inc(i);

  if (i < nodo^.n) and (id = nodo^.claves[i]) then
    Exit(nodo^.valores[i]);

  if nodo^.esHoja then
    Exit(vacio)
  else
    Exit(BuscarB(nodo^.hijos[i], id));
end;

// =============================================================
// Dividir hijo (cuando está lleno)
// =============================================================

procedure DividirHijo(padre: PNodoB; i: Integer; hijo: PNodoB);
var
  nuevoNodo: PNodoB;
  j: Integer;
begin
  nuevoNodo := CrearNodoB(hijo^.esHoja);
  nuevoNodo^.n := MIN_CLAVES;

  for j := 0 to MIN_CLAVES-1 do
  begin
    nuevoNodo^.claves[j] := hijo^.claves[j + MIN_CLAVES + 1];
    nuevoNodo^.valores[j] := hijo^.valores[j + MIN_CLAVES + 1];
  end;

  if not hijo^.esHoja then
    for j := 0 to MIN_CLAVES do
      nuevoNodo^.hijos[j] := hijo^.hijos[j + MIN_CLAVES + 1];

  hijo^.n := MIN_CLAVES;

  for j := padre^.n downto i+1 do
    padre^.hijos[j+1] := padre^.hijos[j];

  padre^.hijos[i+1] := nuevoNodo;

  for j := padre^.n-1 downto i do
  begin
    padre^.claves[j+1] := padre^.claves[j];
    padre^.valores[j+1] := padre^.valores[j];
  end;

  padre^.claves[i] := hijo^.claves[MIN_CLAVES];
  padre^.valores[i] := hijo^.valores[MIN_CLAVES];
  Inc(padre^.n);
end;

// =============================================================
// Insertar en nodo no lleno
// =============================================================

procedure InsertarNoLleno(nodo: PNodoB; correo: TMail);
var
  i: Integer;
begin
  i := nodo^.n - 1;

  if nodo^.esHoja then
  begin
    while (i >= 0) and (correo.id < nodo^.claves[i]) do
    begin
      nodo^.claves[i+1] := nodo^.claves[i];
      nodo^.valores[i+1] := nodo^.valores[i];
      Dec(i);
    end;
    nodo^.claves[i+1] := correo.id;
    nodo^.valores[i+1] := correo;
    Inc(nodo^.n);
  end
  else
  begin
    while (i >= 0) and (correo.id < nodo^.claves[i]) do
      Dec(i);
    Inc(i);

    if nodo^.hijos[i] = nil then
      nodo^.hijos[i] := CrearNodoB(True);

    if nodo^.hijos[i]^.n = MAX_CLAVES then
    begin
      DividirHijo(nodo, i, nodo^.hijos[i]);
      if correo.id > nodo^.claves[i] then
        Inc(i);
    end;
    InsertarNoLleno(nodo^.hijos[i], correo);
  end;
end;

// =============================================================
// Insertar en árbol
// =============================================================

procedure InsertarB(var raiz: PNodoB; correo: TMail);
var
  nuevaRaiz: PNodoB;
begin
  if raiz = nil then
  begin
    raiz := CrearNodoB(True);
    raiz^.claves[0] := correo.id;
    raiz^.valores[0] := correo;
    raiz^.n := 1;
  end
  else
  begin
    if raiz^.n = MAX_CLAVES then
    begin
      nuevaRaiz := CrearNodoB(False);
      nuevaRaiz^.hijos[0] := raiz;
      DividirHijo(nuevaRaiz, 0, raiz);
      InsertarNoLleno(nuevaRaiz, correo);
      raiz := nuevaRaiz;
    end
    else
      InsertarNoLleno(raiz, correo);
  end;
end;

// =============================================================
// Recorrido in-orden (ruta de consola) - lo mantengo
// =============================================================

procedure InOrdenB(nodo: PNodoB);
var
  i: Integer;
begin
  if nodo <> nil then
  begin
    for i := 0 to nodo^.n-1 do
    begin
      if not nodo^.esHoja then
        InOrdenB(nodo^.hijos[i]);
      Writeln('ID: ', nodo^.claves[i], ' | Asunto: ', nodo^.valores[i].asunto);
    end;
    if not nodo^.esHoja then
      InOrdenB(nodo^.hijos[nodo^.n]);
  end;
end;

// =============================================================
// Nuevo: Recorrido in-orden que llena un TStrings (para el grid)
// =============================================================
procedure InOrdenBLista(nodo: PNodoB; lista: TStrings);
var
  i: Integer;
begin
  if (nodo = nil) or (lista = nil) then Exit;

  for i := 0 to nodo^.n - 1 do
  begin
    if not nodo^.esHoja then
      InOrdenBLista(nodo^.hijos[i], lista);

    // formato: ID|Asunto|Remitente
    lista.Add(nodo^.valores[i].id + '|' + nodo^.valores[i].asunto + '|' + nodo^.valores[i].remitente);
  end;

  if not nodo^.esHoja then
    InOrdenBLista(nodo^.hijos[nodo^.n], lista);
end;

// =============================================================
// Eliminar (versión simplificada: elimina claves si están en hojas)
// =============================================================

procedure EliminarEnNodo(var nodo: PNodoB; const id: string);
var
  i, j: Integer;
begin
  if nodo = nil then Exit;

  // buscar posición
  i := 0;
  while (i < nodo^.n) and (id > nodo^.claves[i]) do Inc(i);

  if (i < nodo^.n) and (id = nodo^.claves[i]) then
  begin
    // encontrado en este nodo
    if nodo^.esHoja then
    begin
      // eliminar la entrada i (shift left)
      for j := i to nodo^.n - 2 do
      begin
        nodo^.claves[j] := nodo^.claves[j+1];
        nodo^.valores[j] := nodo^.valores[j+1];
      end;
      Dec(nodo^.n);
      Exit;
    end
    else
    begin
      // si está en nodo interno: versión simplificada -> intentar eliminar en subárbol derecho
      // (una implementación completa requiere reemplazos y reequilibrio)
      EliminarEnNodo(nodo^.hijos[i+1], id);
      Exit;
    end;
  end
  else
  begin
    // no está en este nodo: bajar al hijo correspondiente si existe
    if nodo^.esHoja then
      Exit
    else
    begin
      if nodo^.hijos[i] <> nil then
        EliminarEnNodo(nodo^.hijos[i], id);
    end;
  end;
end;

procedure EliminarBTree(var raiz: PNodoB; const id: string);
var
  tmp: PNodoB;
begin
  if raiz = nil then Exit;

  EliminarEnNodo(raiz, id);

  // si la raiz quedó vacía (n = 0) y tiene hijos, promovemos el hijo 0 como nueva raíz
  if (raiz <> nil) and (raiz^.n = 0) then
  begin
    if raiz^.esHoja then
    begin
      Dispose(raiz);
      raiz := nil;
    end
    else
    begin
      tmp := raiz;
      raiz := raiz^.hijos[0];
      // opcional: liberar tmp (sin liberar sus hijos)
      Dispose(tmp);
    end;
  end;
end;

// =============================================================
// Exportar a DOT
// =============================================================

procedure EscribirLinea(var f: Text; const linea: String);
begin
  Writeln(f, linea);
end;

procedure GenerarNodosDOT(var f: Text; nodo: PNodoB; idNodo: Integer);
var
  i: Integer;
  clavesStr: String;
  idHijo: Integer;
begin
  if nodo = nil then Exit;

  clavesStr := '';
  for i := 0 to nodo^.n-1 do
    clavesStr := clavesStr + Format('|%s:%s', [nodo^.claves[i], nodo^.valores[i].asunto]);

  EscribirLinea(f, Format('  nodo%d [label="%s", shape=record];', [idNodo, clavesStr]));

  for i := 0 to nodo^.n do
    if nodo^.hijos[i] <> nil then
    begin
      idHijo := idNodo * ORDEN + i + 1;
      EscribirLinea(f, Format('  nodo%d -> nodo%d;', [idNodo, idHijo]));
      GenerarNodosDOT(f, nodo^.hijos[i], idHijo);
    end;
end;

procedure GenerarDOTB(raiz: PNodoB; const nombreArchivo: String);
var
  f: Text;
begin
  Assign(f, nombreArchivo);
  Rewrite(f);

  EscribirLinea(f, 'digraph ArbolB {');
  EscribirLinea(f, '  node [shape=record, style=filled, fillcolor=lightblue];');

  if raiz <> nil then
    GenerarNodosDOT(f, raiz, 1)
  else
    EscribirLinea(f, '  vacio [label="(vacio)"];');

  EscribirLinea(f, '}');
  Close(f);
end;

end.

