unit BSTCOMUNIDADES;

{$MODE DELPHI}

interface

uses
  SysUtils, Classes, SLL;

type
  TMsgData = record
    correo: string;
    mensaje: string;
    fecha: string;
  end;

  TComunidadData = record
    nombre: string;
  end;

  PUserData = record
    correo: string;
  end;

function InsertBSTNode(nombreComunidad, fecha: String): Boolean;
function insertUsers(nombreComunidad, email: string): Boolean;
function insertEmails(nombreComunidad, email, mensaje, fecha: string): Boolean;
function BST_GENERARDOT(): string;

implementation

type
  PMsgCell = ^TMsgCell;
  TMsgCell = record
    correo: string;
    mensaje: string;
    fecha: string;
    next: PMsgCell;
  end;

  PUserCell = ^TUserCell;
  TUserCell = record
    correo: string;
    next: PUserCell;
  end;

  PComunidadHeader = ^TComunidadHeader;
  TComunidadHeader = record
    nombreComunidad: string;
    fecha: string;
    numeroMensajes: Integer;
    users: PUserCell;
    msgs: PMsgCell;
    left, right: PComunidadHeader;
  end;

var
  root: PComunidadHeader = nil;

function InsertBST(var root: PComunidadHeader; nombreComunidad, fecha: String): Boolean;
var
  newCom: PComunidadHeader;
begin
  Result := False;
  if root = nil then
  begin
    New(newCom);
    newCom^.nombreComunidad := nombreComunidad;
    newCom^.fecha := fecha;
    newCom^.numeroMensajes := 0;
    newCom^.msgs := nil;
    newCom^.users := nil;
    newCom^.left := nil;
    newCom^.right := nil;

    root := newCom;
    Result := True;
  end
  else if nombreComunidad < root^.nombreComunidad then
    Result := InsertBST(root^.left, nombreComunidad, fecha)
  else if nombreComunidad > root^.nombreComunidad then
    Result := InsertBST(root^.right, nombreComunidad, fecha)
  else
    Exit; // ya existe
end;

function InsertBSTNode(nombreComunidad, fecha: String): Boolean;
begin
  Result := InsertBST(root, nombreComunidad, fecha);
end;

function SearchBST(var root: PComunidadHeader; nameCom: String): PComunidadHeader;
begin
  if (root = nil) or (root^.nombreComunidad = nameCom) then
    Result := root
  else if nameCom < root^.nombreComunidad then
    Result := SearchBST(root^.left, nameCom)
  else
    Result := SearchBST(root^.right, nameCom);
end;

function insertUsers(nombreComunidad, email: string): Boolean;
var
  currentCom: PComunidadHeader;
  newUser, currentUser: PUserCell;
  user: TDataUser;
begin
  currentCom := SearchBST(root, nombreComunidad);
  user := SSL_GETBYEMAIL(email);

  if user.email = '' then
  begin
    Result := False;
    Exit;
  end;

  if currentCom <> nil then
  begin
    New(newUser);
    newUser^.correo := Trim(email);
    newUser^.next := nil;

    if currentCom^.users = nil then
    begin
      currentCom^.users := newUser;
      Result := True;
      Exit;
    end
    else
    begin
      currentUser := currentCom^.users;
      while (currentUser <> nil) do
      begin
        if SameText(currentUser^.correo, Trim(email)) then
        begin
          Dispose(newUser);
          Result := False;
          Exit;
        end;
        if currentUser^.next = nil then
        begin
          currentUser^.next := newUser;
          Result := True;
          Exit;
        end;
        currentUser := currentUser^.next;
      end;
    end;
  end
  else
  begin
    Result := False;
    Exit;
  end;
end;

function insertEmails(nombreComunidad, email, mensaje, fecha: string): Boolean;
var
  currentCom: PComunidadHeader;
  newMsg, currentMsg: PMsgCell;
  currentUser: PUserCell;
begin
  Result := False;
  currentCom := SearchBST(root, nombreComunidad);

  if currentCom <> nil then
  begin
    if currentCom^.users = nil then
    begin
      Result := False;
      Exit;
    end
    else
    begin
      currentUser := currentCom^.users;
      while (currentUser <> nil) do
      begin
        if SameText(currentUser^.correo, Trim(email)) then
        begin
          New(newMsg);
          newMsg^.correo := Trim(email);
          newMsg^.mensaje := Trim(mensaje);
          newMsg^.fecha := Trim(fecha);
          newMsg^.next := nil;

          if currentCom^.msgs = nil then
          begin
            currentCom^.msgs := newMsg;
            currentCom^.numeroMensajes := 1;
            Result := True;
            Exit;
          end
          else
          begin
            currentMsg := currentCom^.msgs;
            while (currentMsg^.next <> nil) do
              currentMsg := currentMsg^.next;
            Inc(currentCom^.numeroMensajes);
            currentMsg^.next := newMsg;
            Result := True;
            Exit;
          end;
        end;
        currentUser := currentUser^.next;
      end;
    end;
  end
  else
  begin
    Result := False;
    Exit;
  end;
end;

procedure GenerarNodosDOT(var SL: TStringList; nodo: PComunidadHeader);
begin
  if nodo = nil then Exit;

  SL.Add(Format(
    '"%s" [label="Comunidad: %s\nFecha: %s\nMensajes: %d", shape=box, style=filled, fillcolor=lightgreen];',
    [nodo^.nombreComunidad, nodo^.nombreComunidad, nodo^.fecha, nodo^.numeroMensajes]
  ));

  if nodo^.left <> nil then
  begin
    SL.Add(Format('"%s" -> "%s";', [nodo^.nombreComunidad, nodo^.left^.nombreComunidad]));
    GenerarNodosDOT(SL, nodo^.left);
  end;

  if nodo^.right <> nil then
  begin
    SL.Add(Format('"%s" -> "%s";', [nodo^.nombreComunidad, nodo^.right^.nombreComunidad]));
    GenerarNodosDOT(SL, nodo^.right);
  end;
end;

function BST_GENERARDOT: string;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add('digraph Comunidades {');
    SL.Add('  rankdir=TB;');
    SL.Add('  node [fontname="Arial", style=filled, fillcolor=lightyellow];');

    if root <> nil then
      GenerarNodosDOT(SL, root)
    else
      SL.Add('"vacio" [label="(No hay comunidades)"];');

    SL.Add('}');
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

end.

