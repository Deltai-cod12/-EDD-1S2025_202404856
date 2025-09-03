unit UPila;

{$MODE DELPHI}

interface

uses DLL_CON; // para usar TNodeMsg

type
    PNodoPila = ^TNodoPila;
    TNodoPila = record
        correo: PNodeMsg;
        Next: PNodoPila;
    end;

    PPila = ^TPila;
    TPila = record
        Top: PNodoPila;
    end;

procedure Push(var P: PPila; correo: PNodeMsg);
function Pop(var P: PPila): PNodeMsg;
procedure PrintStack(var P: PPila);

implementation

procedure Push(var P: PPila; correo: PNodeMsg);
var nuevo: PNodoPila;
begin
    New(nuevo);
    nuevo^.correo := correo;
    nuevo^.Next := P^.Top;
    P^.Top := nuevo;
end;

function Pop(var P: PPila): PNodeMsg;
var temp: PNodoPila;
begin
    if P^.Top = nil then
    begin
        Result := nil;
        Exit;
    end;

    temp := P^.Top;
    Result := temp^.correo;
    P^.Top := temp^.Next;
    Dispose(temp);
end;

procedure PrintStack(var P: PPila);
var actual: PNodoPila;
begin
    actual := P^.Top;
    while actual <> nil do
    begin
        Writeln('Papelera: ', actual^.correo^.asunto);
        actual := actual^.Next;
    end;
end;

end.

