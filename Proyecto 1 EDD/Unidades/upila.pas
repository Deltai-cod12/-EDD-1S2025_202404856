unit UPila;

{$MODE DELPHI}

interface

uses
  Classes, SysUtils, Process, Dialogs, DLL_CON;

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

// Operaciones básicas de la pila
procedure Push(var P: PPila; correo: PNodeMsg);
function Pop(var P: PPila): PNodeMsg;
procedure PrintStack(var P: PPila);

// Generación de DOT para Graphviz
procedure GenerateDotPapelera(Pila: PPila; const DotFile, PNGFile: string);

implementation

procedure Push(var P: PPila; correo: PNodeMsg);
var
  nuevo: PNodoPila;
begin
  New(nuevo);
  nuevo^.correo := correo;
  nuevo^.Next := P^.Top;
  P^.Top := nuevo;
end;

function Pop(var P: PPila): PNodeMsg;
var
  temp: PNodoPila;
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
var
  actual: PNodoPila;
begin
  actual := P^.Top;
  while actual <> nil do
  begin
    Writeln('Papelera: ', actual^.correo^.asunto);
    actual := actual^.Next;
  end;
end;

procedure GenerateDotPapelera(Pila: PPila; const DotFile, PNGFile: string);
var
  SL: TStringList;
  Actual: PNodoPila;
  Output: AnsiString;
begin
  SL := TStringList.Create;
  try
    SL.Add('digraph Papelera {');
    SL.Add('  rankdir=TB;'); // Vertical: Top -> Bottom
    SL.Add('  node [shape=record, style=filled, fillcolor=lightblue];');
    SL.Add('  label="Pila";');
    SL.Add('  labelloc=t; fontsize=20;');
    SL.Add('');

    if (Pila = nil) or (Pila^.Top = nil) then
      SL.Add('  null [label="Papelera vacía", shape=plaintext];')
    else
    begin
      Actual := Pila^.Top;
      while Actual <> nil do
      begin
        SL.Add(Format('  "%s" [label="{ID: %s | Remitente: %s | Asunto: %s | Estado: %s}"];',
          [Actual^.correo^.id, Actual^.correo^.id, Actual^.correo^.remitente, Actual^.correo^.asunto, Actual^.correo^.estado]));
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

    ShowMessage('Reporte de la Papelera generado en: ' + PNGFile);
  finally
    SL.Free;
  end;
end;

end.

