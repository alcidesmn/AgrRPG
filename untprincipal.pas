unit untPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ActnList, ZConnection, ZDataset, GifAnim;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    cbsHist: TComboBox;
    dtsCarInf: TDataSource;
    dtsHist: TDataSource;
    Image1: TImage;
    lblCapitulo: TLabel;
    lblDado: TLabel;
    pnlOp1: TPanel;
    pnlOp3: TPanel;
    pnlOp2: TPanel;
    pnlBotoes: TPanel;
    pnlCentral: TPanel;
    pnlDado: TPanel;
    pnlHistoria: TPanel;
    pnlImg: TPanel;
    pnlMae: TPanel;
    pnlOpcoes: TPanel;
    qryHistID_HISTORIA: TLargeintField;
    qryHistNOME_HIST: TMemoField;
    spbHeroi: TSpeedButton;
    spbOP1: TSpeedButton;
    spbOP2: TSpeedButton;
    spbOP3: TSpeedButton;
    spbRodarDado: TSpeedButton;
    spbNovo: TSpeedButton;
    spbCarregar: TSpeedButton;
    zConn: TZConnection;
    qryHist: TZQuery;
    qryCarInf: TZQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pnlHistoriaClick(Sender: TObject);
    procedure spbNovoClick(Sender: TObject);
    procedure spbOP1Click(Sender: TObject);
    procedure spbOP2Click(Sender: TObject);
    procedure spbOP3Click(Sender: TObject);
    procedure spbRodarDadoClick(Sender: TObject);
  private
    procedure alteraHistoria;
    procedure Delay(msecs: Cardinal);
    procedure procIniciarNovoJogo;
  public

  end;

var
  frmPrincipal: TfrmPrincipal;
  ParteHist: integer;
  min: integer;

implementation

{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.spbRodarDadoClick(Sender: TObject);
begin
  randomize;
  sleep(500);
  lblDado.caption:= IntToStr(round(Random(20)));

  if StrToInt(lblDado.Caption)> min then
  begin
    //pnlBotton.Caption:= 'Teve sorte verme, na proxima não será assim.';

  end
  else
  begin
    //pnlBotton.Caption:= 'HAHAHAHA um verme como você não merece mais que isso.';
  end;

  spbRodarDado.Enabled:= false;

  inc (ParteHist);
end;

procedure TfrmPrincipal.alteraHistoria;
begin
  //pnlBotton.Caption:= EmptyStr;
  inc(ParteHist);
end;

procedure TfrmPrincipal.Delay(msecs: Cardinal);
var
  FirstTickCount: Cardinal;
begin
  FirstTickCount := GetTickCount64;
  repeat
    Application.ProcessMessages;
  until ((GetTickCount64 - FirstTickCount) >= msecs);
end;

procedure TfrmPrincipal.procIniciarNovoJogo;
var Hist: String;
    i: integer;
    opcoes: array[1..3] of integer;
begin

  qryCarInf.close;
  qryCarInf.SQL.Clear;
  qryCarInf.SQL.Add('select his.NOME_HEROI, cap.ID_CAP, cap.HISTORIA  from HIST_CAPA his '+
                    'inner join HIST_CAPITULO cap on his.ID_HISTORIA = cap.ID_HIST where (SELECT ID_CAP_INI FROM HIST_CAPA hc '+
                    ' WHERE ID_HISTORIA = :ID_HISTORIA)');
  qryCarInf.ParamByName('ID_HISTORIA').AsInteger:= Integer(cbsHist.Items.Objects[cbsHist.ItemIndex]);
  qryCarInf.Open;

  spbHeroi.Caption:= qryCarInf.FieldByName('NOME_HEROI').AsString;
  ParteHist:= qryCarInf.FieldByName('ID_CAP').AsInteger;
  lblCapitulo.Caption:= 'Capitulo '+ intToStr(ParteHist);
  Hist:= qryCarInf.FieldByName('HISTORIA').AsString;

  qryCarInf.close;
  qryCarInf.SQL.Clear;
  qryCarInf.SQL.Add('select hc.op_1,hc.op_2,hc.op_3 from HIST_CAPITULO hc where hc.id_Cap = :id_cap');
  qryCarInf.ParamByName('id_cap').AsInteger:= ParteHist;
  qryCarInf.Open;

  for i:= 1 to 3 do
  begin
    opcoes[i]:= qryCarInf.FieldByName('op_'+inttostr(i)).AsInteger;
  end;

  for i:= 1 to 3 do
  begin
    qryCarInf.close;
    qryCarInf.SQL.Clear;
    qryCarInf.SQL.Add('select OP_OPCAO from OPCOES o where ID_OP = :ID_OP');
    qryCarInf.ParamByName('ID_OP').AsInteger:= opcoes[i];
    qryCarInf.Open;
    if i = 1 then
       pnlOp1.Caption:= qryCarInf.FieldByName('OP_OPCAO').AsString;

    if i = 2 then
       pnlOp2.Caption:= qryCarInf.FieldByName('OP_OPCAO').AsString;

    if i = 3 then
       pnlOp3.Caption:= qryCarInf.FieldByName('OP_OPCAO').AsString;
  end;

  Delay(300);
  pnlHistoria.Caption:= Hist;
  Delay(300);
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  ParteHist:= 0;
  min:= 0;
  spbRodarDado.Enabled:= False;
  pnlHistoria.Caption:= 'Eai, pra onde vamos?' + #13;
  Delay(3000);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  qryHist.Close;
  qryHist.Open;

  cbsHist.items.Clear;
  cbsHist.Clear;
  qryHist.First;
  while not qryHist.eof do
  begin
    cbsHist.Items.AddObject(qryHist.FieldByName('NOME_HIST').AsString, TObject(qryHist.FieldByName('ID_HISTORIA').AsInteger));
    qryHist.Next;
  end;
  cbsHist.ItemIndex:= 0;
end;




procedure TfrmPrincipal.pnlHistoriaClick(Sender: TObject);
begin
  alteraHistoria;
end;

procedure TfrmPrincipal.spbNovoClick(Sender: TObject);
begin
  with TTaskDialog.Create(self) do
  try
    Caption := 'Confirmação:';
    Title := 'Iniciar novo jogo?';
    Text := 'Deseja iniciar novo jogo?';
    CommonButtons := [tcbYes, tcbNo];
    MainIcon := tdiQuestion;
    if Execute then
    begin
      if ModalResult = mrYes then
      begin
        procIniciarNovoJogo;
      end;
    end;
  finally
    Free;
  end;
end;



procedure TfrmPrincipal.spbOP1Click(Sender: TObject);
begin
  //pnlBotton.Caption:= 'Agora rode os dados, vejamos sua sorte!';
  spbRodarDado.Enabled:= true;
end;

procedure TfrmPrincipal.spbOP2Click(Sender: TObject);
begin
  //pnlBotton.Caption:= 'Agora rode os dados, vejamos sua sorte!';
  spbRodarDado.Enabled:= true;
end;

procedure TfrmPrincipal.spbOP3Click(Sender: TObject);
begin
  //pnlBotton.Caption:= 'Agora rode os dados, vejamos sua sorte!';
  spbRodarDado.Enabled:= true;
end;



end.

