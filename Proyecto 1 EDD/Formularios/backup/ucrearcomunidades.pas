unit uCrearComunidades;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Comunidades;

type
  { TfrmCrearComunidades }
  TfrmCrearComunidades = class(TForm)
    lblTitulo: TLabel;
    lblNombre: TLabel;
    lblComunidad: TLabel;
    lblCorreo: TLabel;
    txtNombre: TEdit;
    txtComunidad: TEdit;
    txtCorreo: TEdit;
    btnCrear: TButton;
    btnAgregar: TButton;
    btnCerrar: TButton;
    btnReporte: TButton; // 🔹 Nuevo botón
    procedure btnCrearClick(Sender: TObject);
    procedure btnAgregarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnReporteClick(Sender: TObject); // 🔹 Nuevo evento
  private
  public
  end;

var
  frmCrearComunidades: TfrmCrearComunidades;

implementation

{$R *.lfm}

procedure TfrmCrearComunidades.btnCrearClick(Sender: TObject);
var
  response: Boolean;
begin
  response := InsertarComunidad(txtNombre.Text);
  if response then
    ShowMessage('Comunidad creada correctamente.')
  else
    ShowMessage('Error: Ya existe una comunidad con ese nombre.');
end;

procedure TfrmCrearComunidades.btnAgregarClick(Sender: TObject);
var
  response: Boolean;
begin
  response := InsertarUsuario(txtComunidad.Text, txtCorreo.Text);
  if response then
    ShowMessage('Usuario agregado correctamente a la comunidad.')
  else
    ShowMessage('Error: Verifica que la comunidad o el usuario existan o que el usuario ya esté en la comunidad.');
end;

procedure TfrmCrearComunidades.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCrearComunidades.btnReporteClick(Sender: TObject);
var
  dotFile, pngFile: string;
  dotCode: string;
  SL: TStringList;
begin
  dotFile := 'reportes/comunidades.dot';
  pngFile := 'reportes/comunidades.png';

  // Generamos el DOT desde Comunidades
  dotCode := generateGrafComunidades();

  // Guardamos el DOT
  SL := TStringList.Create;
  try
    SL.Text := dotCode;
    if not DirectoryExists('reportes') then
      CreateDir('reportes');
    SL.SaveToFile(dotFile);
  finally
    SL.Free;
  end;

  // Ejecutamos Graphviz para crear el PNG
  if ExecuteProcess('dot', ['-Tpng', dotFile, '-o', pngFile], []) = 0 then
    ShowMessage('Reporte generado en: ' + pngFile)
  else
    ShowMessage('Error al generar el reporte de comunidades.');
end;

end.

