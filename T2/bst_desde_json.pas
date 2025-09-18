program BST_Desde_JSON;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes;

type
  PNodo = ^TNodo;
  TNodo = record
    id: Integer;
    first_name: string;
    last_name: string;
    email: string;
    left: PNodo;
    right: PNodo;
  end;

var
  root: PNodo = nil;

// Crear un nodo
function CrearNodo(id: Integer; first_name, last_name, email: string): PNodo;
var
  nodo: PNodo;
begin
  New(nodo);
  nodo^.id := id;
  nodo^.first_name := first_name;
  nodo^.last_name := last_name;
  nodo^.email := email;
  nodo^.left := nil;
  nodo^.right := nil;
  CrearNodo := nodo;
end;

// Insertar nodo en BST
procedure InsertarNodo(var root: PNodo; nodo: PNodo);
begin
  if root = nil then
    root := nodo
  else if nodo^.id < root^.id then
    InsertarNodo(root^.left, nodo)
  else
    InsertarNodo(root^.right, nodo);
end;

// Generar DOT recursivamente
procedure GenerarDot(nodo: PNodo; sl: TStringList);
begin
  if nodo = nil then Exit;

  sl.Add(Format('  %d [label="%d\n%s %s"];', [nodo^.id, nodo^.id, nodo^.first_name, nodo^.last_name]));

  if nodo^.left <> nil then
  begin
    sl.Add(Format('  %d -> %d;', [nodo^.id, nodo^.left^.id]));
    GenerarDot(nodo^.left, sl);
  end;

  if nodo^.right <> nil then
  begin
    sl.Add(Format('  %d -> %d;', [nodo^.id, nodo^.right^.id]));
    GenerarDot(nodo^.right, sl);
  end;
end;

// Extraer valor entre comillas
function ExtraerValor(linea: string): string;
var
  p1, p2: Integer;
begin
  p1 := Pos(':', linea);
  if p1 = 0 then Exit('');
  linea := Trim(Copy(linea, p1 + 1, Length(linea) - p1));
  if linea[1] = '"' then
  begin
    Delete(linea, 1, 1);
    p2 := Pos('"', linea);
    if p2 > 0 then linea := Copy(linea, 1, p2 - 1);
  end
  else
    linea := StringReplace(linea, ',', '', [rfReplaceAll]);
  ExtraerValor := Trim(linea);
end;

var
  sl, slJSON: TStringList;
  i, id: Integer;
  first_name, last_name, email: string;
begin
  if not FileExists('datos.json') then
  begin
    Writeln('No se encontro el archivo datos.json');
    Exit;
  end;

  slJSON := TStringList.Create;
  sl := TStringList.Create;
  try
    slJSON.LoadFromFile('datos.json');

    i := 0;
    while i < slJSON.Count do
    begin
      if Pos('"id"', slJSON[i]) > 0 then
        id := StrToInt(ExtraerValor(slJSON[i]))
      else if Pos('"first_name"', slJSON[i]) > 0 then
        first_name := ExtraerValor(slJSON[i])
      else if Pos('"last_name"', slJSON[i]) > 0 then
        last_name := ExtraerValor(slJSON[i])
      else if Pos('"email"', slJSON[i]) > 0 then
      begin
        email := ExtraerValor(slJSON[i]);
        // Insertar nodo en BST
        InsertarNodo(root, CrearNodo(id, first_name, last_name, email));
      end;
      Inc(i);
    end;

    // Generar archivo DOT
    sl.Add('digraph BST {');
    sl.Add('  node [shape=box];');
    GenerarDot(root, sl);
    sl.Add('}');
    sl.SaveToFile('arbol_bst.dot');

    Writeln('Archivo arbol_bst.dot generado correctamente.');
  finally
    slJSON.Free;
    sl.Free;
  end;

  Readln;
end.

