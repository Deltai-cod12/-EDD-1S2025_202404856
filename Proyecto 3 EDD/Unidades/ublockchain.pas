unit uBlockchain;

{$mode delphi}

interface

uses
  SysUtils, Classes, MD5, Process, Dialogs;

type
  PBlock = ^TBlock;
  TBlock = record
    Index: Integer;
    CorreoID: string;
    Remitente: string;
    Destinatario: string;
    Fecha: string;
    PrevHash: string;
    Hash: string;
    Next: PBlock;
  end;

var
  BlockchainHead: PBlock = nil;

procedure InitBlockchain;
procedure AddBlock(CorreoID, Remitente, Destinatario: string);
function VerifyBlockchain: Boolean;
function BlockchainToDOT: string;
procedure GenerarDOTBlockchain(const DOTFile, PNGFile: string);

implementation

procedure InitBlockchain;
begin
  BlockchainHead := nil;
end;

function GenerateHash(const Data: string): string;
begin
  Result := MD5Print(MD5String(Data));
end;

procedure AddBlock(CorreoID, Remitente, Destinatario: string);
var
  NewBlock, Last: PBlock;
  FechaHora: string;
begin
  FechaHora := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);

  New(NewBlock);
  NewBlock^.CorreoID := CorreoID;
  NewBlock^.Remitente := Remitente;
  NewBlock^.Destinatario := Destinatario;
  NewBlock^.Fecha := FechaHora;
  NewBlock^.Next := nil;

  if BlockchainHead = nil then
  begin
    NewBlock^.Index := 0;
    NewBlock^.PrevHash := 'GENESIS';
  end
  else
  begin
    Last := BlockchainHead;
    while Last^.Next <> nil do
      Last := Last^.Next;

    NewBlock^.Index := Last^.Index + 1;
    NewBlock^.PrevHash := Last^.Hash;
    Last^.Next := NewBlock;
  end;

  NewBlock^.Hash := GenerateHash(
    NewBlock^.CorreoID +
    NewBlock^.Remitente +
    NewBlock^.Destinatario +
    NewBlock^.Fecha +
    NewBlock^.PrevHash
  );

  if BlockchainHead = nil then
    BlockchainHead := NewBlock;
end;

function VerifyBlockchain: Boolean;
var
  Node: PBlock;
  ExpectedHash: string;
begin
  Result := True;
  Node := BlockchainHead;

  while (Node <> nil) and (Node^.Next <> nil) do
  begin
    ExpectedHash := GenerateHash(
      Node^.Next^.CorreoID +
      Node^.Next^.Remitente +
      Node^.Next^.Destinatario +
      Node^.Next^.Fecha +
      Node^.Next^.PrevHash
    );

    if ExpectedHash <> Node^.Next^.Hash then
      Exit(False);

    Node := Node^.Next;
  end;
end;

function BlockchainToDOT: string;
var
  SL: TStringList;
  Node: PBlock;
begin
  SL := TStringList.Create;
  try
    SL.Add('digraph Blockchain { rankdir=LR; node [shape=record, style=filled, fillcolor=lightyellow];');

    Node := BlockchainHead;
    while Node <> nil do
    begin
      SL.Add(Format(
        '"%d" [label="{Index: %d | ID: %s | Rem: %s | Dest: %s | Fecha: %s | Hash: %s}"];',
        [Node^.Index, Node^.Index, Node^.CorreoID, Node^.Remitente, Node^.Destinatario, Node^.Fecha, Node^.Hash]
      ));

      if Node^.Next <> nil then
        SL.Add(Format('"%d" -> "%d";', [Node^.Index, Node^.Next^.Index]));

      Node := Node^.Next;
    end;

    SL.Add('}');
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

procedure GenerarDOTBlockchain(const DOTFile, PNGFile: string);
var
  SL: TStringList;
  DotCode: string;
  Output: AnsiString;
begin
  DotCode := BlockchainToDOT;
  SL := TStringList.Create;
  try
    SL.Text := DotCode;
    SL.SaveToFile(DOTFile);

    if FileExists('/usr/bin/dot') then
    begin
      RunCommand('/usr/bin/dot', ['-Tpng', DOTFile, '-o', PNGFile], Output);
      ShowMessage('Blockchain generado en: ' + PNGFile);
    end
    else
      ShowMessage('Error: Graphviz (dot) no está instalado.');
  finally
    SL.Free;
  end;
end;

end.
