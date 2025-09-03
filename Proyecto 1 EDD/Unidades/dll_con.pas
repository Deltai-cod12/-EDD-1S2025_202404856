unit DLL_CON;

{$MODE DELPHI}

interface

type
    PNodeMsg = ^TNodeMsg;
    TNodeMsg = record
        id: string;
        remitente: string;
        asunto: string;
        mensaje: string;
        fecha: string;
        estado: string; // L = leído, NL = no leído
        Prev, Next: PNodeMsg;
    end;

    PMsgList = ^TMsgList;
    TMsgList = record
        Head, Last: PNodeMsg;
    end;

procedure DLL_Insert(var L: PMsgList; id, remitente, asunto, mensaje, fecha: string);
function DLL_Search(var L: PMsgList; id: string): PNodeMsg;
procedure DLL_Print(var L: PMsgList);

implementation
uses SysUtils;

procedure DLL_Insert(var L: PMsgList; id, remitente, asunto, mensaje, fecha: string);
var nuevo: PNodeMsg;
begin
    New(nuevo);
    nuevo^.id := id;
    nuevo^.remitente := remitente;
    nuevo^.asunto := asunto;
    nuevo^.mensaje := mensaje;
    nuevo^.fecha := fecha;
    nuevo^.estado := 'NL';
    nuevo^.Prev := nil;
    nuevo^.Next := nil;

    if L^.Head = nil then
    begin
        L^.Head := nuevo;
        L^.Last := nuevo;
    end
    else
    begin
        nuevo^.Prev := L^.Last;
        L^.Last^.Next := nuevo;
        L^.Last := nuevo;
    end;
end;

function DLL_Search(var L: PMsgList; id: string): PNodeMsg;
var actual: PNodeMsg;
begin
    actual := L^.Head;
    while (actual <> nil) and (actual^.id <> id) do
        actual := actual^.Next;
    Result := actual;
end;

procedure DLL_Print(var L: PMsgList);
var actual: PNodeMsg;
begin
    actual := L^.Head;
    while actual <> nil do
    begin
        Writeln('ID: ', actual^.id, ' Asunto: ', actual^.asunto, ' Estado: ', actual^.estado);
        actual := actual^.Next;
    end;
end;

end.

