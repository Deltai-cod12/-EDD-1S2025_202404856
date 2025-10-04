unit Comunidades;
{$MODE DELPHI}
interface

uses
   Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, SLL, Process;


type
   TUsuarioData = record
       correo: string;
   end;


   TComunidadData = record
       nombre: string;
   end;


function InsertarUsuario(nombreComunidad,email: string): Boolean;
function InsertarComunidad(nombre: string): Boolean;
function generateGrafComunidades(): string;

implementation

   type
       PUsuarioCell = ^TUsuarioCell;
       TUsuarioCell = record
           correo: string;
           next: PUsuarioCell;
       end;


       PComunidadHeader = ^TComunidadHeader;
       TComunidadHeader = record
           nombre: string;
           listaUsuarios: PUsuarioCell;
           next: PComunidadHeader;
       end;
   var
       Head: PComunidadHeader = nil;



   function InsertarComunidad(nombre: string): Boolean;
var
    nuevaComunidad, actual: PComunidadHeader;
begin
    Result := False; // Valor por defecto
    New(nuevaComunidad);
    nuevaComunidad^.nombre := Trim(nombre);
    nuevaComunidad^.listaUsuarios := nil;
    nuevaComunidad^.next := nil;

    if Head = nil then
    begin
        Head := nuevaComunidad;
        Result := True;
        Exit;
    end;

    actual := Head;
    // Verificar si ya existe la comunidad
    while actual <> nil do
    begin
        if SameText(actual^.nombre, nuevaComunidad^.nombre) then
        begin
            Dispose(nuevaComunidad);
            Exit;
        end;
        actual := actual^.next;
    end;

    // Insertar al final de la lista
    actual := Head;
    while actual^.next <> nil do
        actual := actual^.next;

    actual^.next := nuevaComunidad;
    Result := True;
end;

   function InsertarUsuario(nombreComunidad, email: string): Boolean;
var
    comunidadActual: PComunidadHeader;
    nuevoUsuario, usuarioActual: PUsuarioCell;
    user: TDataUser;
begin
    Result := False;

    // Buscar la comunidad
    comunidadActual := Head;
    while (comunidadActual <> nil) and (comunidadActual^.nombre <> Trim(nombreComunidad)) do
        comunidadActual := comunidadActual^.next;

    if comunidadActual = nil then Exit; // comunidad no encontrada

    // Verificar que el usuario exista en SLL
    user := SSL_GETBYEMAIL(email);
    if user.email = '' then Exit; // usuario no existe

    // Crear nodo nuevo
    New(nuevoUsuario);
    nuevoUsuario^.correo := Trim(email);
    nuevoUsuario^.next := nil;

    // Si la lista de usuarios está vacía
    if comunidadActual^.listaUsuarios = nil then
    begin
        comunidadActual^.listaUsuarios := nuevoUsuario;
        Result := True;
        Exit;
    end;

    // Verificar que el usuario no esté ya en la lista
    usuarioActual := comunidadActual^.listaUsuarios;
    while usuarioActual <> nil do
    begin
        if SameText(usuarioActual^.correo, Trim(email)) then
        begin
            Dispose(nuevoUsuario); // ya existe
            Exit;
        end;
        if usuarioActual^.next = nil then Break;
        usuarioActual := usuarioActual^.next;
    end;

    // Agregar al final
    usuarioActual^.next := nuevoUsuario;
    Result := True;
end;

   function EscapeDotString(const S: string): string;
   var
       Res: string;
       i: integer;
   begin
       Res := '';
       for i := 1 to Length(S) do
       begin
           case S[i] of
               '"': Res := Res + '\"';
               '\': Res := Res + '\\';
               '|': Res := Res + '\|';
               '{': Res := Res + '\{';
               '}': Res := Res + '\}';
               #10: Res := Res + '\n';
               #13: Res := Res + '\n';
           else
               Res := Res + S[i];


           end;
       end;


       Result := Res;
   end;

   procedure GenerateDotComunidades(const DotFile, PNGFile: string);
var
  SL: TStringList;
  comunidadActual: PComunidadHeader;
  usuarioActual: PUsuarioCell;
  contadorComunidad, contadorUsuarios: Integer;
  nodoComunidad, nodoUsuario, nodoSig: string;
  Output: AnsiString;
begin
  SL := TStringList.Create;
  try
    SL.Add('digraph Comunidades {');
    SL.Add('  rankdir=LR;');
    SL.Add('  nodesep=0.5;');
    SL.Add('  edge[arrowhead=normal];');
    SL.Add('  node [shape=box, style=filled, fillcolor=lightblue];');
    SL.Add('');

    if Head = nil then
    begin
      SL.Add('  null [label="LISTA VACÍA", shape=plaintext];');
    end
    else
    begin
      contadorComunidad := 0;
      comunidadActual := Head;

      while comunidadActual <> nil do
      begin
        nodoComunidad := Format('comunidad%d', [contadorComunidad]);
        SL.Add(Format('  %s [label="%s", fillcolor=lightgreen];',
          [nodoComunidad, EscapeDotString(comunidadActual^.nombre)]));

        // Enlace con la siguiente comunidad
        if comunidadActual^.next <> nil then
        begin
          nodoSig := Format('comunidad%d', [contadorComunidad + 1]);
          SL.Add(Format('  %s -> %s;', [nodoComunidad, nodoSig]));
        end;

        // Usuarios de la comunidad
        if comunidadActual^.listaUsuarios <> nil then
        begin
          contadorUsuarios := 0;
          usuarioActual := comunidadActual^.listaUsuarios;
          nodoUsuario := Format('usuario%d_%d', [contadorComunidad, contadorUsuarios]);

          SL.Add(Format('  %s -> %s;', [nodoComunidad, nodoUsuario]));

          while usuarioActual <> nil do
          begin
            nodoUsuario := Format('usuario%d_%d', [contadorComunidad, contadorUsuarios]);
            SL.Add(Format('  %s [label="%s"];',
              [nodoUsuario, EscapeDotString(usuarioActual^.correo)]));

            if usuarioActual^.next <> nil then
            begin
              nodoSig := Format('usuario%d_%d', [contadorComunidad, contadorUsuarios + 1]);
              SL.Add(Format('  %s -> %s;', [nodoUsuario, nodoSig]));
            end;

            Inc(contadorUsuarios);
            usuarioActual := usuarioActual^.next;
          end;

          // Rank same (comunidad y usuarios al mismo nivel)
          SL.Add('{rank=same; ' + nodoComunidad);
          for contadorUsuarios := 0 to contadorUsuarios - 1 do
            SL.Add(' ' + Format('usuario%d_%d', [contadorComunidad, contadorUsuarios]));
          SL.Add(' }');
        end;

        Inc(contadorComunidad);
        comunidadActual := comunidadActual^.next;
      end;
    end;

    SL.Add('}');
    SL.SaveToFile(DotFile);

    // Ejecuta Graphviz para generar PNG
    if FileExists('/usr/bin/dot') then
      RunCommand('/usr/bin/dot', ['-Tpng', DotFile, '-o', PNGFile], Output)
    else if FileExists('C:\Program Files\Graphviz\bin\dot.exe') then
      RunCommand('C:\Program Files\Graphviz\bin\dot.exe', ['-Tpng', DotFile, '-o', PNGFile], Output)
    else
      ShowMessage('No se encontró Graphviz (dot). Instálalo o ajusta la ruta.');

    ShowMessage('Reporte de Comunidades generado en: ' + PNGFile);
  finally
    SL.Free;
  end;
end;


end.
