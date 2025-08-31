unit uLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uListaSimpleUsuarios, uPrincipal, uAdminRoot;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    btnLogin: TButton;
    btnRegistrar: TButton;
    edtUsuario: TEdit;
    edtPassword: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnLoginClick(Sender: TObject);
    procedure btnRegistrarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ListaUsuarios: TListaUsuarios;
  public

  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.lfm}

{ TfrmLogin }

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  ListaUsuarios := TListaUsuarios.Create;

  // Cargar usuarios desde JSON si existe
  if FileExists('data/usuarios.json') then
    ListaUsuarios.CargarDesdeJSON('data/usuarios.json');

  // Configurar interfaz
  Caption := 'EDDMail - Inicio de Sesión';
  Label1.Caption := 'Sistema de Correo EDD';
  Label2.Caption := 'Usuario:';
  Label3.Caption := 'Contraseña:';
  btnLogin.Caption := 'Iniciar Sesión';
  btnRegistrar.Caption := 'Registrar Nuevo';

  // Configurar campo de password
  edtPassword.PasswordChar := '*';
end;

procedure TfrmLogin.FormDestroy(Sender: TObject);
begin
  ListaUsuarios.Free;
end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  usuario: PUsuario;
begin
  if (edtUsuario.Text = '') or (edtPassword.Text = '') then
  begin
    ShowMessage('Por favor ingrese usuario y contraseña');
    Exit;
  end;

  if ListaUsuarios.Autenticar(edtUsuario.Text, edtPassword.Text) then
  begin
    usuario := ListaUsuarios.BuscarPorUsuario(edtUsuario.Text);

    // Verificar si es usuario root
    if edtUsuario.Text = 'root' then
    begin
      Hide;
      frmAdminRoot := TfrmAdminRoot.Create(Application);
      try
        frmAdminRoot.ListaUsuarios := ListaUsuarios;
        frmAdminRoot.ShowModal;
      finally
        frmAdminRoot.Free;
      end;
      Show;
    end
    else
    begin
      Hide;
      frmPrincipal := TfrmPrincipal.Create(Application);
      try
        frmPrincipal.UsuarioActual := usuario^;
        frmPrincipal.ListaUsuarios := ListaUsuarios;
        frmPrincipal.ShowModal;
      finally
        frmPrincipal.Free;
      end;
      Show;
    end;
  end
  else
  begin
    ShowMessage('Usuario o contraseña incorrectos');
    edtPassword.Text := '';
    edtPassword.SetFocus;
  end;
end;

procedure TfrmLogin.btnRegistrarClick(Sender: TObject);
var
  nombre, email, telefono: string;
begin
  if (edtUsuario.Text = '') or (edtPassword.Text = '') then
  begin
    ShowMessage('Por favor ingrese usuario y contraseña');
    Exit;
  end;

  // Simular diálogo de registro (en una app real sería un formulario aparte)
  nombre := InputBox('Registro', 'Ingrese su nombre completo:', 'Nuevo Usuario');
  email := InputBox('Registro', 'Ingrese su email:', edtUsuario.Text + '@edd.com');
  telefono := InputBox('Registro', 'Ingrese su teléfono:', '00000000');

  // Insertar nuevo usuario
  ListaUsuarios.Insertar(nombre, edtUsuario.Text, edtPassword.Text, email, telefono);

  ShowMessage('Usuario registrado exitosamente. Ya puede iniciar sesión.');
  edtPassword.Text := '';
end;

end.

