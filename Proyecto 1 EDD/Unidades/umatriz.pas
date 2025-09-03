unit UMatriz;

{$MODE DELPHI}

interface

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

implementation
uses SysUtils;

procedure MatrizInit(var M: PMatriz);
begin
    New(M);
    M^.Head := nil;
end;

procedure InsertRelacion(var M: PMatriz; fila, columna: string);
var actual: PMatrizNodo;
begin
    actual := SearchRelacion(M, fila, columna);
    if actual <> nil then
    begin
        Inc(actual^.cantidad);
        Exit;
    end;

    New(actual);
    actual^.fila := fila;
    actual^.columna := columna;
    actual^.cantidad := 1;
    actual^.derecha := M^.Head;
    actual^.abajo := nil;
    M^.Head := actual;
end;

function SearchRelacion(var M: PMatriz; fila, columna: string): PMatrizNodo;
var actual: PMatrizNodo;
begin
    actual := M^.Head;
    while actual <> nil do
    begin
        if (actual^.fila = fila) and (actual^.columna = columna) then
        begin
            Result := actual;
            Exit;
        end;
        actual := actual^.derecha;
    end;
    Result := nil;
end;

procedure PrintMatriz(var M: PMatriz);
var actual: PMatrizNodo;
begin
    actual := M^.Head;
    while actual <> nil do
    begin
        Writeln(actual^.fila, ' -> ', actual^.columna, ' = ', actual^.cantidad);
        actual := actual^.derecha;
    end;
end;

end.

