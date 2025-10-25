unit uCrearComunidadesArbol;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  BSTCOMUNIDADES, Process;

type
  { TfrmCrearComunidadesArbol }
  TfrmCrearComunidadesArbol = class(TForm)
    lblTitulo: TLabel;
    lblNombre: TLabel;
    lblComunidad: TLabel;
    lblCorreo: TLabel;
    lblMensaje: TLabel;
    lblFecha: TLabel;
    txtNombre: TEdit;
    txtComunidad: TEdit;
    txtCorreo: TEdit;
    txtMensaje: TEdit;
    txtFecha: TEdit;
    btnCrear: TButton;
    btnAgregar: TButton;
    btnInsertarMsg: TButton;
    btnCerrar: TButton;
    btnReporte: TButton;
    procedure btnCrearClick(Sender: TObject);
    procedure btnAgregarClick(Sender: TObject);
    procedure btnInsertarMsgClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnReporteClick(Sender: TObject);
  private
  public
  end;

var
  frmCrearComunidadesArbol: TfrmCrearComunidadesArbol;

implementation

{$R *.lfm}

procedure TfrmCrearComunidadesArbol.btnCrearClick(Sender: TObject);
var
  response: Boolean;
begin
  response := InsertBSTNode(txtNombre.Text, DateToStr(Now));
  if response then
    ShowMessage('Comunidad creada correctamente.')
  else
    ShowMessage('Error: Ya existe una comunidad con ese nombre.');
end;

procedure TfrmCrearComunidadesArbol.btnAgregarClick(Sender: TObject);
var
  response: Boolean;
begin
  response := insertUsers(txtComunidad.Text, txtCorreo.Text);
  if response then
    ShowMessage('Usuario agregado correctamente a la comunidad.')
  else
    ShowMessage('Error: Verifica que la comunidad exista o que el usuario ya esté en la comunidad.');
end;

procedure TfrmCrearComunidadesArbol.btnInsertarMsgClick(Sender: TObject);
var
  response: Boolean;
begin
  response := insertEmails(txtComunidad.Text, txtCorreo.Text, txtMensaje.Text, txtFecha.Text);
  if response then
    ShowMessage('Mensaje agregado correctamente a la comunidad.')
  else
    ShowMessage('Error: Verifica que la comunidad y usuario existan en la comunidad.');
end;

procedure TfrmCrearComunidadesArbol.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCrearComunidadesArbol.btnReporteClick(Sender: TObject);
var
  dotFile, pngFile: string;
  dotCode: string;
  SL: TStringList;
  Output: string;
begin
  dotFile := 'reportes/comunidades.dot';
  pngFile := 'reportes/comunidades.png';

  // Generamos el DOT desde el BST
  dotCode := BST_GENERARDOT();

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
  if FileExists('/usr/bin/dot') then
  begin
    RunCommand('/usr/bin/dot', ['-Tpng', dotFile, '-o', pngFile], Output);
    ShowMessage('Reporte generado en: ' + pngFile);
  end
  else
    ShowMessage('No se encontró Graphviz (dot). Instálalo para generar el gráfico.');
end;

end.

