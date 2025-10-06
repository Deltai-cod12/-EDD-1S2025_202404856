unit uAbrirMenuRoot;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL, fpjson, jsonparser, uMatriz, Comunidades, uCrearComunidades,
  uCrearComunidadesArbol, process, DLL_CON;

type
  { TfrmAbrirMenuRoot }
  TfrmAbrirMenuRoot = class(TForm)
    btnCargaMasivaUsuarios: TButton;
    btnCargaMasivaCorreos: TButton;
    btnReporteUsuarios: TButton;
    btnReporteRelaciones: TButton;
    btnCrearComunidades: TButton;
    btnCrearComunidadesArbol: TButton;   // <-- nuevo botón
    btnGrafComunidades: TButton;
    OpenDialog1: TOpenDialog;
    procedure btnCargaMasivaUsuariosClick(Sender: TObject);
    procedure btnCargaMasivaCorreosClick(Sender: TObject);
    procedure btnReporteUsuariosClick(Sender: TObject);
    procedure btnReporteRelacionesClick(Sender: TObject);
    procedure btnCrearComunidadesClick(Sender: TObject);
    procedure btnCrearComunidadesArbolClick(Sender: TObject); // <-- handler
  private
    MatrizRelaciones: PMatriz;
    procedure CargarUsuariosDesdeJSON(const FileName: string);
    procedure CargarCorreosDesdeJSON(const FileName: string);
    procedure GenerarReporteUsuarios;
    procedure GenerarReporteRelaciones;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frmAbrirMenuRoot: TfrmAbrirMenuRoot;

implementation

{$R *.lfm}

constructor TfrmAbrirMenuRoot.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  MatrizInit(MatrizRelaciones); // inicializar matriz de relaciones
end;

procedure TfrmAbrirMenuRoot.btnCargaMasivaUsuariosClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    CargarUsuariosDesdeJSON(OpenDialog1.FileName);
end;

procedure TfrmAbrirMenuRoot.btnCargaMasivaCorreosClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    CargarCorreosDesdeJSON(OpenDialog1.FileName);
end;

procedure TfrmAbrirMenuRoot.btnReporteUsuariosClick(Sender: TObject);
begin
  GenerarReporteUsuarios;
end;

procedure TfrmAbrirMenuRoot.btnReporteRelacionesClick(Sender: TObject);
begin
  GenerarReporteRelaciones;
end;

procedure TfrmAbrirMenuRoot.btnCrearComunidadesClick(Sender: TObject);
begin
  if not Assigned(frmCrearComunidades) then
    Application.CreateForm(TfrmCrearComunidades, frmCrearComunidades);
  frmCrearComunidades.Show;
  frmCrearComunidades.BringToFront;
end;

// ================= NUEVO: abrir formulario de comunidades con BST =================
procedure TfrmAbrirMenuRoot.btnCrearComunidadesArbolClick(Sender: TObject);
begin
  if not Assigned(frmCrearComunidadesArbol) then
    Application.CreateForm(TfrmCrearComunidadesArbol, frmCrearComunidadesArbol);
  frmCrearComunidadesArbol.Show;
  frmCrearComunidadesArbol.BringToFront;
end;

// ====================== CARGA MASIVA DE USUARIOS ======================
procedure TfrmAbrirMenuRoot.CargarUsuariosDesdeJSON(const FileName: string);
var
  jsonData: TJSONData;
  usuariosArray: TJSONArray;
  i, contadorUsuarios: Integer;
  usuarioObj: TJSONObject;
  sl: TStringList;
begin
  if not FileExists(FileName) then
  begin
    ShowMessage('El archivo no existe');
    Exit;
  end;

  contadorUsuarios := 0;
  sl := TStringList.Create;
  try
    sl.LoadFromFile(FileName);
    jsonData := GetJSON(sl.Text);
    try
      if jsonData.JSONType = jtObject then
      begin
        usuariosArray := TJSONArray((jsonData as TJSONObject).FindPath('usuarios'));
        if usuariosArray = nil then
        begin
          ShowMessage('No se encontró el arreglo "usuarios" en el JSON');
          Exit;
        end;

        for i := 0 to usuariosArray.Count - 1 do
        begin
          usuarioObj := usuariosArray.Objects[i];
          if SLL_INSERT(
            IntToStr(usuarioObj.Get('id', 0)),
            usuarioObj.Get('nombre', ''),
            usuarioObj.Get('email', ''),
            usuarioObj.Get('usuario', ''),
            usuarioObj.Get('telefono', ''),
            usuarioObj.Get('password', '')
          ) then
            Inc(contadorUsuarios);
        end;

        ShowMessage('Usuarios cargados exitosamente: ' + IntToStr(contadorUsuarios));
      end
      else
        ShowMessage('Archivo JSON inválido');
    finally
      jsonData.Free;
    end;
  finally
    sl.Free;
  end;
end;

{ ====================== CARGA MASIVA DE CORREOS ====================== }
procedure TfrmAbrirMenuRoot.CargarCorreosDesdeJSON(const FileName: string);
var
  jsonData: TJSONData;
  correosArray: TJSONArray;
  i, contadorCorreos: Integer;
  correoObj: TJSONObject;
  sl: TStringList;
  destinatario: TDataUser;
begin
  if not FileExists(FileName) then
  begin
    ShowMessage('El archivo no existe');
    Exit;
  end;

  contadorCorreos := 0;
  sl := TStringList.Create;
  try
    sl.LoadFromFile(FileName);
    jsonData := GetJSON(sl.Text);
    try
      if jsonData.JSONType = jtObject then
      begin
        correosArray := TJSONArray((jsonData as TJSONObject).FindPath('correos'));
        if correosArray = nil then
        begin
          ShowMessage('No se encontró el arreglo "correos" en el JSON');
          Exit;
        end;

        for i := 0 to correosArray.Count - 1 do
        begin
          correoObj := correosArray.Objects[i];
          destinatario := SSL_GETBYEMAIL(correoObj.Get('destinatario', ''));
          if destinatario.email = '' then
            Continue;

          DLL_Insert(destinatario.Inbox,
                     IntToStr(correoObj.Get('id', 0)),
                     correoObj.Get('remitente', ''),
                     correoObj.Get('asunto', ''),
                     correoObj.Get('mensaje', ''),
                     DateTimeToStr(Now));

          Inc(contadorCorreos);
        end;

        ShowMessage('Correos cargados exitosamente: ' + IntToStr(contadorCorreos));
      end
      else
        ShowMessage('Archivo JSON inválido');
    finally
      jsonData.Free;
    end;
  finally
    sl.Free;
  end;
end;

{ ====================== REPORTES ====================== }
procedure TfrmAbrirMenuRoot.GenerarReporteUsuarios;
var
  SL: TStringList;
  FilePathTXT, DotFile, PNGFile, DotContent: string;
begin
  if not DirectoryExists('Root-Reportes') then
    ForceDirectories('Root-Reportes');

  FilePathTXT := 'Root-Reportes/ReporteUsuarios.txt';
  DotFile := 'Root-Reportes/Usuarios.dot';
  PNGFile := 'Root-Reportes/Usuarios.png';

  SL := TStringList.Create;
  try
    SL.Add('REPORTE DE USUARIOS');
    SL.Add('------------------');
    SSL_PRINT;

    DotContent := SSL_GENERATE_DOT;
    SL.Add(DotContent);

    SL.SaveToFile(FilePathTXT);
  finally
    SL.Free;
  end;

  GenerateDotUsuarios(DotFile, PNGFile);
end;

procedure TfrmAbrirMenuRoot.GenerarReporteRelaciones;
var
  DotFile, PNGFile: string;
begin
  if not DirectoryExists('Root-Reportes') then
    ForceDirectories('Root-Reportes');

  DotFile := 'Root-Reportes' + PathDelim + 'Relaciones.dot';
  PNGFile := 'Root-Reportes' + PathDelim + 'Relaciones.png';

  if (MatrizRelaciones = nil) or (MatrizRelaciones^.Head = nil) then
  begin
    ShowMessage('No hay relaciones registradas para generar el reporte.');
    Exit;
  end;

  GenerateDotRelaciones(MatrizRelaciones, DotFile, PNGFile);
  ShowMessage('Reporte de relaciones generado en: ' + PNGFile);
end;

end.
