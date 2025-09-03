unit UContactTypes;

{$MODE DELPHI}

interface

type
    PContactNode = ^TContactNode;
    TContactNode = record
        email: string;
        name: string;
        user: string;    // nuevo campo: nombre de usuario
        phone: string;   // nuevo campo: teléfono
        Next: PContactNode;
    end;

    PContactList = ^TContactList;
    TContactList = record
        Head, Last: PContactNode;
    end;

procedure InsertContact(var L: PContactList; email, name, user, phone: string);
function SearchContact(var L: PContactList; email: string): PContactNode;
procedure PrintContacts(var L: PContactList);

implementation
uses SysUtils;

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
        nuevo^.Next := nuevo; // circular
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

end.

