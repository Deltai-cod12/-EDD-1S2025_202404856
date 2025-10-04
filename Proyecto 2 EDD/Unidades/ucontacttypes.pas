unit UContactTypes;

{$MODE DELPHI}

interface

type
    PContactNode = ^TContactNode;
    TContactNode = record
        email: string;
        name: string;
        user: string;
        phone: string;
        Next: PContactNode;
    end;

    PContactList = ^TContactList;
    TContactList = record
        Head, Last: PContactNode;
    end;

procedure InsertContact(var L: PContactList; email, name, user, phone: string);
function SearchContact(var L: PContactList; email: string): PContactNode;
procedure PrintContacts(var L: PContactList);
procedure GenerateDotContactos(var L: PContactList; const DotFile, PNGFile: string);

implementation
uses SysUtils, Classes, Process, Dialogs;

procedure InsertContact(var L: PContactList; email, name, user, phone: string);
var
    nuevo: PContactNode;
begin
    New(nuevo);
    nuevo^.email := email;
    nuevo^.name := name;
    nuevo^.user := user;
    nuevo^.phone := phone;

    if L^.Head = nil then
    begin
        L^.Head := nuevo;
        L^.Last := nuevo;
        nuevo^.Next := nuevo; // la hacemos circular
    end
    else
    begin
        nuevo^.Next := L^.Head;
        L^.Last^.Next := nuevo;
        L^.Last := nuevo;
    end;
end;

function SearchContact(var L: PContactList; email: string): PContactNode;
var
    actual: PContactNode;
begin
    Result := nil;
    if L^.Head = nil then Exit;

    actual := L^.Head;
    repeat
        if actual^.email = email then
        begin
            Result := actual;
            Exit;
        end;
        actual := actual^.Next;
    until actual = L^.Head;
end;

procedure PrintContacts(var L: PContactList);
var
    actual: PContactNode;
begin
    if L^.Head = nil then
    begin
        Writeln('No hay contactos');
        Exit;
    end;

    actual := L^.Head;
    repeat
        Writeln('Nombre: ', actual^.name);
        Writeln('Usuario: ', actual^.user);
        Writeln('Correo: ', actual^.email);
        Writeln('Teléfono: ', actual^.phone);
        Writeln('---------------------');
        actual := actual^.Next;
    until actual = L^.Head;
end;
procedure GenerateDotContactos(var L: PContactList; const DotFile, PNGFile: string);
var
  SL: TStringList;
  Actual: PContactNode;
  Output: AnsiString;
begin
  if (L = nil) or (L^.Head = nil) then
  begin
    ShowMessage('El usuario no tiene contactos.');
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.Add('digraph Contactos {');
    SL.Add('  rankdir=LR;');
    SL.Add('  label="Lista Circular";');
    SL.Add('  labelloc="t";');
    SL.Add('  fontsize=14;');
    SL.Add('  node [shape=record, style=filled, fillcolor=lightgreen];');
    SL.Add('');

    Actual := L^.Head;
    repeat
      SL.Add(Format('  "%s" [label="{Nombre: %s | Usuario: %s | Email: %s | Tel: %s}"];',
        [Actual^.email, Actual^.name, Actual^.user, Actual^.email, Actual^.phone]));

      if Actual^.Next <> nil then
      begin
        SL.Add(Format('  "%s" -> "%s";', [Actual^.email, Actual^.Next^.email]));
        SL.Add(Format('  "%s" <- "%s";', [Actual^.email, Actual^.Next^.email]));
      end;

      Actual := Actual^.Next;
    until Actual = L^.Head;

    SL.Add('}');
    SL.SaveToFile(DotFile);

    if FileExists('/usr/bin/dot') then
      RunCommand('/usr/bin/dot', ['-Tpng', DotFile, '-o', PNGFile], Output);

    ShowMessage('Reporte de Contactos generado en: ' + PNGFile);
  finally
    SL.Free;
  end;
end;

end.
