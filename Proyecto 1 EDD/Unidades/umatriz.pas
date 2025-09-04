unit UMatriz;

{$MODE DELPHI}

interface

uses
  SysUtils, Classes, Dialogs, Process;

type
    PMatrizNodo = ^TMatrizNodo;
    TMatrizNodo = record
        fila, columna: string; // email remitente y receptor
        cantidad: Integer;
        derecha, abajo: PMatrizNodo;
    end;

    PMatriz = ^TMatriz;
    TMatriz = record
        Head: PMatrizNodo;
    end;

procedure MatrizInit(var M: PMatriz);
procedure InsertRelacion(var M: PMatriz; fila, columna: string);
function SearchRelacion(var M: PMatriz; fila, columna: string): PMatrizNodo;
procedure PrintMatriz(var M: PMatriz);
procedure GenerateDotRelaciones(Matriz: PMatriz; const DotFile, PNGFile: string);

implementation

procedure MatrizInit(var M: PMatriz);
begin
  New(M);
  M^.Head := nil;
end;

procedure InsertRelacion(var M: PMatriz; fila, columna: string);
var
  Nodo: PMatrizNodo;
begin
  Nodo := SearchRelacion(M, fila, columna);
  if Nodo <> nil then
  begin
    Inc(Nodo^.cantidad);
    Exit;
  end;

  New(Nodo);
  Nodo^.fila := fila;
  Nodo^.columna := columna;
  Nodo^.cantidad := 1;
  Nodo^.derecha := M^.Head;
  Nodo^.abajo := nil;
  M^.Head := Nodo;
end;

function SearchRelacion(var M: PMatriz; fila, columna: string): PMatrizNodo;
var
  Actual: PMatrizNodo;
begin
  Actual := M^.Head;
  while Actual <> nil do
  begin
    if (Actual^.fila = fila) and (Actual^.columna = columna) then
    begin
      Result := Actual;
      Exit;
    end;
    Actual := Actual^.derecha;
  end;
  Result := nil;
end;

procedure PrintMatriz(var M: PMatriz);
var
  Actual: PMatrizNodo;
begin
  Actual := M^.Head;
  while Actual <> nil do
  begin
    Writeln(Actual^.fila, ' -> ', Actual^.columna, ' = ', Actual^.cantidad);
    Actual := Actual^.derecha;
  end;
end;

procedure GenerateDotRelaciones(Matriz: PMatriz; const DotFile, PNGFile: string);
var
  SL: TStringList;
  Actual: PMatrizNodo;
  Output: AnsiString;
begin
  if (Matriz = nil) or (Matriz^.Head = nil) then
  begin
    ShowMessage('La matriz de relaciones está vacía.');
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.Add('digraph Relaciones {');
    SL.Add('  rankdir=LR;'); // de izquierda a derecha
    SL.Add('  node [shape=record, style=filled, fillcolor=lightyellow];');
    SL.Add('  label="Matriz Dispersa de Relaciones";');
    SL.Add('  labelloc=t;');
    SL.Add('');

    Actual := Matriz^.Head;
    while Actual <> nil do
    begin
      SL.Add(Format('  "%s -> %s" [label="%d"];',
        [Actual^.fila, Actual^.columna, Actual^.cantidad]));
      Actual := Actual^.derecha;
    end;

    SL.Add('}');
    SL.SaveToFile(DotFile);

    // Ejecutar Graphviz si existe
    if FileExists('/usr/bin/dot') then
      RunCommand('/usr/bin/dot', ['-Tpng', DotFile, '-o', PNGFile], Output);

    ShowMessage('Reporte de relaciones generado en: ' + PNGFile);
  finally
    SL.Free;
  end;
end;

end.

