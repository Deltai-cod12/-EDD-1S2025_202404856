program GestionUsuariosCorreos;

uses
  SysUtils, Classes, fpjson, jsonparser;

type
  // Definición de tipos para usuarios (Lista Simple)
  TUsuario = record
    id: Integer;
    nombre: string;
    usuario: string;
    password: string;
    email: string;
    telefono: string;
  end;

  PNodoUsuario = ^TNodoUsuario;
  TNodoUsuario = record
    dato: TUsuario;
    siguiente: PNodoUsuario;
  end;

  TListaUsuarios = record
    cabeza: PNodoUsuario;
    cantidad: Integer;
  end;

  // Definición de tipos para correos (Lista Doblemente Enlazada)
  TCorreo = record
    id: Integer;
    remitente: string;
    estado: string;
    programado: string;
    asunto: string;
    fecha: string;
    mensaje: string;
  end;

  PNodoCorreo = ^TNodoCorreo;
  TNodoCorreo = record
    dato: TCorreo;
    anterior: PNodoCorreo;
    siguiente: PNodoCorreo;
  end;

  TBandejaEntrada = record
    usuario_id: Integer;
    correos: PNodoCorreo;
    primero: PNodoCorreo;
    ultimo: PNodoCorreo;
    cantidad: Integer;
  end;

  TListaBandejas = array of TBandejaEntrada;

// Procedimiento para inicializar la lista de usuarios
procedure InicializarListaUsuarios(var lista: TListaUsuarios);
begin
  lista.cabeza := nil;
  lista.cantidad := 0;
end;

// Procedimiento para inicializar una bandeja de entrada
procedure InicializarBandejaEntrada(var bandeja: TBandejaEntrada; usuario_id: Integer);
begin
  bandeja.usuario_id := usuario_id;
  bandeja.correos := nil;
  bandeja.primero := nil;
  bandeja.ultimo := nil;
  bandeja.cantidad := 0;
end;

// Función para crear un nuevo nodo de usuario
function CrearNodoUsuario(usuario: TUsuario): PNodoUsuario;
var
  nuevoNodo: PNodoUsuario;
begin
  New(nuevoNodo);
  nuevoNodo^.dato := usuario;
  nuevoNodo^.siguiente := nil;
  CrearNodoUsuario := nuevoNodo;
end;

// Función para crear un nuevo nodo de correo
function CrearNodoCorreo(correo: TCorreo): PNodoCorreo;
var
  nuevoNodo: PNodoCorreo;
begin
  New(nuevoNodo);
  nuevoNodo^.dato := correo;
  nuevoNodo^.anterior := nil;
  nuevoNodo^.siguiente := nil;
  CrearNodoCorreo := nuevoNodo;
end;

// Procedimiento para insertar usuario al final de la lista simple
procedure InsertarUsuario(var lista: TListaUsuarios; usuario: TUsuario);
var
  nuevoNodo, actual: PNodoUsuario;
begin
  nuevoNodo := CrearNodoUsuario(usuario);

  if lista.cabeza = nil then
    lista.cabeza := nuevoNodo
  else
  begin
    actual := lista.cabeza;
    while actual^.siguiente <> nil do
      actual := actual^.siguiente;
    actual^.siguiente := nuevoNodo;
  end;

  Inc(lista.cantidad);
end;

// Procedimiento para insertar correo al final de la lista doblemente enlazada
procedure InsertarCorreo(var bandeja: TBandejaEntrada; correo: TCorreo);
var
  nuevoNodo: PNodoCorreo;
begin
  nuevoNodo := CrearNodoCorreo(correo);

  if bandeja.primero = nil then
  begin
    bandeja.primero := nuevoNodo;
    bandeja.ultimo := nuevoNodo;
    bandeja.correos := nuevoNodo;
  end
  else
  begin
    bandeja.ultimo^.siguiente := nuevoNodo;
    nuevoNodo^.anterior := bandeja.ultimo;
    bandeja.ultimo := nuevoNodo;
  end;

  Inc(bandeja.cantidad);
end;

// Función para cargar archivo json (para que funcione auxi puse que lee los archivos que estan en el mismo directorio)
procedure CargarUsuariosDesdeJSON(var lista: TListaUsuarios; const nombreArchivo: string);
var
  archivo: TextFile;
  contenido, linea: string;
  datosJSON: TJSONData;
  usuariosArray: TJSONArray;
  i: Integer;
  usuario: TUsuario;
begin
  // Leer el archivo json
  contenido := '';
  AssignFile(archivo, nombreArchivo);
  Reset(archivo);
  while not EOF(archivo) do
  begin
    ReadLn(archivo, linea);
    contenido := contenido + linea;
  end;
  CloseFile(archivo);

  datosJSON := GetJSON(contenido);
  usuariosArray := datosJSON.FindPath('usuarios') as TJSONArray;

  // Cargar usuarios
  for i := 0 to usuariosArray.Count - 1 do
  begin
    usuario.id := (usuariosArray.Objects[i].FindPath('id') as TJSONNumber).AsInteger;
    usuario.nombre := (usuariosArray.Objects[i].FindPath('nombre') as TJSONString).AsString;
    usuario.usuario := (usuariosArray.Objects[i].FindPath('usuario') as TJSONString).AsString;
    usuario.password := (usuariosArray.Objects[i].FindPath('password') as TJSONString).AsString;
    usuario.email := (usuariosArray.Objects[i].FindPath('email') as TJSONString).AsString;
    usuario.telefono := (usuariosArray.Objects[i].FindPath('telefono') as TJSONString).AsString;

    InsertarUsuario(lista, usuario);
  end;

  datosJSON.Free;
end;

// cargamos el archivo json
procedure CargarCorreosDesdeJSON(var bandejas: TListaBandejas; const nombreArchivo: string);
var
  archivo: TextFile;
  contenido, linea: string;
  datosJSON: TJSONData;
  correosArray, bandejaArray: TJSONArray;
  i, j, usuario_id: Integer;
  correo: TCorreo;
  bandeja: TBandejaEntrada;
begin
  // Leer el archivo json
  contenido := '';
  AssignFile(archivo, nombreArchivo);
  Reset(archivo);
  while not EOF(archivo) do
  begin
    ReadLn(archivo, linea);
    contenido := contenido + linea;
  end;
  CloseFile(archivo);

  datosJSON := GetJSON(contenido);
  correosArray := datosJSON.FindPath('correos') as TJSONArray;

  SetLength(bandejas, correosArray.Count);

  // Cargar correos por usuario
  for i := 0 to correosArray.Count - 1 do
  begin
    usuario_id := (correosArray.Objects[i].FindPath('usuario_id') as TJSONNumber).AsInteger;

    InicializarBandejaEntrada(bandejas[i], usuario_id);

    bandejaArray := correosArray.Objects[i].FindPath('bandeja_entrada') as TJSONArray;

    for j := 0 to bandejaArray.Count - 1 do
    begin
      correo.id := (bandejaArray.Objects[j].FindPath('id') as TJSONNumber).AsInteger;
      correo.remitente := (bandejaArray.Objects[j].FindPath('remitente') as TJSONString).AsString;
      correo.estado := (bandejaArray.Objects[j].FindPath('estado') as TJSONString).AsString;
      correo.programado := (bandejaArray.Objects[j].FindPath('programado') as TJSONString).AsString;
      correo.asunto := (bandejaArray.Objects[j].FindPath('asunto') as TJSONString).AsString;
      correo.fecha := (bandejaArray.Objects[j].FindPath('fecha') as TJSONString).AsString;
      correo.mensaje := (bandejaArray.Objects[j].FindPath('mensaje') as TJSONString).AsString;

      InsertarCorreo(bandejas[i], correo);
    end;
  end;

  datosJSON.Free;
end;

// Procedimiento para mostrar la lista de usuarios
procedure MostrarUsuarios(lista: TListaUsuarios);
var
  actual: PNodoUsuario;
  contador: Integer;
begin
  actual := lista.cabeza;
  contador := 1;

  writeln('=== LISTA DE USUARIOS (', lista.cantidad, ' usuarios) ===');
  while actual <> nil do
  begin
    writeln(contador, '. ID: ', actual^.dato.id);
    writeln('   Nombre: ', actual^.dato.nombre);
    writeln('   Usuario: ', actual^.dato.usuario);
    writeln('   Email: ', actual^.dato.email);
    writeln('   Teléfono: ', actual^.dato.telefono);
    writeln('   ------------------------');

    actual := actual^.siguiente;
    Inc(contador);
  end;
end;

// Procedimiento para mostrar los correos de un usuario específico
procedure MostrarCorreosUsuario(bandeja: TBandejaEntrada; usuarios: TListaUsuarios);
var
  actual: PNodoCorreo;
  contador: Integer;
  usuarioActual: PNodoUsuario;
  nombreUsuario: string;
begin
  // Buscar el nombre del usuario
  nombreUsuario := 'Desconocido';
  usuarioActual := usuarios.cabeza;
  while usuarioActual <> nil do
  begin
    if usuarioActual^.dato.id = bandeja.usuario_id then
    begin
      nombreUsuario := usuarioActual^.dato.nombre;
      Break;
    end;
    usuarioActual := usuarioActual^.siguiente;
  end;

  actual := bandeja.primero;
  contador := 1;

  writeln('=== CORREOS DE ', nombreUsuario, ' (ID: ', bandeja.usuario_id, ', ', bandeja.cantidad, ' correos) ===');
  while actual <> nil do
  begin
    writeln(contador, '. ID: ', actual^.dato.id);
    writeln('   Remitente: ', actual^.dato.remitente);
    writeln('   Estado: ', actual^.dato.estado);
    writeln('   Programado: ', actual^.dato.programado);
    writeln('   Asunto: ', actual^.dato.asunto);
    writeln('   Fecha: ', actual^.dato.fecha);
    writeln('   Mensaje: ', actual^.dato.mensaje);
    writeln('   ------------------------');

    actual := actual^.siguiente;
    Inc(contador);
  end;
end;
begin
  // Inicializar listas
  InicializarListaUsuarios(listaUsuarios);

  // Cargar datos desde archivos JSON
  try
    CargarUsuariosDesdeJSON(listaUsuarios, 'usuarios.json');
    writeln('Usuarios cargados exitosamente.');
  except
    on E: Exception do
      writeln('Error al cargar usuarios: ', E.Message);
  end;

  try
    CargarCorreosDesdeJSON(bandejasCorreos, 'correos.json');
    writeln('Correos cargados exitosamente.');
  except
    on E: Exception do
      writeln('Error al cargar correos: ', E.Message);
  end;

  writeln;

  // Mostrar datos
  MostrarUsuarios(listaUsuarios);
  writeln;

end.
