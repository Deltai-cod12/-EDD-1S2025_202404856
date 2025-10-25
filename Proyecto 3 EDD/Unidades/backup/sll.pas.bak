unit SLL;
{$MODE DELPHI}

interface
uses
    DLL_CON, UContactTypes, UPila, UCola, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Process;
    type
        TDataUser = record
        id: string;
        name: string;
        email: string;
        user: string;
        phone: string;
        password: string;
        Contacts: PContactList;
        Inbox: PMsgList;
        Papelera: PPila;
        Programados: PCola;
    end;

    function SLL_INSERT(id,name,email,username,phone,password: string): Boolean;
    procedure SSL_PRINT;
    function ValidatePassAndEmail(email, password: string): Boolean;
    function ValidatePassAndEmailLogin(email, password: string): Boolean;
    function SSL_GETBYEMAIL(const email: string): TDataUser;
    function SSL_GENERATE_DOT: string;
    function SLL_actualizarPerfil(email, username, phone: string):Boolean;
    procedure GenerateDotUsuarios(const DotFile, PNGFile: string);

implementation


    type
        PNode = ^TNode;
        TNode = record
            id: string;
            name: string;
            email: string;
            username: string;
            phone: string;
            password:  string;
            Next: PNode;
            Contacts: PContactList;
            Inbox: PMsgList;
            Papelera: PPila;
            Programados: PCola;

        end;


    var
        Head: PNode = nil;



    function SSL_GETBYEMAIL(const email: string): TDataUser;
    var
        actual : PNode;

    begin
        Result.id := '';
        Result.name := '';
        Result.email := '';
        Result.phone := '';
        Result.password := '';
        Result.user := '';



        if Head = nil then exit;

        actual := Head;
        while actual <> nil do
        begin
            if actual^.email = Trim(email) then
            begin
                Result.id := actual^.id;
                Result.user := actual^.username;
                Result.name := actual^.name;
                Result.email := actual^.email;
                Result.phone := actual^.phone;
                Result.password := actual^.password;
                Result.Contacts := actual^.Contacts;
                Result.Inbox := actual^.Inbox;
                Result.Papelera := actual^.Papelera;
                Result.Programados := actual^.Programados;




                Exit;
            end;
            actual := actual^.Next;
        end;

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

    function SLL_INSERT(id,name,email,username,phone,password:string): Boolean;
    var
        NewNode, Actual: PNode;
        isValid: Boolean;

    begin

        isValid := ValidatePassAndEmail(email, password);
        if isValid then
        begin
            Result:= False;
            exit;
        end
        else
        begin

            New(NewNode);

            NewNode^.id := Trim(ID);
            NewNode^.name := Trim(name);
            NewNode^.email := Trim(email);
            NewNode^.username := Trim(username);
            NewNode^.phone := Trim(phone);
            NewNode^.password := Trim(password);
            NewNode^.Next := nil;
            New(NewNode^.Contacts);
            NewNode^.Contacts^.Head := nil;
            NewNode^.Contacts^.Last := nil;

            New(NewNode^.Inbox);
            NewNode^.Inbox^.Head := nil;
            NewNode^.Inbox^.Last := nil;


            New(NewNode^.Papelera);
            NewNode^.Papelera^.Top := nil;

            New(NewNode^.Programados);
            NewNode^.Programados^.Top := nil;
            NewNode^.Programados^.Tail := nil;


            if Head = nil then
            begin
                Head := NewNode;
            end

            else
            begin
                Actual := Head;
                while Actual^.Next <> nil do
                    Actual := Actual^.Next;
                Actual^.Next := NewNode;
            end;

            Result:= True;
            exit;
        end;
    end;

    function ValidatePassAndEmail(email, password: string):Boolean;
     var
        Actual: PNode;
    begin
        Result := False;

        if Head = nil then exit;

        Actual := Head;
        while Actual <> nil do
        begin
            if (Actual^.email = email) or (Actual^.password = password) then
            begin
                Result := True;
                exit;
            end;
            Actual:= Actual^.Next;
        end;
    end;

    function ValidatePassAndEmailLogin(email, password: string):Boolean;
     var
        Actual: PNode;

    begin
        Result := False;

        if Head = nil then exit;

        Actual := Head;
        while Actual <> nil do
        begin
            if (Actual^.email = email) and (Actual^.password = password) then
            begin
                Result := True;
                exit;
            end;
            Actual:= Actual^.Next;
        end;
    end;

    function SLL_actualizarPerfil(email, username, phone: string):Boolean;
     var
        Actual: PNode;

    begin
        Result := False;

        if Head = nil then exit;

        Actual := Head;
        while Actual <> nil do
        begin
            if (Actual^.email = email) then
            begin
                Actual^.username := Trim(username);
                Actual^.phone := Trim(phone);
                Result := True;
                exit;
            end;
            Actual:= Actual^.Next;
        end;
    end;

    procedure SSL_PRINT;
    var
        Actual: PNode;
    begin
        if Head = nil then
        begin
            Writeln('Lista vacia!!!')
        end;
        Actual := Head;

        while Actual <> nil do
        begin
            Writeln('ID: ', Actual^.id);
            Writeln('Nombre: ', Actual^.name);
            Writeln('Correo: ', Actual^.email);
            Writeln('Usuario: ', Actual^.username);
            Writeln('Telefono: ', Actual^.phone);
            Writeln('Contraseña: ', Actual^.password);
            Writeln('------------------------------');
            Actual := Actual^.Next;
        end;
    end;

    function SSL_GENERATE_DOT: string;
    var
        SL: TStringList;
        Actual: PNode;
        Counter: Integer;
        NodeName, NextName: string;
        ResultText: string;

    begin
        SL := TStringList.Create;

        SL.Add('digraph ListaEnlazada {');
        SL.Add('  rankdir=LR;');
        SL.Add('  nodesep=0.5;');
        SL.Add('');
        SL.Add('  subgraph cluster_0 {');
        SL.Add('     label="Lista Simple enlazada - Usuarios";');
        SL.Add('     fontsize=14;');
        SL.Add('     color=black;');
        SL.Add('     style=filled;');
        SL.Add('     fillcolor=white;');
        SL.Add('     node [shape=record, style=filled, fillcolor=lightblue];');
        SL.Add('');

        if Head = nil then
        begin
            SL.Add('      null [label="LISTAVACIA", shape=plaintext];');
        end

        else
        begin
            Counter := 0;
            Actual := Head;
            while Actual <> nil do
            begin
                NodeName := Format('nodo%d', [Counter]);
                SL.Add(Format('    %s [label="{%s \n %s \n %s \n %s \n %s}"];',
                    [NodeName,
                    EscapeDotString(Actual^.id),
                    EscapeDotString(Actual^.name),
                    EscapeDotString(Actual^.username),
                    EscapeDotString(Actual^.email),
                    EscapeDotString(Actual^.phone)
                    ]));

                    if Actual^.Next <> nil then
                    begin
                        NextName := Format('nodo%d', [Counter + 1]);
                        SL.Add(Format('      %s -> %s;', [NodeName, NextName]));
                    end;

                    Inc(Counter);
                    Actual := Actual^.Next;
            end;
        end;

        SL.Add('  }');
        SL.Add('}');

        ResultText := SL.Text;
        SL.Free;

        Result := ResultText;

    end;

procedure GenerateDotUsuarios(const DotFile, PNGFile: string);
var
  SL: TStringList;
  DotContent: string;
  Output: AnsiString;
begin
  // Generar el contenido .dot
  DotContent := SSL_GENERATE_DOT;

  SL := TStringList.Create;
  try
    SL.Text := DotContent;
    SL.SaveToFile(DotFile);
  finally
    SL.Free;
  end;

  // Ejecutar Graphviz para generar PNG
  if FileExists('/usr/bin/dot') then
    RunCommand('/usr/bin/dot', ['-Tpng', DotFile, '-o', PNGFile], Output)
  else if FileExists('C:\Program Files\Graphviz\bin\dot.exe') then
    RunCommand('C:\Program Files\Graphviz\bin\dot.exe', ['-Tpng', DotFile, '-o', PNGFile], Output)
  else
    ShowMessage('No se encontró Graphviz (dot). Instálalo o ajusta la ruta.');

  ShowMessage('Reporte de usuarios generado en: ' + PNGFile);
end;

end.
