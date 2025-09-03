unit uLogin;

{$mode delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SLL, uRegister, uPrincipal, uAbrirMenuRoot;

type
  TfrmLogin = class(TForm)
    btnLogin: TButton;
    btnRegister: TButton;
    edtEmail: TEdit;
    edtPassword: TEdit;
    lblEmail: TLabel;
    lblPassword: TLabel;
    procedure btnLoginClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
  private
    procedure AbrirMenuRoot;
    procedure AbrirMenuUsuario(email: string);
  public
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.lfm}

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  email, password: string;
begin
  email := Trim(edtEmail.Text);
  password := Trim(edtPassword.Text);

  if (email = '') or (password = '') then
  begin
    ShowMessage('Debe ingresar Email y Password');
    Exit;
  end;

  // Validación ROOT
  if (email = 'root@edd.com') and (password = 'root123') then
  begin
    ShowMessage('Bienvenido ROOT');
    AbrirMenuRoot;
    Exit;
  end;

  // Validación usuario normal
  if ValidatePassAndEmailLogin(email, password) then
  begin
    ShowMessage('Bienvenido ' + email);
    AbrirMenuUsuario(email);
  end
  else
  begin
    ShowMessage('Credenciales incorrectas');
  end;
end;

procedure TfrmLogin.btnRegisterClick(Sender: TObject);
begin
  frmRegister := TfrmRegister.Create(Application);
  try
    frmRegister.ShowModal;
  finally
    frmRegister.Free;
  end;
end;

procedure TfrmLogin.AbrirMenuRoot;
begin
  frmAbrirMenuRoot := TfrmAbrirMenuRoot.Create(Application);
  try
    frmAbrirMenuRoot.ShowModal; // Abre el formulario de Root de manera modal
  finally
    frmAbrirMenuRoot.Free; // Libera la memoria al cerrarlo
  end;
end;

procedure TfrmLogin.AbrirMenuUsuario(email: string);
begin
  Hide; // Oculta el formulario de login
  try
    frmPrincipal := TfrmPrincipal.Create(Application);
    frmPrincipal.UsuarioEmail := email;  // CORRECTO: coincide con TfrmPrincipal
    frmPrincipal.ShowModal;
  finally
    Free; // Cierra y libera el formulario de login
  end;
end;

end.

