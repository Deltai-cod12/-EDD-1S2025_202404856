unit UCola;

{$MODE DELPHI}

interface

uses DLL_CON;

type
    PNodoCola = ^TNodoCola;
    TNodoCola = record
        correo: PNodeMsg;
        Next: PNodoCola;
    end;

    PCola = ^TCola;
    TCola = record
        Top, Tail: PNodoCola;
    end;

procedure Enqueue(var C: PCola; correo: PNodeMsg);
function Dequeue(var C: PCola): PNodeMsg;
procedure PrintQueue(var C: PCola);

implementation

procedure Enqueue(var C: PCola; correo: PNodeMsg);
var nuevo: PNodoCola;
begin
    New(nuevo);
    nuevo^.correo := correo;
    nuevo^.Next := nil;

    if C^.Tail = nil then
    begin
        C^.Top := nuevo;
        C^.Tail := nuevo;
    end
    else
    begin
        C^.Tail^.Next := nuevo;
        C^.Tail := nuevo;
    end;
end;

function Dequeue(var C: PCola): PNodeMsg;
var temp: PNodoCola;
begin
    if C^.Top = nil then
    begin
        Result := nil;
        Exit;
    end;

    temp := C^.Top;
    Result := temp^.correo;
    C^.Top := temp^.Next;
    if C^.Top = nil then
        C^.Tail := nil;
    Dispose(temp);
end;

procedure PrintQueue(var C: PCola);
var actual: PNodoCola;
begin
    actual := C^.Top;
    while actual <> nil do
    begin
        Writeln('Correo programado: ', actual^.correo^.asunto);
        actual := actual^.Next;
    end;
end;

end.

