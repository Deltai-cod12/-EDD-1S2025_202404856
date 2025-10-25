unit UBTree;

{$mode delphi}

interface

uses
  SysUtils;

const
  ORDEN = 5;
  MAX_CLAVES = ORDEN - 1; // 4
  MIN_CLAVES = ORDEN div 2 - 1; // 2

type
  // Registro para correos favoritos
  TMail = record
    id: string;
    remitente: string;
    destinatario: string;
    asunto: string;
    mensaje: string;
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
procedure GenerarDOTB(raiz: PNodoB; const nombreArchivo: String);

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
// Buscar
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
// Recorrido in-orden
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

