unit DLL_CON;

{$MODE DELPHI}

interface

uses
  SysUtils, Classes, Dialogs, Process;

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

// Nuevo método para generar DOT y PNG de la bandeja del usuario
procedure GenerateDotBandeja(Inbox: PMsgList; const DotFile, PNGFile: string);

implementation

procedure DLL_Insert(var L: PMsgList; id, remitente, asunto, mensaje, fecha: string);
var
  nuevo: PNodeMsg;
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
var
  actual: PNodeMsg;
begin
  actual := L^.Head;
  while (actual <> nil) and (actual^.id <> id) do
    actual := actual^.Next;
  Result := actual;
end;

procedure DLL_Print(var L: PMsgList);
var
  actual: PNodeMsg;
begin
  actual := L^.Head;
  while actual <> nil do
  begin
    Writeln('ID: ', actual^.id, ' Asunto: ', actual^.asunto, ' Estado: ', actual^.estado);
    actual := actual^.Next;
  end;
end;

procedure GenerateDotBandeja(Inbox: PMsgList; const DotFile, PNGFile: string);
var
  SL: TStringList;
  actual: PNodeMsg;
  Output: AnsiString;
begin
  SL := TStringList.Create;
  try
    SL.Add('digraph Bandeja {');
    SL.Add('  rankdir=LR;');
    SL.Add('  node [shape=record, style=filled, fillcolor=lightyellow];');
    SL.Add('  label="Lista Doblemente Enlazada";');
    SL.Add('  labelloc=t; fontsize=20;');
    SL.Add('');

    if (Inbox = nil) or (Inbox^.Head = nil) then
      SL.Add('  null [label="Bandeja vacía", shape=plaintext];')
    else
    begin
      actual := Inbox^.Head;
      while actual <> nil do
      begin
        SL.Add(Format('  "%s" [label="{ID: %s | Remitente: %s | Asunto: %s | Fecha: %s | Estado: %s}"];',
          [actual^.id, actual^.id, actual^.remitente, actual^.asunto, actual^.fecha, actual^.estado]));

        if actual^.Next <> nil then
          SL.Add(Format('  "%s" -> "%s" [dir=both];', [actual^.id, actual^.Next^.id]));

        actual := actual^.Next;
      end;
    end;

    SL.Add('}');
    SL.SaveToFile(DotFile);

    // Ejecuta Graphviz para generar PNG
    if FileExists('/usr/bin/dot') then
      RunCommand('/usr/bin/dot', ['-Tpng', DotFile, '-o', PNGFile], Output);

    ShowMessage('Reporte de Correos Recibidos generado en: ' + PNGFile);
  finally
    SL.Free;
  end;
end;

end.

