unit uAbrirMenuRoot;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL, fpjson, jsonparser;

type
  { TfrmAbrirMenuRoot }
  TfrmAbrirMenuRoot = class(TForm)
    btnCargaMasiva: TButton;
    btnReporteUsuarios: TButton;
    btnReporteRelaciones: TButton;
    OpenDialog1: TOpenDialog;
    procedure btnCargaMasivaClick(Sender: TObject);
    procedure btnReporteUsuariosClick(Sender: TObject);
    procedure btnReporteRelacionesClick(Sender: TObject);
  private
    procedure CargarUsuariosDesdeJSON(const FileName: string);
    procedure GenerarReporteUsuarios;
    procedure GenerarReporteRelaciones;
  public
  end;

var
  frmAbrirMenuRoot: TfrmAbrirMenuRoot;

implementation

{$R *.lfm}

{ --- BOTONES --- }

procedure TfrmAbrirMenuRoot.btnCargaMasivaClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    CargarUsuariosDesdeJSON(OpenDialog1.FileName);
end;

procedure TfrmAbrirMenuRoot.btnReporteUsuariosClick(Sender: TObject);
begin
  GenerarReporteUsuarios;
end;

procedure TfrmAbrirMenuRoot.btnReporteRelacionesClick(Sender: TObject);
begin
  GenerarReporteRelaciones;
end;

{ --- FUNCIONES PRIVADAS --- }

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

procedure TfrmAbrirMenuRoot.GenerarReporteUsuarios;
var
  SL: TStringList;
  FilePath: string;
  Actual: string;
begin
  FilePath := 'Root-Reportes/ReporteUsuarios.txt';
  if not DirectoryExists('Root-Reportes') then
    ForceDirectories('Root-Reportes');

  SL := TStringList.Create;
  try
    SL.Add('REPORTE DE USUARIOS');
    SL.Add('-----------------');
    SSL_PRINT; // Muestra en consola, opcional
    Actual := SSL_GENERATE_DOT;
    SL.Add(Actual);
    SL.SaveToFile(FilePath);
    ShowMessage('Reporte de usuarios generado en: ' + FilePath);
  finally
    SL.Free;
  end;
end;

procedure TfrmAbrirMenuRoot.GenerarReporteRelaciones;
begin
  ShowMessage('Generando reporte de relaciones (pendiente de implementar)');
end;

end.

