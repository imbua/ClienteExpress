unit uArqJson;

interface

uses
  Json, System.Classes, System.SysUtils;
procedure Processa_Compra(fCmd: String);
function DoGravarCompra(fjsProd: TJsonObject): String;
function DoGravarCompraDetalhe(fjsProd: TJsonObject; fCompra: String): Boolean;
Function DoGravarPagarDetalhe(fjsRaiz: TJsonValue; fjsProd: TJSONArray; fCompra: String): Boolean;
Function DoGravarPagar(fjsProd: TJSONArray; fCompra: String): Boolean;
procedure AtualizaValores(fCompra, fEmpresa, fDataEntrega: String);

procedure Processa_VndMobile(fCmd: String);
procedure Processa_ColetorMobile(fCmd: String);

Function DoGravarVndMobile(fjsProd, fjsProdItens, fjsCadastro: TJSONArray; fCmd: String): Boolean;
Function DoGravarDAVMobile(fjsProd, fjsProdItens, fjsCadastro: TJSONArray): Boolean;
Function DoGravarColetorMobile(fjsProdItens: TJSONArray): Boolean;

Procedure doSetMobilePreVenda(fRemessa, fTexto, fFormapgto: String);

implementation

uses uModulo, uMain, uClienteDataSetClass, uFuncoes, uVar;

procedure Processa_Compra(fCmd: String);
var
  jsRaiz, jsProd: TJsonObject;
  jsProdDet: TJSONArray;
  jsProdPagar: TJSONArray;
  xSql: string;
  xisPagar, xisSerial, xBoolFin: Boolean;
  xisBaixaCompra: Boolean;
  xCompra: String;
  xmStr: TStringList;
  xId: string;
begin

  xBoolFin := false;;

  jsRaiz := TJsonObject.create;
  jsRaiz.Parse(TEncoding.ASCII.GetBytes(fCmd), 0);

  jsRaiz.TryGetValue('CMP', jsProd);
  jsProd.TryGetValue('PAGAR', jsProdPagar);

  // if not (jsProd =nil) then

  _DB.Banco := ansilowercase(SetJSUpperValue(jsProd, 'autocom'));
  _DB.BancoFinan := ansilowercase(SetJSUpperValue(jsProd, 'financeiro'));

  dmModulo.QueryInt.close;
  dmModulo.QueryInt.SQL.Text := 'select * from ' + _DB.Banco + '.param where id=1';
  dmModulo.QueryInt.open;

  _Parametro.isCompraAtualizaValorVenda := (dmModulo.QueryInt.fieldbyname('atualizaprecovenda').Text = '1') or
    (dmModulo.QueryInt.fieldbyname('atualizaprecodevendamanual').Text = '1');
  _Parametro.isCompraAtualizaValorCusto := dmModulo.QueryInt.fieldbyname('atualizaPrecoDeCusto').Text = '1';
  _Parametro.isProdutoPrecoSimples := dmModulo.QueryInt.fieldbyname('precosimples').AsString = '1';

  xisPagar := not (jsProdPagar = nil);

  xisBaixaCompra := SetJSUpperValue(jsProd, 'isbaixacompra') = '1';

  xisSerial := SetJSUpperValue(jsProd, 'isserial') = '1';

  // se for serial entao nao baixa a compra
  if xisSerial then
    xisBaixaCompra := false;

  if not xisPagar then
    xisBaixaCompra := false;

  _Parametro.isCompraAtualiza := (_Parametro.isCompraAtualizaValorVenda or _Parametro.isCompraAtualizaValorCusto or _Parametro.isCompraAtualizaValorVendaManual) and xisPagar;

  xId := SetJSUpperValue(jsProd, 'id');

  dmModulo.Query.close;
  dmModulo.Query.SQL.Text := ' select * from  ' + _DB.BancoFinan + '.pagardetalhe where remessarquivo="' + _Remessa + '";';
  dmModulo.Query.open;
  if dmModulo.Query.fieldbyname('pagamento').AsString <> '' then
  begin
    logging(nil, ' ERRO: Arquivo de venda ' + _Remessa + ' já foi recebido no financeiro!');
    xBoolFin := True;

  end;

  xSql := ' DELETE from  ' + _DB.Banco + '.compras where remessarquivo="' + _Remessa + '";';
  xSql := xSql + ' DELETE from  ' + _DB.Banco + '.comprasdetalhe where remessarquivo="' + _Remessa + '";';
  xSql := xSql + ' DELETE from  ' + _DB.Banco + '.lancamentoserial where remessarquivo="' + _Remessa + '";';

  xSql := xSql + ' delete from  ' + _DB.Banco + '.compras where cod="' + xId + '";';
  xSql := xSql + ' delete from  ' + _DB.Banco + '.comprasdetalhe where cod="' + xId + '";';
  xSql := xSql + ' delete from  ' + _DB.Banco + '.lancamentoserial where (descricao="compra" or descricao="compras" ) and codigo="' + xId + '";';

  if not xBoolFin then
  begin
    xSql := xSql + ' DELETE from  ' + _DB.BancoFinan + '.pagar where remessarquivo="' + _Remessa + '";';
    xSql := xSql + ' DELETE from  ' + _DB.BancoFinan + '.pagardetalhe where remessarquivo="' + _Remessa + '";';
  end;

  ExecutaComandoSql(xSql);

  xCompra := DoGravarCompra(jsProd);

  // houve erro
  try
    xmStr := TStringList.create;
    xmStr.Text := fCmd;
    if xCompra = '' then
    begin
      xmStr.SaveToFile(_Dir.Erro + '\' + ExtractFileName(_Remessa));
      ExecutaComandoSql(xSql);

    end
    else
      xmStr.SaveToFile(_Dir.Feito + '\' + ExtractFileName(_Remessa));

    DeleteFile(_Dir.Recebimento + '\' + _Remessa);
  finally
    FreeAndNil(xmStr);
  end;

end;

procedure Processa_VndMobile(fCmd: String);
var
  jsRaiz: TJsonObject;
  jsProdDB, jsProd, jsProdDet, jsProdCadastro: TJSONArray;
  jsPair: TJsonPair;
  xSql: string;
  xisBaixaCompra: Boolean;
  xisCompraOk: Boolean;
  xmStr: TStringList;
  xId: string;
  xOrigem: string;
begin
  xisCompraOk := false;

  jsRaiz := TJsonObject.create;
  jsRaiz := TJsonObject.ParseJSONValue(fCmd) as TJsonObject;


  jsRaiz.TryGetValue('VND_MOBILEDB', jsProdDB);
  jsRaiz.TryGetValue('VND_MOBILE', jsProd);
  jsRaiz. TryGetValue('VNDCLIENTES_MOBILE', jsProdCadastro);
  jsRaiz.TryGetValue('VNDITENS_MOBILE', jsProdDet);


  // if not (jsProd =nil) then

  // logging(nil, jsProdDB.ToString);
  _DB.Banco := SetJSStr(jsProdDB.Items[0], 'autocom');
  _DB.BancoFinan := SetJSStr(jsProdDB.Items[0], 'financeiro');
  xOrigem := SetJSStr(jsProdDB.Items[0], 'origem');

  xId := SetJSUpperValue(jsProd, 'id');
  if xOrigem = 'DAV' then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := ' select * from  ' + _DB.Banco + '.vendastemp where remessarquivo="' + _Remessa + '";';
    dmModulo.Query.open;
    if dmModulo.Query.IsEmpty then
    begin
      // verifica se já foi gravado no servidor
      dmModulo.Query.close;
      dmModulo.Query.SQL.Text := ' select * from  ' + _DB.Banco + '.retirada where remessarquivo="' + _Remessa + '";';
      dmModulo.Query.open;
      if not dmModulo.Query.IsEmpty then
      begin
        logging(nil, ' ERRO: Arquivo  ' + _Remessa + ' já foi baixado!');
        xisCompraOk := false;

      end
      else
      begin

        xSql := ' DELETE from  ' + _DB.Banco + '.vendastemp where remessarquivo="' + _Remessa + '";';
        xSql := ' DELETE from  ' + _DB.Banco + '.retirada where remessarquivo="' + _Remessa + '";';
        xSql := xSql + ' DELETE from  ' + _DB.Banco + '.retiradadetalhe where remessarquivo="' + _Remessa + '";';

        ExecutaComandoSql(xSql);

        xisCompraOk := DoGravarDAVMobile(jsProd, jsProdDet, jsProdCadastro);

      end;
    end;
  end
  else
  begin

    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := ' select * from  ' + _DB.Banco + '.pedidosvndmobile where remessarquivo="' + _Remessa + '";';
    dmModulo.Query.open;
    if dmModulo.Query.findfield('comando') = nil then
    begin
      ExecutaComandoSql('alter table  ' + _DB.Banco + '.pedidosvndmobile add comando text ');
    end;
    if dmModulo.Query.findfield('email') = nil then
    begin
      ExecutaComandoSql('alter table  ' + _DB.Banco + '.pedidosvndmobile add email varchar(100) after cep ');
    end;

    if dmModulo.Query.fieldbyname('liberacao').AsString <> '' then
    begin
      logging(nil, ' ERRO: Arquivo  ' + _Remessa + ' já foi liberado!');
      xisCompraOk := false;
    end
    else
      if dmModulo.Query.fieldbyname('cancelado').AsString <> '' then
    begin
      logging(nil, ' ERRO: Arquivo  ' + _Remessa + ' já foi cancelado!');
      xisCompraOk := false;
    end
    else
      if dmModulo.Query.fieldbyname('baixado').AsString <> '' then
    begin
      logging(nil, ' ERRO: Arquivo  ' + _Remessa + ' já foi baixado!');
      xisCompraOk := false;
    end
    else
    begin

      xSql := ' DELETE from  ' + _DB.Banco + '.pedidosvndmobile where remessarquivo="' + _Remessa + '";';
      xSql := xSql + ' DELETE from  ' + _DB.Banco + '.pedidosvndmobiledetalhe where remessarquivo="' + _Remessa + '";';

      ExecutaComandoSql(xSql);

      xisCompraOk := DoGravarVndMobile(jsProd, jsProdDet, jsProdCadastro, fCmd);

    end;
  end;
  // houve erro
  try
    xmStr := TStringList.create;
    xmStr.Text := fCmd;
    if not xisCompraOk then
    begin
      xmStr.SaveToFile(_Dir.Erro + '\' + ExtractFileName(_Remessa));
      ExecutaComandoSql(xSql);

    end
    else
      xmStr.SaveToFile(_Dir.Feito + '\' + ExtractFileName(_Remessa));

    DeleteFile(_Dir.Recebimento + '\' + _Remessa);
  finally
    FreeAndNil(xmStr);
  end;

end;

procedure Processa_ColetorMobile(fCmd: String);
var
  jsRaiz: TJsonObject;
  jsProdDB, jsProdDet: TJSONArray;
  xSql, xOrigem: string;
  xOk: Boolean;
  xmStr: TStringList;
begin
  xOk := false;

  jsRaiz := TJsonObject.create;
  jsRaiz := TJsonObject.ParseJSONValue(fCmd) as TJsonObject;

  jsRaiz.TryGetValue('COLETOR_MOBILEDB', jsProdDB);
  jsRaiz.TryGetValue('ITENS_MOBILE', jsProdDet);


  // if not (jsProd =nil) then

  // logging(nil, jsProdDB.ToString);
  _DB.Banco := SetJSStr(jsProdDB.Items[0], 'autocom');
  _DB.BancoFinan := SetJSStr(jsProdDB.Items[0], 'financeiro');
  xOrigem := SetJSStr(jsProdDB.Items[0], 'origem');
  if xOrigem = 'COLETOR' then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := ' select * from  ' + _DB.Banco + '.geretiqueta;';
    dmModulo.Query.open;
    if dmModulo.Query.findfield('remessarquivo') = nil then
    begin
      ExecutaComandoSql('Alter table ' + _DB.Banco + '.geretiqueta add remessarquivo varchar(150) default null');
    end;
    xSql := ' DELETE from  ' + _DB.Banco + '.geretiqueta where remessarquivo="' + _Remessa + '";';
    ExecutaComandoSql(xSql);

    xOk := DoGravarColetorMobile(jsProdDet);

  end;
  // houve erro
  try
    xmStr := TStringList.create;
    xmStr.Text := fCmd;
    if not xOk then
    begin
      xmStr.SaveToFile(_Dir.Erro + '\' + ExtractFileName(_Remessa));
      ExecutaComandoSql(xSql);

    end
    else
      xmStr.SaveToFile(_Dir.Feito + '\' + ExtractFileName(_Remessa));

    DeleteFile(_Dir.Recebimento + '\' + _Remessa);
  finally
    FreeAndNil(xmStr);
  end;

end;

Function GetVendedorByUserId(fid: String): String;
begin
  result := '001';
  if fid <> '' then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := ' select cod from  ' + _DB.Banco + '.senhas a, ' + _DB.Banco + '.vendedor b where a.usuario=b.usuario and a.id="' +
      fid + '"';
    dmModulo.Query.open;
    if not dmModulo.Query.IsEmpty then
      result := dmModulo.Query.fieldbyname('cod').AsString;

  end;
end;

Function GetBarrasFromProduto(fid: String): String;
begin
  result := '';
  if fid <> '' then
  begin
    dmModulo.Query.close;
    dmModulo.Query.SQL.Text := ' select barras from  ' + _DB.Banco + '.produtos where cod="' + fid + '"';
    dmModulo.Query.open;
    if not dmModulo.Query.IsEmpty then
      result := dmModulo.Query.fieldbyname('barras').AsString;

  end;
end;

Function DoGravarDAVMobile(fjsProd, fjsProdItens, fjsCadastro: TJSONArray): Boolean;
var
  xHeader, xCmd: String;
  i, j: Integer;
  xFormaPgto: string;
begin
  TRY
    result := false;
    FSistemaBrasileiro;
    CDSClass.CriaRetiradas;
    CDSClass.CriaCadastro;
    CDSClass.CriaPagamento;

    // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);

    // Get_Campos(fCmd);
    for i := 0 to fjsProd.Count - 1 do
    begin
      xHeader := '00050|';
      xHeader := xHeader + SetJSStr(fjsProd.Items[i], 'datapedido') + '|';
      xHeader := xHeader + '00001|'; // empresa
      xHeader := xHeader + '00001|'; // setor
      xHeader := xHeader + '888|'; // caixa mobile sempre vai ser 888
      xHeader := xHeader + GetVendedorByUserId(SetJSStr(fjsProd.Items[i], 'idvendedor')) + '|';
      xHeader := xHeader + SetJSStr(fjsProd.Items[i], 'nomevendedor') + '|';
      xHeader := xHeader + SetJSStr(fjsProd.Items[i], 'id') + '|';
      xHeader := xHeader + SetJSStr(fjsProd.Items[i], 'idcliente') + '|'; // cpfcnpj
      xHeader := xHeader + 'PRE-VENDA|'; // cpfcnpj
      xFormaPgto := SetJSStr(fjsProd.Items[i], 'formapgto');
      break;
    end;
    xCmd := '';
    for i := 0 to fjsProdItens.Count - 1 do
    begin
      xCmd := xCmd + xHeader;
      xCmd := xCmd + SetJSStr(fjsProdItens.Items[i], 'idproduto') + '|';
      xCmd := xCmd + SetJSValValue(fjsProdItens.Items[i], 'qtde') + '|';
      xCmd := xCmd + SetJSValValue(fjsProdItens.Items[i], 'valor') + '|';
      xCmd := xCmd + '|'; // id_cancelado (obsoleto aqui)
      xCmd := xCmd + SetJSValValue(fjsProdItens.Items[i], 'valor') + '|';
      xCmd := xCmd + '|'; // categoria
      xCmd := xCmd + '0|'; // desconto
      xCmd := xCmd + SetJSStr(fjsProdItens.Items[i], 'observacao') + '|'; // obs
      xCmd := xCmd + '|'; // obs linhas
      xCmd := xCmd + '|'; // valor do rt ou placa
      xCmd := xCmd + 'RT|'; // tipo rt ou placa
      xCmd := xCmd + GetBarrasFromProduto(SetJSValValue(fjsProdItens.Items[i], 'idproduto')) + '|';
      xCmd := xCmd + '|'; // Executor
      xCmd := xCmd + '0|'; // desconto item
      xCmd := xCmd + '|' + #13; // fator e pula linha
    end;

    for i := 0 to fjsCadastro.Count - 1 do
    begin
      xCmd := xCmd + '99999|';
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'id') + '|';
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'nome') + '|';
      xCmd := xCmd + '|'; // sexo
      xCmd := xCmd + '|'; // email
      xCmd := xCmd + '|'; // nasc
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'telefone') + '|';
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'endereco') + '|';
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'cidade') + '|';
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'cep') + '|';
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'uf') + '|';
      xCmd := xCmd + SetJSStr(fjsCadastro.Items[i], 'bairro') + '|';
      xCmd := xCmd + '|'; // senha
      xCmd := xCmd + '|'; // enviar correspo
      xCmd := xCmd + '|'; // inscr
      xCmd := xCmd + '|' + #13; // fator e pula linha
      break;
    end;

    if xCmd <> '' then
    begin
      frmMain.Get_Campos(xCmd);
      frmMain.Processa_Retiradas('');
      if not dmModulo.cRetiradas.IsEmpty then
      begin
        doSetMobilePreVenda(_Remessa, xCmd, xFormaPgto);
      end;
      result := True;
    end;

  Except
    on e: Exception do
      logging(nil, ' ERRO: Arquivo de pedidosDav ' + _Remessa + ':' + e.message);

  END;
end;

Function DoGravarColetorMobile(fjsProdItens: TJSONArray): Boolean;
var
  xProd, xQte, xSerial: String;
  i, j: Integer;
begin
  TRY
    result := false;
    FSistemaBrasileiro;

    // Pega as linhas e separa em campos no DB (vendas,vendasdetalhe,vendasrecdo);

    // Get_Campos(fCmd);

    for i := 0 to fjsProdItens.Count - 1 do
    begin

      xProd := SetJSStr(fjsProdItens.Items[i], 'id');
      xQte := SetJSStr(fjsProdItens.Items[i], 'qte');
      xSerial := '';
      ExecutaComandoSql('insert into  ' + _DB.Banco + '.geretiqueta (maquina,produto,qte,serial,remessarquivo) values ' +
        '("888","' + xProd + '",' + xQte + ',"' + xSerial + '","' + _Remessa + '")');
    end;
    result := True;

  Except
    on e: Exception do
      logging(nil, ' ERRO: Arquivo de coletor ' + _Remessa + ':' + e.message);

  end;
end;

Procedure doSetMobilePreVenda(fRemessa, fTexto, fFormapgto: String);
var
  xVenda: string;
  xItem: string;
  xval: Double;
  xEmpresa: String;
  xCpfCnpj: string;
begin

  ExecutaComandoSql(' delete from ' + _DB.Banco + '.vendastemp where remessarquivo ="' + fRemessa + '"');
  if not dmModulo.cRetiradas.IsEmpty then
  begin

    dmModulo.cRetiradas.first;
    xVenda := Incrementador(_DB.Banco, 'atend');
    while not dmModulo.cRetiradas.eof do
    begin
      // xItem := Maximo('vendastemp', 'item');

      if xVenda = '' then
        xVenda := 'null';
      xItem := Maximo(_DB.Banco + '.vendastemp', 'item');
      xCpfCnpj := _Cliente.cpf;
      if xCpfCnpj = '' then
        xCpfCnpj := _Cliente.cnpj;

      ExecutaComandoSql('insert into  ' + _DB.Banco + '.vendastemp (item,caixa,venda,tipo,nome,cpfcnpj,empresa,setor,vendedor,' +
        ' vendedor1,entrega,data,hora,produto,desconto,valor,valorprod,qte,tributo,executor1,' +
        ' pagamento,cadastro,remessarquivo)' +
        ' values (' + xItem + ',"' + FCampo_Out('caixa') + '","' + xVenda + '","PRE-VENDA","' +
        _Cliente.nome + '","' +
        xCpfCnpj + '","' +
        FCampo_Out('empresa') + '","' + FCampo_Out('setor') + '","' + FCampo_Out('vendedor') + '","' +
        FCampo_Out('vendedor') + '",' +
        'null,' + // entrega
        FCampo_OutDt('data') + ',"' +
        _Hora + '","' + // emissao e hora
        FCampo_Out('produto') + '",' +

        trans(val2(FCampo_Out('desconto_item'))) + ',' + // desconto
        trans(val2(FCampo_Out('valor'))) + ',' +
        trans(val2(FCampo_Out('valorprod'))) + ',' +
        trans(val2(FCampo_Out('qte'))) + ',"' +
        '0","' + // tributo
        FCampo_Out('executor') + '","' +
        fFormapgto + '",' +
        QuotedStr(fTexto) + ',"' +
        fRemessa + '")'); // *val2(valor.text)*val2(qte.text)

      dmModulo.cRetiradas.next;
    end;
    ExecutaComandoSql(' update  ' + _DB.Banco + '.vendastemp a,  ' + _DB.Banco +
      '.produtos b  set a.barras=b.barras, a.descricao=b.descricao,' +
      ' a.unidade=b.unidade,a.tributo=b.tributo where a.produto=b.cod and a.remessarquivo="' + fRemessa + '"');

    // sempre vai entrar aqui!
    ExecutaComandoSql(' delete from ' + _DB.Banco + '.pendencia where empresa="' + xEmpresa + '" and venda =(' + xVenda + ');');
    ExecutaComandoSql(' insert into ' + _DB.Banco + '.pendencia (empresa,venda) values ("' + xEmpresa + '",' + xVenda + ');');
  end;

end;

Function DoGravarVndMobile(fjsProd, fjsProdItens, fjsCadastro: TJSONArray; fCmd: String): Boolean;
var
  xSql: String;
  i, j: Integer;
  xAtacado: Double;
  xQte: Double;
  xValor: Double;
  xQteAtacado: Double;
begin
  TRY
    result := false;
    for i := 0 to fjsProd.Count - 1 do
    begin
      xSql := 'insert into ' + _DB.Banco + '.pedidosvndmobile (';
      xSql := xSql + 'pedido,';
      xSql := xSql + 'usuario,';
      xSql := xSql + 'usuarionome,';
      xSql := xSql + 'data,';
      xSql := xSql + 'cliente,';
      xSql := xSql + 'nome,';
      xSql := xSql + 'fantasia,';
      xSql := xSql + 'endereco,';
      xSql := xSql + 'bairro,';
      xSql := xSql + 'cidade,';
      xSql := xSql + 'uf,';
      xSql := xSql + 'cep,';
      xSql := xSql + 'email,';

      xSql := xSql + 'telefone,';
      xSql := xSql + 'observacao,';
      xSql := xSql + 'status,';
      xSql := xSql + 'formapgto,';
      xSql := xSql + 'comando,';
      xSql := xSql + 'remessarquivo)';
      xSql := xSql + ' Values (';

      xSql := xSql + ':pedido,';
      xSql := xSql + ':usuario,';
      xSql := xSql + ':usuarionome,';
      xSql := xSql + ':data,';
      xSql := xSql + ':cliente,';
      xSql := xSql + ':nome,';
      xSql := xSql + ':fantasia,';
      xSql := xSql + ':endereco,';
      xSql := xSql + ':bairro,';
      xSql := xSql + ':cidade,';
      xSql := xSql + ':uf,';
      xSql := xSql + ':cep,';
      xSql := xSql + ':email,';
      xSql := xSql + ':telefone,';
      xSql := xSql + ':observacao,';
      xSql := xSql + ':status,';
      xSql := xSql + ':formapgto,';
      xSql := xSql + ':comando,';
      xSql := xSql + ':remessarquivo)';
      dmModulo.QueryInt.Params.clear;
      dmModulo.QueryInt.SQL.Text := xSql;
      dmModulo.QueryInt.ParamByName('pedido').AsString := SetJSStr(fjsProd.Items[i], 'id');
      dmModulo.QueryInt.ParamByName('usuario').AsString := SetJSStr(fjsProd.Items[i], 'idvendedor');
      dmModulo.QueryInt.ParamByName('usuarionome').AsString := SetJSStr(fjsProd.Items[i], 'nomevendedor');
      dmModulo.QueryInt.ParamByName('cliente').AsString := SetJSStr(fjsProd.Items[i], 'idcliente');
      dmModulo.QueryInt.ParamByName('status').AsString := '0';
      dmModulo.QueryInt.ParamByName('observacao').AsString := SetJSStr(fjsProd.Items[i], 'observacao');
      dmModulo.QueryInt.ParamByName('data').AsString := dtos(StrToDate(SetJSStr(fjsProd.Items[i], 'datapedido')));
      dmModulo.QueryInt.ParamByName('comando').AsString := fCmd;
      dmModulo.QueryInt.ParamByName('formapgto').AsString := SetJSStr(fjsProd.Items[i], 'formapgto');
      dmModulo.QueryInt.ParamByName('remessarquivo').AsString := _Remessa;
      for j := 0 to fjsCadastro.Count - 1 do
      // if dmModulo.QueryInt.ParamByName('cliente').AsString = SetJSStr(fjsCadastro.Items[j], 'id') then
      begin
        dmModulo.QueryInt.ParamByName('nome').AsString := SetJSStr(fjsCadastro.Items[j], 'nome');
        dmModulo.QueryInt.ParamByName('fantasia').AsString := SetJSStr(fjsCadastro.Items[j], 'fantasia');
        dmModulo.QueryInt.ParamByName('endereco').AsString := SetJSStr(fjsCadastro.Items[j], 'endereco');
        dmModulo.QueryInt.ParamByName('bairro').AsString := SetJSStr(fjsCadastro.Items[j], 'bairro');
        dmModulo.QueryInt.ParamByName('cidade').AsString := SetJSStr(fjsCadastro.Items[j], 'cidade');
        dmModulo.QueryInt.ParamByName('uf').AsString := SetJSStr(fjsCadastro.Items[j], 'uf');
        dmModulo.QueryInt.ParamByName('cep').AsString := LimpaConteudo(SetJSStr(fjsCadastro.Items[j], 'cep'));
        dmModulo.QueryInt.ParamByName('email').AsString := SetJSStr(fjsCadastro.Items[j], 'email');

        dmModulo.QueryInt.ParamByName('telefone').AsString := copy(SetJSStr(fjsCadastro.Items[j], 'telefone'), 1, 20);
        break;

      end;
      dmModulo.QueryInt.execSql;
    end;

    try
      for i := 0 to fjsProdItens.Count - 1 do
      begin
        xSql := 'INSERT INTO ' + _DB.Banco + '.pedidosvndmobiledetalhe(';
        xSql := xSql + 'pedido,';
        xSql := xSql + 'produto,';
        xSql := xSql + 'qte,';
        xSql := xSql + 'valor,';
        xSql := xSql + 'qteoriginal,';
        xSql := xSql + 'valororiginal,';
        xSql := xSql + 'remessarquivo)';

        xSql := xSql + ' values (:pedido,';
        xSql := xSql + ':produto,';
        xSql := xSql + ':qte,';
        xSql := xSql + ':valor,';
        xSql := xSql + ':qte,';
        xSql := xSql + ':valor,';
        xSql := xSql + ':remessarquivo);';

        dmModulo.QueryInt.Params.clear;
        dmModulo.QueryInt.SQL.Text := xSql;

        xQteAtacado := val2(SetJSValValue(fjsProdItens.Items[i], 'qteminatacado'));
        xQte := val2(SetJSValValue(fjsProdItens.Items[i], 'qtde'));
        if xQte >= xQteAtacado then
          xValor := val2(SetJSValValue(fjsProdItens.Items[i], 'atacado'))
        else
          xValor := val2(SetJSValValue(fjsProdItens.Items[i], 'valor'));
        if xValor = 0 then
          xValor := val2(SetJSValValue(fjsProdItens.Items[i], 'valor'));

        dmModulo.QueryInt.ParamByName('pedido').AsString := SetJSStr(fjsProdItens.Items[i], 'idpedido');
        dmModulo.QueryInt.ParamByName('produto').AsString := SetJSStr(fjsProdItens.Items[i], 'idproduto');
        dmModulo.QueryInt.ParamByName('qte').asFloat := val2(SetJSValValue(fjsProdItens.Items[i], 'qtde'));
        dmModulo.QueryInt.ParamByName('valor').asFloat := xValor;
        dmModulo.QueryInt.ParamByName('remessarquivo').AsString := _Remessa;
        dmModulo.QueryInt.execSql;
      end;

      result := True;
    Except
      on e: Exception do
        logging(nil, ' ERRO: Arquivo de pedidosvndmobiledetalhe ' + _Remessa + ':' + e.message);

    end;

  EXCEPT
    on e: Exception do
      logging(nil, ' ERRO: Arquivo de pedidosvnd ' + _Remessa + ':' + e.message);

  END;
end;

Function DoGravarCompra(fjsProd: TJsonObject): String;
var
  xSql: String;
  jsProdDetalhe, jsProdPagar: TJSONArray;
  xisPagar, xisBaixaCompra, xisSerial, xBoolFin: Boolean;
  xId: string;
  i: Integer;
  xCpf: string;
  xCnpj: string;
  xNf: string;
  xEmpresa, xDataEntrega: String;
begin
  TRY

    fjsProd.TryGetValue('PAGAR', jsProdPagar);

    xisPagar := not (jsProdPagar = nil);

    xisBaixaCompra := SetJSUpperValue(fjsProd, 'isbaixacompra') = '1';
    xisSerial := SetJSUpperValue(fjsProd, 'isserial') = '1';

    if not xisPagar or xisSerial then
      xisBaixaCompra := false;

    if Length(SetJSUpperValue(fjsProd, 'cpfcnpj')) = 11 then
      xCpf := SetJSUpperValue(fjsProd, 'cpfcnpj')
    else
      xCnpj := SetJSUpperValue(fjsProd, 'cpfcnpj');
    xId := SetJSUpperValue(fjsProd, 'id');

    xDataEntrega := SetJSUpperValue(fjsProd, 'DATAENTREGA');
    xEmpresa := SetJSUpperValue(fjsProd, 'empresa');
    xSql := 'insert into ' + _DB.Banco + '.compras (';
    xSql := xSql + 'cod,';
    xSql := xSql + 'caixa,';
    xSql := xSql + 'empresa,';
    xSql := xSql + 'setor,';
    xSql := xSql + 'funcionario,';

    xSql := xSql + 'data,';
    xSql := xSql + 'emissao,';
    xSql := xSql + 'dataentrega,';
    xSql := xSql + 'fornecedor,';
    xSql := xSql + 'cpf,';
    xSql := xSql + 'cnpj,';
    xSql := xSql + 'vendedor,';
    xSql := xSql + 'requisicao,';
    xSql := xSql + 'concluido,';
    xSql := xSql + 'valor,';
    if (xisPagar) then
    begin
      xSql := xSql + 'nf,';
      xSql := xSql + 'unidade,';
      xSql := xSql + 'referencia,';
      xSql := xSql + 'obs,';
      xSql := xSql + 'localentrega,';
    end;
    if (xisBaixaCompra) then
      xSql := xSql + 'baixado,';
    xSql := xSql + 'remessarquivo,';
    xSql := xSql + 'formapgto) ';
    xSql := xSql + 'Values (';

    xSql := xSql + ':cod,';
    xSql := xSql + ':caixa,';
    xSql := xSql + ':empresa,';
    xSql := xSql + ':setor,';
    xSql := xSql + ':funcionario,';
    xSql := xSql + ':data,';
    xSql := xSql + ':emissao,';
    xSql := xSql + ':dataentrega,';
    xSql := xSql + ':fornecedor,';
    xSql := xSql + ':cpf,';
    xSql := xSql + ':cnpj,';
    xSql := xSql + ':vendedor,';
    xSql := xSql + ':requisicao,';
    xSql := xSql + ':concluido,';
    xSql := xSql + ':valor,';
    if (xisPagar) then
    begin
      xSql := xSql + ':nf,';
      xSql := xSql + ':unidade,';
      xSql := xSql + ':referencia,';
      xSql := xSql + ':obs,';
      xSql := xSql + ':localentrega,';
    end;
    if xisBaixaCompra then
      xSql := xSql + 'now(),';
    xSql := xSql + ':remessarquivo,';
    xSql := xSql + ':formapgto); ';

    dmModulo.QueryInt.Params.clear;
    dmModulo.QueryInt.SQL.Text := xSql;
    dmModulo.QueryInt.ParamByName('cod').AsString := xId;
    dmModulo.QueryInt.ParamByName('caixa').AsString := Trim(SetJSUpperValue(fjsProd, 'caixa'));
    dmModulo.QueryInt.ParamByName('empresa').AsString := SetJSUpperValue(fjsProd, 'empresa');
    dmModulo.QueryInt.ParamByName('setor').AsString := Trim(SetJSUpperValue(fjsProd, 'setor'));
    dmModulo.QueryInt.ParamByName('funcionario').AsString := SetJSUpperValue(fjsProd, 'funcionario');
    dmModulo.QueryInt.ParamByName('data').AsString := SetJSUpperValue(fjsProd, 'DATA');
    dmModulo.QueryInt.ParamByName('emissao').AsString := SetJSUpperValue(fjsProd, 'EMISSAO');
    dmModulo.QueryInt.ParamByName('dataentrega').AsString := SetJSUpperValue(fjsProd, 'DATAENTREGA');
    dmModulo.QueryInt.ParamByName('fornecedor').AsString := SetJSUpperValue(fjsProd, 'fornecedor');
    dmModulo.QueryInt.ParamByName('cpf').AsString := xCpf;
    dmModulo.QueryInt.ParamByName('cnpj').AsString := xCnpj;
    dmModulo.QueryInt.ParamByName('vendedor').AsString := SetJSUpperValue(fjsProd, 'comprador');
    dmModulo.QueryInt.ParamByName('concluido').AsString := SetJSUpperValue(fjsProd, 'concluido');
    dmModulo.QueryInt.ParamByName('valor').asFloat := val2(SetJSUpperValue(fjsProd, 'valor'));
    dmModulo.QueryInt.ParamByName('remessarquivo').AsString := _Remessa;
    dmModulo.QueryInt.ParamByName('formapgto').AsString := SetJSUpperValue(fjsProd, 'formapgto');
    if xisPagar then
    begin
      dmModulo.QueryInt.ParamByName('nf').AsString := SetJSUpperValue(fjsProd, 'nf');
      dmModulo.QueryInt.ParamByName('unidade').AsString := SetJSUpperValue(jsProdPagar, 'unidade');
      dmModulo.QueryInt.ParamByName('referencia').AsString := SetJSUpperValue(jsProdPagar, 'referencia');
      dmModulo.QueryInt.ParamByName('obs').AsString := SetJSUpperValue(jsProdPagar, 'obs');
      dmModulo.QueryInt.ParamByName('localentrega').AsString := SetJSUpperValue(jsProdPagar, 'localentrega');
    end;
    dmModulo.QueryInt.execSql;

    if not DoGravarCompraDetalhe(fjsProd, xId) then
      Exit;

    if xisPagar then
    begin
      if not DoGravarPagar(jsProdPagar, xId) then
        Exit;

    end;

    if not xisSerial and xisBaixaCompra then
    begin
      fjsProd.TryGetValue('COMPRADETALHE', jsProdDetalhe);
      for i := 0 to jsProdDetalhe.Count - 1 do
      begin
        BaixaEstoque(SetJSUpperValue(jsProdDetalhe.Items[i], 'produto'),
          '0', val2(SetJSUpperValue(jsProdDetalhe.Items[i], 'qte')),
          'Compra', 'E', '',
          SetJSUpperValue(fjsProd, 'setor'),
          SetJSUpperValue(fjsProd, 'empresa'), xId,
          SetJSUpperValue(fjsProd, 'funcionario'), SetDateJSStr(fjsProd, 'DATA'), _Hora, false);

      end;

    end;
    // foi para o financeiro entao atualiza os precos
    if xisPagar then
    begin
      AtualizaValores(xId, xEmpresa, xDataEntrega);

    end;

    result := xId;

  EXCEPT
    on e: Exception do
      logging(nil, ' ERRO: Arquivo de compra ' + _Remessa + ':' + e.message);

  END;
end;

procedure AtualizaValores(fCompra, fEmpresa, fDataEntrega: String);
var
  xValor, xValorVenda, xCusto, xPerc, xval: Extended;
  xCampo: String;
  xSql: string;
  Procedure SetCampo(fCampo, fConteudo: String);
  begin
    dmModulo.QueryInt.fieldbyname(fCampo).AsString := fConteudo;
  end;

begin

  // if Funcoes.Finder(fQueryInt, 'produtos', ['cod'], ['"' + fQuery.fieldbyname('produto').AsString + '"']) then
  // begin
  //
  // xCusto := Funcoes.Val2(fQuery.fieldbyname('valor').Text);
  // xValorVenda := Funcoes.Val2(fQuery.fieldbyname('vrVenda').Text);
  // xValor := 0;
  if not _Parametro.isCompraAtualiza then
    Exit;

  incString(xCampo, 'a.custoextra=b.custoextra,a.atacado=b.vratacado,a.custo_carreto=b.custonf,a.ultimaalteracao=now()');
  if fDataEntrega <> '' then
  begin
    incString(xCampo, 'a.data_ultima_compra="' + fDataEntrega + '"');
  end;

  if _Parametro.isCompraAtualizaValorVenda then // atualiza por markup
  begin
    incString(xCampo, 'a.valor=b.vrvenda');

  end;

  if _Parametro.isCompraAtualizaValorCusto then // atualiza por markup
  begin
    incString(xCampo, 'a.custo=b.valor');

  end;

  xSql := 'update  ' + _DB.Banco + '.produtos a,  ' + _DB.Banco + '.comprasdetalhe b set ' + xCampo;
  xSql := xSql + '  where  a.cod=b.produto and b.cod=' + fCompra + ';';

  xCampo := '';

  if _Parametro.isCompraAtualizaValorVenda then // atualiza por markup
  begin
    incString(xCampo, 'a.valor=b.vrvenda');

  end;
  if _Parametro.isCompraAtualizaValorCusto then // atualiza por markup
  begin
    incString(xCampo, 'a.custo=b.valor');

  end;

  if _Parametro.isCompraAtualiza then
    if not _Parametro.isProdutoPrecoSimples then
      xSql := xSql + 'update   ' + _DB.Banco + '.empresap a,' + _DB.Banco + ' .comprasdetalhe b ' +
        'set  ' + xCampo +
        ' where a.produto=b.produto and a.empresa="' +
        fEmpresa + '";'
    else
      xSql := xSql + 'update   ' + _DB.Banco + '.empresap a,' + _DB.Banco + ' .comprasdetalhe b ' +
        'set  a.custo=0,a.valor=0 ' +
        ' where a.produto=b.produto and a.empresa="' + fEmpresa + '";';

  ExecutaComandoSql(xSql);

end;

Function DoGravarCompraDetalhe(fjsProd: TJsonObject; fCompra: String): Boolean;
var
  i: Integer;
  xSql: String;
  jsProdDetalhe: TJSONArray;
begin
  result := false;
  try
    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.clear;

    fjsProd.TryGetValue('COMPRADETALHE', jsProdDetalhe);
    for i := 0 to jsProdDetalhe.Count - 1 do
    begin
      xSql := 'INSERT INTO ' + _DB.Banco + '.comprasdetalhe(';
      xSql := xSql + 'cod,';
      xSql := xSql + 'produto,';
      xSql := xSql + 'qte,';
      xSql := xSql + 'valor,';
      xSql := xSql + 'custonf,';
      xSql := xSql + 'custoextra,';
      xSql := xSql + 'volume,';
      xSql := xSql + 'vrvolume,';
      xSql := xSql + 'qtevolume,';
      xSql := xSql + 'vratacado,';
      xSql := xSql + 'vrvenda,';
      xSql := xSql + 'vrvendaant,';
      xSql := xSql + 'unidadevolume,';
      xSql := xSql + 'unidade,';
      xSql := xSql + 'tributo,';
      xSql := xSql + 'remessarquivo)';

      xSql := xSql + ' values (:cod,';
      xSql := xSql + ':produto,';
      xSql := xSql + ':qte,';
      xSql := xSql + ':valor,';
      xSql := xSql + ':custonf,';
      xSql := xSql + ':custoextra,';
      xSql := xSql + ':volume,';
      xSql := xSql + ':vrvolume,';
      xSql := xSql + ':qtevolume,';
      xSql := xSql + ':vratacado,';
      xSql := xSql + ':vrvenda,';
      xSql := xSql + ':vrvendaant,';
      xSql := xSql + ':unidadevolume,';
      xSql := xSql + ':unidade,';
      xSql := xSql + ':tributo,';
      xSql := xSql + ':remessarquivo);';

      dmModulo.QueryInt.Params.clear;
      dmModulo.QueryInt.SQL.Text := xSql;

      dmModulo.QueryInt.ParamByName('cod').AsString := fCompra;
      dmModulo.QueryInt.ParamByName('produto').AsString := SetJSUpperValue(jsProdDetalhe.Items[i], 'produto');
      dmModulo.QueryInt.ParamByName('qte').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'qte'));
      dmModulo.QueryInt.ParamByName('valor').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'vrunit'));
      dmModulo.QueryInt.ParamByName('custonf').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'custonf'));
      dmModulo.QueryInt.ParamByName('custoextra').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'custoextra'));
      dmModulo.QueryInt.ParamByName('volume').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'volume'));
      dmModulo.QueryInt.ParamByName('vrvolume').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'vrvolume'));
      dmModulo.QueryInt.ParamByName('qtevolume').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'qtevolume'));
      dmModulo.QueryInt.ParamByName('vratacado').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'vratacado'));
      dmModulo.QueryInt.ParamByName('vrvenda').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'vrvenda'));
      dmModulo.QueryInt.ParamByName('vrvendaant').asFloat := val2(SetJSValUpperValue(jsProdDetalhe.Items[i], 'vrvendaant'));
      dmModulo.QueryInt.ParamByName('unidadevolume').AsString := SetJSUpperValue(jsProdDetalhe.Items[i], 'unidadevolume');
      dmModulo.QueryInt.ParamByName('unidade').AsString := SetJSUpperValue(jsProdDetalhe.Items[i], 'unidade');
      dmModulo.QueryInt.ParamByName('tributo').AsString := Trim(SetJSUpperValue(jsProdDetalhe.Items[i], 'tributo'));
      dmModulo.QueryInt.ParamByName('remessarquivo').AsString := _Remessa;
      dmModulo.QueryInt.execSql;
    end;

    result := True;
  Except
    on e: Exception do
      logging(nil, ' ERRO: Arquivo de compradetalhe ' + _Remessa + ':' + e.message);

  end;

end;

Function DoGravarPagar(fjsProd: TJSONArray; fCompra: String): Boolean;
var
  i: Integer;
  xId, xSql: String;
  jsProdDetalhe: TJSONArray;
  xCpf: String;
  xCnpj: String;
  xemissao: string;
begin
  result := false;
  try
    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.clear;

    for i := 0 to fjsProd.Count - 1 do
    begin

      fjsProd.Items[i].TryGetValue('PAGARDETALHE', jsProdDetalhe);

      xSql := 'INSERT INTO ' + _DB.BancoFinan + '.pagar(';
      xSql := xSql + 'id,';
      xSql := xSql + 'doc,';
      xSql := xSql + 'oc,';
      xSql := xSql + 'conta,';
      xSql := xSql + 'emissao,';
      xSql := xSql + 'digitacao,';
      xSql := xSql + 'fornecedor,';
      xSql := xSql + 'nome,';
      xSql := xSql + 'cpf,';
      xSql := xSql + 'cnpj,';
      xSql := xSql + 'empresa,';
      xSql := xSql + 'setor,';
      xSql := xSql + 'valor,';
      xSql := xSql + 'obs,';
      xSql := xSql + 'unidade,';
      xSql := xSql + 'referencia,';
      xSql := xSql + 'remessarquivo)';

      xSql := xSql + ' values (:id,';
      xSql := xSql + ':doc,';
      xSql := xSql + ':oc,';
      xSql := xSql + ':conta,';
      xSql := xSql + ':emissao,';
      xSql := xSql + 'now(),';
      xSql := xSql + ':fornecedor,';
      xSql := xSql + ':nome,';
      xSql := xSql + ':cpf,';
      xSql := xSql + ':cnpj,';
      xSql := xSql + ':empresa,';
      xSql := xSql + ':setor,';
      xSql := xSql + ':valor,';
      xSql := xSql + ':obs,';
      xSql := xSql + ':unidade,';
      xSql := xSql + ':referencia,';
      xSql := xSql + ':remessarquivo)';

      xemissao := SetJSUpperValue(fjsProd.Items[i], 'EMISSAO');
      if pos('/', xemissao) > 0 then
        xemissao := DtosHifem(StrToDate(xemissao));

      if Length(SetJSUpperValue(fjsProd.Items[i], 'cpfcnpj')) = 11 then
        xCpf := SetJSUpperValue(fjsProd.Items[i], 'cpfcnpj')
      else
        xCnpj := SetJSUpperValue(fjsProd.Items[i], 'cpfcnpj');

      xId := Incrementador(_DB.BancoFinan, 'pagar');
      dmModulo.QueryInt.close;
      dmModulo.QueryInt.Params.clear;
      dmModulo.QueryInt.SQL.Text := xSql;
      dmModulo.QueryInt.ParamByName('id').AsString := xId;

      dmModulo.QueryInt.ParamByName('doc').AsString := copy(SetJSUpperValue(fjsProd.Items[i], 'documento'),1,20);
      dmModulo.QueryInt.ParamByName('oc').asInteger := StrToIntDef(SetJSUpperValue(fjsProd.Items[i], 'oc'), 0);
      dmModulo.QueryInt.ParamByName('conta').AsString := SetJSUpperValue(fjsProd.Items[i], 'conta');
      dmModulo.QueryInt.ParamByName('emissao').AsString := xemissao;
      dmModulo.QueryInt.ParamByName('fornecedor').AsString := SetJSUpperValue(fjsProd.Items[i], 'fornecedor');
      dmModulo.QueryInt.ParamByName('nome').AsString := SetJSUpperValue(fjsProd.Items[i], 'nome');
      dmModulo.QueryInt.ParamByName('cpf').AsString := xCpf;
      dmModulo.QueryInt.ParamByName('cnpj').AsString := xCnpj;

      dmModulo.QueryInt.ParamByName('empresa').AsString := SetJSUpperValue(fjsProd.Items[i], 'empresa');
      dmModulo.QueryInt.ParamByName('setor').AsString := Trim(SetJSUpperValue(fjsProd.Items[i], 'setor'));
      dmModulo.QueryInt.ParamByName('valor').asFloat := val2(SetJSValUpperValue(fjsProd.Items[i], 'valor'));
      dmModulo.QueryInt.ParamByName('obs').AsString := SetJSUpperValue(fjsProd.Items[i], 'observacao');
      dmModulo.QueryInt.ParamByName('unidade').AsString := SetJSUpperValue(fjsProd.Items[i], 'unidade');
      dmModulo.QueryInt.ParamByName('referencia').AsString := SetJSUpperValue(fjsProd.Items[i], 'referencia');
      dmModulo.QueryInt.ParamByName('remessarquivo').AsString := _Remessa;

      dmModulo.QueryInt.execSql;
      DoGravarPagarDetalhe(fjsProd.Items[i], jsProdDetalhe, xId);

    end;

    result := True;
  except
    on e: Exception do
      logging(nil, ' ERRO: Arquivo de Pagar ' + _Remessa + ':' + e.message);

  end;

end;

Function DoGravarPagarDetalhe(fjsRaiz: TJsonValue; fjsProd: TJSONArray; fCompra: String): Boolean;
var
  i: Integer;
  xId, xSql: String;
  jsProdDetalhe: TJSONArray;
  xemissao: string;
  xVencto: string;
begin
  result := false;
  try
    dmModulo.QueryInt.close;
    dmModulo.QueryInt.SQL.clear;
    for i := 0 to fjsProd.Count - 1 do
    begin
      xSql := ' INSERT INTO  ' + _DB.BancoFinan + '.pagardetalhe(';
      xSql := xSql + 'pagar,';
      xSql := xSql + 'data,';
      xSql := xSql + 'doc,';
      xSql := xSql + 'empresa,';
      xSql := xSql + 'vencimento,';
      xSql := xSql + 'valor,';
      xSql := xSql + 'valorpg,';
      xSql := xSql + 'remessarquivo)';

      xSql := xSql + ' values (';
      xSql := xSql + ':pagar,';
      xSql := xSql + ':data,';
      xSql := xSql + ':doc,';
      xSql := xSql + ':empresa,';
      xSql := xSql + ':vencimento,';
      xSql := xSql + ':valor,';
      xSql := xSql + ':valorpg,';
      xSql := xSql + ':remessarquivo)';

      xemissao := SetJSUpperValue(fjsRaiz, 'EMISSAO');
      if pos('/', xemissao) > 0 then
        xemissao := DtosHifem(StrToDate(xemissao));

      xVencto := SetJSUpperValue(fjsProd.Items[i], 'VENCIMENTO');
      if pos('/', xVencto) > 0 then
        xVencto := DtosHifem(StrToDate(xVencto));

      dmModulo.QueryInt.Params.clear;
      dmModulo.QueryInt.SQL.Text := xSql;
      dmModulo.QueryInt.ParamByName('pagar').AsString := fCompra;
      dmModulo.QueryInt.ParamByName('data').AsString := xemissao;
      dmModulo.QueryInt.ParamByName('vencimento').AsString := xVencto;
      dmModulo.QueryInt.ParamByName('doc').AsString := copy(SetJSUpperValue(fjsProd.Items[i], 'documento'),1,20);
      dmModulo.QueryInt.ParamByName('empresa').AsString := SetJSUpperValue(fjsRaiz, 'empresa');
      dmModulo.QueryInt.ParamByName('valor').asFloat := val2(SetJSValUpperValue(fjsProd.Items[i], 'valor'));
      dmModulo.QueryInt.ParamByName('valorpg').asFloat := val2(SetJSValUpperValue(fjsProd.Items[i], 'valor'));
      dmModulo.QueryInt.ParamByName('remessarquivo').AsString := _Remessa;
      dmModulo.QueryInt.execSql;
    end;
    result := True;
  Except
    on e: Exception do
      logging(nil, ' ERRO: Arquivo de pagardetalhe ' + _Remessa + ':' + e.message);

  end;
end;

end.
