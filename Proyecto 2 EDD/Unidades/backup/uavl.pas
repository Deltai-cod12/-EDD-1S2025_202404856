unit UAVL;

{$mode delphi}

interface

uses
  SysUtils;

type
  // Registro que representa un correo borrador
  TMail = record
    id: string;
    remitente: string;
    destinatario: string;
    asunto: string;
    mensaje: string;
  end;

  PNodoAVL = ^TNodoAVL;
  TNodoAVL = record
    mail: TMail;
    izquierda, derecha: PNodoAVL;
    altura: Integer;
  end;

  TAVLTree = record
    raiz: PNodoAVL;
  end;
  PAVLTree = ^TAVLTree;

function CrearAVL: PAVLTree;
function InsertarAVL(var raiz: PNodoAVL; correo: TMail): PNodoAVL;
function BuscarAVL(raiz: PNodoAVL; id: string): PNodoAVL;
procedure InOrdenAVL(nodo: PNodoAVL);
function EliminarAVL(var raiz: PNodoAVL; id: string): PNodoAVL;
procedure GenerarDOTAVL(raiz: PNodoAVL; const nombreArchivo: String);

implementation

// =============================================================
// Funciones auxiliares
// =============================================================

function GetAltura(nodo: PNodoAVL): Integer;
begin
  if nodo = nil then
    GetAltura := 0
  else
    GetAltura := nodo^.altura;
end;

procedure ActualizarAltura(nodo: PNodoAVL);
var
  alturaIzq, alturaDer: Integer;
begin
  alturaIzq := GetAltura(nodo^.izquierda);
  alturaDer := GetAltura(nodo^.derecha);
  if alturaIzq > alturaDer then
    nodo^.altura := 1 + alturaIzq
  else
    nodo^.altura := 1 + alturaDer;
end;

function GetBalance(nodo: PNodoAVL): Integer;
begin
  if nodo = nil then
    GetBalance := 0
  else
    GetBalance := GetAltura(nodo^.izquierda) - GetAltura(nodo^.derecha);
end;

// =============================================================
// Rotaciones
// =============================================================

function RotarDerecha(y: PNodoAVL): PNodoAVL;
var
  x: PNodoAVL;
begin
  x := y^.izquierda;
  y^.izquierda := x^.derecha;
  x^.derecha := y;
  ActualizarAltura(y);
  ActualizarAltura(x);
  RotarDerecha := x;
end;

function RotarIzquierda(x: PNodoAVL): PNodoAVL;
var
  y: PNodoAVL;
begin
  y := x^.derecha;
  x^.derecha := y^.izquierda;
  y^.izquierda := x;
  ActualizarAltura(x);
  ActualizarAltura(y);
  RotarIzquierda := y;
end;

// =============================================================
// Crear nodo y árbol
// =============================================================

function CrearNodo(correo: TMail): PNodoAVL;
var
  nuevo: PNodoAVL;
begin
  New(nuevo);
  nuevo^.mail := correo;
  nuevo^.izquierda := nil;
  nuevo^.derecha := nil;
  nuevo^.altura := 1;
  CrearNodo := nuevo;
end;

function CrearAVL: PAVLTree;
var
  nuevo: PAVLTree;
begin
  New(nuevo);
  nuevo^.raiz := nil;
  CrearAVL := nuevo;
end;

// =============================================================
// Insertar borrador
// =============================================================

function InsertarAVL(var raiz: PNodoAVL; correo: TMail): PNodoAVL;
var
  balance: Integer;
begin
  if raiz = nil then
  begin
    raiz := CrearNodo(correo);
    Exit(raiz);
  end;

  if correo.id < raiz^.mail.id then
    raiz^.izquierda := InsertarAVL(raiz^.izquierda, correo)
  else if correo.id > raiz^.mail.id then
    raiz^.derecha := InsertarAVL(raiz^.derecha, correo)
  else
  begin
    raiz^.mail := correo; // si existe, actualiza
    Exit(raiz);
  end;

  ActualizarAltura(raiz);
  balance := GetBalance(raiz);

  if (balance > 1) and (correo.id < raiz^.izquierda^.mail.id) then
    Exit(RotarDerecha(raiz));

  if (balance < -1) and (correo.id > raiz^.derecha^.mail.id) then
    Exit(RotarIzquierda(raiz));

  if (balance > 1) and (correo.id > raiz^.izquierda^.mail.id) then
  begin
    raiz^.izquierda := RotarIzquierda(raiz^.izquierda);
    Exit(RotarDerecha(raiz));
  end;

  if (balance < -1) and (correo.id < raiz^.derecha^.mail.id) then
  begin
    raiz^.derecha := RotarDerecha(raiz^.derecha);
    Exit(RotarIzquierda(raiz));
  end;

  InsertarAVL := raiz;
end;

// =============================================================
// Buscar borrador por ID
// =============================================================

function BuscarAVL(raiz: PNodoAVL; id: string): PNodoAVL;
begin
  if (raiz = nil) or (raiz^.mail.id = id) then
    Exit(raiz);

  if id < raiz^.mail.id then
    Exit(BuscarAVL(raiz^.izquierda, id))
  else
    Exit(BuscarAVL(raiz^.derecha, id));
end;

// =============================================================
// Recorrido in-orden
// =============================================================

procedure InOrdenAVL(nodo: PNodoAVL);
begin
  if nodo <> nil then
  begin
    InOrdenAVL(nodo^.izquierda);
    Writeln('ID: ', nodo^.mail.id, ' | Asunto: ', nodo^.mail.asunto,
      ' | De: ', nodo^.mail.remitente, ' | Para: ', nodo^.mail.destinatario);
    InOrdenAVL(nodo^.derecha);
  end;
end;

// =============================================================
// Exportar a DOT
// =============================================================

procedure EscribirLinea(var f: Text; const linea: String);
begin
  Writeln(f, linea);
end;

procedure GenerarNodosDOT(var f: Text; nodo: PNodoAVL);
begin
  if nodo = nil then Exit;

  EscribirLinea(f, Format('  "%s" [label="ID:%s\nAsunto:%s"];',
    [nodo^.mail.id, nodo^.mail.id, nodo^.mail.asunto]));

  if nodo^.izquierda <> nil then
  begin
    EscribirLinea(f, Format('  "%s" -> "%s";', [nodo^.mail.id, nodo^.izquierda^.mail.id]));
    GenerarNodosDOT(f, nodo^.izquierda);
  end;

  if nodo^.derecha <> nil then
  begin
    EscribirLinea(f, Format('  "%s" -> "%s";', [nodo^.mail.id, nodo^.derecha^.mail.id]));
    GenerarNodosDOT(f, nodo^.derecha);
  end;
end;

procedure GenerarDOTAVL(raiz: PNodoAVL; const nombreArchivo: String);
var
  f: Text;
begin
  Assign(f, nombreArchivo);
  Rewrite(f);

  EscribirLinea(f, 'digraph AVL {');
  EscribirLinea(f, '  node [shape=record, style=filled, fillcolor=lightblue];');

  if raiz <> nil then
    GenerarNodosDOT(f, raiz)
  else
    EscribirLinea(f, '  vacio [label="(vacio)"];');

  EscribirLinea(f, '}');
  Close(f);
end;

end.

