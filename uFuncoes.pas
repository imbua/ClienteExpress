unit uFuncoes;

interface

uses Forms, System.Classes, Variants, IniFiles, Winapi.Windows, Uni,
  TLhelp32, System.Math, Vcl.StdCtrls, Json, System.SysUtils;

function ListaProcessos: String;
procedure PegaDB(fResp: TMemo; fstr: string);

procedure GetDbinFile(mResp: TMemo; fCmd: string);

Procedure ResetBancoDb(fResp: TMemo);
function Config_DB(fResp: TMemo; var fconection: TUniConnection): Boolean;
procedure logging(fResp: TMemo; fTrace: string);
function Numero(Fnum: Double; FQte: integer; fdec: integer; ftip: string = ''): string;
function StoD_Ex(fdat: string): string;
function DtoS(ADate: TDateTime): string;
function DtoST(ADate: TDateTime): string;
function DtoShifem(ADate: TDateTime): string;
Procedure IncString(Var fInc: String; fstr: String; fOpt: String = ',');

procedure LimparLog;

function StrDeleteAll(S: string; DelChar: char): string;

function ClearString(fstr: string): string;
function LimpaConteudo(fstr: string): string;
function StrZero(Fnum: string; FQte: integer): string;
Function IsIpConfigurado(fIp: String): Boolean;
function SetSlash(fdir: string): string;

function trans(fValor: variant): string;
function val2(fstr: string): Double;

function StringCrc16(AString: AnsiString): word;
procedure GravaINICrypt(INI: TIniFile; Section, Ident, AString, Pass: string);
function LeINICrypt(INI: TIniFile; Section, Ident, Pass: string): string;
function ListarDiretorios(Diretorio: string; Curinga: string): string;
procedure DeletaFiles(fdir: string; fFiles: TStringList; fTudo: Boolean = false);
function FGet_CPF(fstr: string; fOpt: string = ''): string;
function FGet_CNPJ(fstr: string; fOpt: string = ''): string;
function SetS(fstr: string): string;
function SetSD(fstr: string): string;
function BRound(Value: Extended; Decimals: integer; FTrunc: Boolean = false): Extended;
function GetifTem(fmstr: TStringList; flin: integer): string;
function Completa(fstr: string; fqtd: integer): string;
function FCampo_It(fcampo: string): string;

function SetJSUpperValue(fJSValue: TJSONValue; fstr: String): String;
function SetJSValUpperValue(fJSValue: TJSONValue; fstr: String): String;
function SetJSValValue(fJSValue: TJSONValue; fstr: String): String;

Function SetJSStr(fJSValue: TJSONValue; fstr: String): String;
function SetDateJSStr(fJSValue: TJSONValue; fstr: String): String;
Function StrToVal(fVal: String): string;
function StoDIfem(ADate: string): string;
function ExecutaComandoSql(fstr: string): Boolean;
procedure FSistemaBrasileiro;
procedure VerificaSistemaBrasileiro;
function Incrementador(fbanco, fcampo: string): string;
procedure BaixaEstoque(FProduto: string; FServico: string; FQte: Double; FDescricao: string; fTipo: string; fserial: string; fsetor: string;
  fempresa: string; fcodigo: string; fusuario: string; fdata, fHora: string; fisSerial: Boolean);
procedure AtualizaQtProduto(fcod, fsetor: string);
function getQteProd(fcodprod, fsetor: string; fdata: string = ''): Double;
function VeValorUltimaCompra(FProduto, fsetor, fcodcompra: string): Double;
function FCampo_OutDt(fcampo: string): string;
function FCampo_Out(fcampo: string): string;
function Maximo(fQuery, fcod: string): string;
Function TirarAcentos(Texto: string): string;


implementation

uses uModulo, uVar;


Function TirarAcentos(Texto: string): string;

var
  Contar, Posicao: integer;
  Acentos, TiraAcentos: string;
begin
  Acentos := '·‰‡„‚¡ƒ¿√¬ÈÎËÍ…À» ÌÔÏÓÕœÃŒÛˆÚıÙ”÷“’‘˙¸˘˚⁄‹Ÿ€Á«&';
  TiraAcentos := 'aaaaaAAAAAeeeeEEEEiiiiIIIIoooooOOOOOuuuuUUUUcCE';
  result := '';

  For Contar := 1 to Length(Texto) do
  begin

    Posicao := Pos(Copy(Texto, Contar, 1), Acentos);

    If Posicao = 0 then

      result := result + Copy(Texto, Contar, 1)

    else

      result := result + Copy(TiraAcentos, Posicao, 1);

  end;

end;


function Maximo(fQuery, fcod: string): string;
begin

  dmModulo.QueryInc.close;
  dmModulo.QueryInc.SQL.Text := 'select max(' + fcod + ')+1 as maximo from ' + fQuery;
  dmModulo.QueryInc.open;
  result := dmModulo.QueryInc.fieldbyname('maximo').asstring;
  if dmModulo.QueryInc.fieldbyname('maximo').asstring = '' then
    result := '1'

end;

function FCampo_OutDt(fcampo: string): string;
begin
  if dmModulo.cRetiradas.fieldbyname(fcampo).asstring = '' then
    result := 'null'
  else
    result := DtoS(strtodate(dmModulo.cRetiradas.fieldbyname(fcampo).asstring));
end;

function FCampo_Out(fcampo: string): string;
begin
  result := dmModulo.cRetiradas.fieldbyname(fcampo).asstring;
end;

function VeValorUltimaCompra(FProduto, fsetor, fcodcompra: string): Double;
begin
  dmModulo.QueryResult.close;
  dmModulo.QueryResult.SQL.Text := 'select * from ' + _DB.Banco + '.comprasdetalhe,' + _DB.Banco + '.compras where compras.cod="' + fcodcompra +
    '" and   produto="' + FProduto + '" and compras.setor="' + fsetor + '" and comprasdetalhe.cod=compras.cod';
  dmModulo.QueryResult.open;
  result := (val2(dmModulo.QueryResult.fieldbyname('valor').Text));
end;

function getQteProd(fcodprod, fsetor: string; fdata: string = ''): Double;
var
  xData: string;
  xwhere: string;
  xwhere1: string;
  // xSql: string;
  // i:integer;
begin
  // verifica data//
  // quem manda e a contagem!
  // pega todas os seriais do produto;

  if fdata = '  /  /    ' then
    fdata := '';
  // PEGA A ULTIMA CONTAGEM DO PRODUTO
  if fdata <> '' then
    xwhere1 := ' and data<=' + DtoS(strtodate(fdata));

  dmModulo.QueryResult.close;
  dmModulo.QueryResult.SQL.Text := 'SELECT  data   FROM ' + _DB.Banco + '.lancamentoserial where  produto="' + fcodprod + '"  and setor in ("' +
    fsetor +
    '") and descricao="contagem" ' + xwhere1 + ' order by data desc limit 1';
  dmModulo.QueryResult.open;

  // xwhere := ' and ((data=' + xSql + ' and descricao="contagem"))';

  // se existe contagem forumle a data se nao vai a de cristo

  if dmModulo.QueryResult.fieldbyname('data').Text <> '' then
  begin
    xData := DtoS(strtodate(dmModulo.QueryResult.fieldbyname('data').Text));
    xwhere := ' and ((data=' + xData + ' and descricao="contagem") or data>' + xData + ')';
    // atualizaqtproduto(fcodprod,fsetor,'contagem',queryresult.fieldbyname('data').text);
  end
  else
  begin
    xData := '19000101';
    xwhere := ' and 1=1 ';
    // atualizaqtproduto(fcodprod,fsetor,'','');
  end;
  dmModulo.QueryResult.close;
  dmModulo.QueryResult.SQL.Text := 'SELECT  max(data) as data ,sum(if(tipo="E",a.qte,-1*a.qte)) AS Total  FROM ' + _DB.Banco +
    '.lancamentoserial a ' +
    ' where setor in ("' + fsetor + '") ' + xwhere + ' and produto="' + fcodprod + '" ' + xwhere1 + '';
  dmModulo.QueryResult.open;

  _DataContagem := dmModulo.QueryResult.fieldbyname('data').Text;
  result := val2(Numero(val2(dmModulo.QueryResult.fieldbyname('Total').Text), 10, 3));

  // result:=i;
  dmModulo.QueryResult.close;
end;

procedure AtualizaQtProduto(fcod, fsetor: string);
var
  FQte: Double;
  xData: string;
  xCompra, xcompraqte: string;
  xcodcompra: string;
  xcompravalor: string;
begin

  FQte := getQteProd(fcod, fsetor);

  // PEGA A ULTIMA compra DO PRODUTO

  dmModulo.QueryResult.close;
  dmModulo.QueryResult.SQL.Text := 'SELECT  data,sum(qte) as qte,codigo  FROM ' + _DB.Banco + '.lancamentoserial where  produto=' +
    QuotedStr(fcod) +
    '  and setor="' + fsetor + '" and descricao="compra" group by codigo,produto,descricao,data order by data desc limit 1 ';
  dmModulo.QueryResult.open;
  xCompra := '';
  if dmModulo.QueryResult.fieldbyname('data').Text <> '' then
  begin
    xCompra := DtoS(strtodate(dmModulo.QueryResult.fieldbyname('data').Text));
    xcompraqte := trans(val2(dmModulo.QueryResult.fieldbyname('qte').Text));
    xcodcompra := dmModulo.QueryResult.fieldbyname('codigo').Text;
  end;

  dmModulo.QueryResult.close;
  dmModulo.QueryResult.SQL.Text := 'select * from ' + _DB.Banco + '.produtosestoque where  produto=' + QuotedStr(fcod) + ' and setor="' +
    fsetor + '"';
  dmModulo.QueryResult.open;
  if (_DataContagem <> '') and (_DataContagem <> '19000101') then
    xData := DtoS(strtodate(_DataContagem))
  else
    xData := 'null';

  if not dmModulo.QueryResult.isempty then
  begin
    if xCompra <> '' then
    begin
      xcompravalor := trans(VeValorUltimaCompra(fcod, fsetor, xcodcompra));
      ExecutaComandoSql('update ' + _DB.Banco + '.produtosestoque set qte=(' + trans(FQte) + '),compraqte=(' + xcompraqte + '),contagem=' +
        xData +
        ',compra=' + xCompra + ',compravalor=' + xcompravalor + ' where produto=' + QuotedStr(fcod) + ' and setor="' + fsetor + '"')
    end
    else
    begin
      ExecutaComandoSql('update ' + _DB.Banco + '. produtosestoque set qte=(' + trans(FQte) + '),contagem=' + xData + ' where produto=' +
        QuotedStr(fcod) + ' and setor="' + fsetor + '"');
    end;

  end
  else
  begin

    if (xCompra <> '') then
    begin
      xcompravalor := trans(VeValorUltimaCompra(fcod, fsetor, xcodcompra));
      ExecutaComandoSql('insert into ' + _DB.Banco + '.produtosestoque (produto,setor,qte,compraqte,compra,contagem,compravalor) values (' +
        QuotedStr(fcod) + ',"' + fsetor + '",' + trans(FQte) + ',' + xcompraqte + ',' + xCompra + ',' + xData + ',' + xcompravalor + ')')
    end
    else
      ExecutaComandoSql('insert into ' + _DB.Banco + '.produtosestoque (produto,setor,qte,contagem) values (' + QuotedStr(fcod) + ',"' +
        fsetor + '",'
        + trans(FQte) + ',' + xData + ')');
  end;

end;

procedure BaixaEstoque(FProduto: string; FServico: string; FQte: Double; FDescricao: string; fTipo: string;
  fserial: string; fsetor: string; fempresa: string; fcodigo: string; fusuario: string; fdata, fHora: string; fisSerial: Boolean);
var
  xData: String;
  procedure Set_Estoque(fSProd, fSDescricao, fSTipo, fSSetor, fsCodigo: string;
    fSqte:
    Double);
  begin
    ExecutaComandoSql('insert into ' + _DB.Banco + '.lancamentoserial (empresa,setor,data,codigo,produto,qte,' +
      'serial,descricao,tipo,usuario,datahora,remessarquivo) values("' + fempresa + '","' + fSSetor + '",' + DtoS(strtodate(fdata)) + ',' +
      trans(val2(fsCodigo)) + ',"' + fSProd + '","' + trans(fSqte * FQte) + '","' + fserial + '","' + fSDescricao + '","' + fSTipo + '","' + fusuario
      + '",now(),"' + _Remessa + '");');

    AtualizaQtProduto(fSProd, fsetor);
  end;

begin
  xData := fdata;
  if _Hora <> '' then
  begin
    if (_Hora >= '00:00') and (_Hora <= '07:00') then
    begin
      xData := datetostr(strtodate(xData) - 1);
      fdata := xData;
    end;
  end;

  if FServico <> '1' then
  begin
    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.ficha where produto="' + FProduto + '"';
    dmModulo.QueryInt.open;

    if not dmModulo.QueryInt.isempty then
    begin
      // dentro da ficha nao colocar servico
      while not dmModulo.QueryInt.eof do
      begin
        Set_Estoque(dmModulo.QueryInt.fieldbyname('codigo').Text, FDescricao, fTipo, fsetor, fcodigo,
          val2(dmModulo.QueryInt.fieldbyname('qte').Text));
        dmModulo.QueryInt.next;
      end; // ficha
    end
    else
    begin
      if (fserial <> '') and (fTipo = 'S') then
      // somente para saida de mercadorias
      begin
        dmModulo.QueryResult.close;
        dmModulo.QueryResult.SQL.Text := 'select * from ' + _DB.Banco + '.lancamentoserial where serial="' + fserial + '" order by id desc limit 1 ';
        dmModulo.QueryResult.open;
        if not dmModulo.QueryResult.isempty then
        begin
          if dmModulo.QueryResult.fieldbyname('tipo').Text = 'S' then // È da mesma
          begin
            Set_Estoque(FProduto, 'Transferencia', 'E', fsetor, '99990', 1);
          end
          else if dmModulo.QueryResult.fieldbyname('setor').Text <> fsetor then
          // È da mesma
          begin
            Set_Estoque(FProduto, 'Transferencia', 'S', dmModulo.QueryResult.fieldbyname('setor').Text, '99990', 1);
            Set_Estoque(FProduto, 'Transferencia', 'E', fsetor, '99990', 1);

          end;
        end;
      end;
      if (fisSerial and (fserial <> '')) or not fisSerial then
        Set_Estoque(FProduto, FDescricao, fTipo, fsetor, fcodigo, 1);
    end;
  end;
end;

function Incrementador(fbanco, fcampo: string): string;
begin

  if fbanco <> '' then
    fbanco := fbanco + '.';

  dmModulo.QueryInc.SQL.Text := 'lock tables ' + fbanco + 'sequencias WRITE';
  dmModulo.QueryInc.execSql;
  dmModulo.QueryInc.SQL.Text := 'update ' + fbanco + 'sequencias set ' + fcampo + ' = ' + fcampo + '+1';
  dmModulo.QueryInc.execSql;

  dmModulo.QueryInc.close;
  dmModulo.QueryInc.SQL.Text := 'select * from ' + fbanco + 'sequencias';
  dmModulo.QueryInc.open;
  if dmModulo.QueryInc.fieldbyname(fcampo).asstring = '' then
  begin
    dmModulo.QueryInc.edit;
    dmModulo.QueryInc.fieldbyname(fcampo).asstring := '1';
    dmModulo.QueryInc.post;
  end;

  result := dmModulo.QueryInc.fieldbyname(fcampo).asstring;
  dmModulo.QueryInc.close;

  dmModulo.QueryInc.SQL.Text := 'unlock tables ';
  dmModulo.QueryInc.execSql;

end;

procedure VerificaSistemaBrasileiro;
var
  xval: Double;
  i: integer;
begin
  // tenta 20 vezes
  xval := 11.11;
  i := 0;
  while pos(',', floattostr(xval)) <= 0 do
  begin
    FSistemaBrasileiro;
    Sleep(10);
    inc(i);
    if i = 20 then
      break;
  end;
  // Application.ProcessMessages;
end;

procedure FSistemaBrasileiro;
begin
  FormatSettings.shortdateformat := 'dd/mm/yyyy';
  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ThousandSeparator := '.';

end;

function FCampo_It(fcampo: string): string;
begin
  result := dmModulo.cItens.fieldbyname(fcampo).asstring;

end;

function ExecutaComandoSql(fstr: string): Boolean;
begin
  // fica bom isso para o caso de comecar a query e o sistema estar fora do ar....
  VerificaSistemaBrasileiro;
  try

    result := false;
    dmModulo.Querycmd.SQL.clear;

    dmModulo.Querycmd.SQL.Text := fstr;
    dmModulo.Querycmd.Execute;
    result := True;
  except
    on E: Exception do
    begin
      result := false;
      logging(nil, 'Em ' + datetimetostr(now()) + ' Erro ' + E.Message);
    end;
  end;

end;

function SetJSUpperValue(fJSValue: TJSONValue; fstr: String): String;
var
  xstr: String;
begin

  xstr := SetJSStr(fJSValue, ansiUpperCase(fstr));
  result := xstr;
  if xstr = '01/01/1900' then
    result := '';

end;

Function StrToVal(fVal: String): string;
begin
  result := StringReplace(fVal, '.', ',', []);

end;

function SetJSValUpperValue(fJSValue: TJSONValue;
  fstr: String): String;
var
  xstr: String;
begin

  xstr := SetJSStr(fJSValue, ansiUpperCase(fstr));

  result := StrToVal(xstr);

end;

function SetJSValValue(fJSValue: TJSONValue; fstr: String): String;
var
  xstr: String;
begin

  xstr := SetJSStr(fJSValue, fstr);

  result := StrToVal(xstr);

end;

function StoDIfem(ADate: string): string;
var
  xstr: string;
begin
  xstr := ADate;
  result := copy(xstr, 9, 2) + '/' + copy(xstr, 6, 2) + '/' + copy(xstr, 1, 4);

end;

function SetDateJSStr(fJSValue: TJSONValue; fstr: String): String;
var
  xstr: String;
begin

  xstr := SetJSStr(fJSValue, fstr);
  result := xstr;

  if (Length(result) = 10) and (pos('-', xstr) = 5) and (copy(xstr, 8, 1) = '-') then
    result := StoDIfem(xstr);
  if xstr = '01/01/1900' then
    result := '';

end;

Function SetJSStr(fJSValue: TJSONValue; fstr: String): String;
var
  xJsData: String;
begin

  result := '';
  if fstr = '' then
    exit;

  fJSValue.TryGetValue(fstr, xJsData);

  if xJsData <> '' then
  begin
    result := StringReplace(xJsData, '"', '', [rfreplaceall]);
    if xJsData = '01/01/1900' then
      result := '';
    if lowercase(xJsData) = 'null' then
      result := '';
  end;

end;

procedure GetDbinFile(mResp: TMemo; fCmd: string);
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
        begin
          PegaDB(mResp, copy(xtexto[i], 7, 5000));
          break;
        end;
      end;

    Except
      on E: Exception do
        logging(mResp, 'Em ' + datetimetostr(now()) + ' Erro ' + E.Message);

    end;

  finally
    FreeAndNil(xtexto);
  end;
end;

procedure LimparLog;
var
  i: integer;
  xfiles: TStringList;
begin
  try

    xfiles := TStringList.create;
    xfiles.Text := ListarDiretorios(_Dir.Dir + '\log', 'Debug' + _Aplicacao + _DB.DB + '*.log');

    for i := 0 to xfiles.count - 5 do
      DeleteFile(_Dir.Dir + '\log\' + xfiles.Strings[i]);

  finally
    FreeAndNil(xfiles);

  end;

end;

function BRound(Value: Extended; Decimals: integer; FTrunc: Boolean = false): Extended;
var
  Factor, Fraction: Extended;
  // xdec: Extended;
begin
  Factor := IntPower(10, Decimals);
  { if Ftrunc then
    xdec := 0.4
    else
    xdec := 0; }
  { A convers„o para string e depois para float evita
    erros de arredondamentos indesej·veis. }
  Value := strtofloat(floattostr(Value * Factor));
  result := int(Value);
  Fraction := 0;
  if not FTrunc then
    Fraction := Frac(Value);
  if Fraction >= 0.5 then // + xdec then
    result := result + 1
  else if Fraction <= - 0.5 then // - xdec then
    result := result - 1;
  result := result / Factor;
end;

function SetS(fstr: string): string;
begin
  result := StringReplace(fstr, '|', '', [rfreplaceall]);
  result := QuotedStr(result);

end;

function SetSD(fstr: string): string;
var
  xDat: string;
begin
  result := StringReplace(fstr, '|', '', [rfreplaceall]);
  xDat := StringReplace(fstr, '|', '', [rfreplaceall]);
  xDat := StringReplace(xDat, '/', '', [rfreplaceall]);
  if (trim(xDat) = '') then
    result := 'null'
  else
    result := DtoS(strtodate(result));

end;

procedure DeletaFiles(fdir: string; fFiles: TStringList; fTudo: Boolean = false);
var
  xArqDel: array [0 .. 1000] of char;
  j, i: integer;

begin
  j := 5;
  if fTudo then
    j := 1;
  if fTudo or (fFiles.count > 10) then
    for i := fFiles.count - j downto 0 do
    begin
      try
        StrPCopy(xArqDel, fdir + '\' + fFiles.Strings[i]);
        DeleteFile(xArqDel);
      except
        on E: Exception do
        begin
          logging(nil, datetimetostr(now) + ' ERRO: (DeletaFiles) ' + E.Message);
        end;
      end;
    end;
end;

function Completa(fstr: string; fqtd: integer): string;
var
  i: integer;
begin
  fstr := trim(fstr);
  for i := 0 to fqtd - 1 do
    fstr := fstr + ' ';
  fstr := copy(fstr, 1, fqtd);
  result := fstr;
end;

function GetifTem(fmstr: TStringList; flin: integer): string;
begin
  if fmstr.count > flin then
    result := fmstr[flin]
  else
    result := '';
end;

function StrZero(Fnum: string; FQte: integer): string;
var
  xstr: string;
begin
  xstr := Fnum;
  while FQte > Length(xstr) do
    xstr := '0' + xstr;
  result := xstr;
end;

function StrDeleteAll(S: string;
  DelChar: char): string;
begin
  result := StringReplace(S, DelChar, '', [rfreplaceall, rfIgnoreCase]);
end;

function ClearString(fstr: string): string;
begin
  fstr := StrDeleteAll(fstr, '"');
  fstr := StrDeleteAll(fstr, '''');
  fstr := StrDeleteAll(fstr, '*');
  fstr := StrDeleteAll(fstr, '/');
  fstr := StrDeleteAll(fstr, '|');
  fstr := StrDeleteAll(fstr, '\');
  result := fstr;
end;

function LimpaConteudo(fstr: string): string;
begin
  fstr := StrDeleteAll(fstr, ' ');
  fstr := StrDeleteAll(fstr, '.');
  fstr := StrDeleteAll(fstr, '-');
  fstr := StrDeleteAll(fstr, '/');
  fstr := StrDeleteAll(fstr, ',');
  result := fstr;
end;

function FGet_CPF(fstr: string; fOpt: string = ''): string;
begin
  fstr := LimpaConteudo(fstr);
  if Length(fstr) <> 11 then
    fstr := '';
  if fstr = '' then
    result := fOpt
  else
    result := fstr;
end;

function FGet_CNPJ(fstr: string; fOpt: string = ''): string;
begin
  fstr := LimpaConteudo(fstr);
  if Length(fstr) <> 14 then
    fstr := '';
  if fstr = '' then
    result := fOpt
  else
    result := fstr;
end;

{ -----------------------------------------------------------------------------
  Retorna valor de CRC16 de <AString>    http://www.ibrtses.com/delphi/dcrc.html
  ----------------------------------------------------------------------------- }

function StringCrc16(AString: AnsiString): word;

  procedure ByteCrc(Data: byte; var crc: word);
  var
    i: byte;
  begin
    for i := 0 to 7 do
    begin
      if ((Data and $01) xor (crc and $0001) <> 0) then
      begin
        crc := crc shr 1;
        crc := crc xor $A001;
      end
      else
        crc := crc shr 1;

      Data := Data shr 1; // this line is not ELSE and executed anyway.
    end;
  end;

var
  len, i: integer;
begin
  len := Length(AString);
  result := 0;

  for i := 1 to len do
    ByteCrc(ord(AString[i]), result);
end;

function StrCrypt(const AString, StrChave: AnsiString): AnsiString;
var
  i, TamanhoString, pos, PosLetra, TamanhoChave: integer;
  C: AnsiString;
begin
  result := AString;
  TamanhoString := Length(AString);
  TamanhoChave := Length(StrChave);

  for i := 1 to TamanhoString do
  begin
    pos := (i mod TamanhoChave);
    if pos = 0 then
      pos := TamanhoChave;

    PosLetra := ord(result[i]) xor ord(StrChave[pos]);
    if PosLetra = 0 then
      PosLetra := ord(result[i]);

    C := AnsiChar(chr(PosLetra));
    result[i] := C[1];
  end;
end;

function ListarDiretorios(Diretorio: string;
  Curinga: string): string;
var
  F: TSearchRec;
  Ret: integer;
  // xname,xnovoname:Array [0..1000] of char;
  // xf1,xf2,xstr,TempNome: string;
  // TempNome: string;
  xfile: TStringList;

  function TemAtributo(Attr, Val: integer): Boolean;
  begin
    result := Attr and Val = Val;
  end;

begin
  try
    xfile := TStringList.create;
    Ret := FindFirst(Diretorio + '\' + Curinga, faAnyFile, F);
    while Ret = 0 do
    begin
      // se nao for diretorio
      if not TemAtributo(F.Attr, faDirectory) then
      begin
        xfile.Add(F.name);
      end;
      Ret := FindNext(F);
    end;
  finally
    begin
      FindClose(F);
      result := xfile.Text;
      FreeAndNil(xfile);
    end;
  end;
end;

function LeINICrypt(INI: TIniFile; Section, Ident, Pass: string): string;
var
  SStream: TStringStream;
  CryptStr: string;
begin
  SStream := TStringStream.create('');
  try
    INI.ReadBinaryStream(Section, Ident, SStream);
    CryptStr := SStream.DataString;
    result := StrCrypt(CryptStr, Pass);
  finally
    SStream.Free;
  end;
end;

{ ------------------------------------------------------------------------------ }

procedure GravaINICrypt(INI: TIniFile; Section, Ident, AString, Pass: string);
var
  SStream: TStringStream;
  CryptStr: string;
begin
  CryptStr := StrCrypt(AString, Pass);
  SStream := TStringStream.create(CryptStr);
  try
    INI.WriteBinaryStream(Section, Ident, SStream);
  finally
    SStream.Free;
  end;
end;

function Numero(Fnum: Double;
  FQte: integer;
  fdec: integer;
  ftip:
  string = ''): string;
var
  xstr: string;
  xstr1: string;
  i: integer;
begin
  xstr1 := '';
  for i := 0 to fdec - 1 do
    xstr1 := xstr1 + '0';

  if fdec = 0 then
    xstr := formatfloat('####0', Fnum)
  else if ftip = '$' then
    xstr := formatfloat('###,###,###,###,##0.' + xstr1, Fnum)
  else
    xstr := formatfloat('############0.' + xstr1, Fnum);
  while Length(xstr) <= FQte do
    xstr := ' ' + xstr;
  Numero := xstr;
end;

function StoD_Ex(fdat: string): string;
var
  xstr: string;
begin
  xstr := fdat;
  result := copy(xstr, 7, 2) + '/' + copy(xstr, 5, 2) + '/' + copy(xstr, 1, 4);
end;

function DtoS(ADate: TDateTime): string;
begin
  result := FormatDateTime('yyyymmdd', ADate);
end;

function DtoST(ADate: TDateTime): string;
begin
  result := FormatDateTime('yyyymmddhhmmss', ADate);
end;

function DtoShifem(ADate: TDateTime): string;
begin
  result := FormatDateTime('yyyy-mm-dd', ADate);
end;

Procedure IncString(Var fInc: String; fstr: String; fOpt: String = ',');
begin
  if fInc = '' then
    fInc := fstr
  else
    fInc := fInc + ' ' + fOpt + ' ' + fstr;

end;

function HostPorta(fIp: string; ftip: string = ''): string;
var
  xip, xport: string;
  i: integer;
begin
  fIp := StringReplace(fIp, ' ', '', [rfreplaceall]);

  if pos(':', fIp) > 0 then
  begin
    i := pos(':', fIp);
    xip := copy(fIp, 1, i - 1);
    xport := copy(fIp, i + 1, 100);
  end
  else
  begin
    xip := fIp;
    xport := '3306';
  end;
  if ftip = '' then
    result := xip
  else
    result := xport;
end;

function Config_DB(fResp: TMemo; var fconection: TUniConnection): Boolean;
var
  i: integer;
begin
  result := false;

  try
    // Application.ProcessMessages;
    fconection.Disconnect;
    // Application.ProcessMessages;
    Sleep(10);
    fconection.ProviderName := 'MySql';

    fconection.DataBase := _DB.Banco;
    fconection.AutoCommit := True;

    fconection.Server := HostPorta(_DB.Host);
    fconection.Port := strtoint(HostPorta(_DB.Host, '1'));
    fconection.UserName := _DB.Usr;
    fconection.Password := _DB.Pwd;
    fconection.Connected := True;
    result := True;
    begin
      if not DirectoryExists(_Dir.Dir + '\log') then
        ForceDirectories('.\Log');
      dmModulo.monitor.Active := True;
    end;

  except
    on E: Exception do
    begin
      logging(fResp, datetimetostr(now) + ' ERRO: N„o foi possivel conectar com banco de dados' + E.Message);
      Application.terminate;
      Application.ProcessMessages;
    end;

  end;
end;

procedure logging(fResp: TMemo; fTrace: string);
var
  Stream: TFileStream;
  Temp: AnsiString;
  Buffer: PAnsiChar;
  FFileName: string;
begin

  try
    if fResp <> nil then
      fResp.lines.Add(fTrace);

    FFileName := _MonitorFilename;

    if not FileExists(FFileName) then
      Stream := TFileStream.create(FFileName, fmCreate)
    else
      Stream := TFileStream.create(FFileName, fmOpenReadWrite or fmShareDenyWrite);

    Stream.Seek(0, soFromEnd);
    Temp := AnsiString(FormatDateTime('yyyy-mm-dd hh:mm:ss', now()) + '   Conexao:' + fTrace + #13#10);
    Buffer := PAnsiChar(Temp);
    Stream.Write(Buffer^, StrLen(Buffer));
    Stream.Free;
  except
    // Stream.Free;
  end;
  // sleep(60);
end;

function SetSlash(fdir: string): string;
begin
  if copy(fdir, Length(fdir), 1) <> '\' then
    fdir := fdir + '\';
  result := fdir;
end;

Function IsIpConfigurado(fIp: String): Boolean;
var
  xBool: Boolean;
begin
  xBool := True;
  if (HostPorta(fIp) <> dmModulo.Bancocnx.Server) then
    xBool := false;
  if xBool then
    if (StrToIntDef(HostPorta(fIp, '1'), 3306) <> dmModulo.Bancocnx.Port) then
      xBool := false;
  result := xBool;
end;

function trans(fValor: variant): string;
var
  xstr: string;
begin

  if not ((vartype(fValor) = varString) or (vartype(fValor) = varUString)) then
    xstr := floattostr(fValor)
  else
    xstr := fValor;

  if xstr = '' then
    xstr := '0';
  while pos(',', xstr) > 0 do
    xstr[pos(',', xstr)] := '.';
  trans := xstr;
end;

function StrIsNumber(
  const
  S:
  AnsiString): Boolean;
var
  A: integer;
  function CharIsNum(
    const
    C:
    AnsiChar): Boolean;
  begin
    result := (C in ['0' .. '9']) or (C = ',') or (C = '.') or (C = ' ') or (C = '-');
  end;

begin
  if S <> '' then
    if pos('-', trim(S)) > 1 then
    begin
      result := false;
      exit;
    end;

  result := True;
  A := 1;
  while result and (A <= Length(S)) do
  begin
    result := CharIsNum(S[A]);
    inc(A);
  end;
end;

function val2(fstr: string): Double;
var
  i: integer;
  xstr: string;
begin
  if not StrIsNumber(fstr) then
    result := 0
  else
  begin
    fstr := trim(fstr);
    if fstr = '' then
      fstr := '0';
    for i := 1 to Length(fstr) do
      if fstr[i] <> '.' then
        xstr := xstr + fstr[i];
    try
      result := strtofloat(xstr);
    except
      result := 0;
      ;
    end;
  end;
end;




Procedure ResetBancoDb(fResp: TMemo);
begin
  _DB.Usr := 'processaexpress';
  _DB.Pwd := 'processaexpress';

  if (_DB.Host <> '') and not IsIpConfigurado(_DB.Host) then
    Config_DB(fResp, dmModulo.Bancocnx);

end;

procedure PegaDB(fResp: TMemo; fstr: string);
var
  xmemo: TStringList;
begin
  try
    xmemo := TStringList.create;
    xmemo.Text := StringReplace(fstr, '|', #13, [rfreplaceall]);

    _DB.Banco := xmemo.Strings[0];
    _DB.BancoFinan := xmemo.Strings[1];
    ResetBancoDb(fResp);

  finally
    FreeAndNil(xmemo);

  end;
end;

function ListaProcessos: String;
var
  ContinueLoop: Boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  xMStr: TStringList;
begin
  try
    xMStr := TStringList.create;

    FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
    ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
    // congela numa variavel
    while ContinueLoop do // and (not Boolean(Xbool)) do
    begin
      xMStr.Add(floattostr(FProcessEntry32.th32ProcessID));
      ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
    end;
    xMStr.Sort;
    result := xMStr.Text;
  finally

    FreeAndNil(xMStr);
  end;
end;

end.
