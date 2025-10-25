unit UCola;

{$MODE DELPHI}

interface

uses DLL_CON, SysUtils, Classes, Process, Dialogs;

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
procedure GenerateDotProgramados(Cola: PCola; const DotFile, PNGFile: string);

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
procedure GenerateDotProgramados(Cola: PCola; const DotFile, PNGFile: string);
var
  SL: TStringList;
  Actual: PNodoCola;
  Output: AnsiString;
begin
  SL := TStringList.Create;
  try
    SL.Add('digraph Programados {');
    SL.Add('  rankdir=LR;'); // Left to Right
    SL.Add('  node [shape=record, style=filled, fillcolor=lightgreen];');
    SL.Add('  label="Cola";');
    SL.Add('  labelloc=t;'); // Título en la parte superior
    SL.Add('');

    if (Cola = nil) or (Cola^.Top = nil) then
      SL.Add('  null [label="Cola vacía", shape=plaintext];')
    else
    begin
      Actual := Cola^.Top;
      while Actual <> nil do
      begin
        SL.Add(Format('  "%s" [label="{ID: %s | Remitente: %s | Asunto: %s | Fecha: %s | Estado: %s}"];',
          [Actual^.correo^.id, Actual^.correo^.id, Actual^.correo^.remitente, Actual^.correo^.asunto, Actual^.correo^.fecha, Actual^.correo^.estado]));
        if Actual^.Next <> nil then
          SL.Add(Format('  "%s" -> "%s";', [Actual^.correo^.id, Actual^.Next^.correo^.id]));
        Actual := Actual^.Next;
      end;
    end;

    SL.Add('}');
    SL.SaveToFile(DotFile);

    // Ejecuta Graphviz para generar PNG
    if FileExists('/usr/bin/dot') then
      RunCommand('/usr/bin/dot', ['-Tpng', DotFile, '-o', PNGFile], Output);

    ShowMessage('Reporte de Correos Programados generado en: ' + PNGFile);
  finally
    SL.Free;
  end;
end;

end.

