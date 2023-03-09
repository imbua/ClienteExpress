{ Este programa serve para receber as fichas de requisicao dos programas e


  devolve-los assim que terminar...
  Os modulos processaldos sao:
  2 - Vendas
  3 - Exclusao de Vendas...

}

unit uMain;

interface


uses
  Windows, Mask, JPeg, Math, Messages, SysUtils, System.StrUtils, Variants, ExtCtrls, Classes,
  Graphics, Controls, Forms, Json, WinSock,
  Dialogs, StdCtrls, Buttons, ComCtrls,
  ImgList, IniFiles, Data.DB, Uni, DAScript,
  ZLIBArchive2, DBClient, ShellApi, IdHTTP, IdFTP, IdURI, Menus, Spin, ZLIB,
  Vcl.Samples.Gauges, System.ImageList, MemDS, uVar, DBAccess;

type
  TVendaTotal = record
    Comissao: String;
    Acrescimo: String;
    Total: String;
    Ind: String;
  end;

type
  TfrmMain = class(TForm)
    pBotoes: TPanel;
    stBar: TStatusBar;
    pRespostas: TPanel;
    mResp: TMemo;
    pTopRespostas: TPanel;
    ImageList1: TImageList;
    pCmd: TPanel;
    mCmd: TMemo;
    pTopCmd: TPanel;
    sbProcessando: TStatusBar;
    Timer1: TTimer;
    pbProgress: TProgressBar;
    procedure BancocnxError(Sender: TObject; E: EDAError; var Fail: Boolean);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private

    // procedure Set_FTPEnvio;

    _Venda: TVendaTotal;
    { tirei estas duas linhas pois estava dando conflito na conexao tcp
      procedure InicializaQuery(var fDb: TZConnection; var fQuery: TZQuery);
      procedure SetQuery(var fDb: TZConnection; var fQuery: TZQuery); }

    function FCampo_Pag(fcampo: string): string;

    procedure IniciaVariaves;

    procedure Roda_Arquivos;
    procedure GetHoraRemessa(fFiles: string);
    procedure PegaItens(fstr: string);
    procedure PegaItensRodizio(fstr: string);
    procedure PegaPagamentos(fstr: string);
    procedure PegaCadastro(fstr: string);
    procedure PegaCadastroPet(fstr: string);
    procedure PegaSangria(fstr: string);
    procedure PegaFundo(fstr: string);
    procedure PegaPagamentosPrazo(fstr: string);
    procedure PegaPagamentosCredito(fstr: string);
    procedure PegaRetiradas(fstr: string);
    procedure PegaRetiradasBaixa(fstr: string);
    procedure PegaDevolucao(fstr: string);
    procedure PegaItensCanc(fstr: string);
    procedure PegaEcf_Z(fstr: string);
    procedure PegaEcf_Z_Aliquota(fstr: string);
    procedure PegaECFDetalhe(fstr: string);
    procedure PegaECFRecdo(fstr: string);
    procedure PegaECFCanc(fstr: string);
    procedure PegaECFCancItem(fstr: string);
    procedure PegaEcfGNF(fstr: string);
    procedure PegaItensPedidoEntregaPontos(fstr: string);
    procedure PegaItensTransf(fstr: string);
    procedure PegaProdutos(fstr: string);

    function GetIP: string; // --> Declare a Winsock na clausula uses da unit
    function Grava_ItensRetiradas(fid: string): Double;
    procedure Grava_Itens(var fid: string; var fVal, fRepique: Double; var fEntrega: string);
    function Grava_Devolucao(fid: string): Double;
    function Grava_Canc(fid: string): Double;
    function Grava_Retiradas(fid: string; fVal: Double; fVenda: String = '0'): string;
    function Grava_Venda(fid: string; fRepique: Double; fEntrega, fNomeCliente: string): string;
    function Grava_Recdo(fid: string): string;
    procedure Grava_RecdoPrazo;
    procedure Grava_RecdoCredito(ftroco: Double);
    procedure Grava_Cadastro(fUsu: string);
    procedure Grava_CadastroPet(fUsu: string);
    procedure Grava_Credito(fVenda: string);

    function DoSangria(fCmd: string): string;
    function DoFundo(fCmd: string): string;
    function DoVenda(fCmd: string): string;
    procedure DoCompra(fCmd: string);
    function DoCadastro(fCmd: string): string;
    function DoCadastroPet(fCmd: string): string;

    function DoFiscal(fCmd: string): string;
    function DoItensExcluidos(fCmd: string): string;
    function DoPrazo(fCmd: string): string;
    function DoCredito(fCmd: string): string;
    function DoRetiradas(fCmd: string): string;
    function DoRetiradasCancel(fCmd: string): string;
    function DoRetiradasBaixa(fCmd: string): string;
    procedure DoFechamento(ffile: string; ftip: string = 'zlb');

    procedure Processa_Fundo;
    procedure Processa_Sangria;
    procedure ProcessaInt_Sangria(fDescr, fdata, fValor: string);
    procedure LancaBonus(fempresa, fcaixa, fdata, fid, fVal: string);
    procedure Processa_RetiradasBaixa;
    procedure Processa_Venda;
    procedure Processa_Fiscal(fTipo, fEcf, fempresa, fdata, fTexto: string);

    procedure Processa_RecebimentoPrazo;
    procedure Processa_RecebimentoCredito;
    procedure Set_CItens;
    procedure Set_Itens; // agrupar os itens
    procedure Set_Recdo(fQuery: TClientDataSet; fDev: Double);
    procedure SetConta(fcod: string);
    procedure SetEmpresa(femp: string);
    function SetNumero(Fnum: string): string;

    procedure fCancelaVenda(fNumFab, fCCF: string);
    procedure FCancelaVendaEx(fRemessa: string; fHasFinan: Boolean);
    function fChecFechamento(fZip: TZLBArc2; fQuery: TUniQuery; ffile: string): string;
    function fVerificaValorFechamento(fSList: TStringList; fQuery: TUniQuery; fArq: string): Boolean;
    function fVerificavalorVenda(fSList: TStringList; fArq: string; fQuery: TUniQuery): Boolean;

    // procedure RespostaEx(Comando, TipoResposta, Resposta: string; Socket: TCustomWinSocket);
    procedure Processar(ACmd: string);
    procedure Lancamento(fempresa: string; fid: string; FCliente: string; fVal: Double; fdata: string);
    procedure Set_Receber(fcodigo, fconta, ftaxa, fValor, fvencimento, FCliente,
      fempresa, fdata, fcupom, fid, ftroco, fpaciente, fTefAutoricao: string);
    procedure Set_Lancamento(fempresa, fcusto, FCliente, fcpf, fcnpj, fconta, fconta_tipo, fcaixa, fdoc, FDescricao, fdata: string; Fsval: Double);
    procedure Lanca_Caixa(fVal: Double; fdata, fconta, fDescr, fTipo: string);
    Function Baixa_Recebimentos(fValor, fdata, fcaixa, fVenda, fempresa, fBoleto: string): Boolean;
    function ProcuraConta(fcod: string): Boolean;
    function ProcuraCampo(fcampo, fTexto: string): Boolean;
    function ProcuraImposto(fcod: string): Boolean;
    procedure fbaixa_rec_parcial(ftotal, fVal: Double; fdata, fcaixa: string);
    procedure fbaixa_rec(fVal: Double; fid, fdata, fcaixa: string);
    procedure Set_Cliente(FCliente: string; Var FVarCliente: TCliente);
    function fTipoCmd(fCmd: TStringList): string;

    procedure SetComissao(fempresa, fdata, fcod: string);

    function GetFile(fURL: string; fdir: string): Boolean;
    procedure GetDBArquivos;
    procedure LancaPontos(var fid: string);
    function SetDef(fConteudo, fDefault: String): string;
    procedure Grava_CadastroProdutos;
    function DoCadastroProdutos(fCmd: string): string;
    function FindProdutos(fcampo, fBarras: String): Boolean;
    Procedure CheckTables(fopt: String);
    Function OpenCheckedTables(fopt: String): Boolean;
    function DoItensTransf(fCmd: string): string;
    procedure Processa_ItensTransf;
    procedure DoContagemEstoque(fFileCmd: string);
    procedure PegaContagem(fstr: string);
    procedure querycmdError(Sender: TObject; E: Exception; SQL: string;
      var Action: TErrorAction);
    function DoContagem(fCmd: string): string;
    procedure Processa_Contagem;
    Function SetProdutosNaoContados: String;
    function CheckMasterHandle: Boolean;
    procedure PegaAcrescimo(fstr: string);
    procedure Grava_CadastroProdutosVenda;
    procedure DoVndMobile(fCmd: string);
    procedure DoColetorMobile(fCmd: string);
    procedure doFileError(fRemessa, fMessage: String);

    { Private declarations }
  public
    procedure Get_Campos(fCmd: string);
    Function Processa_Retiradas(fVenda: String; fTroca: Boolean = false): Double;

    { Public declarations }
  end;

var

  frmMain: TfrmMain;
  Financeiro: string;

implementation

uses
  uModulo, uFuncoes, uArqJson, uClienteDataSetClass, DateUtils;

{$R *.dfm}


procedure TfrmMain.Set_Cliente(FCliente: string; Var FVarCliente: TCliente);
begin
  dmModulo.Query.close;
  if FGet_CPF(FCliente) <> '' then
    dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cpf="' + FGet_CPF(FCliente) + '"'
  else
    if FGet_CNPJ(FCliente) <> '' then
    dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cnpj="' + FGet_CNPJ(FCliente) + '"'
  else
    dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cpf="000000001"';

  dmModulo.Query.open;

  if dmModulo.Query.FindField('nfc') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.BancoFinan + '.cadastro add nfc varchar(20) default null, add key iNFC (nfc)');
    dmModulo.Query.close;
    dmModulo.Query.open;
  end;

  if FVarCliente.NFC <> '' then
  begin
    if dmModulo.Query.isempty then
    begin
      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where nfc="' + FVarCliente.NFC + '"';
      dmModulo.Query.open;
    end;
  end;

  if dmModulo.Query.isempty then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where codigo="00001"';
    dmModulo.Query.open;
  end;
  FVarCliente.Codigo := dmModulo.Query.fieldbyname('codigo').Text;
  FVarCliente.Nome := copy(dmModulo.Query.fieldbyname('nome').Text, 1, 50);
  FVarCliente.Cpf := dmModulo.Query.fieldbyname('cpf').Text;
  FVarCliente.Cnpj := dmModulo.Query.fieldbyname('cnpj').Text;
  FVarCliente.senha := dmModulo.Query.fieldbyname('senha').Text;
  FVarCliente.bonus := dmModulo.Query.fieldbyname('bonus').Text;
  FVarCliente.NFC := dmModulo.Query.fieldbyname('nfc').Text;
end;

procedure TfrmMain.IniciaVariaves;
var
  xBool: Boolean;
  xmStr: TStringList;
begin
  try

    xBool := True;

    _DB.Usr := 'processaexpress';
    _DB.Pwd := 'processaexpress';

    _Dir.Dir := GetCurrentDir;
    _Dir.Recebimento := _Dir.Dir + '\recebimento';
    _Dir.Carga := _Dir.Dir + '\carga';
    _Dir.Imagens := _Dir.Dir + '\imagens';
    _Dir.Feito := _Dir.Dir + '\feito';
    _Dir.Update := _Dir.Dir + '\Update';
    _Dir.Backup := _Dir.Dir + '\Backup';
    _Dir.Erro := _Dir.Dir + '\Erro';
    _Dir.Fiscal := _Dir.Dir + '\fiscal';
    _Dir.IP := GetIP;

    _Dir.DirEnvio := ExtractFileDir(paramstr(0)); // GetCurrentDir;

    if not Config_DB(mResp, dmModulo.Bancocnx) then
    begin
      logging(mResp, 'Problemas de acesso ao DB ' + _DB.Host + ', processo abortado!');
      Application.Terminate;

      abort;
    end;

    if not DirectoryExists(_Dir.Dir + '\recebimento') then
      ForceDirectories(_Dir.Dir + '\recebimento');
    if not DirectoryExists(_Dir.Dir + '\feito') then
      ForceDirectories(_Dir.Dir + '\feito');
    if not DirectoryExists(_Dir.Dir + '\carga') then
      ForceDirectories(_Dir.Dir + '\carga');
    if not DirectoryExists(_Dir.Dir + '\erro') then
      ForceDirectories(_Dir.Dir + '\erro');
    if not DirectoryExists(_Dir.Dir + '\fechamento') then
      ForceDirectories(_Dir.Dir + '\fechamento');
    if not DirectoryExists(_Dir.Dir + '\fiscal') then
      ForceDirectories(_Dir.Dir + '\fiscal');
    if not DirectoryExists(_Dir.Dir + '\update') then
      ForceDirectories(_Dir.Dir + '\update');

    if not DirectoryExists(_Dir.Dir + '\Update') then
      ForceDirectories(_Dir.Dir + '\Update');
    if not DirectoryExists(_Dir.Dir + '\Backup') then
      ForceDirectories(_Dir.Dir + '\Backup');
    if not DirectoryExists(_Dir.Dir + '\Imagens') then
      ForceDirectories(_Dir.Dir + '\Imagens');

    // TcpServer.Active:=true;
    Timer1.Enabled := True;
  except
    on E: Exception do
    begin
      logging(mResp, 'Error on Iniciavariaveis  ' + _DB.DB + ' ' + E.Message + ', processo abortado!');
      Application.Terminate;
      abort;
    end;
  end;

end;

procedure TfrmMain.Processar(ACmd: string);
var
  cLinha, Linha: string;
  xTipo_Comando, xCmd: string;
  xfile: string;
  xArqDel: array [0 .. 1000] of char;
  xmStr: TStringList;

begin
  FSistemaBrasileiro;

  try
    if not dmModulo.Bancocnx.Connected then
    begin

      if not Config_DB(mResp, dmModulo.Bancocnx) then
      begin
        logging(mResp, 'Problemas de acesso ao DB ' + _DB.Host + ', processo abortado!');
        exit;
      end;

    end;
    try
      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := 'select now()';
      dmModulo.Query.open;
    except

      if not Config_DB(mResp, dmModulo.Bancocnx) then
      begin
        logging(mResp, 'Problemas de acesso ao DB ' + _DB.Host + ', processo abortado!');
        exit;
      end;

    end;

    if pos('"', ACmd) > 0 then
      ACmd := StringReplace(ACmd, '"', '', [rfReplaceAll]);

    mCmd.Lines.Text := ACmd;
    if mCmd.Lines.count > 0 then
    begin
      // Application.ProcessMessages;

      Linha := trim(mCmd.Lines[0]); // verifica se tem o inicio
      cLinha := trim(mCmd.Lines[mCmd.Lines.count - 1]);
      // verifica se tem o inicio
      // if not json
      if copy(Linha, 1, 1) <> '{' then
      begin

        if pos('inicio', Linha) < 0 then
          exit;
        if pos('fim', Linha) < 0 then
          exit;

      end;

      if Linha <> '' then
      begin
        sbProcessando.Panels[1].Text := _Remessa;
        sbProcessando.Refresh;
        frmMain.Refresh;

        try
          xmStr := TStringList.create;
          xmStr.Text := mCmd.Lines.Text;

          xTipo_Comando := fTipoCmd(xmStr);
          xmStr.Text := StringReplace(Linha, '|', #13, [rfReplaceAll]);

          xCmd := mCmd.Lines.Text;

          if (xTipo_Comando = 'CMP') then
            DoCompra(xCmd);
          if (xTipo_Comando = 'venda') or (xTipo_Comando = 'env') then
            DoVenda(xCmd);
          if (xTipo_Comando = 'retiradas') then
            DoRetiradas(xCmd);
          if (xTipo_Comando = 'retiradasbaixa') then
            DoRetiradasBaixa(xCmd);
          if (xTipo_Comando = 'retiradascancel') then
            DoRetiradasCancel(xCmd);
          if (xTipo_Comando = 'sped') or (xTipo_Comando = 'sintegra') or (xTipo_Comando = 'cat52') then
            DoFiscal(xCmd);
          if (xTipo_Comando = 'itensexcluidos') then
            DoItensExcluidos(xCmd);
          if (xTipo_Comando = 'itenstransf') then
            DoItensTransf(xCmd);
          if (xTipo_Comando = 'cadastro') then
            DoCadastro(xCmd);

          if (xTipo_Comando = 'contagem') then
            DoContagem(xCmd);
          if (xTipo_Comando = 'cadastropet') then
            DoCadastroPet(xCmd);
          if (xTipo_Comando = 'prazo') then
            DoPrazo(xCmd);
          if (xTipo_Comando = 'credito_lancado') then
            DoCredito(xCmd);
          if (xTipo_Comando = 'sangria') then
            DoSangria(xCmd);
          if (xTipo_Comando = 'fundo') then
            DoFundo(xCmd);
          if xTipo_Comando = 'fechamento' then
            DoFechamento(xCmd); // file

          mCmd.Lines.SaveToFile(_Dir.Feito + '\' + _Remessa);
          xfile := _Dir.Recebimento + '\' + _Remessa;
          StrPCopy(xArqDel, xfile);
          DeleteFile(xArqDel);
        except
          on E: Exception do
          begin
            doFileError(_Remessa, E.Message);

          end;
        end;

        sbProcessando.Panels[1].Text := '';
      end;
    end;
  finally
    FreeAndNil(xmStr);

  end;
end;

Procedure TfrmMain.doFileError(fRemessa, fMessage: String);
var
  xfile: string;
  xArqDel: array [0 .. 1000] of char;
begin
  logging(mResp, ' ERRO: (processar) ' + fMessage + ' on ' + _DB.Host + ', processo enviado a pasta de erros!');

  mCmd.Lines.SaveToFile(_Dir.Erro + '\' + fRemessa);
  xfile := _Dir.Recebimento + '\' + fRemessa;
  try
    StrPCopy(xArqDel, xfile);
    DeleteFile(xArqDel);
  except
    on E: Exception do
      logging(mResp, ' ERRO: (processar_on execpt) ao excluir o arquivo ' + E.Message);
  end;
end;

{ Parei Aqui
  eu ia fazer uma procedure DoCliente que faz query ao banco e retorna o padrao pelo xcomando enviado - é apenas uma query
}

procedure TfrmMain.DoCompra(fCmd: string);
begin
  FSistemaBrasileiro;
  CDSClass.CriaCItens;
  CDSClass.CriaCadastro;

  _Venda.Acrescimo := '';
  _Venda.Comissao := '';
  _Venda.Total := '';

  if (fCmd <> '') then
  begin
    Processa_Compra(fCmd);

  end;

end;

procedure TfrmMain.DoVndMobile(fCmd: string);
begin
  FSistemaBrasileiro;

  if (fCmd <> '') then
  begin
    Processa_VndMobile(fCmd);

  end;

end;

procedure TfrmMain.DoColetorMobile(fCmd: string);
begin
  FSistemaBrasileiro;

  if (fCmd <> '') then
  begin
    Processa_ColetorMobile(fCmd);
  end;

end;

function TfrmMain.DoContagem(fCmd: string): string;
begin

  _DB.Banco := '';
  _DB.BancoFinan := '';

  _Contagem.Data := '';
  _Contagem.Empresa := '';
  _Contagem.Setor := '';
  _Contagem.Usuario := '';
  _Contagem.Remessa := '';
  _Contagem.Zera := '';

  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);

  if (_Contagem.Data <> '') and (_Contagem.Setor <> '') then
  begin
    Processa_Contagem;
  end;
end;

procedure TfrmMain.Processa_Contagem;
var
  xstr: String;
  xHasisFicha: Boolean;
  xmStr: TStringList;
begin
  try
    xmStr := TStringList.create;
    xHasisFicha := false;

    xmStr.Add('update ' + _DB.Banco + '.contagem a, ' + _DB.Banco +
      '.ficha b set a.isFicha=1 ,a.processado=now() where a.codigo=b.produto and a.setor="' + _Contagem.Setor + '" and a.data=' +
      DtoS(strtodate(_Contagem.Data)) + ';');

    xmStr.Add('update ' + _DB.Banco + '.contagem a set a.processado=now(),a.remessarquivo="' + _Contagem.Remessa + '" where a.setor="' +
      _Contagem.Setor + '" and a.data=' +
      DtoS(strtodate(_Contagem.Data)) + ';');

    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.contagem where setor="' + _Contagem.Setor + '" and data=' +
      DtoS(strtodate(_Contagem.Data)) + ';';
    dmModulo.Query.open;

    while not dmModulo.Query.eof do
    begin
      if xstr = '' then
        xstr := '"' + dmModulo.Query.fieldbyname('codigo').Text + '"'
      else
        xstr := xstr + ',"' + dmModulo.Query.fieldbyname('codigo').Text + '"';

      if not xHasisFicha then
        if dmModulo.Query.fieldbyname('isFicha').Text = '1' then
          xHasisFicha := True;

      dmModulo.Query.next;
    end;
    if xstr <> '' then
    begin
      xmStr.Add('delete  from ' + _DB.Banco + '.lancamentoserial where descricao="contagem" and ' +
        '  setor="' + _Contagem.Setor + '" and data=' + DtoS(strtodate(_Contagem.Data)) + ' and produto in (' + xstr + ');');

      if _Contagem.Zera = '1' then
      begin
        xmStr.Add(SetProdutosNaoContados);
      end;
      xmStr.Add('insert into ' + _DB.Banco + '.lancamentoserial (empresa,setor,data,codigo,produto,qte,' +
        'serial,descricao,tipo,usuario,datahora,remessarquivo) select empresa,setor,data, id,codigo,qte,serial,"contagem","E","' +
        _Contagem.Usuario + '",now(),"' + _Contagem.Remessa + '" from ' + _DB.Banco + '.contagem where setor="' + _Contagem.Setor +
        '" and data=' + DtoS(strtodate(_Contagem.Data)) + ' ; '); // and (isficha is null or isficha<>"1"

      // a pedido do bruno
      { if xHasisFicha then
        begin
        xmStr.Add('insert into ' + _DB.Banco + '.lancamentoserial (empresa,setor,data,codigo,produto,qte,' +
        'serial,descricao,tipo,usuario,datahora,remessarquivo)' +
        ' select a.empresa,a.setor,a.data, a.id,b.codigo,a.qte*b.qte,a.serial,"contagem","E","' +
        _Contagem.Usuario + '",now(),"' + _Contagem.Remessa + '" from ' + _DB.Banco + '.contagem a, ' + _DB.Banco + '.ficha b ' +
        ' where a.codigo=b.produto and  a.setor="' + _Contagem.Setor + '" and a.data=' + DtoS(strtodate(_Contagem.Data)) +
        ' and ( isficha="1") ;');
        end; }
      ExecutaComandoSql(xmStr.Text);
    end;

    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.contagem where setor="' + _Contagem.Setor + '" and data=' +
      DtoS(strtodate(_Contagem.Data)) + ';';
    dmModulo.Query.open;
    if dmModulo.Query.RecordCount < 100 then
    begin
      while not dmModulo.Query.eof do
      begin
        AtualizaQtProduto(dmModulo.Query.fieldbyname('codigo').asstring, _Contagem.Setor);
        dmModulo.Query.next;

      end;
    end;

  finally
    FreeAndNil(xmStr);
  end;

end;

Function TfrmMain.SetProdutosNaoContados: String;
var
  xmStr: TStringList;
  xstr: String;
begin
  try
    xmStr := TStringList.create;
    xmStr.Add('drop table if exists ' + _DB.Banco + '.produtosnaocontadostmp;');
    xstr := ' CREATE TABLE ' + _DB.Banco + '.produtosnaocontadostmp (';
    xstr := xstr + '   cod varchar(20) DEFAULT NULL,';
    xstr := xstr + '   descricao varchar(60) DEFAULT NULL,';
    xstr := xstr + '   custo double(13,6) DEFAULT NULL,';
    xstr := xstr + '   KEY iCod (cod)';
    xstr := xstr + ' ) ENGINE=MyISAM DEFAULT CHARSET=latin1;';
    xmStr.Add(xstr);
    xmStr.Add('insert ignore into ' + _DB.Banco + '.produtosnaocontadostmp select cod,descricao,custo from ' + _DB.Banco + '.produtos a' +
      '  where  (a.desativado=0 or a.desativado is null);');

    xmStr.Add('delete ' + _DB.Banco + '.produtosnaocontadostmp.* from  ' + _DB.Banco + '.produtosnaocontadostmp ,' + _DB.Banco + '.contagem b ' +
      ' where b.codigo= ' + _DB.Banco + '.produtosnaocontadostmp.cod and b.data=' + DtoS(strtodate(_Contagem.Data)) + ' and b.setor="' +
      _Contagem.Setor + '";');

    xmStr.Add('insert into   ' + _DB.Banco + '.contagem(setor,empresa,data,codigo,custo,qte,tipo,remessarquivo)  ' +
      ' select "' + _Contagem.Setor + '" as setor,  "' + _Contagem.Empresa + '" as empresa,' + DtoS(strtodate(_Contagem.Data)) + ' as data,' +
      ' b.cod,b.custo,0,1,"' + _Contagem.Remessa + '" as remessa from  ' + _DB.Banco + '.produtosnaocontadostmp b ;');

    result := xmStr.Text;
  finally
    FreeAndNil(xmStr);
  end;
end;

function TfrmMain.DoSangria(fCmd: string): string;
begin

  CDSClass.CriaSangria;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);

  if dmModulo.cSangriaFundo.RecordCount > 0 then
  begin
    Processa_Sangria;
  end;
end;

function TfrmMain.DoFundo(fCmd: string): string;
begin

  CDSClass.CriaSangria;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);

  if dmModulo.cSangriaFundo.RecordCount > 0 then
  begin
    Processa_Fundo;
  end;
end;

function TfrmMain.DoItensTransf(fCmd: string): string;
begin

  CDSClass.CriaCItens;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);

  if dmModulo.cItens.RecordCount > 0 then
  begin
    Processa_ItensTransf;
  end;
end;

Procedure TfrmMain.DoContagemEstoque(fFileCmd: string);
var
  jsonRaiz: TJSONArray;
  jsProd: TJSONArray;
  xProd: TJSONValue;
  xData: string;
  xmStr: TStringList;

  j, i: integer;
  xSetor: string;
  xCodigo, xArq, xRemessa: string;
  xQte: Double;
  xEmpresa: String;
  xSerial: String;
begin
  try
    try
      xArq := fFileCmd;
      if xArq = '' then
        exit;
      if not FileExists(SetSlash(_Dir.Recebimento) + xArq) then
        exit;

      _DB.Banco := copy(xArq, 1, pos('_', xArq) - 1);

      xmStr := TStringList.create;
      xmStr.loadfromfile(SetSlash(_Dir.Recebimento) + xArq);

      try

        jsonRaiz := TJsonObject.ParseJSONValue('[' + xmStr.Text + ']') as TJSONArray;

      Except
        on E: Exception do
        begin
          logging(mResp, 'Em ' + datetimetostr(now()) + ' Erro ' + E.Message);

        end;
      end;

      for i := 0 to jsonRaiz.count - 1 do
      begin
        if TJSONValue(jsonRaiz.Items[i]).TryGetValue('ContagemEstoque', jsProd) then
        begin
          for j := 0 to jsProd.count - 1 do
          begin
            xProd := jsProd.Items[j] as TJSONValue;
            xProd.TryGetValue('remessa', xRemessa);
            if xRemessa <> '' then
              break;

          end;
          if xRemessa = '' then
            xRemessa := xArq;
          // if xRemessa <> '' then
          // begin
          // if not ExecutaComandoSql('delete from ' + _DB.Banco + '.contagem where remessarquivo="' +
          // ExtractFileName(fFileCmd) + '" and (baixado is null or baixado="")') then
          // begin
          // xmStr.SaveToFile(_Dir.Erro + '\' + ExtractFileName(fFileCmd));
          // DeleteFile(_Dir.Recebimento + '\' + fFileCmd);
          //
          // end;
          dmModulo.Query.close;
          dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.contagem where remessarquivo="' +
            ExtractFileName(xRemessa) + '" limit 10';
          dmModulo.Query.open;
          if not dmModulo.Query.isempty then
            break;
          // end;
          for j := 0 to jsProd.count - 1 do
          begin
            xProd := jsProd.Items[j] as TJSONValue;
            if xProd.GetValue<string>('id') <> '' then
            begin
              xData := trim(xProd.GetValue<string>('data'));
              xSetor := trim(xProd.GetValue<string>('setor'));
              xEmpresa := trim(xProd.GetValue<string>('empresa'));
              xCodigo := trim(xProd.GetValue<string>('id'));
              xQte := val2(trim(xProd.GetValue<string>('qte')));
              xProd.TryGetValue('serial', xSerial);

              dmModulo.Query.close;
              dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.contagem where setor="' + xSetor + '" and data=' + DtoS(strtodate(xData)) +
                ' and codigo="' + xCodigo + '"';
              if xSerial <> '' then
                dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.contagem where setor="' + xSetor + '" and data=' + DtoS(strtodate(xData)) +
                  ' and serial="' + xSerial + '"';

              dmModulo.Query.open;
              if dmModulo.Query.isempty or (xSerial <> '') then
              begin
                dmModulo.Query.Append;
                dmModulo.Query.fieldbyname('empresa').asstring := xEmpresa;
                dmModulo.Query.fieldbyname('setor').asstring := xSetor;
                dmModulo.Query.fieldbyname('data').asstring := xData;
                dmModulo.Query.fieldbyname('codigo').asstring := xCodigo;
                dmModulo.Query.fieldbyname('serial').asstring := xSerial;
                dmModulo.Query.fieldbyname('qte').asstring := floattostr(xQte);
                dmModulo.Query.fieldbyname('remessarquivo').asstring := ExtractFileName(xRemessa);
              end
              else
              begin
                dmModulo.Query.edit;
                dmModulo.Query.fieldbyname('qte').asstring := floattostr(xQte + val2(dmModulo.Query.fieldbyname('qte').asstring));
              end;
              dmModulo.Query.post;
              // ExecutaComandoSql('insert into ' + _DB.Banco + '.contagem(setor,data,codigo,qte,remessarquivo) values ' + '("' +
              // trim(xProd.GetValue<string>('setor')) + '",' +
              // DtoS(strtodate(xData)) + ',"' +
              // trim(xProd.GetValue<string>('id')) + '",' + trans(val2(trim(xProd.GetValue<string>('qte')))) + ',"' + ExtractFileName(fFileCmd) + '")');

            end;
          end;
        end;
      end;
      xmStr.SaveToFile(_Dir.Feito + '\' + ExtractFileName(xArq));
      DeleteFile(_Dir.Recebimento + '\' + xArq);
    Except
      on E: Exception do
      begin
        xmStr.SaveToFile(_Dir.Erro + '\' + ExtractFileName(xArq));
        DeleteFile(_Dir.Recebimento + '\' + xArq);
        logging(mResp, 'Problemas de processamento da contagem do arquivo' + xArq + ' db' + _DB.Host + ', processo cancelado!');
      end;
    end;

  finally
    FreeAndNil(xmStr);
  end;
end;

function TfrmMain.DoFiscal(fCmd: string): string;
var
  xtexto: TStringList;
  xLinha: TStringList;
  xCorpo: TStringList;
  i: integer;
  xTipo, xData, xEmpresa, xEcf: string;
  xTextStream: TStringStream;

  xIn: Boolean;
begin

  try
    try

      _DB.Banco := '';
      _DB.BancoFinan := '';

      dmModulo.ZipFec.OpenArchive(_Dir.Dir + '\recebimento\' + fCmd);
      xTextStream := TStringStream.create('');
      dmModulo.ZipFec.ExtractStreamByIndex(xTextStream, 0);
      dmModulo.ZipFec.CloseArchive;
      xtexto := TStringList.create;
      xtexto.Text := xTextStream.DataString;
      FreeAndNil(xTextStream);
      xLinha := TStringList.create;
      xCorpo := TStringList.create;
      FSistemaBrasileiro;
      xIn := false;
      for i := 0 to xtexto.count - 1 do
      begin
        if copy(xtexto[i], 1, 5) = '00000' then
          PegaDB(mResp, copy(xtexto[i], 7, 5000));

        if copy(xtexto.Strings[i], 1, 5) = '00701' then
        begin
          xTipo := 'sped';
          break;
        end;
        if copy(xtexto.Strings[i], 1, 5) = '00702' then
        begin
          xTipo := 'sintegra';
          break;
        end;
        if copy(xtexto.Strings[i], 1, 5) = '00703' then
        begin
          xTipo := 'cat52';
          break;
        end;
      end;

      for i := 0 to xtexto.count - 1 do
      begin

        if xTipo = 'sped' then
        begin
          if copy(xtexto.Strings[i], 2, 4) = 'C400' then
          begin
            xLinha.Text := StringReplace(xtexto.Strings[i], '|', #13, [rfReplaceAll]);
            xEcf := xLinha.Strings[4];
            xIn := True;
          end;
          if not xIn and (copy(xtexto.Strings[i], 2, 4) = '0200') then
          begin
            xIn := True;
          end;
          if copy(xtexto.Strings[i], 1, 5) = '00701' then
          begin
            xLinha.Text := StringReplace(xtexto.Strings[i], '|', #13, [rfReplaceAll]);
            xEmpresa := xLinha.Strings[2];
            xData := xLinha.Strings[3];
          end;
        end;
        if xTipo = 'sintegra' then
        begin
          if copy(xtexto.Strings[i], 1, 2) = '60M' then
          begin
            xEcf := copy(xtexto.Strings[i], 13, 20);
            xIn := True;
          end;
          if copy(xtexto.Strings[i], 1, 5) = '00702' then
          begin
            xLinha.Text := StringReplace(xtexto.Strings[i], '|', #13, [rfReplaceAll]);
            xEmpresa := xLinha.Strings[2];
            xData := xLinha.Strings[3];
          end;
        end;
        if xTipo = 'cat52' then
        begin
          if copy(xtexto.Strings[i], 1, 3) = 'E01' then
          begin
            xEcf := copy(xtexto.Strings[i], 13, 20);
            xIn := True;
          end;
          if copy(xtexto.Strings[i], 1, 5) = '00703' then
          begin
            xLinha.Text := StringReplace(xtexto.Strings[i], '|', #13, [rfReplaceAll]);
            xEmpresa := xLinha.Strings[2];
            xData := xLinha.Strings[3];
          end;
        end;

        if xIn then
        begin
          xCorpo.Add(xtexto.Strings[i]);
        end;
      end;
      if (xEcf <> '') and (xEmpresa <> '') and (xCorpo.Text <> '') then
      begin
        _Remessa := ChangeFileExt(fCmd, '.fis');
        Processa_Fiscal(xTipo, xEcf, xEmpresa, xData, xCorpo.Text);
      end;
      CopyFile(pChar(_Dir.Dir + '\recebimento\' + fCmd), pChar(_Dir.Fiscal + '\' + fCmd), false);
      DeleteFile(_Dir.Dir + '\Recebimento\' + fCmd);
    except
      on E: Exception do
      begin

        begin
          CopyFile(pChar(_Dir.Dir + '\Recebimento\' + fCmd), pChar(_Dir.Erro + '\' + fCmd), false);
          try
            if FileExists(pChar(_Dir.Erro + '\' + fCmd)) then
              DeleteFile(pChar(_Dir.Dir + '\Recebimento\' + fCmd));
          except
            mResp.Lines.Add(datetimetostr(now) + ' ERRO: (processar_on delete do fechamento execpt) ' + E.Message);
          end;
        end;
      end;

    end;
  finally
    FreeAndNil(xCorpo);
    FreeAndNil(xtexto);
    FreeAndNil(xLinha);

  end;
end;

function TfrmMain.DoVenda(fCmd: string): string;
begin
  FSistemaBrasileiro;
  CDSClass.CriaCItens;
  CDSClass.CriaCItensRodizio;
  CDSClass.CriaCItensPedidoEntregaPontos;
  CDSClass.CriaRetiradas;
  CDSClass.CriaPagamento;
  CDSClass.CriaCadastroProdutos;
  CDSClass.CriaCadastro;

  _DB.Banco := '';
  _DB.BancoFinan := '';
  _Venda.Acrescimo := '';
  _Venda.Comissao := '';
  _Venda.Total := '';
  Get_Campos(fCmd);
  // cadastra o produto antes
  if dmModulo.cCadastroProdutos.RecordCount > 0 then
  begin
    Grava_CadastroProdutosVenda;
  end;
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);

  if dmModulo.cItens.RecordCount > 0 then
  begin
    Processa_Venda;

  end;
end;

function TfrmMain.DoCadastro(fCmd: string): string;
begin
  FSistemaBrasileiro;
  CDSClass.CriaCadastro;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd); // Pega as linhas e separa em campos no DB (Cadastro);

  if dmModulo.cCadastro.RecordCount > 0 then
  begin
    Grava_Cadastro('001');
  end;
end;

function TfrmMain.DoCadastroPet(fCmd: string): string;
begin
  FSistemaBrasileiro;
  CDSClass.CriaCadastroPet;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd); // Pega as linhas e separa em campos no DB (Cadastro);

  if dmModulo.cCadastroPet.RecordCount > 0 then
  begin
    Grava_CadastroPet('001');
  end;
end;

function TfrmMain.DoCadastroProdutos(fCmd: string): string;
begin
  FSistemaBrasileiro;
  CDSClass.CriaCadastro;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd); // Pega as linhas e separa em campos no DB (Cadastro);

  if dmModulo.cCadastroProdutos.RecordCount > 0 then
  begin
    Grava_CadastroProdutos;
  end;
end;

function TfrmMain.DoItensExcluidos(fCmd: string): string;
begin
  FSistemaBrasileiro;
  CDSClass.CriaCItens;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd); // Pega as linhas e separa em campos no DB ;

  while not dmModulo.cItens.eof do
  begin
    Grava_Canc(dmModulo.cItens.fieldbyname('Venda').asstring);
    // grava //uma linha avulsa de excluido
    dmModulo.cItens.next;
  end;
end;

function TfrmMain.DoPrazo(fCmd: string): string;
begin

  FSistemaBrasileiro;
  CDSClass.CriaPagamento;
  CDSClass.CriaCadastro;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);
  Processa_RecebimentoPrazo;
end;

function TfrmMain.DoCredito(fCmd: string): string;
begin

  FSistemaBrasileiro;
  CDSClass.CriaPagamento;
  CDSClass.CriaCadastro;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);
  Processa_RecebimentoCredito;
end;

function TfrmMain.DoRetiradas(fCmd: string): string;
begin

  FSistemaBrasileiro;
  CDSClass.CriaRetiradas;
  CDSClass.CriaCadastro;
  CDSClass.CriaPagamento;

  _DB.Banco := '';
  _DB.BancoFinan := '';
  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);
  Processa_Retiradas('');
end;

function TfrmMain.DoRetiradasCancel(fCmd: string): string;
var
  xtexto: TStringList;
  xLinha: TStringList;
  i: integer;
begin
  try
    _DB.Banco := '';
    _DB.BancoFinan := '';

    xtexto := TStringList.create;
    xLinha := TStringList.create;
    xtexto.Text := fCmd;
    for i := 0 to xtexto.count - 1 do
    begin

      if copy(xtexto[i], 1, 5) = '00000' then
        PegaDB(mResp, copy(xtexto[i], 7, 5000));
      if copy(xtexto.Strings[i], 1, 5) = '00051' then
      begin
        xLinha.Text := StringReplace(xtexto.Strings[i], '|', #13, [rfReplaceAll]);
        if GetifTem(xLinha, 7) <> '' then
        begin
          ExecutaComandoSql('update  ' + _DB.Banco + '.retiradadetalhe set baixado=now() where remessarquivo="' + GetifTem(xLinha, 7) + '"');
          ExecutaComandoSql('update  ' + _DB.Banco + '.retirada set status=9,usuario="' + GetifTem(xLinha, 6) + '"  where remessarquivo="' +
            GetifTem(xLinha, 7) + '"');
        end;
      end;
    end;
  finally
    FreeAndNil(xLinha);
    FreeAndNil(xtexto);
  end;

end;

function TfrmMain.DoRetiradasBaixa(fCmd: string): string;
begin

  FSistemaBrasileiro;
  CDSClass.CriaRetiradas;
  CDSClass.CriaCadastro;

  _DB.Banco := '';
  _DB.BancoFinan := '';

  Get_Campos(fCmd);
  // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);
  Processa_RetiradasBaixa;
end;

procedure TfrmMain.Set_CItens;
var
  xstr: string;
  function FFator(fcampo: string): string;
  begin
    result := dmModulo.Query.fieldbyname(fcampo).Text;
    if val2(dmModulo.Query.fieldbyname('fator').Text) > 0 then
      result := floattostr(val2(dmModulo.Query.fieldbyname('fator').Text) * val2(dmModulo.Query.fieldbyname(fcampo).Text));
  end;

begin
  dmModulo.cItens.First;
  while not dmModulo.cItens.eof do
  begin
    if xstr = '' then
      xstr := '"' + dmModulo.cItens.fieldbyname('produto').Text + '"'
    else
      xstr := xstr + ',"' + dmModulo.cItens.fieldbyname('produto').Text + '"';
    dmModulo.cItens.next;
  end;
  // processa produtos... simula um update
  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.produtos where cod in (' + xstr + ')';
  dmModulo.Query.open;
  while not dmModulo.Query.eof do
  begin
    if dmModulo.cItens.FindKey([dmModulo.Query.fieldbyname('cod').Text]) then
    begin
      while not dmModulo.cItens.eof and (dmModulo.cItens.fieldbyname('Produto').Text = dmModulo.Query.fieldbyname('cod').Text) do
      begin
        dmModulo.cItens.edit;
        dmModulo.cItens.fieldbyname('tributo').Text := dmModulo.Query.fieldbyname('tributo').Text;
        dmModulo.cItens.fieldbyname('descricao').Text := dmModulo.Query.fieldbyname('descricao').Text;
        dmModulo.cItens.fieldbyname('ValorProd').Text := FFator('valor');
        dmModulo.cItens.fieldbyname('Conta').Text := dmModulo.Query.fieldbyname('conta').Text;
        dmModulo.cItens.fieldbyname('VrCusto').Text := FFator('Custo');
        dmModulo.cItens.fieldbyname('Servico').Text := dmModulo.Query.fieldbyname('Servico').Text;
        dmModulo.cItens.fieldbyname('pontos').Text := dmModulo.Query.fieldbyname('pontos').Text;
        dmModulo.cItens.fieldbyname('pontosresgate').Text := dmModulo.Query.fieldbyname('pontosresgate').Text;
        dmModulo.cItens.post;
        dmModulo.cItens.next;
      end;
    end;
    dmModulo.Query.next;
  end;
end;

procedure TfrmMain.Set_Recdo(fQuery: TClientDataSet;
  fDev:
  Double);
var
  xOldIndex: string;
begin
  VerificaSistemaBrasileiro;
  // processa produtos... simula um update
  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.tipopgto ';
  dmModulo.Query.open;
  xOldIndex := fQuery.IndexName;
  fQuery.IndexName := '';
  fQuery.First;
  while not fQuery.eof do
  begin
    // conserta devolucao
    if fQuery.fieldbyname('devolucao').Text = '-1' then
    begin
      fQuery.edit;
      fQuery.fieldbyname('Codigo').Text := '96';
      fQuery.fieldbyname('Descricao').Text := 'Troca';
      fQuery.fieldbyname('Tipo').Text := '3';
      fQuery.post;
      fQuery.next;
      Continue;
    end;

    dmModulo.Query.First;
    if (fQuery.fieldbyname('Codigo').Text <> '97') then
      // nao pode troco nem desconto ne devolucao
      if fQuery.fieldbyname('devolucao').Text <> '-1' then
        while not dmModulo.Query.eof do
        begin
          if (fQuery.fieldbyname('Codigo').Text = dmModulo.Query.fieldbyname('cod').Text) or
            ((fQuery.fieldbyname('codigo').Text = '99') and (fQuery.fieldbyname('codigo').Text = dmModulo.Query.fieldbyname('tipo').Text)) then
          // excessao para desconto que procura pelo tipo
          begin

            fQuery.edit;
            fQuery.fieldbyname('Taxa').Text := dmModulo.Query.fieldbyname('taxa').Text;

            fQuery.fieldbyname('Descricao').Text := copy(dmModulo.Query.fieldbyname('Descricao').Text, 1, 15);
            if dmModulo.Query.fieldbyname('Cliente').Text <> '' then
              fQuery.fieldbyname('ClienteCartao').Text := dmModulo.Query.fieldbyname('Cliente').Text;
            fQuery.fieldbyname('Tipo').Text := dmModulo.Query.fieldbyname('Tipo').Text;
            // ser for devolucao entao anule o desconto concedido e transforme em desconto por troca tipo 3
            fQuery.fieldbyname('tef').Text := dmModulo.Query.fieldbyname('TipoFiscal').Text;
            fQuery.fieldbyname('Conta').Text := dmModulo.Query.fieldbyname('Conta').Text;
            fQuery.fieldbyname('dias').Text := dmModulo.Query.fieldbyname('dias').Text;
            fQuery.post;
            break;
          end;
          dmModulo.Query.next;
        end;
    fQuery.next;
  end;
  fQuery.IndexName := xOldIndex;

  if fQuery.FindKey(['97']) then // troco
  begin

    fQuery.edit;
    fQuery.fieldbyname('Taxa').Text := '0';
    fQuery.fieldbyname('Descricao').Text := copy('Troco', 1, 15);
    fQuery.fieldbyname('Tipo').Text := '97';
    fQuery.fieldbyname('Conta').Text := '';
    fQuery.post;
  end;
end;

procedure TfrmMain.SetComissao(fempresa, fdata, fcod: string);
begin
  // setando o total
  ExecutaComandoSql('update ' + _DB.Banco + '.vendasdetalhe a set a.total=a.qte*a.valor where ' + '  a.empresa="' + fempresa + '" and a.data=' +
    DtoS(strtodate(fdata)) + ' and a.venda="' + fcod + '"');

  { ExecutaComandoSql('update ' + _DB.Banco + '.vendas a, ' + _DB.Banco + '.vendasdetalhe b set b.desconto=(b.total+b.comissaosrv)*(a.desconto/a.valor) where ' +
    ' a.cod=b.venda and a.empresa=b.empresa and a.data=b.data and a.empresa="' + fempresa + '" and a.data=' + DtoS(strtodate(fdata)) +
    ' and b.venda="' + fcod + '" and a.desconto>0'); }

  if _Comissao = '1' then
  begin
    ExecutaComandoSql('update ' + _DB.Banco + '.vendasdetalhe a, ' + _DB.Banco +
      '.vendedor b set a.comissao=((a.qte*a.valor)+a.juros-a.desconto)*(b.comissao/100) where ' + ' a.vendedor1=b.cod and a.empresa="' + fempresa +
      '" and a.data=' + DtoS(strtodate(fdata)) + ' and a.venda="' + fcod + '" and b.comissao>0');
    if val2(_Comissaovr) > 0 then
    begin
      ExecutaComandoSql('update ' + _DB.Banco + '.vendasdetalhe a set  a.comissao=((a.qte*a.valor)+a.juros-a.desconto)*(' + trans(val2(_Comissaovr)) +
        '/100) where (a.comissao<=0 or a.comissao is null) ' + ' and a.empresa="' + fempresa + '" and a.data=' + DtoS(strtodate(fdata)) +
        ' and a.venda="' + fcod + '"');
    end;
  end
  else
    ExecutaComandoSql('update ' + _DB.Banco + '.vendasdetalhe a, ' + _DB.Banco +
      '.produtos b set a.comissao=((a.qte*a.valor)+a.juros-a.desconto)*(b.comissao/100) where ' + ' a.produto=b.cod and a.empresa="' + fempresa +
      '" and a.data=' + DtoS(strtodate(fdata)) + ' and a.venda="' + fcod + '" and b.comissao>0');
  // setando desconto
end;

procedure TfrmMain.Grava_Itens(var fid: string; var fVal, fRepique: Double; var fEntrega: string);
var
  xval, xRepique: Double;
  xDescricao: String;
  xJuros: Extended;
  xInd: Double;
  xObs: String;
  function FRec_Canc(fid: string): Boolean;
  var
    xRec: integer;
  begin
    result := false;
    xRec := dmModulo.cItens.Recno;
    dmModulo.cItens.First;
    while not dmModulo.cItens.eof do
    begin
      if FCampo_It('id_cancelado') = fid then
      begin
        result := True;
        break;
      end;
      dmModulo.cItens.next;
    end;
    dmModulo.cItens.Recno := xRec;
  end;

begin
  dmModulo.cItens.IndexName := 'index2';
  dmModulo.cItens.First;
  xval := 0;
  xRepique := 0;
  fEntrega := '0';
  while not dmModulo.cItens.eof do
  begin
    if FCampo_It('tipo') <> '00001' then // somente vendas
    begin
      dmModulo.cItens.next;
      Continue;
    end;
    if not FRec_Canc(IntToStr(dmModulo.cItens.Recno)) then
    begin
      // procura se este item e cancelado

      if LowerCase(FCampo_It('entrega')) = 'entrega' then
        fEntrega := '1';

      xDescricao := copy(FCampo_It('descricao'), 1, 100);

      xObs := copy(FCampo_It('obs'), 1, 50);
      xObs := ClearString(xObs);

      xDescricao := ClearString(copy(FCampo_It('descricao'), 1, 100));
      if trim(xDescricao) = '' then
        xDescricao := 'Diversos';

      xval := xval + BRound(val2(FCampo_It('qte')) * val2(FCampo_It('valor')), 2, True);

      xInd := val2(_Venda.Ind);
      xJuros := val2(FCampo_It('qte')) * val2(FCampo_It('valor'));
      xJuros := BRound(xJuros * xInd, 4);

      ExecutaComandoSql('insert into ' + _DB.Banco + '.vendasdetalhe (empresa,caixa,data,venda,produto,serial,' +
        ' descricao,qte,valor,desconto,juros,total,tributo,vendedor1,executor1,valorprod,conta,vrcusto,comissaosrv, outrassaidaid,obs, remessarquivo) values ("'
        + FCampo_It('Empresa') + '",' + FCampo_It('caixa') + ',' + DtoS(strtodate(FCampo_It('data'))) + ',"' + fid + '","' +
        FCampo_It('produto') +
        '","' + FCampo_It('serial') + '",' + QuotedStr(xDescricao) + ',' + trans(val2(FCampo_It('qte'))) + ',' +
        trans(val2(FCampo_It('valor'))) + ',' + trans(val2(FCampo_It('desconto_item'))) + ',' + trans(xJuros) + ',' +
        trans(BRound(val2(FCampo_It('qte')) * val2(FCampo_It('valor')), 2, True)) + ',"' + FCampo_It('tributo') + '","' +
        FCampo_It('vendedor') +
        '","' + FCampo_It('executor1') + '",' + trans(val2(FCampo_It('valorprod'))) + ',"' + FCampo_It('conta') + '",' +
        trans(val2(FCampo_It('VrCusto'))) + ',' + trans(val2(FCampo_It('comissaosrv'))) + ',"' + trans(val2(FCampo_It('outrassaidaid'))) +
        '",' + QuotedStr(xObs) + ',"' +
        _Remessa + '");');
      xval := xval + val2(FCampo_It('comissaosrv'));
      if xRepique = 0 then
        xRepique := val2(FCampo_It('repique'));
    end;
    dmModulo.cItens.next;
    // refresh no servidor
    if (dmModulo.cItens.Recno mod 50) = 0 then
  end;
  fVal := xval;
  fRepique := xRepique;
  dmModulo.cItens.IndexName := 'index1';
end;

procedure TfrmMain.LancaPontos(var fid: string);
var
  xval, xRepique: Double;
  function FRec_Canc(fid: string): Boolean;
  var
    xRec: integer;
  begin
    result := false;
    xRec := dmModulo.cItens.Recno;
    dmModulo.cItens.First;
    while not dmModulo.cItens.eof do
    begin
      if FCampo_It('id_cancelado') = fid then
      begin
        result := True;
        break;
      end;
      dmModulo.cItens.next;
    end;
    dmModulo.cItens.Recno := xRec;
  end;

begin
  dmModulo.cItens.IndexName := 'index2';
  dmModulo.cItens.First;
  xval := 0;
  xRepique := 0;
  while not dmModulo.cItens.eof do
  begin
    if FCampo_It('tipo') <> '00001' then // somente vendas
    begin
      dmModulo.cItens.next;
      Continue;
    end;
    if not FRec_Canc(IntToStr(dmModulo.cItens.Recno)) then
    begin
      if val2(FCampo_It('pontos')) > 0 then
      begin
        ExecutaComandoSql('insert into ' + _DB.Banco + '.pontos (empresa,data,venda,pedido,cpfcnpj,usuario,produto,qte,valor,' +
          ' tipo, pontos, remessarquivo) values ("' + FCampo_It('Empresa') + '",' + DtoS(strtodate(FCampo_It('data'))) + ',"' + fid + '","' +
          FCampo_Pag('comanda') + '","' + FCampo_Pag('CPFCNPJ') + '","' + FCampo_It('usuario') + '","' + FCampo_It('produto') + '",' +
          trans(val2(FCampo_It('qte'))) + ',' + trans(val2(FCampo_It('valor'))) + ',"E",' + trans(val2(FCampo_It('pontos'))) + ',"' +
          _Remessa + '");');
      end;
    end;
    dmModulo.cItens.next;
  end;
  dmModulo.cItens.IndexName := 'index1';
end;

function TfrmMain.Grava_ItensRetiradas(fid: string): Double;
var
  xval: Double;
  xDesc: Double;
  function FCampo_It(fcampo: string): string;
  begin
    result := dmModulo.cRetiradas.fieldbyname(fcampo).asstring;
  end;

begin
  dmModulo.cRetiradas.IndexName := 'index1';
  dmModulo.cRetiradas.First;
  xval := 0;
  xDesc := val2(FCampo_It('desconto'));
  while not dmModulo.cRetiradas.eof do
  begin

    // procura se este item e cancelado
    ExecutaComandoSql('insert into ' + _DB.Banco + '.retiradadetalhe(empresa, data, cod,produto,qte,consignado,valor,valorprod, ' +
      '  desconto_item, fator, tipo,categoria,serial,' +
      ' obs_item, executor1, remessarquivo)' + ' values ("' + FCampo_It('Empresa') + '",' + DtoS(strtodate(FCampo_It('data'))) + ',"' + fid +
      '","' +
      FCampo_It('produto') + '",' + trans(val2(FCampo_It('qte'))) + ',' + trans(val2(FCampo_It('qte'))) + ',' +
      trans(val2(FCampo_It('valor'))) + ',' + trans(val2(FCampo_It('valorprod'))) + ',' + trans(val2(FCampo_It('desconto_item'))) + ',' +
      trans(val2(FCampo_It('fator'))) + ',"' +
      FCampo_It('opcao') + '","' + FCampo_It('categoria') + '","' + FCampo_It('serial') + '","' + FCampo_It('obs_item') + '","' +
      FCampo_It('executor') + '","' + _Remessa + '")');
    xval := xval + (val2(FCampo_It('qte')) * val2(FCampo_It('valor')));
    dmModulo.cRetiradas.next;
  end;

  dmModulo.cRetiradas.IndexName := 'index1';
  result := xval - xDesc;
end;

function TfrmMain.Grava_Canc(fid: string): Double;
var
  xval: Double;

begin
  dmModulo.cItens.First;
  xval := 0;

  while not dmModulo.cItens.eof do
  begin
    if FCampo_It('tipo') <> '00011' then // somente cancelamentos
    begin
      dmModulo.cItens.next;
      Continue;
    end;

    ExecutaComandoSql('insert into ' + _DB.Banco + '.itensexcluidos (empresa,data,venda,vendedor,cliente,caixa,produto,' +
      ' descricao,qte,valor,remessarquivo) values ("' + FCampo_It('Empresa') + '",' + DtoS(strtodate(FCampo_It('data'))) + ',"' + fid + '","' +
      FCampo_It('vendedor') + '","' + _Cliente.Codigo + '","' + FCampo_It('caixa') + '","' + FCampo_It('produto') + '","' +
      FCampo_It('descricao') +
      '",' + trans( - 1 * val2(FCampo_It('qte'))) + ',' + trans(val2(FCampo_It('valor'))) + ',"' + _Remessa + '");');

    xval := xval + (val2(FCampo_It('qte')) * val2(FCampo_It('valor')));
    dmModulo.cItens.next;
  end;
  result := - 1 * xval;
end;

function TfrmMain.Grava_Devolucao(fid: string): Double;
var
  xQte, xvalor, xval: Double;
  xcod: string;

begin
  dmModulo.cItens.First;
  xval := 0;

  while not dmModulo.cRetiradas.eof do
  begin
    if FCampo_It('tipo') <> '00010' then // somente vendas
    begin
      dmModulo.cItens.next;
      Continue;
    end;
    if xcod = '' then
    begin
      xcod := Incrementador(_DB.Banco, 'devolve'); // pega so na primeira ve
    end;

    ExecutaComandoSql('insert into ' + _DB.Banco + '.devolucaodetalhe (empresa,data,cod,produto,' + ' qte,valor,remessarquivo) values ("' +
      FCampo_It('Empresa') + '",' + DtoS(strtodate(FCampo_It('data'))) + ',"' + xcod + '","' + FCampo_It('produto') + '",' +
      trans( - 1 * val2(FCampo_It('qte'))) + ',' + trans(val2(FCampo_It('valor'))) + ',"' + _Remessa + '");');

    xQte := - 1 * val2(FCampo_It('qte'));
    xvalor := val2(FCampo_It('valor'));
    xval := xval + (xQte * xvalor);
    dmModulo.cItens.next;
  end;
  if (xcod <> '') then
  begin
    ExecutaComandoSql('insert into ' + _DB.Banco + '.devolucao (empresa,data,cod, Valor,cliente,cpf,cnpj,vendedor,' +
      '  funcionario,datahora,hora,datafim,venda,remessarquivo) ' + ' values ("' + FCampo_It('Empresa') + '",' +
      DtoS(strtodate(FCampo_It('data'))) +
      ',"' + xcod + '",' + trans(xval) + ',"' + _Cliente.Codigo + '","' + LimpaConteudo(_Cliente.Cpf) + '","' + LimpaConteudo(_Cliente.Cnpj) +
      '","' +
      FCampo_It('vendedor') + '","' + FCampo_It('usuario') + '","' + _Hora + '",now(),now(),' + fid + ',"' + _Remessa + '");');
  end;

  result := xval;
end;

function TfrmMain.FCampo_Pag(fcampo: string): string;
begin
  result := dmModulo.CPagamento.fieldbyname(fcampo).asstring;
end;

function TfrmMain.Grava_Venda(fid: string;
  fRepique: Double;
  fEntrega, fNomeCliente: string): string;
var
  xNomeCliente: String;
  xCpfCNPJ: string;
  xCaixa: String;
  xBool: Boolean;
  function FCampo_PagDt(fcampo: string): string;
  begin
    if dmModulo.CPagamento.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.CPagamento.fieldbyname(fcampo).asstring));
  end;

  function Get_Desconto: string;
  var
    xDesc: Double;
  begin
    dmModulo.CPagamento.First; // no pagamento eu posso setar a venda primeiro;
    xDesc := 0;
    while not dmModulo.CPagamento.eof do
    begin
      if (FCampo_Pag('tipo') = '99') or (FCampo_Pag('codigo') = '99') then
        xDesc := xDesc + val2(FCampo_Pag('valor'));
      if (FCampo_Pag('tipo') = '3') then
        xDesc := xDesc + val2(FCampo_Pag('valor'));
      dmModulo.CPagamento.next;
    end;
    result := trans(xDesc);
    dmModulo.CPagamento.First;
  end;

  function Get_Troca: string;
  var
    xDesc: Double;
  begin
    dmModulo.CPagamento.First; // no pagamento eu posso setar a venda primeiro;
    xDesc := 0;
    while not dmModulo.CPagamento.eof do
    begin
      if (FCampo_Pag('tipo') = '3') then
        xDesc := xDesc + val2(FCampo_Pag('valor'));
      dmModulo.CPagamento.next;
    end;
    result := trans(xDesc);
    dmModulo.CPagamento.First;
  end;
  function Get_DescontoPgto: string;
  var
    xDesc: Double;
  begin
    dmModulo.CPagamento.First; // no pagamento eu posso setar a venda primeiro;
    xDesc := 0;
    while not dmModulo.CPagamento.eof do
    begin
      if (FCampo_Pag('tipo') = '99') then
        xDesc := xDesc + val2(FCampo_Pag('valor'));
      dmModulo.CPagamento.next;
    end;
    result := trans(xDesc);
    dmModulo.CPagamento.First;
  end;

  function Get_ValorVenda: string;
  var
    xval: Double;
  begin
    dmModulo.cItens.First; // no pagamento eu posso setar a venda primeiro;
    xval := 0;
    while not dmModulo.cItens.eof do
    begin
      xval := xval + (val2(FCampo_It('valor')) * val2(FCampo_It('qte')));
      dmModulo.cItens.next;
    end;
    result := trans(xval);
    dmModulo.CPagamento.First;
  end;

begin
  dmModulo.cItens.First; // no pagamento eu posso setar a venda primeiro;
  dmModulo.CPagamento.First; // no pagamento eu posso setar a venda primeiro;
  // o campo da forma de pagamento cliente sempre traz o cliente do cabecalho da venda...
  // o campo desconto e o total de desconto + troca!

  Set_Cliente(FCampo_Pag('cliente'), _Cliente);
  xNomeCliente := _Cliente.Nome;
  if fNomeCliente <> '' then
    xNomeCliente := fNomeCliente;
  xCpfCNPJ := FCampo_Pag('cliente');
  if xCpfCNPJ = '' then
    xCpfCNPJ := '00000000001';

  xCaixa := FCampo_Pag('caixa');
  if xCaixa = '' then
    xCaixa := FCampo_It('caixa');
  if xCaixa = '' then
    xCaixa := '1';

  try
    xBool := ExecutaComandoSql('insert into ' + _DB.Banco + '.vendas (caixa,cod,mesa,atendimento,venda_remoto,cpf,cnpj,data,Valor,repique,juros,' +
      ' cliente,nome,vendedor,desconto, descontopgto, troca, vrservico, frete,' +
      ' funcionario,hora,empresa,setor,concluida,cupom,cpfcnpj_fiscal,usuario,placa, veiculo, rt, entrega, ChaveNFec,remessarquivo)' +
      ' values ("' +
      xCaixa + '","' + fid + '","' + FCampo_Pag('mesa') + '","' + FCampo_Pag('comanda') + '","' + FCampo_Pag('venda') + '","' +
      FGet_CPF(xCpfCNPJ) + '","' + FGet_CNPJ(xCpfCNPJ) + '",' + FCampo_PagDt('data') + ',' + Get_ValorVenda + ',' +
      trans(fRepique) + ',' + trans(val2(_Venda.Acrescimo)) + ',"' + _Cliente.Codigo + '","' + fNomeCliente + '","' + FCampo_Pag('vendedor') +
      '",' + Get_Desconto + ',' +
      Get_DescontoPgto +
      ',' + Get_Troca + ',' + trans(val2(FCampo_Pag('vrservico'))) + ',' + trans(val2(FCampo_Pag('frete'))) + ',"' + FCampo_Pag('usuario') +
      '","' +
      FCampo_Pag('hora') + '","' +
      FCampo_Pag('empresa') + '","' + FCampo_Pag('setor') + '"' + ',' + FCampo_PagDt('data') + ',"' + FCampo_Pag('cupom') + '","' +
      FCampo_Pag('CPFCNPJ') + '","' + FCampo_Pag('usuario') + '","' + FCampo_Pag('placa') + '","' + FCampo_Pag('veiculo') + '","' +
      FCampo_Pag('rt') +
      '","' + fEntrega + '","' + FCampo_Pag('ChaveNfec') + '","' + _Remessa + '")');
  except
    xBool := false;
  end;
  if not xBool then
  begin
    raise Exception.create('Sql:Error Gravando Vendas');
    // Action := TErrorAction.eaAbort;

  end;

  if _Cliente.Codigo <> '00001' then
  begin
    ExecutaComandoSql('update  ' + _DB.BancoFinan + '.cadastro set vendedor="' + FCampo_Pag('vendedor') + '" where codigo="' +
      _Cliente.Codigo + '"');

  end;

  result := xCaixa;

end;

function TfrmMain.Grava_Retiradas(fid: string;
  fVal:
  Double;
  fVenda:
  String = '0'): string;
var
  xVenda: String;

begin
  dmModulo.cRetiradas.First; // no pagamento eu posso setar a venda primeiro;
  // o campo da forma de pagamento cliente sempre traz o cliente do cabecalho da venda...

  if trim(fVenda) = '' then
    fVenda := '0';
  xVenda := FCampo_Out('venda');
  if xVenda = '' then
    xVenda := 'null';

  ExecutaComandoSql('insert into ' + _DB.Banco + '.retirada (cod,empresa,setor,data,caixa,tipo,desconto,valor,cliente,cpf, ' +
    ' cnpj, vendedor, funcionario, pagamento, id_remoto, pedido, obs , rt, placa , venda, remessarquivo)' + ' values (' + fid + ',"' +
    FCampo_Out('empresa') + '","' + FCampo_Out('setor') + '",' + FCampo_OutDt('data') + ',"' + FCampo_Out('caixa') + '","' +
    FCampo_Out('opcao') +
    '",' + trans(FCampo_Out('desconto')) + ',' + trans(fVal) + ',"' + _Cliente.Codigo + '","' + FGet_CPF(_Cliente.Cpf) + '","' +
    FGet_CNPJ(_Cliente.Cnpj) + '","' + FCampo_Out('vendedor') + '","' + FCampo_Out('usuario') + '",null,"' + FCampo_Out('id') + '","' + fVenda
    + '",'
    + QuotedStr(FCampo_Out('obs')) + ',' + QuotedStr(FCampo_Out('rt')) + ',' + QuotedStr(FCampo_Out('placa')) + ',' + xVenda + ',"' +
    _Remessa + '")');
  ExecutaComandoSql('update ' + _DB.Banco + '.retiradadetalhe a, ' + _DB.Banco +
    '.produtos b set a.descricao=b.descricao , a.vrcusto=b.custo where a.produto=b.cod and a.cod=' + fid);

end;

procedure TfrmMain.Processa_Sangria;
  function FCampo_It(fcampo: string): string;
  begin
    result := dmModulo.cSangriaFundo.fieldbyname(fcampo).asstring;

  end;

begin
  ExecutaComandoSql('delete from ' + _DB.Banco + '.sangria where remessarquivo="' + _Remessa + '"');
  ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.lancamento where remessarquivo="' + _Remessa + '"');

  dmModulo.cSangriaFundo.First;
  SetEmpresa(FCampo_It('empresa'));
  while not dmModulo.cSangriaFundo.eof do
  begin
    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.sangria where 1<>1';
    dmModulo.QueryInt.open;
    dmModulo.QueryInt.edit;

    dmModulo.QueryInt.fieldbyname('empresa').Text := FCampo_It('Empresa');
    dmModulo.QueryInt.fieldbyname('caixa').Text := FCampo_It('caixa');
    dmModulo.QueryInt.fieldbyname('data').Text := FCampo_It('data');
    dmModulo.QueryInt.fieldbyname('descricao').Text := FCampo_It('descricao');
    dmModulo.QueryInt.fieldbyname('valor').AsFloat := val2(FCampo_It('Valor'));
    dmModulo.QueryInt.fieldbyname('funcionario').Text := copy(FCampo_It('Usuario'), 1, 10);
    dmModulo.QueryInt.fieldbyname('completa').Text := '0';
    dmModulo.QueryInt.fieldbyname('datahora').Text := FCampo_It('data');
    dmModulo.QueryInt.fieldbyname('remessarquivo').Text := _Remessa;
    dmModulo.QueryInt.post;
    ProcessaInt_Sangria(FCampo_It('descricao'), FCampo_It('data'), FCampo_It('valor'));

    dmModulo.cSangriaFundo.next;
  end;

end;

procedure TfrmMain.Processa_Fundo;
  function FCampo_It(fcampo: string): string;
  begin
    result := dmModulo.cSangriaFundo.fieldbyname(fcampo).asstring;

  end;

begin
  ExecutaComandoSql('delete from ' + _DB.Banco + '.fundo where remessarquivo="' + _Remessa + '"');

  dmModulo.cSangriaFundo.First;
  while not dmModulo.cSangriaFundo.eof do
  begin

    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.fundo where 1<>1';
    dmModulo.QueryInt.open;
    dmModulo.QueryInt.Append;

    dmModulo.QueryInt.fieldbyname('empresa').Text := FCampo_It('empresa');
    dmModulo.QueryInt.fieldbyname('caixa').Text := FCampo_It('caixa');
    dmModulo.QueryInt.fieldbyname('data').Text := FCampo_It('data');
    dmModulo.QueryInt.fieldbyname('hora').Text := FCampo_It('descricao');
    dmModulo.QueryInt.fieldbyname('valor').AsFloat := val2(FCampo_It('Valor'));
    dmModulo.QueryInt.fieldbyname('funcionario').Text := copy(FCampo_It('Usuario'), 1, 10);
    dmModulo.QueryInt.fieldbyname('remessarquivo').Text := _Remessa;
    dmModulo.QueryInt.post;
    dmModulo.cSangriaFundo.next;
  end;

end;

procedure TfrmMain.Processa_ItensTransf;

begin
  ExecutaComandoSql('delete from ' + _DB.Banco + '.itenstransferidos where remessarquivo="' + _Remessa + '"');

  dmModulo.cItens.First;
  while not dmModulo.cItens.eof do
  begin

    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.itenstransferidos where 1<>1';
    dmModulo.QueryInt.open;
    dmModulo.QueryInt.Append;

    dmModulo.QueryInt.fieldbyname('empresa').Text := FCampo_It('empresa');
    dmModulo.QueryInt.fieldbyname('setor').Text := FCampo_It('setor');
    dmModulo.QueryInt.fieldbyname('caixa').Text := FCampo_It('caixa');
    dmModulo.QueryInt.fieldbyname('data').Text := FCampo_It('data');
    dmModulo.QueryInt.fieldbyname('hora').Text := FCampo_It('hora');
    dmModulo.QueryInt.fieldbyname('funcionario').Text := copy(FCampo_It('Usuario'), 1, 10);
    dmModulo.QueryInt.fieldbyname('origem').Text := FCampo_It('origem');
    dmModulo.QueryInt.fieldbyname('destino').Text := FCampo_It('destino');
    dmModulo.QueryInt.fieldbyname('produto').Text := FCampo_It('produto');

    dmModulo.QueryInt.fieldbyname('qte').Text := floattostr(StrToFloatDef(FCampo_It('qte'), 0));

    dmModulo.QueryInt.fieldbyname('remessarquivo').Text := _Remessa;
    dmModulo.QueryInt.post;
    dmModulo.cItens.next;
  end;

end;

procedure TfrmMain.fCancelaVenda(fNumFab, fCCF: string);
// comando internerno
var
  xcoo, xData, xstr: string;
begin
  try
    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.paf_z_ecf where numFab in ("' + fNumFab + '") order by marca_ecf,numfab';
    dmModulo.QueryInt.open;

    if not dmModulo.QueryInt.isempty then
    begin
      xstr := dmModulo.QueryInt.fieldbyname('empresa').Text;
      dmModulo.QueryInt.close;
      dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.paf_detalhe where numFab in ("' + fNumFab + '") and CCF="' + fCCF + '"';
      dmModulo.QueryInt.open;
      xcoo := dmModulo.QueryInt.fieldbyname('coo').Text;
      xData := DtoS(strtodate(dmModulo.QueryInt.fieldbyname('data').Text));
      if not dmModulo.QueryInt.isempty then
      begin

        dmModulo.QueryInt.close;
        dmModulo.QueryInt.SQL.Text := 'Select a.remessarquivo  from ' + _DB.Banco + '.vendas a,' + _DB.Banco +
          '.vendasrecdo b where a.cod=b.venda and ' +
          ' a.cupom="' + xcoo + '" and a.data=' + xData + ' and a.empresa="' + xstr + '" limit 1';
        dmModulo.QueryInt.open; // segurando os dados!
        if not dmModulo.QueryInt.isempty then
        begin
          xstr := dmModulo.QueryInt.fieldbyname('remessarquivo').Text;
          dmModulo.QueryInt.close;
          dmModulo.QueryInt.SQL.Text := 'Select produto,setor  from ' + _DB.Banco + '.lancamentoserial  where remessarquivo="' + xstr +
            '" group by produto';
          dmModulo.QueryInt.open; // segurando os dados!
          FCancelaVendaEx(xstr, True); // deleta finan

          while not dmModulo.QueryInt.eof do
          begin
            AtualizaQtProduto(dmModulo.QueryInt.fieldbyname('produto').Text, dmModulo.QueryInt.fieldbyname('setor').Text);
            dmModulo.QueryInt.next;
          end;

        end;
      end;
    end;
  finally

  end;
end;

procedure TfrmMain.ProcessaInt_Sangria(fDescr, fdata, fValor: string);
var
  xContaSangria, XcontaDescricao: string;
begin
  // setar parametros
  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.param where id=1';
  dmModulo.QueryInt.open;
  xContaSangria := dmModulo.QueryInt.fieldbyname('ContaSangria').Text;
  SetConta(xContaSangria);
  if _Conta.Conta <> '' then
  begin
    XcontaDescricao := trim(copy(_Conta.Descricao + ' ' + fDescr, 1, 100));
    Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, '', '', '', _Conta.Conta, _Conta.Tipo, _Empresa.Caixa, '', XcontaDescricao, fdata,
      val2(fValor));
  end;
end;

procedure TfrmMain.Grava_Cadastro(fUsu: string);
var
  xcampo, xcod: string;
begin

  dmModulo.cCadastro.First;
  while not dmModulo.cCadastro.eof do
  begin
    dmModulo.Query.close;
    if FGet_CPF(dmModulo.cCadastro.fieldbyname('codigo').Text) <> '' then
    begin
      dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cpf="' +
        FGet_CPF(dmModulo.cCadastro.fieldbyname('codigo').Text) + '"';
      xcampo := 'cpf';
    end
    else
      if FGet_CNPJ(dmModulo.cCadastro.fieldbyname('codigo').Text) <> '' then
    begin
      dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cnpj="' +
        FGet_CNPJ(dmModulo.cCadastro.fieldbyname('codigo').Text) + '"';
      xcampo := 'cnpj';
    end
    else
    begin
      dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cpf="00000000001"';
      xcampo := 'cpf';
    end;
    dmModulo.Query.open;

    if dmModulo.Query.FindField('nfc') = nil then
    begin
      ExecutaComandoSql('Alter table ' + _DB.BancoFinan + '.cadastro add nfc varchar(20) default null, add key iNFC (nfc)');
      dmModulo.Query.close;
      dmModulo.Query.open;
    end;

    if dmModulo.Query.isempty then
    begin
      xcod := StrZero(Maximo(_DB.BancoFinan + '.cadastro', 'codigo'), 5);
      ExecutaComandoSql('insert into ' + _DB.BancoFinan + '.cadastro (codigo,cliente,nome,' + xcampo +
        ',sexo,inscr,nasc,fone,email,endereco,cep,cidade,bairro,uf,senha,cadastroempresa,enviarcorrespondencia,vendedor,nfc,cadastro) ' +
        ' values (' + SetS(xcod) +
        ',1,' + SetS(dmModulo.cCadastro.fieldbyname('nome').Text) + ',' + SetS(dmModulo.cCadastro.fieldbyname('codigo').Text) + ',' +
        SetS(dmModulo.cCadastro.fieldbyname('sexo').Text) + ',' + SetS(dmModulo.cCadastro.fieldbyname('inscr').Text) +
        ',' + SetSD(dmModulo.cCadastro.fieldbyname('nasc').Text) + ',' + SetS(dmModulo.cCadastro.fieldbyname('fone').Text) + ',' +
        SetS(dmModulo.cCadastro.fieldbyname('email').Text) + ',' + SetS(dmModulo.cCadastro.fieldbyname('endereco').Text) + ',' +
        SetS(dmModulo.cCadastro.fieldbyname('cep').Text)
        + ',' + SetS(copy(dmModulo.cCadastro.fieldbyname('cidade').Text, 1, 50)) + ',' + SetS(copy(dmModulo.cCadastro.fieldbyname('bairro').Text, 1,
        20)) + ',' +
        SetS(dmModulo.cCadastro.fieldbyname('uf').Text) + ',' + SetS(dmModulo.cCadastro.fieldbyname('senha').Text) + ',' + SetS(_Empresa.Codigo) + ',' +
        SetS(dmModulo.cCadastro.fieldbyname('enviarcorrespondencia').Text) + ',' + SetS(fUsu) + ',' +
        SetS(dmModulo.cCadastro.fieldbyname('nfc').Text) + ',now())');

    end
    else
    begin
      if (dmModulo.cCadastro.fieldbyname('nfc').Text <> '') then
        if (dmModulo.cCadastro.fieldbyname('nfc').Text <> dmModulo.Query.fieldbyname('nfc').asstring) then
        begin
          xcod := dmModulo.Query.fieldbyname('codigo').asstring;
          ExecutaComandoSql('update ' + _DB.BancoFinan + '.cadastro set nfc=' + SetS(dmModulo.cCadastro.fieldbyname('nfc').Text) + ' where codigo=' +
            SetS(xcod));
          // grava para historico e faz valer o atual
          // codigo fica para depois
        end;
    end;

    dmModulo.cCadastro.next;
  end;
  dmModulo.cCadastro.First;
  Set_Cliente(dmModulo.cCadastro.fieldbyname('codigo').Text, _Cliente);

end;

procedure TfrmMain.Grava_CadastroPet;
var
  xcampo, xcod: string;
  xCodigo: string;
begin

  dmModulo.cCadastroPet.First;
  while not dmModulo.cCadastroPet.eof do
  begin
    dmModulo.Query.close;
    if FGet_CPF(dmModulo.cCadastroPet.fieldbyname('cadastro').Text) <> '' then
    begin
      dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cpf="' +
        FGet_CPF(dmModulo.cCadastroPet.fieldbyname('cadastro').Text) + '"';
      xcampo := 'cpf';
    end
    else
      if FGet_CNPJ(dmModulo.cCadastroPet.fieldbyname('cadastro').Text) <> '' then
    begin
      dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cnpj="' +
        FGet_CNPJ(dmModulo.cCadastroPet.fieldbyname('cadastro').Text) + '"';
      xcampo := 'cnpj';
    end
    else
    begin
      dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where cpf="000000001"';
      xcampo := 'cpf';
    end;
    dmModulo.Query.open;
    if not dmModulo.Query.isempty then
    begin
      if dmModulo.Query.fieldbyname('qtecaes') = nil then
      begin
        ExecutaComandoSql('Alter table ' + _DB.BancoFinan +
          '.cadastro add qtecaes int(4),add qtegatos int(4),add qteoutros int(4),outro varchar(30)');
      end;
      xCodigo := dmModulo.Query.fieldbyname('codigo').asstring;
      ExecutaComandoSql('update ' + _DB.BancoFinan + '.cadastro set qtecaes=' + trans(val2(dmModulo.cCadastroPet.fieldbyname('qtecaes').Text)) + ' ,' +
        'qtegatos=' + trans(val2(dmModulo.cCadastroPet.fieldbyname('qtegatos').Text)) +
        ' ,qteoutros=' + trans(val2(dmModulo.cCadastroPet.fieldbyname('qteoutros').Text)) +
        ' ,outros=' + SetS(dmModulo.cCadastroPet.fieldbyname('outro').Text) + ' where codigo="' + xCodigo + '"');

      ExecutaComandoSql('insert into ' + _DB.Banco + '.clientespet (cadastro,nome,especie,porte,raca,sexo,nascimento)' +
        ' values ("' + xCodigo + '",' + SetS(dmModulo.cCadastroPet.fieldbyname('nome').Text) + ',' +
        SetS(dmModulo.cCadastroPet.fieldbyname('especie').Text) + ',' + SetS(dmModulo.cCadastroPet.fieldbyname('tamanho').Text) +
        ',' + SetS(dmModulo.cCadastroPet.fieldbyname('raca').Text) + ',' + SetS(dmModulo.cCadastroPet.fieldbyname('sexo').Text) + ',' +
        SetSD(dmModulo.cCadastroPet.fieldbyname('nascimento').Text) + ')');

    end;
    dmModulo.cCadastroPet.next;

  end;

end;

Function TfrmMain.FindProdutos(fcampo, fBarras: String): Boolean;
begin
  dmModulo.QueryResult.close;
  dmModulo.QueryResult.SQL.Text := 'select cod,barras from  ' + _DB.Banco + '.produtos where ' + fcampo + '="' + fBarras + '"';
  dmModulo.QueryResult.open;

  result := (dmModulo.QueryResult.fieldbyname(fcampo).asstring = fBarras);

end;

procedure TfrmMain.Grava_CadastroProdutos;
var
  xcampo, xcod: string;
  xbarras: string;
  xZeroEsquerda: Boolean;
begin

  dmModulo.cCadastroProdutos.First;
  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select zeroaesquerda from ' + _DB.Banco + '.param ';
  dmModulo.Query.open;
  xZeroEsquerda := dmModulo.Query.fieldbyname('zeroaesquerda').asstring = '1';

  while not dmModulo.cCadastroProdutos.eof do
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'Select * from ' + _DB.Banco + '.produtos where codexpress="' + dmModulo.cCadastroProdutos.fieldbyname('codigo')
      .Text + '"';
    dmModulo.Query.open;
    if dmModulo.Query.isempty then
    begin

      xcod := StrZero(Incrementador(_DB.Banco, 'produtos'), 12);
      // pega so na primeira ve
      while FindProdutos('cod', xcod) do
      begin
        if xZeroEsquerda then
          xcod := StrZero(Incrementador(_DB.Banco, 'produtos'), 9)
          // pega so na primeira ve
        else
          xcod := Incrementador(_DB.Banco, 'produtos'); // pega so na primeira ve
      end;

      xbarras := StrZero(Incrementador(_DB.Banco, 'produtos'), 12);
      // pega so na primeira ve
      while FindProdutos('barras', xbarras) do
        xbarras := StrZero(Incrementador(_DB.Banco, 'barras'), 12);
      // pega so na primeira ve

      ExecutaComandoSql('insert into ' + _DB.Banco + '.produtos (cod,barras,codexpress,descricao,grupo,custo,valor,vender) values (' +
        SetS(xcod) +
        ',' + SetS(xbarras) + ',' + SetS(dmModulo.cCadastroProdutos.fieldbyname('codigo').Text) + ',' +
        SetS(dmModulo.cCadastroProdutos.fieldbyname('descricao').Text) +
        ',' + SetS(dmModulo.cCadastroProdutos.fieldbyname('grupo').Text) + ',' + trans(dmModulo.cCadastroProdutos.fieldbyname('custo').Text) + ',' +
        trans(dmModulo.cCadastroProdutos.fieldbyname('valor').Text) + ',1)');
    end;
    dmModulo.cCadastroProdutos.next;
  end;
  dmModulo.cCadastroProdutos.First;

end;

procedure TfrmMain.Grava_CadastroProdutosVenda;
var
  xcampo, xcod: string;
  xbarras: string;
  xZeroEsquerda: Boolean;
begin

  dmModulo.cCadastroProdutos.First;

  while not dmModulo.cCadastroProdutos.eof do
  begin
    if not FindProdutos('cod', dmModulo.cCadastroProdutos.fieldbyname('codigo').Text) then
    begin
      xcod := dmModulo.cCadastroProdutos.fieldbyname('codigo').Text;
      // pega so na primeira ve

      xbarras := dmModulo.cCadastroProdutos.fieldbyname('barras').Text;
      // pega so na primeira ve
      while FindProdutos('barras', xbarras) do
        xbarras := StrZero(Incrementador(_DB.Banco, 'barras'), 12);
      // pega so na primeira ve

      ExecutaComandoSql('insert into ' + _DB.Banco + '.produtos (cod,barras,codexpress,descricao,grupo,custo,valor,vender) values (' +
        SetS(xcod) +
        ',' + SetS(xbarras) + ',' + SetS(dmModulo.cCadastroProdutos.fieldbyname('codigo').Text) + ',' +
        SetS(dmModulo.cCadastroProdutos.fieldbyname('descricao').Text) +
        ',' + SetS(dmModulo.cCadastroProdutos.fieldbyname('grupo').Text) + ',' + trans(dmModulo.cCadastroProdutos.fieldbyname('custo').Text) + ',' +
        trans(dmModulo.cCadastroProdutos.fieldbyname('valor').Text) + ',1)');
    end;
    dmModulo.cCadastroProdutos.next;
  end;
  dmModulo.cCadastroProdutos.First;

end;

procedure TfrmMain.LancaBonus(fempresa, fcaixa, fdata, fid, fVal: string);
var
  xbonus: Double;
  xId: string;
begin

  if _Cliente.Codigo = '00001' then
    exit;
  if val2(_Cliente.bonus) <= 0 then
    exit;
  if val2(fVal) <= 0 then
    exit;
  xbonus := BRound(val2(fVal) * (val2(_Cliente.bonus) / 100), 2);
  if xbonus > 0 then
  begin
    ExecutaComandoSql('delete from ' + _DB.Banco + '.creditos where remessarquivo="' + _Remessa + '"');

    xId := Incrementador(_DB.Banco, 'creditos');
    ExecutaComandoSql('insert into ' + _DB.Banco +
      '.creditos (cod,empresa,local,data,hora,cliente,cpf,cnpj,codigo,valor,tipo,descricao,subtipo,remessarquivo) values(' + '"' + xId + '","' +
      fempresa + '","' + fcaixa + '",now(),now(),"' + _Cliente.Codigo + '","' + LimpaConteudo(_Cliente.Cpf) + '","' +
      LimpaConteudo(_Cliente.Cnpj) +
      '",' + fid + ',' + trans(xbonus) + ',"E","Venda","Bonus","' + _Remessa + '")');

  end
end;

procedure TfrmMain.FCancelaVendaEx(fRemessa: string; fHasFinan: Boolean);
begin
  ExecutaComandoSql('delete from ' + _DB.Banco + '.vendas where remessarquivo="' + fRemessa + '"');
  // antes de deletar vendas detalhe pego os produtos para equalizar o estoque!';
  ExecutaComandoSql('delete from ' + _DB.Banco + '.retirada where remessarquivo="' + fRemessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.retiradadetalhe where remessarquivo="' + fRemessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.itensexcluidos where remessarquivo="' + fRemessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.creditos where remessarquivo="' + fRemessa + '"');

  // antes de deletar vendas detalhe pego os produtos para equalizar o estoque!';

  ExecutaComandoSql('delete from ' + _DB.Banco + '.vendasdetalhe where remessarquivo="' + fRemessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.vendasrecdo where remessarquivo="' + fRemessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.pontos where remessarquivo="' + fRemessa + '"');

  ExecutaComandoSql('delete from ' + _DB.Banco + '.lancamentoserial where remessarquivo="' + fRemessa + '"');
  if not fHasFinan then
  begin
    ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.lancamento where remessarquivo="' + fRemessa + '"');
    ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receber where remessarquivo="' + fRemessa + '"');
    ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receberdetalhe where remessarquivo="' + fRemessa + '"');
  end;
end;

procedure TfrmMain.Processa_Fiscal(fTipo, fEcf, fempresa, fdata, fTexto: string);
var
  i: integer;
  xmStr: TStringList;
begin
  try
    ExecutaComandoSql('delete from ' + _DB.Banco + '.arquivo_sped_ecf where remessarquivo="' + _Remessa + '"');
    ExecutaComandoSql('delete from ' + _DB.Banco + '.arquivo_sped_ecf ' + '  where tipo="' + fTipo + '" and Ecf="' + trim(fEcf) +
      '" and mesano="' +
      FormatDateTime('mmyyyy', strtodate(fdata)) + '"');

    // se tiver deletado entao aborte
    xmStr := TStringList.create;
    xmStr.Text := fTexto;
    for i := 0 to xmStr.count - 1 do
    begin
      ExecutaComandoSql('insert into ' + _DB.Banco + '.arquivo_sped_ecf (empresa,ecf,tipo,mesano,data,texto,remessarquivo) values ("' +
        fempresa +
        '","' + fEcf + '","' + fTipo + '","' + FormatDateTime('mmyyyy', strtodate(fdata)) + '",' + DtoS(strtodate(fdata)) + ',' +
        QuotedStr(xmStr.Strings[i]) + ',"' + _Remessa + '")');
    end;

    { dmModulo.Query.close;
      dmModulo.Query.sql.text := 'Select * from ' + _DB.Banco + '.arquivo_sped_ecf limit 0';
      dmModulo.Query.open; //segurando os dados!

      dmModulo.Query.Append;
      dmModulo.Query.fieldbyname('empresa').asstring := fEmpresa;
      dmModulo.Query.fieldbyname('Ecf').asstring := fEcf;
      dmModulo.Query.fieldbyname('Tipo').asstring := fTipo;
      dmModulo.Query.fieldbyname('Mesano').asstring := fData;
      dmModulo.Query.fieldbyname('Data').asstring := datetostr(date);
      //  dmModulo.Query.fieldbyname('Texto').asstring := fTexto;
      dmModulo.Query.Post;
    }
  finally
    FreeAndNil(xmStr);

  end;
end;

procedure TfrmMain.Processa_Venda;
var
  xSerial, xId: string;
  xval, xCredVal, xRepique, xDev: Double;
  xQte: Double;
  xEntrega: string;
  xValBonus: string;
  xCaixa: string;
  xcod: string;
  xDesc: string;
  xTipo: string;
  xisSerial: Boolean;
  xBooFin: Boolean;
  xhasvnd: Boolean;
  xAcrescimo: Double;
  xIsSaidaEstoquista: Boolean;
  function FCampo_ItRod(fcampo: string): string;
  begin
    result := dmModulo.cItensRodizio.fieldbyname(fcampo).asstring;

  end;
  function FCampo_ItPnt(fcampo: string): string;
  begin
    result := dmModulo.cItensPedidoEntregaPontos.fieldbyname(fcampo).asstring;

  end;
  function FCampo_ItPntDt(fcampo: string): string;
  begin
    if dmModulo.cItensPedidoEntregaPontos.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.cItensPedidoEntregaPontos.fieldbyname(fcampo).asstring));
  end;
  function FCampo_ItDt(fcampo: string): string;
  begin
    if dmModulo.cItens.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.cItens.fieldbyname(fcampo).asstring));
  end;

begin
  // se tiver deletado entao aborte
  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select * from ' + _DB.Banco + '.vendasexcluida where remessarquivo="' + _Remessa + '"';
  dmModulo.Query.open; // segurando os dados!
  if not dmModulo.Query.isempty then
  begin
    mResp.Lines.Add(datetimetostr(now) + ' ERRO: Arquivo de venda ' + _Remessa + ' foi excluido no autocom, este processo foi cancelado!');
    exit;
  end;

  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.receberdetalhe where remessarquivo="' + _Remessa + '"';
  dmModulo.Query.open; // segurando os dados!
  xBooFin := false;
  if dmModulo.Query.fieldbyname('pagamento').asstring <> '' then
  begin
    xBooFin := True;
    // mResp.Lines.Add(datetimetostr(now) + ' ERRO: Arquivo de venda ' + _Remessa +
    // ' já foi recebido no financeiro, este processo foi cancelado!');
    // exit;
  end;

  if dmModulo.Query.FindField('autorizacaotef') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.BancoFinan + '.receberdetalhe add autorizacaotef varchar(20) default null ');
  end;

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.receber limit 0';
  dmModulo.QueryInt.open; // segurando os dados!
  if dmModulo.QueryInt.FindField('paciente') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.BancoFinan + '.receber add paciente varchar(10) default null ');
  end;

  if dmModulo.QueryInt.FindField('tefautorizacao') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.BancoFinan + '.receber add tefautorizacao varchar(20) default null ');
  end;

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'Select * from ' + _DB.Banco + '.vendasdetalhe a where  a.remessarquivo="' + _Remessa + '"';
  dmModulo.QueryInt.open; // segurando os dados!
  if dmModulo.QueryInt.FindField('juros') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalhe add juros double(13,4) default null after desconto ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalheexcluida add juros double(13,4) default null after desconto ');

  end;
  // deletar caso houver;
  // primeira tentativa

  // if xID = '' then
  // begin
  xhasvnd := false;
  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select a.cod as venda from ' + _DB.Banco + '.vendas a where  a.remessarquivo="' + _Remessa + '"';
  dmModulo.Query.open; // segurando os dados!
  xId := dmModulo.Query.fieldbyname('venda').Text;
  if xId <> '' then
    xhasvnd := True;
  // end;
  if xId = '' then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'Select a.venda  from ' + _DB.Banco + '.vendasrecdo a where  a.remessarquivo="' + _Remessa + '"';
    dmModulo.Query.open; // segurando os dados!
    xId := dmModulo.Query.fieldbyname('venda').Text;
  end;

  // se nao achou tudo na venda mas tem financeiro entao faz somente a venda
  if xId = '' then
  begin
    if xBooFin then
    begin
      logging(mResp, ' ERRO: Arquivo de venda ' + _Remessa + ' já foi recebido no financeiro!');
      // mResp.Lines.Add(datetimetostr(now) + ' ERRO: Arquivo de venda ' + _Remessa +
      // ' já foi recebido no financeiro, este processo foi cancelado!');
      // exit;

    end;
  end;

  // se tiver venda pega o mesmo numero para refazer...
  if xId = '' then // se nao achou nada entao CDSClass.Cria um novo numero
    xId := Incrementador(_DB.Banco, 'vendas');
  if not xhasvnd then
    FCancelaVendaEx(_Remessa, xBooFin);

  // Ehqualizando o estoque'
  if xhasvnd then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'Select a.cod, b.produto,a.setor from ' + _DB.Banco + '.vendas a, ' + _DB.Banco + '.vendasdetalhe b where ' +
      ' a.cod=b.venda and a.remessarquivo=b.remessarquivo and a.remessarquivo="' + _Remessa + '"';
    dmModulo.Query.open; // segurando os dados!
    FCancelaVendaEx(_Remessa, xBooFin);

    while not dmModulo.Query.eof do
    begin
      AtualizaQtProduto(dmModulo.Query.fieldbyname('produto').Text, dmModulo.Query.fieldbyname('setor').Text);
      dmModulo.Query.next;
    end;

  end;

  // setar parametros

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.vendasdetalhe limit 0';
  dmModulo.QueryInt.open;
  if dmModulo.QueryInt.FindField('total') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalhe add total double(10,2) default null after valor ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalheexcluida add total double(10,2) default null after valor ');
    ExecutaComandoSql('update ' + _DB.Banco + '.vendasdetalhe set total =qte*valor ');
    ExecutaComandoSql('update ' + _DB.Banco + '.vendasdetalheexcluida set total =qte*valor ');
  end;
  if dmModulo.QueryInt.FindField('juros') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalhe add juros double(13,4) default null after desconto ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalheexcluida add juros double(13,4) default null after desconto ');
  end;
  if dmModulo.QueryInt.FindField('obs') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalhe add obs varchar(50) default null  ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalheexcluida add obs varchar(50) default null ');
  end;
  if dmModulo.QueryInt.FindField('desconto') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalhe add desconto double(10,2) default 0 after valor ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasdetalheexcluida add desconto double(10,2) default 0 after valor ');
    ExecutaComandoSql('update ' + _DB.Banco + '.vendas a, ' + _DB.Banco +
      '.vendasdetalhe b set b.desconto=b.total*(a.desconto/a.valor) where ' +
      ' a.cod=b.venda and a.empresa=b.empresa and a.data=b.data  and a.desconto>0');
  end;
  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.vendas limit 0';
  dmModulo.QueryInt.open;
  if dmModulo.QueryInt.FindField('rt') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendas add rt varchar(3) after vendedor ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasexcluida add rt varchar(3) after vendedor ');
  end;

  if dmModulo.QueryInt.FindField('frete') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendas add frete double(13,2) after valor ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasexcluida add frete double(13,2) after valor ');
  end;

  if dmModulo.QueryInt.FindField('ChaveNfec') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendas add ChaveNFec varchar(50) Default null ');
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasexcluida add ChaveNFec varchar(50) Default null ');
  end;

  if dmModulo.QueryInt.FindField('troca') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendas add troca double(13,3) default 0 after desconto ');
    ExecutaComandoSql('update ' + _DB.Banco + '.vendas a, ' + _DB.Banco +
      '.vendasrecdo b set a.troca=b.valor where a.cod=b.venda and b.tipo=3');
  end;
  if dmModulo.QueryInt.FindField('descontopgto') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendas add descontopgto double(13,3) default 0 after desconto ');
    ExecutaComandoSql('update ' + _DB.Banco + '.vendas a, ' + _DB.Banco +
      '.vendasrecdo b set a.descontopgto=b.valor where a.cod=b.venda and b.tipo=99');
    ExecutaComandoSql('update ' + _DB.Banco + '.vendas a set desconto=descontopgto+troca');
  end;

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.vendasexcluida limit 0';
  dmModulo.QueryInt.open;
  if dmModulo.QueryInt.FindField('troca') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasexcluida add troca double(13,3) default 0 after desconto ');
  end;
  if dmModulo.QueryInt.FindField('descontopgto') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasexcluida add descontopgto double(13,3) default 0 after desconto ');
  end;

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.vendasrecdo limit 0';
  dmModulo.QueryInt.open;
  if dmModulo.QueryInt.FindField('tefautorizacao') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasrecdo add tefautorizacao varchar(20)  ');
  end;
  if dmModulo.QueryInt.FindField('aluguel') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.vendasrecdo add aluguel int(11)  after venda ');
  end;
  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.param where id=1';
  dmModulo.QueryInt.open;

  xisSerial := dmModulo.QueryInt.fieldbyname('serial').Text = '1';

  xIsSaidaEstoquista := dmModulo.QueryInt.fieldbyname('saida_estoquista').Text = '1';
  _ContaFinanceiro.ContaPorProduto_Grupo := dmModulo.QueryInt.fieldbyname('contaporproduto_grupo').Text;
  _ContaFinanceiro.ContaCredito := dmModulo.QueryInt.fieldbyname('contacredito').Text;
  _ContaFinanceiro.ContaJuros := dmModulo.QueryInt.fieldbyname('contajuros').Text;
  _Comissao := dmModulo.QueryInt.fieldbyname('comissao').Text;
  _Comissaovr := dmModulo.QueryInt.fieldbyname('comissaovr').Text;
  if dmModulo.QueryInt.FindField('Contatroca') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.param add contatroca varchar(10)');
    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.param where id=1';
    dmModulo.QueryInt.open;
  end;

  _ContaFinanceiro.ContaTroca := dmModulo.QueryInt.fieldbyname('contatroca').Text;

  Set_CItens;
  // coloca descricao e tributo etc.. no citem preparando para o vendasdetalhe
  Grava_Itens(xId, xval, xRepique, xEntrega);

  dmModulo.cItens.First;
  Grava_Cadastro(FCampo_It('vendedor'));

  // Grava Devolucao tem que ser primeiro pois fornece dados ao set_recdo
  // xDev := Grava_Devolucao(xID); // dmModulo.cItens tipo 00010

  xDev := Processa_Retiradas(xId, True); // true= foi uma troca...

  xCredVal := 0;
  // grava a diferenca de credito quando a devolcuao e maior que a venda
  if (xDev - xval) > 0 then
  begin
    xcod := Incrementador(_DB.Banco, 'creditos'); // pega so na primeira ve
    ExecutaComandoSql('insert into ' + _DB.Banco +
      '.creditos(cod,codigo,empresa,data,hora,cliente,cpf,cnpj,tipo,descricao,subtipo,valor,remessarquivo) ' + ' values (' + xcod + ',' + xcod
      + ',"' + FCampo_It('empresa') + '",' + FCampo_ItDt('data') + ',"' + _Hora + '","' +
      _Cliente.Codigo + '","' + _Cliente.Cpf + '","' +
      _Cliente.Cnpj +
      '","E","Lancamento Crédito","lanc",' + trans(xDev - xval) + ',"' + _Remessa + '")');
    xCredVal := xDev - xval;
  end;

  Set_Recdo(dmModulo.CPagamento, xDev);
  xCaixa := Grava_Venda(xId, xRepique, xEntrega, dmModulo.cCadastro.fieldbyname('nome').asstring);
  xValBonus := Grava_Recdo(xId);
  xAcrescimo := val2(FCampo_Pag('acrescimo'));
  // grava o uso de creditos...
  Grava_Credito(xId);

  SetEmpresa(FCampo_It('empresa'));

  SetComissao(FCampo_It('Empresa'), FCampo_It('data'), xId);

  LancaBonus(FCampo_It('Empresa'), xCaixa, FCampo_It('data'), xId, xValBonus);

  LancaPontos(xId);

  // Grava itensExcluidos...
  Grava_Canc(xId); // dmModulo.cItens tipo 00011

  // baixa estoque

  if not xIsSaidaEstoquista then
  begin
    dmModulo.cItens.First;
    while not dmModulo.cItens.eof do
    begin
      xQte := 0;
      if FCampo_It('tipo') = '00001' then
      begin
        xDesc := 'Vendas';
        xTipo := 'S';
        xQte := val2(FCampo_It('qte'));
      end;
      if FCampo_It('tipo') = '00010' then
      begin
        xDesc := 'Devolucao';
        xTipo := 'E';
        xQte := - 1 * val2(FCampo_It('qte'));
      end;

      if FCampo_It('tipo') = '00011' then
      begin
        xDesc := 'Item excluido';
        xTipo := 'E';
        xQte := - 1 * val2(FCampo_It('qte'));
      end;
      if not xisSerial then
        xSerial := ''
      else
        xSerial := FCampo_It('serial');

      BaixaEstoque(FCampo_It('produto'), FCampo_It('servico'), xQte, xDesc, xTipo, xSerial, FCampo_It('Setor'), FCampo_It('Empresa'), xId,
        FCampo_It('Usuario'), FCampo_It('Data'), _Hora, xisSerial);
      dmModulo.cItens.next;
    end;
  end;

  if not xisSerial then
  begin
    dmModulo.cItensRodizio.First;
    while not dmModulo.cItensRodizio.eof do
    begin
      xQte := val2(FCampo_ItRod('qte'));

      BaixaEstoque(FCampo_ItRod('produto'), '0', xQte, 'VendasRodizio', 'S', '', FCampo_ItRod('Setor'), FCampo_ItRod('Empresa'), xId,
        FCampo_ItRod('Usuario'), FCampo_ItRod('Data'), _Hora, false);
      dmModulo.cItensRodizio.next;
    end;

    dmModulo.CPagamento.First;
    dmModulo.cItensPedidoEntregaPontos.First;
    while not dmModulo.cItensPedidoEntregaPontos.eof do
    begin
      xQte := val2(FCampo_ItPnt('qte'));

      BaixaEstoque(FCampo_ItPnt('produto'), '0', xQte, 'PontosResgate', 'S', '', FCampo_ItPnt('Setor'), FCampo_ItPnt('Empresa'), xId,
        FCampo_ItPnt('Usuario'), FCampo_ItPnt('Data'), _Hora, false);
      ExecutaComandoSql('insert into ' + _DB.Banco + '.pontos(empresa,data,venda,pedido,usuario,cpfcnpj,produto,qte,' +
        ' pontos,valor,tipo,remessarquivo) ' + ' values ("' + FCampo_ItPnt('empresa') + '",' + FCampo_ItPntDt('data') + ',"' + xId + '","' +
        FCampo_Pag('comanda') + '","' + FCampo_ItPnt('usuario') + '","' + FCampo_Pag('cpfcnpj') + '","' + FCampo_ItPnt('produto') + '",' +
        trans(val2(FCampo_ItPnt('qte'))) + ',' + trans(val2(FCampo_ItPnt('pontos'))) + ',' + trans(val2(FCampo_ItPnt('valor'))) + ',"S' + '","' +
        _Remessa + '")');
      dmModulo.cItensPedidoEntregaPontos.next;
    end;
  end;

  dmModulo.cItens.First;
  if not xBooFin then
  begin
    Lancamento(FCampo_It('Empresa'), xId, _Cliente.Codigo, xval, FCampo_It('data'));
    if (_ContaFinanceiro.ContaJuros <> '') and (xAcrescimo > 0) then
    begin
      SetConta(_ContaFinanceiro.ContaJuros);
      Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo,
        _Empresa.Caixa, xId,
        copy(_Conta.Descricao + ' ' + _Cliente.Nome, 1, 100), FCampo_It('data'), xAcrescimo);
    end;

    if (_ContaFinanceiro.ContaCredito <> '') and (xCredVal > 0) then
    begin
      // Creditar no lancamento
      SetConta(_ContaFinanceiro.ContaCredito);
      if _Conta.Conta <> '' then
      begin
        Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo,
          _Empresa.Caixa, xId,
          copy(_Conta.Descricao + ' ' + _Cliente.Nome, 1, 100), FCampo_It('data'), xCredVal);
      end;
    end;
  end;

  dmModulo.Query.close;
  dmModulo.QueryInc.close;
end;

Function TfrmMain.Processa_Retiradas(fVenda: String;
  fTroca:
  Boolean = false): Double;
var
  xId: string;
  xval: Double;
  xQte: Double;
  xCaixa: string;
  xDesc: string;
  xSerial, xcod, xTipo: string;
  xisSerial, xMov, xDev: Boolean;
  xConta: string;
  xContaDescr: string;
  xIsSaidaEstoquista: Boolean;
  function FCampo_It(fcampo: string): string;
  begin
    result := dmModulo.cRetiradas.fieldbyname(fcampo).asstring;
  end;
  function FCampo_ItDt(fcampo: string): string;
  begin
    if dmModulo.cRetiradas.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.cRetiradas.fieldbyname(fcampo).asstring));
  end;

begin

  // caso não houver troca
  if dmModulo.cRetiradas.isempty then
  begin
    result := 0;
    exit;
  end;
  // deletar caso houver;

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.param where id=1';
  dmModulo.QueryInt.open;

  xisSerial := dmModulo.QueryInt.fieldbyname('serial').Text = '1';

  xIsSaidaEstoquista := dmModulo.QueryInt.fieldbyname('saida_estoquista').Text = '1';

  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select *  from ' + _DB.Banco + '.retiradadetalhe a limit 1';
  dmModulo.Query.open; // segurando os dados!

  if dmModulo.Query.FindField('categoria') = nil then
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.retiradadetalhe add categoria varchar(50)');
  if dmModulo.Query.FindField('obs_item') = nil then
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.retiradadetalhe add obs_item varchar(255)');
  if dmModulo.Query.FindField('desconto_item') = nil then
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.retiradadetalhe add desconto_item double(10,3)');
  if dmModulo.Query.FindField('fator') = nil then
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.retiradadetalhe add fator double(10,4)');

  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select *  from ' + _DB.Banco + '.retirada a where a.remessarquivo="' + _Remessa + '"';
  dmModulo.Query.open; // segurando os dados!

  if dmModulo.Query.FindField('venda') = nil then
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.retirada add venda int(11) default null');

  if dmModulo.Query.FindField('obs') = nil then
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.retirada add obs text');

  if dmModulo.Query.FindField('rt') = nil then
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.retirada add rt varchar(3)');




  xId := dmModulo.Query.fieldbyname('cod').Text;
  // se tiver venda pega o mesmo numero para refazer...
  if xId = '' then // se nao achou nada entao CDSClass.Cria um novo numero
    xId := Incrementador(_DB.Banco, 'outrassaidas');




  ExecutaComandoSql('delete from ' + _DB.Banco + '.retirada where remessarquivo="' + _Remessa + '"');
  // antes de deletar vendas detalhe pego os produtos para equalizar o estoque!';
  ExecutaComandoSql('delete from ' + _DB.Banco + '.retiradadetalhe where remessarquivo="' + _Remessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.lancamentoserial where remessarquivo="' + _Remessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.creditos where remessarquivo="' + _Remessa + '"');

  ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.lancamento where remessarquivo="' + _Remessa + '"');
  // ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receber where remessarquivo="' + _Remessa + '"');
  // ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receberdetalhe where remessarquivo="' + _Remessa + '"');

  // setar parametros
  // if (_Cliente.Cnpj = '') or (_Cliente.Cpf = '') then
  Grava_Cadastro('001');

  xval := Grava_ItensRetiradas(xId);
  if xval < 0 then
    xval := - 1 * xval;
  result := xval;
  xCaixa := Grava_Retiradas(xId, xval, fVenda);

  dmModulo.cRetiradas.First;
  if (TirarAcentos(FCampo_It('opcao')) = 'PRE-VENDA') then
  begin
    ExecutaComandoSql('update  ' + _DB.Banco + '.retiradadetalhe set baixado=now(), qtevendido=qte where cod=' + xId);
    ExecutaComandoSql('update  ' + _DB.Banco + '.retirada set baixado=now() where cod=' + xId);
  end;

  if TirarAcentos(FCampo_It('opcao')) <> 'PRE-VENDA' then
  begin

    dmModulo.QueryResult.close;
    dmModulo.QueryResult.SQL.Text := 'select * from ' + _DB.Banco + '.outrassaidas  where opcao="' + FCampo_It('opcao') + '"';
    dmModulo.QueryResult.open;

    xTipo := 'S';
    if dmModulo.QueryResult.FindField('devolucao') = nil then
    begin
      ExecutaComandoSql('Alter table ' + _DB.Banco + '.outrassaidas add devolucao varchar(1)');
      xDev := false;
    end
    else
      xDev := dmModulo.QueryResult.fieldbyname('devolucao').Text = '1';

    if dmModulo.QueryResult.fieldbyname('entrada').Text = '1' then
      xTipo := 'E';
    xMov := dmModulo.QueryResult.fieldbyname('naomovimenta').Text <> '1';
    xConta := dmModulo.QueryResult.fieldbyname('conta').Text;

    if (FCampo_It('opcao') = 'DEVOLUCAO') or (xDev and (xTipo = 'E')) then // para devolucao entreda força-se um credito
    begin
      if not xDev or (xTipo <> 'E') or not xMov then
      begin
        xDev := True;
        xTipo := 'E';
        xMov := True;
        if dmModulo.QueryResult.isempty then
        begin
          xcod := StrZero(Maximo(_DB.Banco + '.outrassaidas', 'codigo'), 3);
          ExecutaComandoSql('insert into  ' + _DB.Banco + '.outrassaidas  (codigo,opcao,devolucao,entrada,emitenf,naomovimenta) values (' +
            '"' + xcod
            + '","DEVOLUCAO",1,1,1,0)');
        end
        else
          ExecutaComandoSql('update  ' + _DB.Banco +
            '.outrassaidas  set devolucao=1,entrada=1,emitenf=1,naomovimenta=0 where opcao="DEVOLUCAO"');
      end;
    end;

    if not xIsSaidaEstoquista then
      if xMov then
      begin
        while not dmModulo.cRetiradas.eof do
        begin
          xDesc := 'DAV';
          xQte := val2(FCampo_It('qte'));
          if not xisSerial then
            xSerial := ''
          else
            xSerial := FCampo_It('Serial');

          BaixaEstoque(FCampo_It('produto'), '', xQte, xDesc, xTipo, xSerial, FCampo_It('Setor'), FCampo_It('Empresa'), xId,
            FCampo_It('Usuario'),
            FCampo_It('Data'), _Hora, xisSerial);

          dmModulo.cRetiradas.next;

        end;
      end;

    dmModulo.cRetiradas.First;
    SetEmpresa(FCampo_It('empresa'));
    SetConta(xConta);
    // se for troca , isto é vindo da venda , nao lanca, pois tem na forma de pagamento
    if (_Conta.Conta <> '') and not fTroca then // caso haja conta no tipo da DAV
    begin
      xContaDescr := trim(copy(_Conta.Descricao + ' - DAV ' + FCampo_It('opcao') + '-' + xcod, 1, 100));
      Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo, _Empresa.Caixa,
        xId, xContaDescr, FCampo_It('Data'), xval);
      if (_Conta.ContraPartida <> '') then
      begin
        SetConta(_Conta.ContraPartida);
        xContaDescr := trim(copy(_Conta.Descricao + ' - DAV ' + FCampo_It('opcao') + '-' + xcod, 1, 100));
        Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo, _Empresa.Caixa,
          xId, xContaDescr, FCampo_It('Data'), xval);
      end;
    end;

    if xDev then
    begin
      if not fTroca then
      begin
        // implementar o credito
        dmModulo.cRetiradas.First;
        xcod := Incrementador(_DB.Banco, 'creditos'); // pega so na primeira ve
        ExecutaComandoSql('insert into ' + _DB.Banco +
          '.creditos(venda,cod,codigo,empresa,data,hora,cliente,cpf,cnpj,tipo,descricao,subtipo,valor,remessarquivo) ' + 'values (' + xId +
          ',' + xcod
          + ',' + xcod + ',"' + FCampo_It('empresa') + '",' + FCampo_ItDt('data') + ',now(),"' + _Cliente.Codigo + '","' + _Cliente.Cpf +
          '","' +
          _Cliente.Cnpj + '","E","DAV","DEVOLUCAO",' + trans(xval) + ',"' + _Remessa + '")');
      end;
      ExecutaComandoSql('update  ' + _DB.Banco + '.retiradadetalhe set baixado=now(), qtedevolvido=qte where cod=' + xId);
      ExecutaComandoSql('update  ' + _DB.Banco + '.retirada set baixado=now() where cod=' + xId);
    end;
  end;
end;

procedure TfrmMain.Processa_RetiradasBaixa;
var
  xDesc: string;
  xTipo: string;
  function FCampo_It(fcampo: string): string;
  begin
    result := dmModulo.cRetiradas.fieldbyname(fcampo).asstring;

  end;

begin
  // Este e um procedimenteo de Baixa
  ExecutaComandoSql('update ' + _DB.Banco + '.retiradadetalhe set baixado =null, qtevendido= null,qtedevolvido=null where remessarquivo="' +
    _Remessa + '"');
  ExecutaComandoSql('delete from ' + _DB.Banco + '.lancamentoserial where remessarquivo="' + _Remessa + '"');

  dmModulo.cRetiradas.First;
  xTipo := 'E';
  while not dmModulo.cRetiradas.eof do
  begin
    xDesc := 'DAV';

    ExecutaComandoSql('update  ' + _DB.Banco + '.retiradadetalhe set baixado=now(), qtevendido=' + trans(val2(FCampo_It('qtevendido'))) +
      ', qtedevolvido=' + trans(val2(FCampo_It('qtedevolvido'))) + '  where id =' + FCampo_It('id'));

    if val2(FCampo_It('qtedevolvido')) > 0 then
      BaixaEstoque(FCampo_It('produto'), '', val2(FCampo_It('qtedevolvido')), xDesc, xTipo, '', FCampo_It('Setor'), FCampo_It('Empresa'),
        FCampo_It('id'), FCampo_It('Usuario'), FCampo_It('Data'), _Hora, false);
    if val2(FCampo_It('qtevendido')) > 0 then
      BaixaEstoque(FCampo_It('produto'), '', val2(FCampo_It('qtevendido')), xDesc, xTipo, '', FCampo_It('Setor'), FCampo_It('Empresa'),
        FCampo_It('id'), FCampo_It('Usuario'), FCampo_It('Data'), _Hora, false);

    dmModulo.cRetiradas.next;
  end;
end;

procedure TfrmMain.Processa_RecebimentoPrazo;
var
  xtroco: Double;
  xvalor: Double;
  xVenda: String;
  xEmpresa: String;
  xData: String;
  xBoleto: String;
begin

  //
  try
    ExecutaComandoSql('delete from ' + _DB.Banco + '.creditos where remessarquivo="' + _Remessa + '"');
    ExecutaComandoSql('delete from ' + _DB.Banco + '.prazosrecdo where remessarquivo="' + _Remessa + '"');
    ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.lancamento where remessarquivo="' + _Remessa + '"');
    ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receber where remessarquivo="' + _Remessa + '"');
    ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receberdetalhe where remessarquivo="' + _Remessa + '"');

    // coloquei este topico temporario para passar todas as vendas e atualizar as tabelas
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'select *  from ' + _DB.BancoFinan + '.receberdetalhe limit 0';
    dmModulo.Query.open;
    if dmModulo.Query.FindField('remessarquivopg') = nil then
    begin
      ExecutaComandoSql('Alter table ' + _DB.BancoFinan +
        '.receberdetalhe add remessarquivopg varchar(50) default null, add key iremessapg (remessarquivopg) ');
    end;

    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'select *  from ' + _DB.Banco + '.creditos limit 0';
    dmModulo.Query.open;
    if dmModulo.Query.FindField('venda') = nil then
    begin
      ExecutaComandoSql('Alter table ' + _DB.Banco + '.creditos add venda int(11) default null');
    end;

    ExecutaComandoSql('update  ' + _DB.BancoFinan + '.receberdetalhe set pagamento=null where remessarquivopg="' + _Remessa + '"');
    Set_Recdo(dmModulo.CPagamento, 0);

    // pega o troco
    dmModulo.CPagamento.First;
    Set_Cliente(FCampo_Pag('cliente'), _Cliente);
    SetEmpresa(FCampo_Pag('empresa'));
    Grava_RecdoPrazo;
    dmModulo.CPagamento.First;
    xtroco := 0;
    xvalor := 0;
    while not dmModulo.CPagamento.eof do
    begin
      if (FCampo_Pag('tipo') = '97') or (FCampo_Pag('codigo') = '97') then
      // entao é aprazo
      begin
        xtroco := xtroco + val2(FCampo_Pag('Valor'));
      end;
      if (FCampo_Pag('tipo') <> '97') and (FCampo_Pag('codigo') <> '97') then
        xvalor := xvalor + val2(FCampo_Pag('Valor'));

      dmModulo.CPagamento.next;
    end;

    // Testa se tem creditos
    Grava_Credito('0');
    // processa a baixa no contas a receber
    dmModulo.CPagamento.First;
    xVenda := FCampo_Pag('venda');
    xEmpresa := FCampo_Pag('empresa');
    xData := FCampo_Pag('data');
    xBoleto := FCampo_Pag('boleto');
    if not Baixa_Recebimentos(floattostr(xvalor), xData, _Empresa.Caixa, xVenda, xEmpresa, xBoleto) then
    begin
      ExecutaComandoSql('delete from ' + _DB.Banco + '.creditos where remessarquivo="' + _Remessa + '"');
      ExecutaComandoSql('delete from ' + _DB.Banco + '.prazosrecdo where remessarquivo="' + _Remessa + '"');
      raise Exception.create('Sql:Error Recebendo a prazo');
      // erro na baixa

    end;

    while not dmModulo.CPagamento.eof do
    begin

      if (FCampo_Pag('tipo') = '99') or (FCampo_Pag('codigo') = '99') then
        if (FCampo_Pag('conta') <> '') and ProcuraConta(FCampo_Pag('conta')) then
        begin
          Lanca_Caixa(val2(FCampo_Pag('Valor')), FCampo_Pag('data'), dmModulo.QueryInt.fieldbyname('codigo').Text,
            dmModulo.QueryInt.fieldbyname('descricao').Text,
            dmModulo.QueryInt.fieldbyname('tipo').Text);
        end;

      dmModulo.CPagamento.next;
    end;

    // cria novos a receber...
    dmModulo.CPagamento.First;
    while not dmModulo.CPagamento.eof do
    begin
      if (FCampo_Pag('tipo') <> '4') then
        if (FCampo_Pag('tipo') = '2') or (FCampo_Pag('tef') <> '') or (val2(FCampo_Pag('dias')) > 0) then
        // Se for prazo cria uma conta a prazo!
        begin
          Set_Receber(FCampo_Pag('codigo'), FCampo_Pag('Conta'), FCampo_Pag('Taxa'), FCampo_Pag('Valor'), FCampo_Pag('vencimento'),
            FCampo_Pag('clienteCartao'), _Empresa.Codigo, FCampo_Pag('data'),
            FCampo_Pag('cupom'), '', floattostr(xtroco), FCampo_Pag('paciente'), FCampo_Pag('tefautorizacao'));
          if (_Conta.Conta <> '') and (_Conta.AReceber <> '') then
          begin

            Lanca_Caixa(val2(FCampo_Pag('Valor')), FCampo_Pag('data'), _Conta.Conta, 'Recebimento a Prazo a Receber (' + _Conta.Descricao +
              ')',
              _Conta.Tipo);
          end;

        end;
      dmModulo.CPagamento.next;
    end;
  finally
  end;
end;

procedure TfrmMain.Processa_RecebimentoCredito;
var
  xvalor, xtroco: Currency;
  xBooFin: Boolean;
begin
  //

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.param where id=1';
  dmModulo.QueryInt.open;

  _ContaFinanceiro.ContaCredito := dmModulo.QueryInt.fieldbyname('contacredito').Text;

  if _ContaFinanceiro.ContaCredito = '' then

    _ContaFinanceiro.ContaCredito := _Empresa.Conta;

  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.receberdetalhe where remessarquivo="' + _Remessa + '"';
  dmModulo.Query.open; // segurando os dados!
  xBooFin := false;
  while not dmModulo.Query.eof do
  begin
    if dmModulo.Query.fieldbyname('pagamento').asstring <> '' then
    begin
      xBooFin := True;
      // mResp.Lines.Add(datetimetostr(now) + ' ERRO: Arquivo de venda ' + _Remessa +
      // ' já foi recebido no financeiro, este processo foi cancelado!');
      // exit;
    end;
    dmModulo.Query.next;
  end;

  if xBooFin then
  begin
    Raise Exception.create('já foi recebido no financeiro, este processo foi cancelado!');
    // abort;
  end;

  ExecutaComandoSql('delete from   ' + _DB.Banco + '.creditos where remessarquivo="' + _Remessa + '"');
  ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.lancamento where remessarquivo="' + _Remessa + '"');
  ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receber where remessarquivo="' + _Remessa + '"');
  ExecutaComandoSql('delete from ' + _DB.BancoFinan + '.receberdetalhe where remessarquivo="' + _Remessa + '"');
  Set_Recdo(dmModulo.CPagamento, 0);
  Grava_Cadastro('001');

  // pega o troco
  dmModulo.CPagamento.First;
  // Set_Cliente(FCampo_Pag('cliente'), _Cliente);
  SetEmpresa(FCampo_Pag('empresa'));

  dmModulo.CPagamento.First;
  xtroco := val2('0');
  while not dmModulo.CPagamento.eof do
  begin
    if (FCampo_Pag('tipo') = '97') or (FCampo_Pag('codigo') = '97') then
    // entao é aprazo
    begin
      xtroco := xtroco + val2(FCampo_Pag('Valor'));
    end;
    dmModulo.CPagamento.next;
  end;
  Grava_RecdoCredito(val2(floattostr(xtroco)));

  // //processa a baixa no contas a receber
  dmModulo.CPagamento.First;
  xvalor := 0;
  while not dmModulo.CPagamento.eof do
  begin
    if AnsiMatchStr(FCampo_Pag('tipo'), ['1', '2', '8', '7']) then // dinheiro , prazo,pix
      xvalor := xvalor + val2(FCampo_Pag('valor'));
    // lanca creditos
    // if FCampo_Pag('tipo') = '1' then

    dmModulo.CPagamento.next;
  end;

  Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _ContaFinanceiro.ContaCredito, 'C', _Empresa.Caixa,
    '', 'Lancamento Crédito ' + FCampo_Pag('descricao'), FCampo_Pag('data'), xvalor);

  // cria novos a receber...
  dmModulo.CPagamento.First;
  while not dmModulo.CPagamento.eof do
  begin
    if (AnsiMatchStr(FCampo_Pag('tipo'), ['2', '7', '8'])) or (FCampo_Pag('tef') <> '') or (val2(FCampo_Pag('dias')) > 0) then
    // Se for prazo cria uma conta a prazo!
    begin
      SetConta(FCampo_Pag('conta'));
      if (_Conta.Conta <> '') and (_Conta.AReceber <> '') then
      begin
        Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo, _Empresa.Caixa,
          '', 'Lancamento Crédito a receber' + FCampo_Pag('descricao'), FCampo_Pag('data'), val2(FCampo_Pag('valor')));

        Set_Receber(FCampo_Pag('codigo'), FCampo_Pag('Conta'), FCampo_Pag('Taxa'), FCampo_Pag('Valor'), FCampo_Pag('vencimento'),
          FCampo_Pag('clienteCartao'), _Empresa.Codigo, FCampo_Pag('data'),
          FCampo_Pag('cupom'), '', floattostr(xtroco), FCampo_Pag('paciente'), FCampo_Pag('tefautorizacao'));
      end;

    end;
    dmModulo.CPagamento.next;
  end;
end;

function TfrmMain.Grava_Recdo(fid: string): string;
var
  xval: Double;
  xAluguel: String;
  function FCampo_Pag(fcampo: string): string;
  begin
    result := dmModulo.CPagamento.fieldbyname(fcampo).asstring;
  end;

  function FCampo_PagDt(fcampo: string): string;
  begin
    if dmModulo.CPagamento.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.CPagamento.fieldbyname(fcampo).asstring));
  end;

begin

  dmModulo.CPagamento.First;
  xval := 0;
  while not dmModulo.CPagamento.eof do
  begin
    if (FCampo_Pag('tipo') = '1') or (FCampo_Pag('tipo') = '2') or (FCampo_Pag('tipo') = '8') or (FCampo_Pag('tipo') = '7') then
      xval := xval + val2(FCampo_Pag('valor'));
    // desconta o desconto ou troco
    if (FCampo_Pag('tipo') = '97') or (FCampo_Pag('tipo') = '99') then
      xval := xval - val2(FCampo_Pag('valor'));

    if FCampo_Pag('opcao') = 'ALUGUEL' then
      xAluguel := FCampo_Pag('venda');
    if trim(xAluguel) = '' then
      xAluguel := '0';

    ExecutaComandoSql('insert into ' + _DB.Banco +
      '.vendasrecdo(caixa,venda,codigo,descricao,vencto,pagto,valor,tipo,clientecartao,taxa,conta,empresa,data,tefautorizacao,aluguel,remessarquivo)'
      + ' values (' +
      FCampo_Pag('caixa') + ',' + fid + ',' + FCampo_Pag('codigo') + ',"' + FCampo_Pag('descricao') + '",' + FCampo_PagDt('vencimento') + ',' +
      FCampo_PagDt('pagamento') + ',' + trans(val2(FCampo_Pag('valor'))) + ',"' + FCampo_Pag('tipo') + '","' + FCampo_Pag('ClienteCartao') +
      '",' +
      trans(val2(FCampo_Pag('Taxa'))) + ',"' + FCampo_Pag('conta') + '","' + FCampo_Pag('empresa') + '",' +
      FCampo_PagDt('Data') + ',"' + FCampo_Pag('tefautorizacao') + '","' + xAluguel +
      '","' + _Remessa + '")');
    dmModulo.CPagamento.next;
  end;
  result := floattostr(xval);

end;

procedure TfrmMain.Grava_RecdoPrazo;
  function FCampo_Pag(fcampo: string): string;
  begin
    result := dmModulo.CPagamento.fieldbyname(fcampo).asstring;
  end;

  function FCampo_PagDt(fcampo: string): string;
  begin
    if dmModulo.CPagamento.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.CPagamento.fieldbyname(fcampo).asstring));
  end;

begin

  dmModulo.CPagamento.First;

  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.parametros';
  dmModulo.Query.open;
  _ContaFinanceiro.ContaJuros := dmModulo.Query.fieldbyname('juros').Text;
  _ContaFinanceiro.ContaMulta := dmModulo.Query.fieldbyname('multa').Text;
  _ContaFinanceiro.ContaAbono := dmModulo.Query.fieldbyname('abono').Text;
  _ContaFinanceiro.ContaReajuste := dmModulo.Query.fieldbyname('reajuste').Text;

  while not dmModulo.CPagamento.eof do
  begin
    ExecutaComandoSql('insert into ' + _DB.Banco + '.prazosrecdo(cliente,caixa,data,valor,tipopgto,empresa,remessarquivo) ' + 'values ("' +
      _Cliente.Codigo + '",' + FCampo_Pag('caixa') + ',' + FCampo_PagDt('Data') + ',' + trans(val2(FCampo_Pag('valor'))) + ',"' +
      FCampo_Pag('codigo')
      + '","' + FCampo_Pag('empresa') + '","' + _Remessa + '")');
    dmModulo.CPagamento.next;
  end;

  {
    if val2(dmModulo.CPagamento.Caption)>0 then
    begin
    xQuerycmd.Script.add('insert into prazosrecdo(cliente,caixa,data,valor,tipopgto,empresa) '+
    'values ("'+cliente.Text+'",'+vgcaixa+',now(),'+trans(val2(troco1.Caption))+',"troco","'+vgempresa+'");');
    dmModulo.cquery.Next;

    end;
  }

end;

procedure TfrmMain.Grava_RecdoCredito(ftroco: Double);
var
  xcod: string;
  xtroco: Double;
  xvalor: Double;
  function FCampo_Pag(fcampo: string): string;
  begin
    result := dmModulo.CPagamento.fieldbyname(fcampo).asstring;
  end;

  function FCampo_PagDt(fcampo: string): string;
  begin
    if dmModulo.CPagamento.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.CPagamento.fieldbyname(fcampo).asstring));
  end;

begin
  dmModulo.CPagamento.First;
  xtroco := ftroco;

  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'Select * from ' + _DB.Banco + '.creditos  limit 0';

  dmModulo.Query.open;

  if dmModulo.Query.FindField('nfc') = nil then
  begin
    ExecutaComandoSql('Alter table ' + _DB.Banco + '.creditos add nfc varchar(20)  default null after valor ');
  end;

  while not dmModulo.CPagamento.eof do
  begin
    if (FCampo_Pag('tipo') <> '97') or (FCampo_Pag('codigo') <> '97') then
    begin
      xvalor := val2(FCampo_Pag('valor'));
      if xtroco > xvalor then
      begin
        xtroco := xtroco - xvalor;
        dmModulo.CPagamento.next;
        Continue;
      end;
      xvalor := val2(FCampo_Pag('valor')) - xtroco;
      xtroco := 0;
      xcod := Incrementador(_DB.Banco, 'creditos'); // pega so na primeira ve

      ExecutaComandoSql('insert into ' + _DB.Banco +
        '.creditos(cod,codigo,empresa,data,hora,cliente,cpf,cnpj,tipo,descricao,subtipo,valor,nfc,remessarquivo) ' + 'values (' + xcod + ',' +
        xcod + ',"' + FCampo_Pag('empresa') + '",' + FCampo_PagDt('data') + ',"' + FCampo_Pag('hora') + '","' +
        _Cliente.Codigo + '","' + _Cliente.Cpf + '","' +
        _Cliente.Cnpj + '","E","Lancamento Crédito","lanc",' + trans(xvalor) + ',"' + _Cliente.NFC + '","' + _Remessa + '")');
    end;
    dmModulo.CPagamento.next;
  end;

end;

procedure TfrmMain.Grava_Credito(fVenda: string);
var
  xcod: string;
  xCliente: TCliente;
  function FCampo_Pag(fcampo: string): string;
  begin
    result := dmModulo.CPagamento.fieldbyname(fcampo).asstring;
  end;

  function FCampo_PagDt(fcampo: string): string;
  begin
    if dmModulo.CPagamento.fieldbyname(fcampo).asstring = '' then
      result := 'null'
    else
      result := DtoS(strtodate(dmModulo.CPagamento.fieldbyname(fcampo).asstring));
  end;

begin
  dmModulo.CPagamento.First;
  while not dmModulo.CPagamento.eof do
  begin
    if (FCampo_Pag('tipo') = '4') then
    begin
      Set_Cliente(FCampo_Pag('cliente'), xCliente);
      xcod := Incrementador(_DB.Banco, 'creditos'); // pega so na primeira ve
      ExecutaComandoSql('insert into ' + _DB.Banco +
        '.creditos(venda,cod,codigo,empresa,data,hora,cliente,cpf,cnpj,tipo,descricao,subtipo,valor,remessarquivo) ' + 'values (' + fVenda +
        ',' +
        xcod + ',' + xcod + ',"' + FCampo_Pag('empresa') + '",' + FCampo_PagDt('data') + ',"' + FCampo_Pag('hora') + '","' + xCliente.Codigo +
        '","' +
        xCliente.Cpf + '","' + xCliente.Cnpj + '","S","Venda","Venda",' + trans(val2(FCampo_Pag('valor'))) + ',"' + _Remessa + '")');
    end;
    dmModulo.CPagamento.next;

  end;
end;

function TfrmMain.ProcuraCampo(fcampo, fTexto: string): Boolean;
var
  xtexto: TStringList;
  i: integer;
begin
  try
    xtexto := TStringList.create;
    xtexto.Text := fTexto;
    result := false;

    for i := 0 to xtexto.count - 1 do
    begin
      if copy(xtexto[i], 1, 5) = fcampo then
      begin
        result := True;
        break;
      end;
    end;
  finally
    FreeAndNil(xtexto);

  end;
end;

procedure TfrmMain.Get_Campos(fCmd: string);
var
  xtexto: TStringList;
  i: integer;
begin
  try
    xtexto := TStringList.create;
    xtexto.Text := fCmd;

    try
      for i := 0 to xtexto.count - 1 do
      begin
        // Progresso.Position:=i;

        if copy(xtexto[i], 1, 5) = '00000' then
          PegaDB(mResp, copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00001' then // vendas
          PegaItens(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00002' then
          PegaPagamentos(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00003' then
          PegaAcrescimo(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00008' then
          PegaItensRodizio(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00009' then
          PegaItensPedidoEntregaPontos(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00010' then
          // sub item de 00001 que e devolucao
          PegaDevolucao(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00011' then
          // sub item de 00001 que e cancelamento de items
          PegaItensCanc(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00111' then
          // sub item de 00111 que e cancelamento de items
          PegaItensCanc(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00222' then
          // transferencia de mesa ou produtos da mesa
          PegaItensTransf(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00015' then
          PegaPagamentosPrazo(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00020' then
          PegaSangria(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00030' then
          PegaFundo(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00040' then
          PegaPagamentosCredito(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00050' then
          PegaRetiradas(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00060' then
          PegaContagem(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '00059' then
          PegaRetiradasBaixa(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '99999' then
          PegaCadastro(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '99001' then
          PegaCadastroPet(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '99991' then
          PegaProdutos(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '88000' then
          PegaEcf_Z(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '88001' then
          PegaEcf_Z_Aliquota(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '88010' then
          PegaECFDetalhe(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '88011' then
          PegaECFRecdo(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '88051' then
          PegaEcfGNF(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '88090' then
          PegaECFCanc(copy(xtexto[i], 7, 5000));

        if copy(xtexto[i], 1, 5) = '88091' then
          PegaECFCancItem(copy(xtexto[i], 7, 5000));

      end;

    Except
      on E: Exception do
        logging(mResp, 'Em ' + datetimetostr(now()) + ' Erro ' + E.Message);

    end;

  finally
    FreeAndNil(xtexto);
  end;
end;

Function TfrmMain.SetDef(fConteudo, fDefault: String): string;
begin
  result := fConteudo;
  if fConteudo = '' then
    result := fDefault;
end;

procedure TfrmMain.PegaItensRodizio(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.cItensRodizio.Append;
    dmModulo.cItensRodizio.fieldbyname('id').asstring := IntToStr(dmModulo.cItensRodizio.RecordCount + 1);
    dmModulo.cItensRodizio.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cItensRodizio.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cItensRodizio.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cItensRodizio.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');

    dmModulo.cItensRodizio.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cItensRodizio.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cItensRodizio.fieldbyname('Venda').asstring := xmemo.Strings[6];
    dmModulo.cItensRodizio.fieldbyname('Cupom').asstring := xmemo.Strings[7];
    dmModulo.cItensRodizio.fieldbyname('mesa').asstring := xmemo.Strings[8];
    dmModulo.cItensRodizio.fieldbyname('Produto').asstring := xmemo.Strings[9];
    dmModulo.cItensRodizio.fieldbyname('Qte').asstring := xmemo.Strings[10];
    dmModulo.cItensRodizio.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaItensPedidoEntregaPontos(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.cItensPedidoEntregaPontos.Append;
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('id').asstring := IntToStr(dmModulo.cItensPedidoEntregaPontos.RecordCount + 1);
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Venda').asstring := xmemo.Strings[6];
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Cupom').asstring := xmemo.Strings[7];
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Pedido').asstring := xmemo.Strings[8];
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Produto').asstring := xmemo.Strings[9];
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('Qte').asstring := GetifTem(xmemo, 10);
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('pontos').asstring := GetifTem(xmemo, 11);
    dmModulo.cItensPedidoEntregaPontos.fieldbyname('valor').asstring := GetifTem(xmemo, 12);
    dmModulo.cItensPedidoEntregaPontos.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaItens(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.cItens.Append;
    dmModulo.cItens.fieldbyname('id').asstring := IntToStr(dmModulo.cItens.RecordCount + 1);
    dmModulo.cItens.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cItens.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cItens.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cItens.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cItens.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cItens.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cItens.fieldbyname('Venda').asstring := xmemo.Strings[6];
    dmModulo.cItens.fieldbyname('Cupom').asstring := xmemo.Strings[7];
    dmModulo.cItens.fieldbyname('Produto').asstring := xmemo.Strings[8];
    dmModulo.cItens.fieldbyname('Qte').asstring := xmemo.Strings[9];
    dmModulo.cItens.fieldbyname('Valor').asstring := xmemo.Strings[10];
    dmModulo.cItens.fieldbyname('id_cancelado').asstring := xmemo.Strings[11];
    dmModulo.cItens.fieldbyname('comissaosrv').asstring := GetifTem(xmemo, 13);
    dmModulo.cItens.fieldbyname('Repique').asstring := GetifTem(xmemo, 14);
    dmModulo.cItens.fieldbyname('entrega').asstring := GetifTem(xmemo, 15);
    dmModulo.cItens.fieldbyname('executor1').asstring := GetifTem(xmemo, 16);
    dmModulo.cItens.fieldbyname('outrassaidaid').asstring := GetifTem(xmemo, 17);
    dmModulo.cItens.fieldbyname('serial').asstring := GetifTem(xmemo, 19);
    dmModulo.cItens.fieldbyname('tipo').asstring := '00001';
    dmModulo.cItens.fieldbyname('rt').asstring := GetifTem(xmemo, 20);
    dmModulo.cItens.fieldbyname('desconto_item').asstring := GetifTem(xmemo, 21);
    // dmModulo.cItens.fieldbyname('obs').asstring := GetifTem(xmemo, 23);
    // dmModulo.cItens.fieldbyname('juros_item').AsString := GetifTem(xmemo, 22);

    dmModulo.cItens.fieldbyname('obs').asstring := GetifTem(xmemo, 23);
    dmModulo.cItens.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaCadastro(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);
    dmModulo.cCadastro.Append;
    dmModulo.cCadastro.fieldbyname('codigo').asstring := LimpaConteudo(xmemo.Strings[0]);
    if (FGet_CNPJ(dmModulo.cCadastro.fieldbyname('codigo').asstring) = '') and (FGet_CPF(dmModulo.cCadastro.fieldbyname('codigo').asstring) = '') then
    begin
      dmModulo.cCadastro.fieldbyname('codigo').asstring := '000000001';
    end;
    dmModulo.cCadastro.fieldbyname('nome').asstring := xmemo.Strings[1];
    dmModulo.cCadastro.fieldbyname('sexo').asstring := xmemo.Strings[2];
    dmModulo.cCadastro.fieldbyname('email').asstring := xmemo.Strings[3];
    dmModulo.cCadastro.fieldbyname('nasc').asstring := xmemo.Strings[4];
    dmModulo.cCadastro.fieldbyname('fone').asstring := GetifTem(xmemo, 5);
    dmModulo.cCadastro.fieldbyname('endereco').asstring := GetifTem(xmemo, 6);
    dmModulo.cCadastro.fieldbyname('cidade').asstring := GetifTem(xmemo, 7);
    dmModulo.cCadastro.fieldbyname('cep').asstring := GetifTem(xmemo, 8);
    dmModulo.cCadastro.fieldbyname('uf').asstring := GetifTem(xmemo, 9);
    dmModulo.cCadastro.fieldbyname('bairro').asstring := GetifTem(xmemo, 10);
    dmModulo.cCadastro.fieldbyname('senha').asstring := GetifTem(xmemo, 11);
    dmModulo.cCadastro.fieldbyname('enviarcorrespondencia').asstring := GetifTem(xmemo, 12);
    dmModulo.cCadastro.fieldbyname('inscr').asstring := GetifTem(xmemo, 13);
    dmModulo.cCadastro.fieldbyname('nfc').asstring := GetifTem(xmemo, 14);
    dmModulo.cCadastro.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaCadastroPet(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);
    dmModulo.cCadastroPet.Append;
    dmModulo.cCadastroPet.fieldbyname('cadastro').asstring := LimpaConteudo(xmemo.Strings[0]);
    if (FGet_CNPJ(dmModulo.cCadastroPet.fieldbyname('cadastro').asstring) = '')
      and (FGet_CPF(dmModulo.cCadastroPet.fieldbyname('cadastro').asstring) = '') then
    begin
      dmModulo.cCadastroPet.fieldbyname('cadastro').asstring := '000000001';
    end;
    dmModulo.cCadastroPet.fieldbyname('qtecaes').asstring := GetifTem(xmemo, 1);
    dmModulo.cCadastroPet.fieldbyname('qtegatos').asstring := GetifTem(xmemo, 2);
    dmModulo.cCadastroPet.fieldbyname('qteoutros').asstring := GetifTem(xmemo, 3);
    dmModulo.cCadastroPet.fieldbyname('outro').asstring := GetifTem(xmemo, 4);
    dmModulo.cCadastroPet.fieldbyname('nome').asstring := GetifTem(xmemo, 5);
    dmModulo.cCadastroPet.fieldbyname('especie').asstring := GetifTem(xmemo, 6);
    dmModulo.cCadastroPet.fieldbyname('sexo').asstring := GetifTem(xmemo, 7);
    dmModulo.cCadastroPet.fieldbyname('raca').asstring := GetifTem(xmemo, 8);
    dmModulo.cCadastroPet.fieldbyname('tamanho').asstring := GetifTem(xmemo, 9);
    dmModulo.cCadastroPet.fieldbyname('nascimento').asstring := GetifTem(xmemo, 10);
    dmModulo.cCadastroPet.post;

  finally
    FreeAndNil(xmemo);
  end;
end;

procedure TfrmMain.PegaProdutos(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);
    dmModulo.cCadastroProdutos.Append;
    dmModulo.cCadastroProdutos.fieldbyname('codigo').asstring := LimpaConteudo(xmemo.Strings[0]);
    dmModulo.cCadastroProdutos.fieldbyname('barras').asstring := LimpaConteudo(xmemo.Strings[1]);
    dmModulo.cCadastroProdutos.fieldbyname('descricao').asstring := GetifTem(xmemo, 2) + ' ' + GetifTem(xmemo, 3) + ' ' + GetifTem(xmemo, 4);
    dmModulo.cCadastroProdutos.fieldbyname('Grupo').asstring := 'LVR';
    dmModulo.cCadastroProdutos.fieldbyname('custo').asstring := GetifTem(xmemo, 5);
    dmModulo.cCadastroProdutos.fieldbyname('valor').asstring := GetifTem(xmemo, 6);
    dmModulo.cCadastroProdutos.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaDevolucao(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);
    dmModulo.cRetiradas.Append;

    dmModulo.cRetiradas.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cRetiradas.fieldbyname('Hora').asstring := copy(_Hora, 1, 5);
    dmModulo.cRetiradas.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cRetiradas.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cRetiradas.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cRetiradas.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cRetiradas.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cRetiradas.fieldbyname('id').asstring := GetifTem(xmemo, 20);
    if dmModulo.cRetiradas.fieldbyname('id').asstring = '' then
      dmModulo.cRetiradas.fieldbyname('id').asstring := GetifTem(xmemo, 6);

    dmModulo.cRetiradas.fieldbyname('CPFCNPJ').asstring := xmemo.Strings[12];
    dmModulo.cRetiradas.fieldbyname('Opcao').asstring := 'DEVOLUCAO';
    dmModulo.cRetiradas.fieldbyname('produto').asstring := xmemo.Strings[8];
    dmModulo.cRetiradas.fieldbyname('qte').asstring := xmemo.Strings[9];
    if val2(dmModulo.cRetiradas.fieldbyname('qte').asstring) < 0 then
      dmModulo.cRetiradas.fieldbyname('qte').asstring := floattostr( - 1 * val2(xmemo.Strings[9]));

    dmModulo.cRetiradas.fieldbyname('Valor').asstring := xmemo.Strings[10];
    dmModulo.cRetiradas.fieldbyname('Categoria').asstring := '';
    // feito para o dav
    dmModulo.cRetiradas.fieldbyname('desconto').asstring := '';
    dmModulo.cRetiradas.fieldbyname('Obs_item').asstring := '';
    dmModulo.cRetiradas.fieldbyname('Obs').asstring := '';
    dmModulo.cRetiradas.fieldbyname('serial').asstring := GetifTem(xmemo, 19);
    dmModulo.cRetiradas.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaECFCanc(fstr: string);
begin

end;

procedure TfrmMain.PegaECFCancItem(fstr: string);
begin

end;

procedure TfrmMain.PegaECFDetalhe(fstr: string);
begin

end;

procedure TfrmMain.PegaEcfGNF(fstr: string);
begin

end;

procedure TfrmMain.PegaECFRecdo(fstr: string);
begin

end;

procedure TfrmMain.PegaEcf_Z(fstr: string);
begin

end;

procedure TfrmMain.PegaEcf_Z_Aliquota(fstr: string);
begin

end;

procedure TfrmMain.PegaItensCanc(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.cItens.Append;
    dmModulo.cItens.fieldbyname('id').asstring := IntToStr(dmModulo.cItens.RecordCount + 1);
    dmModulo.cItens.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cItens.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cItens.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cItens.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cItens.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cItens.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cItens.fieldbyname('Venda').asstring := xmemo.Strings[6];
    dmModulo.cItens.fieldbyname('Cupom').asstring := xmemo.Strings[7];
    dmModulo.cItens.fieldbyname('Produto').asstring := xmemo.Strings[8];
    dmModulo.cItens.fieldbyname('Qte').asstring := xmemo.Strings[9];
    dmModulo.cItens.fieldbyname('Valor').asstring := xmemo.Strings[10];
    dmModulo.cItens.fieldbyname('id_cancelado').asstring := GetifTem(xmemo, 11);
    dmModulo.cItens.fieldbyname('tipo').asstring := '00011';
    dmModulo.cItens.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaItensTransf(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.cItens.Append;
    dmModulo.cItens.fieldbyname('id').asstring := IntToStr(dmModulo.cItens.RecordCount + 1);
    dmModulo.cItens.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cItens.fieldbyname('Hora').asstring := _Hora;
    dmModulo.cItens.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cItens.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cItens.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cItens.fieldbyname('Usuario').asstring := xmemo.Strings[4];
    dmModulo.cItens.fieldbyname('origem').asstring := xmemo.Strings[5];
    dmModulo.cItens.fieldbyname('destino').asstring := xmemo.Strings[6];
    dmModulo.cItens.fieldbyname('Produto').asstring := xmemo.Strings[7];
    dmModulo.cItens.fieldbyname('Qte').asstring := xmemo.Strings[8];
    dmModulo.cItens.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaSangria(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.cSangriaFundo.Append;
    dmModulo.cSangriaFundo.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cSangriaFundo.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cSangriaFundo.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cSangriaFundo.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cSangriaFundo.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cSangriaFundo.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cSangriaFundo.fieldbyname('Descricao').asstring := xmemo.Strings[6];
    dmModulo.cSangriaFundo.fieldbyname('Valor').asstring := xmemo.Strings[7];
    dmModulo.cSangriaFundo.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaFundo(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.cSangriaFundo.Append;
    dmModulo.cSangriaFundo.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cSangriaFundo.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cSangriaFundo.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cSangriaFundo.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cSangriaFundo.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cSangriaFundo.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cSangriaFundo.fieldbyname('Descricao').asstring := xmemo.Strings[6]; // hora
    dmModulo.cSangriaFundo.fieldbyname('Valor').asstring := xmemo.Strings[7];
    dmModulo.cSangriaFundo.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaPagamentos(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.CPagamento.Append;
    dmModulo.CPagamento.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.CPagamento.fieldbyname('Hora').asstring := copy(_Hora, 1, 5);
    dmModulo.CPagamento.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.CPagamento.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.CPagamento.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.CPagamento.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.CPagamento.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.CPagamento.fieldbyname('Venda').asstring := xmemo.Strings[6];
    dmModulo.CPagamento.fieldbyname('Cupom').asstring := xmemo.Strings[7];
    dmModulo.CPagamento.fieldbyname('Codigo').asstring := floattostr(val2(xmemo.Strings[8]));
    dmModulo.CPagamento.fieldbyname('Cliente').asstring := xmemo.Strings[9];
    dmModulo.CPagamento.fieldbyname('Valor').asstring := xmemo.Strings[10];
    dmModulo.CPagamento.fieldbyname('Vencimento').asstring := xmemo.Strings[11];
    dmModulo.CPagamento.fieldbyname('CPFCNPJ').asstring := GetifTem(xmemo, 12);
    dmModulo.CPagamento.fieldbyname('Devolucao').asstring := GetifTem(xmemo, 13);
    dmModulo.CPagamento.fieldbyname('Mesa').asstring := GetifTem(xmemo, 14);
    dmModulo.CPagamento.fieldbyname('Comanda').asstring := GetifTem(xmemo, 15);
    dmModulo.CPagamento.fieldbyname('vrservico').asstring := GetifTem(xmemo, 16);
    dmModulo.CPagamento.fieldbyname('Conta_Venda').asstring := GetifTem(xmemo, 17);
    // simplestroca
    dmModulo.CPagamento.fieldbyname('placa').asstring := GetifTem(xmemo, 19);
    dmModulo.CPagamento.fieldbyname('veiculo').asstring := GetifTem(xmemo, 20);
    dmModulo.CPagamento.fieldbyname('rt').asstring := GetifTem(xmemo, 21);
    dmModulo.CPagamento.fieldbyname('opcao').asstring := GetifTem(xmemo, 23);
    dmModulo.CPagamento.fieldbyname('paciente').asstring := GetifTem(xmemo, 24);
    // paciente do odontowave
    dmModulo.CPagamento.fieldbyname('ChaveNfec').asstring := GetifTem(xmemo, 25);
    dmModulo.CPagamento.fieldbyname('frete').asstring := '0';
    dmModulo.CPagamento.fieldbyname('tefautorizacao').asstring := GetifTem(xmemo, 27);
    dmModulo.CPagamento.fieldbyname('nfc').asstring := GetifTem(xmemo, 28);
    dmModulo.CPagamento.fieldbyname('acrescimo').asstring := GetifTem(xmemo, 29);
    // paciente do odontowave
    dmModulo.CPagamento.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaAcrescimo(fstr: string);
var
  xmemo: TStringList;
begin
  try

    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);
    _Venda.Acrescimo := GetifTem(xmemo, 1);
    _Venda.Comissao := GetifTem(xmemo, 0);
    _Venda.Total := GetifTem(xmemo, 2);
    _Venda.Ind := '';
    if (val2(_Venda.Total) > 0) and (val2(_Venda.Acrescimo) > 0) then
      _Venda.Ind := floattostr(val2(_Venda.Acrescimo) / val2(_Venda.Total));

  finally
    FreeAndNil(xmemo);
  end;
end;

procedure TfrmMain.PegaPagamentosPrazo(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.CPagamento.Append;
    dmModulo.CPagamento.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.CPagamento.fieldbyname('Hora').asstring := copy(_Hora, 1, 5);
    dmModulo.CPagamento.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.CPagamento.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.CPagamento.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.CPagamento.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.CPagamento.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.CPagamento.fieldbyname('Venda').asstring := xmemo.Strings[6];
    dmModulo.CPagamento.fieldbyname('Cupom').asstring := xmemo.Strings[7];
    dmModulo.CPagamento.fieldbyname('Codigo').asstring := xmemo.Strings[8];
    dmModulo.CPagamento.fieldbyname('Cliente').asstring := xmemo.Strings[9];
    dmModulo.CPagamento.fieldbyname('Valor').asstring := xmemo.Strings[10];
    dmModulo.CPagamento.fieldbyname('Vencimento').asstring := xmemo.Strings[11];
    dmModulo.CPagamento.fieldbyname('boleto').asstring := GetifTem(xmemo, 22);
    dmModulo.CPagamento.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaPagamentosCredito(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    dmModulo.CPagamento.Append;
    dmModulo.CPagamento.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.CPagamento.fieldbyname('Hora').asstring := copy(_Hora, 1, 5);
    dmModulo.CPagamento.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.CPagamento.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.CPagamento.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.CPagamento.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.CPagamento.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.CPagamento.fieldbyname('Venda').asstring := xmemo.Strings[6];
    dmModulo.CPagamento.fieldbyname('Cupom').asstring := xmemo.Strings[7];
    dmModulo.CPagamento.fieldbyname('Codigo').asstring := xmemo.Strings[8];
    dmModulo.CPagamento.fieldbyname('Cliente').asstring := xmemo.Strings[9];
    dmModulo.CPagamento.fieldbyname('Valor').asstring := xmemo.Strings[10];
    dmModulo.CPagamento.fieldbyname('Vencimento').asstring := xmemo.Strings[11];
    dmModulo.CPagamento.fieldbyname('NFC').asstring := GetifTem(xmemo, 27);

    dmModulo.CPagamento.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaContagem(fstr: string);
var
  xmemo: TStringList;
begin
  try

    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);

    _Contagem.Data := GetifTem(xmemo, 1);
    _Contagem.Empresa := GetifTem(xmemo, 2);
    _Contagem.Setor := GetifTem(xmemo, 3);
    _Contagem.Usuario := GetifTem(xmemo, 4);
    _Contagem.Zera := GetifTem(xmemo, 5);
    _Contagem.Remessa := GetifTem(xmemo, 6);

  finally
    FreeAndNil(xmemo);

  end;

end;

procedure TfrmMain.PegaRetiradas(fstr: string);
var
  xmemo: TStringList;
begin
  try

    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);
    dmModulo.cRetiradas.Append;
    dmModulo.cRetiradas.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cRetiradas.fieldbyname('Hora').asstring := copy(_Hora, 1, 5);
    dmModulo.cRetiradas.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cRetiradas.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cRetiradas.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cRetiradas.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cRetiradas.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cRetiradas.fieldbyname('id').asstring := xmemo.Strings[6];
    dmModulo.cRetiradas.fieldbyname('CPFCNPJ').asstring := xmemo.Strings[7];
    dmModulo.cRetiradas.fieldbyname('Opcao').asstring := xmemo.Strings[8];
    dmModulo.cRetiradas.fieldbyname('produto').asstring := xmemo.Strings[9];
    dmModulo.cRetiradas.fieldbyname('qte').asstring := xmemo.Strings[10];
    dmModulo.cRetiradas.fieldbyname('Valor').asstring := xmemo.Strings[11];
    dmModulo.cRetiradas.fieldbyname('desconto').asstring := GetifTem(xmemo, 15);
    dmModulo.cRetiradas.fieldbyname('ValorProd').asstring := xmemo.Strings[13];
    dmModulo.cRetiradas.fieldbyname('Categoria').asstring := GetifTem(xmemo, 14);
    // feito para o dav
    dmModulo.cRetiradas.fieldbyname('Obs_item').asstring := GetifTem(xmemo, 16);
    dmModulo.cRetiradas.fieldbyname('Obs').asstring := GetifTem(xmemo, 17);
    if GetifTem(xmemo, 19) = 'RT' then
      dmModulo.cRetiradas.fieldbyname('rt').asstring := GetifTem(xmemo, 18)
    else
      dmModulo.cRetiradas.fieldbyname('placa').asstring := GetifTem(xmemo, 18);

    dmModulo.cRetiradas.fieldbyname('serial').asstring := GetifTem(xmemo, 20);
    dmModulo.cRetiradas.fieldbyname('executor').asstring := GetifTem(xmemo, 21);
    dmModulo.cRetiradas.fieldbyname('Venda').asstring := GetifTem(xmemo, 22);
    dmModulo.cRetiradas.fieldbyname('desconto_item').asstring := GetifTem(xmemo, 23);
    dmModulo.cRetiradas.fieldbyname('fator').asstring := GetifTem(xmemo, 24);

    dmModulo.cRetiradas.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.PegaRetiradasBaixa(fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfReplaceAll]);
    dmModulo.cRetiradas.Append;
    dmModulo.cRetiradas.fieldbyname('Data').asstring := xmemo.Strings[0];
    dmModulo.cRetiradas.fieldbyname('Hora').asstring := copy(_Hora, 1, 5);
    dmModulo.cRetiradas.fieldbyname('Empresa').asstring := xmemo.Strings[1];
    dmModulo.cRetiradas.fieldbyname('Setor').asstring := xmemo.Strings[2];
    dmModulo.cRetiradas.fieldbyname('Caixa').asstring := SetDef(xmemo.Strings[3], '1');
    dmModulo.cRetiradas.fieldbyname('Vendedor').asstring := xmemo.Strings[4];
    dmModulo.cRetiradas.fieldbyname('Usuario').asstring := xmemo.Strings[5];
    dmModulo.cRetiradas.fieldbyname('CPFCNPJ').asstring := xmemo.Strings[6];
    dmModulo.cRetiradas.fieldbyname('id').asstring := xmemo.Strings[7];
    dmModulo.cRetiradas.fieldbyname('produto').asstring := xmemo.Strings[8];
    dmModulo.cRetiradas.fieldbyname('qtevendido').asstring := GetifTem(xmemo, 9);
    dmModulo.cRetiradas.fieldbyname('qtedevolvido').asstring := GetifTem(xmemo, 10);

    dmModulo.cRetiradas.post;

  finally
    FreeAndNil(xmemo);

  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  xmStr: TStringList;
begin
  /// oficial///
  _DB.MasterHandle := paramstr(1);
  _DB.DB := paramstr(2);
  if LowerCase(_DB.DB) = 'onlyhost' then
    _DB.DB := '';
  _DB.Host := paramstr(3);
  if _DB.Host = '' then
    _DB.Host := 'localhost';


  // //
  // _DB.MasterHandle := '9064';
  // _DB.DB := 'autocom';
  // _DB.BancoFinan := 'financeiro';
  // _DB.Banco := 'autocom';
  // _DB.Host := 'localhost';
  // _DB.Usr := 'root';
  // _DB.Pwd := '2525';




  // Showmessage(_DB.MasterHandle + ' ' + _DB.DB + ' ' + _DB.Host);

  caption := _Aplicacao + ' ' + _DB.DB + ' ' + _DB.Host + ' Versão:' + Versao + '';

  // Application.OnException        := TrataErros ;
  Application.Title := caption;

  ApplicationHandleException := nil;

  _Inicio := True;
  _Dir.Dir := ExtractFileDir(paramstr(0));
  if not DirectoryExists('.\log') then
    ForceDirectories('.\log');

  IniciaVariaves;
  _EmCarga := false;

  if _DB.DB <> '' then
    _MonitorFilename := _Dir.Dir + '\log\Debug' + _Aplicacao + _DB.DB + DtoS(Date) + '.log';

  if _DB.DB <> '' then
    LimparLog;

  logging(nil, 'conexao:' + _DB.MasterHandle + ' ' + _DB.DB + ' ' + _DB.Host);

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  _Aplicacao := ExtractFileName(Application.ExeName);
  _Aplicacao := ChangeFileExt(_Aplicacao, '');
  Application.HintHidePause := 5000;

end;

procedure TfrmMain.querycmdError(Sender: TObject; E: Exception; SQL: string; var Action: TErrorAction);
begin
  raise Exception.create(E.Message);
  Action := eaAbort;

end;

procedure TfrmMain.GetDBArquivos;
var
  xmStr: TStringList;
  xId: string;
begin
  try

    if not dmModulo.Bancocnx.Connected or (_DB.MasterHandle = '9064') then
    begin
      if not Config_DB(mResp, dmModulo.Bancocnx) then
      begin
        logging(mResp, 'Problemas de acesso ao DB ' + _DB.Host + ', processo abortado!');
        exit;
      end;

    end;

    try
      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := 'select now()';
      dmModulo.Query.open;
    except
      if not Config_DB(mResp, dmModulo.Bancocnx) then
      begin
        logging(mResp, 'Problemas de acesso ao DB ' + _DB.Host + ', processo abortado!');
        Application.Terminate;
        abort;
      end;
      try
        dmModulo.Query.close;
        dmModulo.Query.SQL.Text := 'select now()';
        dmModulo.Query.open;
      except
        on E: Exception do
        begin
          mResp.Lines.Add(datetimetostr(now) + ' ERRO: Não foi possivel processar dbarquivos' + E.Message);
          Application.Terminate;
          abort;
        end;
      end;
    end;
    try

      xmStr := TStringList.create;

      ExecutaComandoSql('CREATE database if not exists clientesweb');

      ExecutaComandoSql('CREATE TABLE if not exists clientesweb.arquivos (id int(11) NOT NULL auto_increment,' +
        'linha longtext,' +
        'remessarquivo varchar(50),' +
        'baixado datetime default NULL,' +
        'remessabaixada datetime default NULL,' +
        'origemip varchar(20),' +
        '  PRIMARY KEY  (id),' +
        '  key irem (remessarquivo))');
      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := 'select * from clientesweb.arquivos where (remessabaixada is null or remessabaixada<19000101 ) order by id';
      dmModulo.Query.open;
      if not dmModulo.Query.isempty then
      begin
        xId := '0';
        while not dmModulo.Query.eof do
        begin
          xId := xId + ',' + dmModulo.Query.fieldbyname('id').Text;
          xmStr.Text := dmModulo.Query.fieldbyname('linha').asstring;
          xmStr.SaveToFile(SetSlash(_Dir.Recebimento) + dmModulo.Query.fieldbyname('remessarquivo').asstring);
          dmModulo.Query.next;
        end;
        ExecutaComandoSql('update clientesweb.arquivos set remessabaixada=now(),origemip="' + _Dir.IP + '" where id in (' + xId + ')');
      end;
      xmStr.clear;
    except
      on E: Exception do
        mResp.Lines.Add(datetimetostr(now) + ' ERRO: Não foi possivel processar dbarquivos' + E.Message);

    end;
  finally
    FreeAndNil(xmStr);
  end;
end;

function TfrmMain.CheckMasterHandle: Boolean;
var
  xmStr: TStringList;

begin
  Try
    xmStr := TStringList.create;
    xmStr.Text := ListaProcessos;

    result := false;
    if '9064' = _DB.MasterHandle then
      result := True
    else
      if '9064' <> _DB.MasterHandle then
      if xmStr.IndexOf(_DB.MasterHandle) >= 0 then
      begin
        result := True;
      end
      else
      begin
        Application.Terminate;
        exit;
      end;

  Finally
    FreeAndNil(xmStr);

  End;

end;

procedure TfrmMain.Roda_Arquivos;
var
  xfiles: TStringList;
  i: integer;
  xLinhas: TStringList;
begin
  try

    dmModulo.Bancocnx.Connected := false;
    GetDBArquivos;

    xfiles := TStringList.create;
    xfiles.Text := ListarDiretorios(_Dir.Recebimento, _DB.DB + '_*.*');
    if (xfiles.count <= 0) or (_DB.DB = '') or (LowerCase(_DB.DB) = 'onlyhost') then
    begin
      Application.Terminate;
      abort;
    end;

    pbProgress.Max := xfiles.count;
    pbProgress.Position := 0;
    for i := 0 to xfiles.count - 1 do
    begin
      if i mod 10 = 0 then
        if not CheckMasterHandle then
          exit;

      pbProgress.Position := i;
      Application.ProcessMessages;
      if LowerCase(ExtractFileExt(xfiles.Strings[i])) = '.zlb' then
      begin
        if pos('_Fiscal_', LowerCase(ExtractFileName(xfiles.Strings[i]))) <= 0 then
          DoFechamento(xfiles.Strings[i])
        else
          DoFiscal(xfiles.Strings[i]);
      end
      else

        if LowerCase(ExtractFileExt(xfiles.Strings[i])) = '.jsn' then
      begin

        Try
          GetHoraRemessa(xfiles.Strings[i]);
          xLinhas := TStringList.create;
          xLinhas.loadfromfile(_Dir.Recebimento + '\' + xfiles.Strings[i]);

          if fTipoCmd(xLinhas) = 'CMP' then
            DoCompra(xLinhas.Text)
          else
            if fTipoCmd(xLinhas) = 'VND_MOBILE' then
            DoVndMobile(xLinhas.Text)
          else
            if fTipoCmd(xLinhas) = 'COLETOR_MOBILE' then
            DoColetorMobile(xLinhas.Text)
          else
            DoContagemEstoque(xfiles.Strings[i]);
        Finally
          FreeAndNil(xLinhas);
        End;
      end
      else
        if LowerCase(ExtractFileExt(xfiles.Strings[i])) = '.fec' then
        DoFechamento(xfiles.Strings[i], 'fec')
      else if LowerCase(ExtractFileExt(xfiles.Strings[i])) = '.txt' then
        if FileExists(_Dir.Recebimento + '\' + xfiles.Strings[i]) then
        begin
          try
            mCmd.Lines.loadfromfile(_Dir.Recebimento + '\' + xfiles.Strings[i]);
          except
            on E: Exception do
            begin
              doFileError(ExtractFileName(xfiles.Strings[i]), E.Message + ' lendo arquivo');
              Continue;

            end;
          end;
          if (trim(mCmd.Lines.Text) = '') or (length(mCmd.Lines.Text) < 50) then
          begin
            doFileError(ExtractFileName(xfiles.Strings[i]), ' arquivo vazio!');
            Continue;
          end;
          // Application.ProcessMessages;
          frmMain.Refresh;
          Sleep(200);
          GetHoraRemessa(xfiles.Strings[i]);

          Processar(mCmd.Lines.Text);
        end;
    end; // for
  finally
    FreeAndNil(xfiles);

  end;

end;

procedure TfrmMain.GetHoraRemessa(fFiles: string);
var
  j: integer;
  xPos: integer;
begin

  _Remessa := fFiles;
  xPos := - 1;
  for j := length(_Remessa) - 1 downto 1 do
    if _Remessa[j] = '_' then // ultimo sublinha
    begin
      xPos := j;
      break;
    end;
  // if xpos < 0 then continue;

  _Hora := copy(_Remessa, xPos + 9, 4);
  _Hora := copy(_Hora, 1, 2) + ':' + copy(_Hora, 3, 2);
end;

function TfrmMain.GetIP: string;

var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  Name: string;
begin
  WSAStartup(2, WSAData);
  SetLength(Name, 255);
  Gethostname(PAnsichar(Name), 255);
  SetLength(Name, StrLen(pChar(Name)));
  HostEnt := gethostbyname(PAnsichar(Name));
  with HostEnt^ do
    result := Format('%d.%d.%d.%d', [Byte(h_addr^[0]), Byte(h_addr^[1]), Byte(h_addr^[2]), Byte(h_addr^[3])]);
  WSACleanup;
end;

/// //////////////////////////////////////////////////////////////////////////////////////////////////////////////

procedure TfrmMain.SetConta(fcod: string);
begin
  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.conta where codigo="' + fcod + '"';
  dmModulo.QueryInt.open;
  _Conta.Conta := dmModulo.QueryInt.fieldbyname('codigo').Text;
  _Conta.Descricao := dmModulo.QueryInt.fieldbyname('Descricao').Text;
  _Conta.Tipo := dmModulo.QueryInt.fieldbyname('Tipo').Text;
  _Conta.AReceber := dmModulo.QueryInt.fieldbyname('Lanca').Text;
  _Conta.ContraPartida := dmModulo.QueryInt.fieldbyname('contrapartida').Text;
end;

procedure TfrmMain.Set_Itens;
var
  xConta, XcontaDescricao: string;
  xvalor: Double;
begin
  CDSClass.CriaCItens_Conta;
  dmModulo.cItens.First;
  while not dmModulo.cItens.eof do
  begin
    XcontaDescricao := 'Conta inexistente ';
    xConta := dmModulo.cItens.fieldbyname('conta').Text;
    if xConta = '' then
    begin
      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := ' select * from ' + _DB.Banco + '.produtos  where cod="' + dmModulo.cItens.fieldbyname('produto').Text + '"';
      dmModulo.Query.open;
      xConta := dmModulo.Query.fieldbyname('conta').Text;
    end;
    if xConta = '' then
    begin
      dmModulo.QueryResult.close;
      dmModulo.QueryResult.SQL.Text := ' select * from ' + _DB.Banco + '.grupo  where codigo="' + dmModulo.Query.fieldbyname('grupo').Text + '"';
      dmModulo.QueryResult.open;
      xConta := dmModulo.QueryResult.fieldbyname('conta').Text;
    end;

    if xConta = '' then
      xConta := '0.1.1';

    SetConta(xConta);

    XcontaDescricao := copy(_Conta.Descricao + ' - ' + _Cliente.Nome, 1, 100);

    xvalor := val2(dmModulo.cItens.fieldbyname('valor').Text) * val2(dmModulo.cItens.fieldbyname('qte').Text);

    if dmModulo.cItens_conta.FindKey([xConta]) then
      dmModulo.cItens_conta.edit
    else
      dmModulo.cItens_conta.Append;
    dmModulo.cItens_conta.fieldbyname('conta').Text := _Conta.Conta;
    dmModulo.cItens_conta.fieldbyname('contadescricao').Text := XcontaDescricao;
    dmModulo.cItens_conta.fieldbyname('tipo').Text := _Conta.Tipo;
    dmModulo.cItens_conta.fieldbyname('valor').Text := floattostr(val2(dmModulo.cItens_conta.fieldbyname('valor').Text) + xvalor);
    dmModulo.cItens_conta.post;
    dmModulo.cItens.next;
  end;
end;

procedure TfrmMain.SetEmpresa(femp: string);
begin

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := ' select * from ' + _DB.BancoFinan + '.empresa where codigo="' + femp + '"';
  dmModulo.QueryInt.open;

  _Empresa.Codigo := dmModulo.QueryInt.fieldbyname('codigo').Text;
  _Empresa.Conta := dmModulo.QueryInt.fieldbyname('Conta').Text;
  if _Empresa.Conta = '' then
    _Empresa.Conta := '0.1.1';
  _Empresa.Caixa := dmModulo.QueryInt.fieldbyname('Caixa').Text;
  if _Empresa.Caixa = '' then
    _Empresa.Caixa := '00001';
end;

procedure TfrmMain.Set_Lancamento(fempresa, fcusto, FCliente, fcpf, fcnpj, fconta, fconta_tipo, fcaixa, fdoc, FDescricao,
  fdata: string; Fsval: Double);
var
  xId: string;
begin
  if Fsval <= 0 then
    exit;
  xId := Incrementador(_DB.BancoFinan, 'lancamento');
  ExecutaComandoSql('insert into ' + _DB.BancoFinan + '.lancamento (id,empresa,custo,cadastro,cpf,cnpj,setor,conta,caixa,tipo,documento,' +
    ' descricao,valor,data,conciliado,tipolanc,remessarquivo)' + ' values (' + xId + ',"' + fempresa + '","' + fcusto + '","' + FCliente +
    '","' +
    LimpaConteudo(fcpf) + '","' + LimpaConteudo(fcnpj) + '","FINAN","' + fconta + '","' + fcaixa + '","' + fconta_tipo + '","' + fdoc + '","' +
    FDescricao + '",' + trans(Fsval) + ',' + DtoS(strtodate(fdata)) + ',' + DtoS(strtodate(fdata)) + ',"autocom","' + _Remessa + '")');

  { executacomandosql('insert into '+_DB.BancoFinan+'.lancamento (id,empresa,custo,cadastro,cpf,cnpj,setor,conta,caixa,tipo,documento,'+
    ' descricao,valor,data,conciliado,tipolanc,remessarquivo)'+
    ' values ('+xid+',"'+_Empresa.Codigo+'","'+_Empresa.Codigo+'","'+_Cliente.codigo+'","'+
    limpaconteudo(_Cliente.cpf)+'","'+limpaconteudo(_Cliente.cnpj)+'","FINAN","'+_Conta.Conta+
    '","'+_Empresa.Caixa+'","'+_Conta.tipo+'","'+Fid+'","'+XContaDescricao+ '",'+
    trans(Fsval)+','+dtos(StrTodate(fdata))+','+dtos(StrTodate(fdata))+',"autocom","'+_Remessa+'")'); }
end;

procedure TfrmMain.Lancamento(fempresa: string; fid: string; FCliente: string; fVal: Double; fdata: string);
var
  XcontaDescricao: string;
  xtroco, xvalor: Double;

begin

  xvalor := fVal;
  SetEmpresa(fempresa);
  // total de pedidos faturados +
  if _ContaFinanceiro.ContaPorProduto_Grupo <> '1' then
  begin

    dmModulo.CPagamento.First;
    if FCampo_Pag('conta_venda') <> '' then
      SetConta(FCampo_Pag('conta_venda'))
    else
      SetConta(_Empresa.Conta);

    XcontaDescricao := trim(copy(_Conta.Descricao + ' ' + _Cliente.Nome, 1, 100));

    Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo, _Empresa.Caixa,
      fid, XcontaDescricao, fdata, xvalor);

  end
  else
  begin
    Set_Itens; // agrupa itens por conta!
    dmModulo.cItens_conta.First;
    while not dmModulo.cItens_conta.eof do
    begin
      if dmModulo.cItens_conta.fieldbyname('conta').Text <> '' then
        SetConta(dmModulo.cItens_conta.fieldbyname('conta').Text)
      else
        SetConta(_Empresa.Conta);

      XcontaDescricao := copy(_Conta.Descricao + ' ' + _Cliente.Nome, 1, 100);
      xvalor := val2(dmModulo.cItens_conta.fieldbyname('valor').Text);
      Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo, _Empresa.Caixa,
        fid, XcontaDescricao, fdata, xvalor);
      dmModulo.cItens_conta.next;
    end;
  end;
  // manda para o contas a receber o aprazo e manda para a contrapartida o lancamento

  dmModulo.CPagamento.First;
  xtroco := 0;
  while not dmModulo.CPagamento.eof do
  begin
    if (FCampo_Pag('tipo') = '97') or (FCampo_Pag('codigo') = '97') then
    // entao é aprazo
    begin
      xtroco := xtroco + val2(FCampo_Pag('Valor'));
    end;
    dmModulo.CPagamento.next;
  end;

  dmModulo.CPagamento.First;
  while not dmModulo.CPagamento.eof do
  begin
    if (FCampo_Pag('tipo') = '2') or (FCampo_Pag('tipo') = '4') or (FCampo_Pag('tef') <> '') or (val2(FCampo_Pag('dias')) > 0) then
    // Se for prazo cria uma conta a prazo!
    begin
      if (FCampo_Pag('tipo') = '2') or (FCampo_Pag('tef') <> '') or (FCampo_Pag('dias') <> '') then
        Set_Receber(FCampo_Pag('codigo'), FCampo_Pag('Conta'), FCampo_Pag('Taxa'),
          FCampo_Pag('Valor'), FCampo_Pag('vencimento'),
          FCampo_Pag('clienteCartao'), _Empresa.Codigo, FCampo_Pag('data'),
          FCampo_Pag('cupom'), fid, floattostr(xtroco), FCampo_Pag('paciente'), FCampo_Pag('tefautorizacao'));
    end;
    { Se for do tipo 1 e tiver conta negativa entao faca o negativo }
    if ((FCampo_Pag('tipo') = '1') and (copy(FCampo_Pag('conta'), 1, 1) = '1')) or
      ((FCampo_Pag('tipo') >= '2') and (FCampo_Pag('tipo') <> '97') and (FCampo_Pag('codigo') <> '97')) or (FCampo_Pag('tef') <> '') then
    begin
      SetConta(FCampo_Pag('conta'));
      XcontaDescricao := copy(_Conta.Descricao + ' ' + _Cliente.Nome, 1, 100);
      if (FCampo_Pag('devolucao') = '-1') then
      begin
        SetConta(_ContaFinanceiro.ContaTroca);
        XcontaDescricao := copy('Devolucao/Troca  ' + _Cliente.Nome, 1, 100);
      end;
      xvalor := val2(FCampo_Pag('Valor'));
      Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, _Conta.Conta, _Conta.Tipo, _Empresa.Caixa,
        fid,
        XcontaDescricao, fdata, xvalor);
    end;
    xtroco := 0;
    dmModulo.CPagamento.next;
  end;
end;

procedure TfrmMain.Set_Receber(fcodigo, fconta, ftaxa, fValor, fvencimento, FCliente,
  fempresa, fdata, fcupom, fid, ftroco, fpaciente, fTefAutoricao: string);
var
  xObs, xReferencia, xAreceber: string;
  xStatus, xDoc, xbanco, xagencia: string;
  x: string;
  xtax: string;
  xVenda, xData: string;
  xdatatroco: string;
  xDesc: Double;
  xCodigo, xNome, xcpf, xcnpj: string;
begin
  // pega o padrao
  xCodigo := _Cliente.Codigo;
  xNome := _Cliente.Nome;
  xReferencia := xNome;

  xcpf := _Cliente.Cpf;
  xcnpj := _Cliente.Cnpj;

  if fvencimento = '' then
    fvencimento := fdata;
  // procura se tem clientecartao;
  if FCliente <> '' then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.cadastro where codigo="' + FCliente + '"';
    dmModulo.Query.open;

    // se nao achou pega o do cabecalho
    if not dmModulo.Query.isempty then
    begin
      xCodigo := dmModulo.Query.fieldbyname('codigo').Text;
      xNome := dmModulo.Query.fieldbyname('nome').Text;
      xcpf := dmModulo.Query.fieldbyname('cpf').Text;
      xcnpj := dmModulo.Query.fieldbyname('cnpj').Text;
    end;
  end;

  xData := DtoS(strtodate(fdata));
  xdatatroco := DtoS(strtodate(fdata));
  SetConta(fconta);
  if _Conta.Conta <> '' then // achou
  begin
    xAreceber := _Conta.AReceber;
    if xAreceber = '' then
      exit; // sai pois nao tem contrapartida!
  end;
  xObs := _Conta.Descricao; //
  xDoc := fcupom;
  if fcupom = '' then
    xDoc := fid;
  xVenda := fid;
  if xVenda = '' then
    xVenda := 'null';

  x := Incrementador(_DB.BancoFinan, 'receber');

  ExecutaComandoSql('insert into ' + _DB.BancoFinan + '.receber (id,emissao,doc,venda,cliente,nome,cpf,cnpj,conta,empresa,' +
    ' valor,tipo,referencia,obs,paciente,tefautorizacao,tipolanc,remessarquivo) values (' + x + ',' + xData + ',"' + xDoc + '",' + xVenda +
    ',"' + xCodigo + '","' +
    xNome + '","' + xcpf + '","' + xcnpj + '","' + xAreceber + '","' + fempresa + '",' + trans(val2(fValor)) + ',"Aut","' + xReferencia + '","'
    + xObs + '","' + fpaciente + '","' + fTefAutoricao + '","autocom","' + _Remessa + '")');

  // ver os vencimentos possiveis
  // pega o do cartao que e parametrizado no autocom
  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.cheques where cod="' + fid + '" and vencimento=' + DtoS(strtodate(fvencimento));
  dmModulo.Query.open;
  if not dmModulo.Query.isempty then
  begin
    xDoc := dmModulo.Query.fieldbyname('numero').Text;
    xbanco := dmModulo.Query.fieldbyname('banco').Text;
    xagencia := dmModulo.Query.fieldbyname('agencia').Text;
  end;

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.tipopgto where cod="' + fcodigo + '" and posicao=2 ';
  dmModulo.QueryInt.open;
  if dmModulo.QueryInt.fieldbyname('posicao').Text = '02' then
    xStatus := 'CH';

  xDesc := 0;
  if val2(ftaxa) > 0 then
  begin
    xDesc := val2(fValor) * (val2(ftaxa) / 100);
    if xDesc > 0 then
      xtax := 'TXA'
    else
      xtax := '';
  end;

  ExecutaComandoSql('insert into ' + _DB.BancoFinan + '.receberdetalhe (receber,vencimento,valor,valorpg,desconto,' +
    ' desconto1,tipodes1,doc,banco,agencia,data,empresa,venda,cliente,tipolanc,status,autorizacaotef, remessarquivo) values (' + x + ',' +
    DtoS(strtodate(fvencimento)) + ',' + trans(val2(fValor) - val2(ftroco)) + ',' + trans(val2(fValor) - xDesc) + ',' + trans(xDesc) + ',' +
    // desconto
    trans(xDesc) + ',"' + xtax + '","' + xDoc + '","' + xbanco + '","' + xagencia + '",' + DtoS(strtodate(fdata)) + ',' + '"' + fempresa +
    '",' + xVenda + ',' + '"' + xCodigo + '","autocom","' + xStatus + '","' + fTefAutoricao + '","' + _Remessa + '");');

  // troco facil
  if val2(ftroco) > 1 then
  begin
    ExecutaComandoSql('insert into ' + _DB.BancoFinan + '.receberdetalhe (receber,vencimento,valor,valorpg,desconto,desconto1,' +
      ' tipodes1,doc,banco,agencia,data,empresa,venda,cliente,tipolanc,status,remessarquivo) values (' + x + ',' + xdatatroco + ',' +
      trans(val2(ftroco)) + ',' + trans(val2(ftroco)) + ',null,null' + ',null,"' + xDoc + '","' + xbanco + '","' + xagencia + '",' +
      DtoS(strtodate(fdata)) + ',' + '"' + fempresa + '",' + xVenda + ',' + '"' + xCodigo + '","autocom","' + xStatus + '","' +
      _Remessa + '");');
  end;
  dmModulo.Query.close;
end;

function TfrmMain.GetFile(fURL: string;
  fdir:
  string): Boolean;
var
{$IFDEF useopenssl}
  LIO: TIdSSLIOHandlerSocketOpenSSL;
{$ENDIF}
  LHTTP: TIdHTTP;
  LStr: TMemoryStream;
  LHE: EIdHTTPProtocolException;
  GURL: TIdURI;
{$IFDEF usezlib}
  LC: TIdCompressorZLib;
{$ENDIF}
begin
  GURL := TIdURI.create;
  GURL.URI := fURL;
{$IFDEF useopenssl}
  LIO := TIdSSLIOHandlerSocketOpenSSL.create;
{$ENDIF}
{$IFDEF  usezlib}
  LC := TIdCompressorZLib.create;
{$ENDIF}
  try
    LHTTP := TIdHTTP.create;
    try
{$IFDEF useopenssl}
      LHTTP.Compressor := LC;
{$ENDIF}
      // set to false if you want this to simply raise an exception on redirects
      LHTTP.HandleRedirects := True;
      {
        Note that you probably should set the UserAgent because some servers now screen out requests from
        our default string "Mozilla/3.0 (compatible; Indy Library)" to prevent address harvesters
        and Denial of Service attacks.  SOme people have used Indy for these.

        Note that you do need a Mozilla string for the UserAgent property. The format is like this:

        Mozilla/4.0 (compatible; MyProgram)
      }
      LHTTP.Request.UserAgent := 'Mozilla/4.0 (compatible; httpget)';
      LStr := TMemoryStream.create;
{$IFDEF useopenssl}
      LHTTP.IOHandler := LIO;
{$ENDIF}
      LHTTP.Get(GURL.URI, LStr);
      if LStr.Size > 0 then
      begin
        LStr.SaveToFile(fdir);
        result := True;
      end
      else
        result := false;

    except
      on E: Exception do
      begin
        if E is EIdHTTPProtocolException then
        begin
          LHE := E as EIdHTTPProtocolException;
          mResp.Lines.Add('HTTP Protocol Error - ' + IntToStr(LHE.ErrorCode));
          mResp.Lines.Add(LHE.ErrorMessage);
        end
        else
        begin
          if pos('host not found', E.Message) <= 0 then
            mResp.Lines.Add(E.Message);
        end;
      end;
    end;
    FreeAndNil(LHTTP);
    FreeAndNil(LStr);
  finally
{$IFDEF useopenssl}
    FreeAndNil(LIO);
{$ENDIF}
{$IFDEF  usezlib}
    FreeAndNil(LC);
{$ENDIF}
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
  xtime: Double;
  xmStr: TStringList;
begin
  try
    xmStr := TStringList.create;
    try
      VerificaSistemaBrasileiro;

      Timer1.Enabled := false;
      if not CheckMasterHandle then
        exit;

      xtime := Time;

      // processa a venda...
      // se o programa for prode. expr   / ou se for o monitor e nao exisitr o arquivo anto rode
      Roda_Arquivos;

    except
      on E: Exception do
        mResp.Lines.Add(datetimetostr(now) + ' ERRO: (Timer) ' + E.Message);
    end;

  finally
    FreeAndNil(xmStr);
    Timer1.Enabled := True;
  end;
end;

function TfrmMain.fVerificaValorFechamento(fSList: TStringList; fQuery: TUniQuery; fArq: string): Boolean;
var
  fTexto: TStringList;
  ftroco: Double;
  fVal: Double;
  fdif: Double;
  fDesc: Double;
begin
  try
    result := True;
    fTexto := TStringList.create;
    fTexto.Text := StringReplace(fSList.Strings[0], '|', #13, [rfReplaceAll]);
    fVal := val2(fTexto.Strings[5]);
    if _DB.Host <> '' then
      ResetBancoDb(mResp);
    // Get_Campos(fSList.Text);
    try
      fQuery.close;
      fQuery.SQL.Text := 'select sum(vendasrecdo.valor) as total from ' + _DB.Banco + '.vendasrecdo ,' + _DB.Banco + '.vendas a' +
        ' where vendasrecdo.codigo=97 and a.cod=vendasrecdo.venda and ' + ' a.caixa=vendasrecdo.caixa and a.remessarquivo in (' + fArq + ')' +
        ' and a.empresa=vendasrecdo.empresa and vendasrecdo.data=a.data ';
      fQuery.open;

      ftroco := val2(fQuery.fieldbyname('total').Text);

      fQuery.close;
      fQuery.SQL.Text := 'select sum(vendasrecdo.valor) as total from ' + _DB.Banco + '.vendasrecdo ,' + _DB.Banco + '.vendas a' +
        ' where vendasrecdo.codigo=99 and a.cod=vendasrecdo.venda and ' + ' a.caixa=vendasrecdo.caixa and a.remessarquivo in (' + fArq + ')' +
        ' and a.empresa=vendasrecdo.empresa and vendasrecdo.data=a.data ';
      fQuery.open;

      fDesc := val2(fQuery.fieldbyname('total').Text);

      fQuery.close;
      fQuery.SQL.Text := 'select sum(vendasrecdo.valor) as total from ' + _DB.Banco + '.vendasrecdo ,' + _DB.Banco + '.vendas a' +
        ' where vendasrecdo.codigo<>97 and a.cod=vendasrecdo.venda and ' + ' a.caixa=vendasrecdo.caixa and a.remessarquivo in (' + fArq + ')' +
        ' and a.empresa=vendasrecdo.empresa and vendasrecdo.data=a.data ';
      fQuery.open;
      fdif := BRound(val2(fQuery.fieldbyname('total').Text) - fDesc - ftroco - fVal, 2);
      if (fdif > 0.05) or (fdif < - 0.05) then
        result := false;
    Except
      on E: Exception do
        logging(mResp, 'Em ' + datetimetostr(now()) + ' Erro ' + E.Message);

    end;
  finally
    FreeAndNil(fTexto);
  end;
  // ou falta ou troco
end;

function TfrmMain.fVerificavalorVenda(fSList: TStringList;
  fArq:
  string;
  fQuery:
  TUniQuery): Boolean;
var
  fTexto: TStringList;
  xtroco: Double;
  xDif, xval: Double;
  xTotalTexto: Double;
begin
  try
    CDSClass.CriaCItens;
    CDSClass.CriaPagamento;
    CDSClass.CriaCadastro;
    CDSClass.CriaSangria;
    CDSClass.CriaRetiradas;

    fTexto := TStringList.create;
    fTexto.Text := StringReplace(fSList.Strings[1], '|', #13, [rfReplaceAll]);

    result := True;
    Get_Campos(fSList.Text);
    xtroco := 0;
    xval := 0;
    while not dmModulo.CPagamento.eof do
    begin
      if (FCampo_Pag('tipo') = '97') or (FCampo_Pag('codigo') = '97') then
        // entao é aprazo
        xtroco := xtroco + val2(FCampo_Pag('Valor'))
      else
        xval := xval + val2(FCampo_Pag('Valor'));
      dmModulo.CPagamento.next;
    end;
    xTotalTexto := xval - xtroco;
    fQuery.close;
    fQuery.SQL.Text := 'select sum(vendasrecdo.valor) as total from  ' + _DB.Banco + '.vendasrecdo ,' + _DB.Banco + '.vendas a' +
      ' where vendasrecdo.codigo=97 and a.cod=vendasrecdo.venda and ' + ' a.caixa=vendasrecdo.caixa and a.remessarquivo="' + fArq + '"' +
      ' and a.empresa=vendasrecdo.empresa and vendasrecdo.data=a.data ';
    fQuery.open;

    xtroco := val2(fQuery.fieldbyname('total').Text);

    fQuery.close;
    fQuery.SQL.Text := 'select sum(vendasrecdo.valor) as total from ' + _DB.Banco + '.vendasrecdo ,' + _DB.Banco + '.vendas a' +
      ' where vendasrecdo.codigo<>97 and a.cod=vendasrecdo.venda and ' + ' a.caixa=vendasrecdo.caixa and a.remessarquivo="' + fArq + '"' +
      ' and a.empresa=vendasrecdo.empresa and vendasrecdo.data=a.data ';
    fQuery.open;
    xDif := val2(fQuery.fieldbyname('total').Text) - xtroco - xTotalTexto;
    if (xDif > 0.03) or (xDif < - 0.03) then
      result := false;
    // ou falta ou troco
  Finally
    FreeAndNil(fTexto);
  end;
end;

function TfrmMain.fChecFechamento(fZip: TZLBArc2;
  fQuery:
  TUniQuery;
  ffile:
  string): string;
type
  xMtext = record
    Texto: string;
    FileName: string;
  end;
var
  fTextStream: TStringStream;
  xArqs: string;
  xLinhas: TStringList;
  xRet: TStringList;
  i: integer;
  xText: array of xMtext;
begin
  try
    // try
    // pegando os arquivos no fechamento
    for i := 0 to fZip.FileCount - 1 do
      if LowerCase(ExtractFileExt(fZip.Files[i].Name)) = '.txt' then
      // se for fechamento entao tira
      begin
        if xArqs = '' then
          xArqs := '"' + StrDeleteAll(fZip.Files[i].Name, '/') + '"'
        else
          xArqs := xArqs + ',"' + StrDeleteAll(fZip.Files[i].Name, '/') + '"';
      end;

    // pegando o fechamento

    xLinhas := TStringList.create;
    xRet := TStringList.create;
    SetLength(xText, 0);
    for i := 0 to fZip.FileCount - 1 do
    begin
      if LowerCase(ExtractFileExt(fZip.Files[i].Name)) = '.fec' then
      // se for fechamento entao tira
      begin
        fTextStream := TStringStream.create('');
        fZip.ExtractStreamByIndex(fTextStream, i);
        xLinhas.Text := fTextStream.DataString;
        FreeAndNil(fTextStream);
        result := xLinhas.Text;
        // break;
      end;
      if LowerCase(ExtractFileExt(fZip.Files[i].Name)) = '.txt' then
      // se for fechamento entao tira
      begin
        fTextStream := TStringStream.create('');
        fZip.ExtractStreamByIndex(fTextStream, i);
        SetLength(xText, length(xText) + 1);
        xText[length(xText) - 1].Texto := fTextStream.DataString;
        xText[length(xText) - 1].FileName := StrDeleteAll(fZip.Files[i].Name, '/');
        FreeAndNil(fTextStream);
      end;
    end;
    // verificar se o valor do fechamento bate com o que foi enviado!

    if length(xText) > 0 then
      GetDbinFile(mResp, xText[0].Texto);

    // Verificando o Fechamento venda a venda

    if (xArqs <> '') and (not fVerificaValorFechamento(xLinhas, dmModulo.Query, xArqs)) then
    begin
      // se nao foi entao ele vai procurar venda por venda !
      for i := 0 to length(xText) - 1 do
      // if lowercase(ExtractFileExt(fZip.Files[i].name)) = '.txt' then //se for fechamento entao tira
      begin
        // redundancia mas tem que ser pois ele ativa nas funcoes
        { Timer1.enabled := False;
          TcpServer.Active := False;
          fTextStream := TstringStream.Create('');
          fZip.ExtractStreamByIndex(fTextStream, i); }
        xRet.Text := xText[i].Texto; // arquivo do vendas
        // FreeAndNil(fTextStream);

        if ProcuraCampo('00001', xRet.Text) then
          if not fVerificavalorVenda(xRet, xText[i].FileName, dmModulo.Query) then
          begin
            // GetHoraRemessa(xText[i].Filename);
            xRet.SaveToFile(_Dir.Dir + '\Recebimento\' + xText[i].FileName);
            {

              DoVenda(xRet.Text);
              sleep(100);
              //Application.ProcessMessages; }
            mResp.Lines.Add(datetimetostr(now) + ' ERRO: (fechamento), Arquivo de venda ' + xText[i].FileName +
              ' com problemas de valores, e vai ser reprocessado!');
          end;

        if ProcuraCampo('00040', xRet.Text) then
        begin
          // GetHoraRemessa(xText[i].Filename);
          xRet.SaveToFile(_Dir.Dir + '\Recebimento\' + xText[i].FileName);

          mResp.Lines.Add(datetimetostr(now) + ' ERRO: (fechamento), Arquivo de Creditos ' + xText[i].FileName +
            ' com problemas de valores, e vai ser reprocessado!');
        end;

      end;



      // FreeAndNil(fTextStream);

      // verificando o fechamento e descompactando tudo

      { if not fVerificaValorFechamento(xLinhas, fQuery, xArqs) then
        begin
        for i := 0 to fZip.FileCount - 1 do
        if lowercase(ExtractFileExt(fZip.Files[i].name)) = '.txt' then //se for fechamento entao tira
        begin
        if i mod 10 = 0 then SaveFileTimer;
        if pos('00001|', xRet.text) > 0 then
        fZip.ExtractFileByIndex(_Dir.Dir + '\recebimento\', i);
        end;
        MResp.Lines.add(datetimetostr(now) + ' ERRO: (fechamento), Arquivo ' + ffile + ' com problemas de valores, foi reprocessado!');
        end; }
    end;
    { except

      MResp.Lines.add(datetimetostr(now) + ' ERRO: (fechamento), Arquivo ' + ffile + ' com problemas de valores, foi reprocessado!');

      end; }
  finally
    mResp.Lines.SaveToFile('Error.log');
    FreeAndNil(xLinhas);
    FreeAndNil(xRet);
  end;

end;

procedure TfrmMain.DoFechamento(ffile: string;
  ftip:
  string = 'zlb');
var // xstr_: TMemoryStream;
  // xin: integer;
  xLinhas, xRet: TStringList;
  xstr: string;
begin
  try

    try

      xRet := TStringList.create;
      xLinhas := TStringList.create;

      if not FileExists(_Dir.Dir + '\recebimento\' + ffile) then
        exit;
      if ftip = 'zlb' then
      begin
        dmModulo.ZipFec.OpenArchive(_Dir.Dir + '\recebimento\' + ffile);
        xLinhas.Text := fChecFechamento(dmModulo.ZipFec, dmModulo.Query, ffile);
        dmModulo.ZipFec.CloseArchive;
      end
      else if FileExists(_Dir.Dir + '\recebimento\' + ChangeFileExt(ffile, '.fec')) then
        xLinhas.loadfromfile(_Dir.Dir + '\recebimento\' + ChangeFileExt(ffile, '.fec'));

      if xLinhas.Text = '' then
      // FileExists(_Dir.Dir + '\fechamento\' + ChangeFileExt(ffile, '.fec')) then
      begin
        xstr := '0';
        exit;
      end;
      // se achou entao gravo no DB
      // xLinhas.LoadFromFile(_Dir.Dir + '\fechamento\' + ChangeFileExt(ffile, '.fec'));
      xRet.Text := StringReplace(xLinhas.Strings[0], '|', #13, [rfReplaceAll]);
      xLinhas.Delete(0);

      ExecutaComandoSql('delete from ' + xRet.Strings[0] + '.fechamento where remessarquivo="' + ChangeFileExt(ffile, '.fec') + '"');
      ExecutaComandoSql('delete from ' + xRet.Strings[0] + '.fechamentodata where remessarquivo="' + ChangeFileExt(ffile, '.fec') + '"');

      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := 'select * from ' + xRet.Strings[0] + '.fechamento where 1<>1';
      dmModulo.Query.open;
      dmModulo.Query.Append;
      dmModulo.Query.fieldbyname('caixa').Text := xRet.Strings[1];
      dmModulo.Query.fieldbyname('empresa').Text := xRet.Strings[2];
      dmModulo.Query.fieldbyname('data').AsDateTime := StrToDateTime(xRet.Strings[3]);
      dmModulo.Query.fieldbyname('vendedor').Text := xRet.Strings[4];
      // 'trim(copy(balcaofrm.vendedornome.text,1,50));
      dmModulo.Query.fieldbyname('valor').AsFloat := val2(xRet.Strings[5]);
      dmModulo.Query.fieldbyname('texto').asstring := xLinhas.Text;
      dmModulo.Query.fieldbyname('datahora').AsDateTime := StrToDateTime(xRet.Strings[3]);
      dmModulo.Query.fieldbyname('remessarquivo').Text := ChangeFileExt(ffile, '.fec');
      dmModulo.Query.post;

      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := 'select * from ' + xRet.Strings[0] + '.fechamentodata where 1<>1';
      dmModulo.Query.open;
      dmModulo.Query.Append;
      dmModulo.Query.fieldbyname('caixa').Text := xRet.Strings[1];
      dmModulo.Query.fieldbyname('empresa').Text := xRet.Strings[2];
      dmModulo.Query.fieldbyname('data').AsDateTime := StrToDateTime(xRet.Strings[3]);

      dmModulo.Query.fieldbyname('dataatual').AsDateTime := StrToDateTime(xRet.Strings[3]);
      dmModulo.Query.fieldbyname('usuario').Text := xRet.Strings[4];
      // 'trim(copy(balcaofrm.vendedornome.text,1,50));
      dmModulo.Query.fieldbyname('remessarquivo').Text := ChangeFileExt(ffile, '.fec');
      dmModulo.Query.post;

      { Resposta('', '1', 'Arquivo ' + ffile + ' recebido ' +
        'Máquina: ' + AThread.Connection.Socket.Binding.PeerIP, AThread); }
      if ftip = 'zlb' then
      begin
        CopyFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.zlb')), pChar(_Dir.Dir + '\fechamento\' + ChangeFileExt(ffile, '.zlb')
          ), false);
        if FileExists(pChar(_Dir.Dir + '\fechamento\' + ChangeFileExt(ffile, '.zlb'))) then
          DeleteFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.zlb')));
      end
      else
      begin
        CopyFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.fec')), pChar(_Dir.Dir + '\fechamento\' + ChangeFileExt(ffile, '.fec')
          ), false);
        if FileExists(pChar(_Dir.Dir + '\fechamento\' + ChangeFileExt(ffile, '.fec'))) then
          DeleteFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.fec')));
      end;
    except
      on E: Exception do
      begin
        if ftip = 'zlb' then
        begin
          CopyFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.zlb')), pChar(_Dir.Erro + '\' + ChangeFileExt(ffile, '.zlb')), false);
          try
            if FileExists(pChar(_Dir.Erro + '\' + ChangeFileExt(ffile, '.zlb'))) then
              DeleteFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.zlb')));
          except
            mResp.Lines.Add(datetimetostr(now) + ' ERRO: (processar_on delete do fechamento execpt) ' + E.Message);
          end;
        end;
        if ftip = 'fec' then
        begin
          CopyFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.fec')), pChar(_Dir.Erro + '\' + ChangeFileExt(ffile, '.fec')), false);
          try
            if FileExists(pChar(_Dir.Erro + '\' + ChangeFileExt(ffile, '.fec'))) then
              DeleteFile(pChar(_Dir.Dir + '\Recebimento\' + ChangeFileExt(ffile, '.fec')));
          except
            mResp.Lines.Add(datetimetostr(now) + ' ERRO: (processar_on delete do fechamento execpt) ' + E.Message);
          end;
        end;
        // Resposta('', '0', 'ERRO: Arquivo ' + ffile + ' com problemas.', AThread);
      end;
    end;
  finally
    FreeAndNil(xLinhas);
    FreeAndNil(xRet);
  end;

end;

{ procedure TfrmConsulta.SetQuery(var fDb: TZConnection; var fQuery: TUniQuery);
  begin
  fQuery := TUniQuery.Create(Self);
  fQuery.Connection := fDb;
  fQuery.ShowRecordTypes := [usUnmodified, usModified, usInserted];

  end;
}
{ procedure TfrmConsulta.InicializaQuery(var fDb: TZConnection; var fQuery: TUniQuery);
  begin
  fDb := TZConnection.Create(dmModulo.Bancocnx);
  fDb.Protocol := BancoCnx_.Protocol;

  Config_DB(fDb, '', hostporta_ex(ip.text), hostporta_ex(ip.text, '1'), user.text, (Password.text));
  SetQuery(fDb, fQuery);
  end;
}

function Encrypt(
  const
  S:
  string): string;
const
  C1 = 5284512194871;
  C2 = 2271901327410;
var
  i: Byte;
  key: word;
  TempStr: string;
  Retstring: string;
begin
  key := 10703;
  SetLength(TempStr, length(S));
  for i := 1 to length(S) do
  begin
    TempStr[i] := char(Byte(S[i]) xor (key shr 8));
    key := (Byte(TempStr[i]) + key) * C1 + C2;
  end; { _ for I := 1 to Length(S) do _ }
  for i := 1 to length(TempStr) do
  begin
    Retstring := Retstring + IntToHex(ord(TempStr[i]), 2);
  end; { _ for I := 1 to Length(Tempstr) do _ }
  result := Retstring;
end; { _ function Encrypt(const S: string): string; _ }

function Get_File_Size(sFileToExamine: string;
  bInKBytes:
  Boolean): string;
var
  SearchRec: TSearchRec;
  sgPath: string;
  inRetval, I1: integer;
begin
  sgPath := ExpandFileName(sFileToExamine);
  try
    inRetval := FindFirst(ExpandFileName(sFileToExamine), faAnyFile, SearchRec);
    if inRetval = 0 then
      I1 := SearchRec.Size
    else
      I1 := - 1;
  finally
    SysUtils.FindClose(SearchRec);
  end;
  result := IntToStr(I1);
end;

function TfrmMain.SetNumero(Fnum: string): string;
begin
  if pos('.', Fnum) > 0 then
    Fnum[pos('.', Fnum)] := ',';
  result := Fnum;
end;

procedure TfrmMain.Lanca_Caixa(fVal: Double;
  fdata, fconta, fDescr, fTipo: string);
var
  xxstr: string;
  xconciliado: string;
begin
  xconciliado := 'now()';

  if dmModulo.QueryResult.fieldbyname('obs').Text <> '' then
    xxstr := xxstr + ' ' + dmModulo.QueryResult.fieldbyname('obs').Text;

  if dmModulo.QueryResult.fieldbyname('referencia').Text <> '' then
    xxstr := xxstr + ' ' + dmModulo.QueryResult.fieldbyname('referencia').Text;

  // if pos(copy(dmModulo.QueryResult.fieldbyname('nome').text,1,15),xxstr)<=0 then
  xxstr := dmModulo.QueryResult.fieldbyname('nome').Text + ' ' + xxstr;

  xxstr := xxstr + ' ' + fDescr;

  xxstr := StringReplace(xxstr, #13, '', [rfReplaceAll]);
  xxstr := StringReplace(xxstr, #10, '', [rfReplaceAll]);

  xxstr := trim(xxstr);

  { if fstr<>'1' then  //primerio  lancamento
    xxstr:=xxstr+' '+dmModulo.contadescricao.text;
  }

  Set_Lancamento(_Empresa.Codigo, _Empresa.Codigo, _Cliente.Codigo, _Cliente.Cpf, _Cliente.Cnpj, fconta, fTipo, _Empresa.Caixa, '', xxstr,
    fdata, fVal);

end;

procedure TfrmMain.fbaixa_rec(fVal: Double;
  fid, fdata, fcaixa: string);
  procedure ProcessaDesconto(ftip: string);
  begin
    if (val2(dmModulo.QueryResult.fieldbyname('desconto' + ftip).Text) > 0) and
      (dmModulo.QueryResult.fieldbyname('tipodes' + ftip).Text <> '') and
      ProcuraImposto(dmModulo.QueryResult.fieldbyname('tipodes' + ftip).Text) and ProcuraConta(dmModulo.QueryInt.fieldbyname('conta').Text) then
    begin
      Lanca_Caixa(val2(dmModulo.QueryResult.fieldbyname('desconto' + ftip).Text), fdata, dmModulo.QueryInt.fieldbyname('codigo').Text,
        dmModulo.QueryInt.fieldbyname('descricao').Text, dmModulo.QueryInt.fieldbyname('tipo').Text);
    end;
  end;
  procedure ProcessaAdicional(fadic, fconta: string);
  begin
    if (val2(dmModulo.QueryResult.fieldbyname(fadic).Text) > 0) and ProcuraConta(fconta) then
    begin
      Lanca_Caixa(val2(dmModulo.QueryResult.fieldbyname(fadic).Text), fdata, dmModulo.QueryInt.fieldbyname('codigo').Text,
        dmModulo.QueryInt.fieldbyname('descricao').Text,
        dmModulo.QueryInt.fieldbyname('tipo').Text);
    end;
  end;

begin
  if (dmModulo.QueryResult.fieldbyname('conta').Text <> '') and ProcuraConta(dmModulo.QueryResult.fieldbyname('conta').Text) then
  begin
    Lanca_Caixa(fVal, fdata, dmModulo.QueryInt.fieldbyname('codigo').Text, dmModulo.QueryInt.fieldbyname('descricao').Text,
      dmModulo.QueryInt.fieldbyname('tipo').Text);
  end;

  ProcessaAdicional('juros', _ContaFinanceiro.ContaJuros);
  ProcessaAdicional('multa', _ContaFinanceiro.ContaMulta);
  ProcessaAdicional('abono', _ContaFinanceiro.ContaAbono);
  ProcessaAdicional('reajuste', _ContaFinanceiro.ContaReajuste);
  ProcessaDesconto('1');
  ProcessaDesconto('2');
  ProcessaDesconto('3');
  ProcessaDesconto('4');

  ExecutaComandoSql(' update ' + _DB.BancoFinan + '.receberdetalhe b set b.remessarquivopg="' + _Remessa + '",' + ' b.pagamento=' +
    DtoS(strtodate(fdata)) + ',  b.origem=1 ,b.caixa=' + QuotedStr(fcaixa) + ' where b.id in (' + fid + ')');
end;

function TfrmMain.ProcuraConta(fcod: string): Boolean;
begin
  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.conta where codigo="' + fcod + '"';
  dmModulo.QueryInt.open;
  result := dmModulo.QueryInt.fieldbyname('codigo').Text <> '';
end;

function TfrmMain.ProcuraImposto(fcod: string): Boolean;
begin
  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'Select * from ' + _DB.BancoFinan + '.impostos where codigo="' + fcod + '"';
  dmModulo.QueryInt.open;
  result := dmModulo.QueryInt.fieldbyname('codigo').Text <> '';
end;

procedure TfrmMain.fbaixa_rec_parcial(ftotal, fVal: Double;
  fdata, fcaixa: string);
var
  xfvenc: string;
  xfval: Double;
  xfpag: string;
  xfrec, xfemp, xfdat: string;
begin
  // faco o lancamento
  if (dmModulo.QueryResult.fieldbyname('conta').Text <> '') and ProcuraConta(dmModulo.QueryResult.fieldbyname('conta').Text) then
  begin
    Lanca_Caixa(fVal, fdata, dmModulo.QueryInt.fieldbyname('codigo').Text, dmModulo.QueryInt.fieldbyname('descricao').Text,
      dmModulo.QueryInt.fieldbyname('tipo').Text);
  end;

  // dou a baixa referente oa valor restante pago
  xfvenc := dmModulo.QueryResult.fieldbyname('vencimento').Text;
  xfemp := dmModulo.QueryResult.fieldbyname('empresa').Text;
  xfdat := dmModulo.QueryResult.fieldbyname('data').Text;
  xfrec := dmModulo.QueryResult.fieldbyname('receber').Text;
  ExecutaComandoSql('update ' + _DB.BancoFinan + '.receberdetalhe set remessarquivopg="' + _Remessa + '", valor = ' + trans(fVal) +
    ', valorpg = ' +
    trans(fVal) + ', ' + ' pagamento=' + DtoS(strtodate(fdata)) + ', caixa="' + fcaixa +
    '", origem=1,desconto=null, tipodes1=null,desconto1=null, tipodes2=null,desconto2=null, tipodes3=null,desconto3=null, tipodes4=null,desconto4=null,'
    + ' abono=null,juros=null,multa=null,reajuste=null where id=' + dmModulo.QueryResult.fieldbyname('id').Text);

  // crio um contas a receber do que nao baixou
  if ftotal > fVal then
  begin
    xfval := ftotal - fVal;
    if xfval > 0.02 then
      xfpag := 'null'
    else
      xfpag := DtoS(strtodate(xfvenc));
    // se for valor pegqueno ja dá a baixa;
    ExecutaComandoSql('insert into ' + _DB.BancoFinan +
      '.receberdetalhe(receber,empresa,data,vencimento,pagamento,valor,valorpg,remessarquivo) values (' + xfrec + ',"' + xfemp + '",' +
      DtoS(strtodate(xfdat)) + ',' + DtoS(strtodate(xfvenc)) + ',' + xfpag + ',' + trans(xfval) + ',' + trans(xfval) + ',"' + _Remessa + '")');
  end;
end;

Function TfrmMain.Baixa_Recebimentos(fValor, fdata, fcaixa, fVenda, fempresa, fBoleto: string): Boolean;
var
  xId: string;
  xval: Double;
  xlimite, xvalor: Double;
  xwhere: string;
begin
  // parsequery(obs.lines.text);
  // obs.lines.text:=replstr(obs.lines.text,',',' ');
  result := True;
  if not ((_Cliente.Codigo <> '') and (fcaixa <> '') and (val2(fValor) > 0)) then
    exit;

  if (fVenda <> '') then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := 'select * from ' + _DB.Banco + '.vendas where venda_remoto="' + fVenda + '" and empresa="' + fempresa +
      '" and data=' +
      DtoS(strtodate(fdata));
    dmModulo.Query.open;
    if not dmModulo.Query.isempty then
    begin
      xwhere := ' and a.venda=' + dmModulo.Query.fieldbyname('cod').Text + ' and a.empresa="' + dmModulo.Query.fieldbyname('empresa').Text +
        '" and a.emissao=' +
        DtoS(strtodate(fdata));
    end;
  end;

  if (fBoleto <> '') then
  begin
    xwhere := xwhere + ' and b.boleto=' + fBoleto;
  end;

  if xwhere = '' then
  begin
    result := false;
    logging(mResp, 'Erro no Recebimento de conta(Baixa_Recebimentos):Venda nao encontrada!');
    exit;

  end;
  dmModulo.QueryResult.close;
  dmModulo.QueryResult.SQL.Text := 'select sum(b.valor) as total,sum(b.valorpg) as totalpg,' +
    ' a.conta,a.empresa,a.doc,a.unidade,a.cliente,a.nome,b.id,b.vencimento,b.receber,b.data, ' + ' b.tipodes1,' + ' b.tipodes2,' +
    ' b.tipodes3,' +
    ' b.tipodes4,' + ' b.obs,a.referencia,' + ' sum(juros) as juros, ' + ' sum(b.abono) as abono, ' + ' sum(b.multa) as multa, ' +
    ' sum(b.desconto1) as desconto1, ' + ' sum(b.desconto2) as desconto2, ' + ' sum(b.desconto3) as desconto3, ' + ' sum(b.desconto4) as desconto4, '
    + ' sum(b.reajuste) as reajuste ' + ' from ' + _DB.BancoFinan + '.receberdetalhe b,' + _DB.BancoFinan + '.receber a ' +
    ' where a.id=b.receber and a.id=b.receber and a.empresa=b.empresa and a.emissao=b.data and (a.cliente="' + _Cliente.Codigo + '") ' +
    xwhere +
    ' and not (a.conta is null) and (pagamento is null ) and  (b.status<>"CH" or b.status is null) group by b.id order by b.vencimento,b.valor ';
  dmModulo.QueryResult.open;

  if dmModulo.QueryResult.isempty then
    exit;

  // pegar os id`s

  // processar
  dmModulo.QueryResult.First;
  xval := 0; // varialvel aumenta ate chegar no limite
  xlimite := val2(fValor);

  while not dmModulo.QueryResult.eof do
  begin
    xId := dmModulo.QueryResult.fieldbyname('id').Text;
    xvalor := val2(dmModulo.QueryResult.fieldbyname('total').Text) + val2(dmModulo.QueryResult.fieldbyname('juros').Text) +
      val2(dmModulo.QueryResult.fieldbyname('multa').Text)
      + val2(dmModulo.QueryResult.fieldbyname('reajuste').Text) + val2(dmModulo.QueryResult.fieldbyname('abono').Text);
    xvalor := xvalor - (val2(dmModulo.QueryResult.fieldbyname('desconto1').Text) + val2(dmModulo.QueryResult.fieldbyname('desconto2').Text) +
      val2(dmModulo.QueryResult.fieldbyname('desconto3').Text) - val2(dmModulo.QueryResult.fieldbyname('desconto4').Text));
    xval := xval + xvalor;

    // se fvalor que a fatura individual entao baixa toda
    if xlimite >= xval then
    begin // ainda vai compor
      fbaixa_rec(val2(dmModulo.QueryResult.fieldbyname('total').Text), xId, fdata, fcaixa);
    end
    else
    begin
      xval := xval - xvalor;
      // volta um para ficar dentro do limite

      xval := xlimite - xval; // pego o resto que sobrou //ver se sobrou
      if xval > 0 then // so quando for caixa mas ai vem sem o group by
        fbaixa_rec_parcial(xvalor, xval, fdata, fcaixa);
      break;
    end;
    dmModulo.QueryResult.next;
  end; // while
end;

Function TfrmMain.OpenCheckedTables(fopt: String): Boolean;
begin
  dmModulo.Query.close;
  if fopt = '' then
    dmModulo.Query.SQL.Text := 'show table status where (engine=null or engine="") or comment like "%crash%"'
  else
    dmModulo.Query.SQL.Text := 'show table status   from ' + fopt + ' where (engine=null or engine="") or comment like "%crash%"';
  dmModulo.Query.open;
  if not dmModulo.Query.isempty then
  begin
    pbProgress.Max := dmModulo.Query.RecordCount + 1;
    while not dmModulo.Query.eof do
    begin
      pbProgress.Position := dmModulo.Query.Recno;
      if fopt = '' then
        ExecutaComandoSql('repair table  ' + dmModulo.Query.Fields[0].asstring)
      else
        ExecutaComandoSql('repair table  ' + fopt + '.' + dmModulo.Query.Fields[0].asstring);
      logging(mResp, 'Repair Table:' + fopt + '.' + dmModulo.Query.Fields[0].asstring + ' ' + dmModulo.Query.fieldbyname('comment').asstring);
      dmModulo.Query.next;
    end;
  end;
end;

Procedure TfrmMain.CheckTables(fopt: String);
begin
  dmModulo.Query.close;
  if fopt = '' then
    dmModulo.Query.SQL.Text := 'show tables '
  else
    dmModulo.Query.SQL.Text := 'show tables from ' + fopt;
  dmModulo.Query.open;
  pbProgress.Max := dmModulo.Query.RecordCount + 1;
  while not dmModulo.Query.eof do
  begin
    pbProgress.Position := dmModulo.Query.Recno;
    if fopt = '' then
      ExecutaComandoSql('check table  ' + dmModulo.Query.Fields[0].asstring)
    else
      ExecutaComandoSql('check table  ' + fopt + '.' + dmModulo.Query.Fields[0].asstring);

    dmModulo.Query.next;
  end;
  OpenCheckedTables(fopt);
end;

procedure TfrmMain.BancocnxError(Sender: TObject;
  E:
  EDAError;
  var
  Fail:
  Boolean);
begin
  if E.ErrorCode > 0 then
  begin
    if (E.ErrorCode in ([126, 145, 134, 141])) or
      ((E.ErrorCode = 1062) and (pos('primary', LowerCase(E.Message)) > 0)) then
    begin
      Try
        if _DB.Banco <> '' then
        begin
          CheckTables(_DB.Banco);

        end;
        if _DB.Banco <> '' then
        begin
          CheckTables(_DB.BancoFinan);
        end;
      Finally
      end;

    end;
  end;

end;

function TfrmMain.fTipoCmd(fCmd: TStringList): string;
var
  i: integer;
  xLinhas: TStringList;
begin
  try
    xLinhas := TStringList.create;
    xLinhas.Text := LowerCase(StringReplace(fCmd.Strings[0], '|', #13, [rfReplaceAll]));

    if copy(fCmd.Text, 1, 6) = '{"CMP"' then
      result := 'CMP'
    else
      if copy(fCmd.Text, 1, 12) = '{"VND_MOBILE' then
      result := 'VND_MOBILE'
    else
      if copy(fCmd.Text, 1, 16) = '{"COLETOR_MOBILE' then
      result := 'COLETOR_MOBILE'
    else

      for i := 0 to fCmd.count - 1 do
      begin
        if copy(fCmd.Strings[i], 1, 5) = '00001' then // vendas
          result := 'venda';

        if copy(fCmd.Strings[i], 1, 5) = '00010' then
          // sub item de 00001 que e devolucao
          result := 'retiradas'; // devolucao da venda

        if copy(fCmd.Strings[i], 1, 5) = '00011' then
          // sub item de 00001 que e cancelamento de items
          result := 'venda'; // cancelamento da venda

        if copy(fCmd.Strings[i], 1, 5) = '00111' then
          // sub item de 00111 que e cancelamento de items
          result := 'itensexcluidos'; // cancelamento da ITENS DA VENDA

        if copy(fCmd.Strings[i], 1, 5) = '00222' then
          // sub item de 00222 transferencia de items
          result := 'itenstransf'; //

        if copy(fCmd.Strings[i], 1, 5) = '00002' then
          result := 'venda'; // pagamento da venda

        if copy(fCmd.Strings[i], 1, 5) = '00015' then
          result := 'prazo'; // pagamento da venda

        if copy(fCmd.Strings[i], 1, 5) = '00020' then
          result := 'sangria'; // pagamento da venda

        if copy(fCmd.Strings[i], 1, 5) = '00030' then
          result := 'fundo'; // pagamento da venda

        if copy(fCmd.Strings[i], 1, 5) = '00040' then
          result := 'credito_lancado'; // pagamento da venda

        if copy(fCmd.Strings[i], 1, 5) = '00050' then
          result := 'retiradas';

        if copy(fCmd.Strings[i], 1, 5) = '00060' then
          result := 'contagem';

        if copy(fCmd.Strings[i], 1, 5) = '00051' then
          result := 'retiradascancel';

        if copy(fCmd.Strings[i], 1, 5) = '00059' then
          result := 'retiradasbaixa';

        if copy(fCmd.Strings[i], 1, 5) = '00701' then
          result := 'sped'; // pagamento da venda

        if copy(fCmd.Strings[i], 1, 5) = '00702' then
          result := 'sintegra'; // pagamento da venda

        if result <> '' then
          break;
      end;
    if result = '' then
      result := LowerCase(xLinhas.Strings[0]);

  finally
    FreeAndNil(xLinhas);
  end;
end;

function isTipo(fTipo: string): Boolean;
begin
  fTipo := LowerCase(fTipo);
  result := (fTipo = 'CMP') or (fTipo = 'VND_MOBILE') or (fTipo = 'COLETOR_MOBILE') or (fTipo = 'venda') or (fTipo = 'cadastro') or
    (fTipo = 'prazo') or (fTipo = 'credito_lancado') or
    (fTipo = 'sped') or
    (fTipo = 'sintegra')
    or (fTipo = 'sangria') or (fTipo = 'fundo') or (fTipo = 'itensexcluidos') or (fTipo = 'itenstransf') or (fTipo = 'retiradas') or
    (fTipo = 'retiradasbaixa') or
    (fTipo = 'retiradascancel') or (fTipo = 'paf_ultima_reducaoz') or (fTipo = 'paf_detalhe') or (fTipo = 'paf_recdo') or (fTipo = 'paf_canc') or
    (fTipo = 'paf_gnf') or (fTipo = 'paf_cancitem');
end;

end.
