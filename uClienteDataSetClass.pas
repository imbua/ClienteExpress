unit uClienteDataSetClass;

interface

uses System.SysUtils, System.Classes, DB, DBClient, VCl.Forms;

Type
  TClienteDataSetClass = Class
  Private

  published
    procedure Put_Campo_Padrao(FCQuery: TClientDataSet);

    procedure CriaCLinha;
    procedure CriaCItens;
    procedure CriaCItensRodizio;
    procedure CriaCItensPedidoEntregaPontos;

    procedure CriaCItens_Conta; // tabela temporaria para fechamento financeiro
    procedure CriaCadastro;
    procedure CriaCadastroProdutos;

    procedure CriaPagamento;
    procedure CriaRetiradas;
    procedure CriaSangria;
    procedure CriaCadastroPet;

    Constructor Create;
  End;

Var
  CDSClass: TClienteDataSetClass;

implementation

uses uModulo;

procedure TClienteDataSetClass.Put_Campo_Padrao(FCQuery: TClientDataSet);
begin
  with FCQuery do
  begin
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Data';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Empresa';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Setor';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Caixa';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 30;
      Name := 'usuario';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 30;
      Name := 'venda';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Cupom';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Vendedor';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'CPFCNPJ';
    end;
  end;
end;

constructor TClienteDataSetClass.Create;
begin
  inherited;
end;

procedure TClienteDataSetClass.CriaCLinha;
begin
  with dmModulo.cLinha do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo1';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo2';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo3';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo4';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo5';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo6';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo7';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'campo8';
    end;

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'campo1';
      Name := 'index1';
    end;
    with IndexDefs.AddIndexDef do
    begin
      Fields := 'campo2';
      Name := 'index2';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaCItens;
begin
  with dmModulo.cItens do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftInteger;
      Name := 'id';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'produto';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'Descricao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'qte';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'obs';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'Valor';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'ValorProd';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'VrCusto';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'Custo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Tributo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Servico';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'comissaosrv';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'repique';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Conta';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'tipo';
      // se e 00001 ou 00010 ou 00011 para vendas devol. ou canc.
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'id_cancelado';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 5;
      Name := 'rt';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 5;
      Name := 'executor1';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'entrega';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'desconto_item';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'outrassaidaid';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'serial';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'pontos';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'pontosresgate';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 5;
      Name := 'hora';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'origem';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'destino';
    end;

    Put_Campo_Padrao(dmModulo.cItens);

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'produto';
      Name := 'index1';
    end;
    with IndexDefs.AddIndexDef do
    begin
      Fields := 'id';
      Name := 'index2';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaCItensRodizio;
begin
  with dmModulo.cItensRodizio do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftInteger;
      Name := 'id';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'produto';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'qte';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 4;
      Name := 'mesa';
    end;

    Put_Campo_Padrao(dmModulo.cItensRodizio);

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'produto';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaCItensPedidoEntregaPontos;
begin
  with dmModulo.cItensPedidoEntregaPontos do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftInteger;
      Name := 'id';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'pedido';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'produto';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'qte';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'pontos';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'valor';
    end;

    Put_Campo_Padrao(dmModulo.cItensPedidoEntregaPontos);

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'produto';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaSangria;
begin
  with dmModulo.cSangriaFundo do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'Descricao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'Valor';
    end;

    Put_Campo_Padrao(dmModulo.cSangriaFundo);

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'Descricao';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaCItens_Conta;
begin
  with dmModulo.citens_conta do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'conta';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'contaDescricao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 2;
      Name := 'tipo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'Valor';
    end;

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'Conta';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaCadastroPet;
begin
  with dmModulo.cCadastroPet do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'cadastro';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'qtecaes';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'qtegatos';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'outro';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'qteoutros';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'nome';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'especie';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'raca';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 2;
      Name := 'sexo';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 2;
      Name := 'tamanho';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'nascimento';
    end;

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'cadastro';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaCadastro;
begin
  with dmModulo.cCadastro do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'codigo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'nome';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 2;
      Name := 'sexo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'senha';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'nasc';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'fone';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'email';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'endereco';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'uf';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'cep';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'cidade';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'bairro';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'cadastroempresa';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 1;
      Name := 'enviarcorrespondencia';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'inscr';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'nfc';
    end;

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'codigo';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaCadastroProdutos;
begin
  with dmModulo.cCadastroProdutos do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'codigo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'barras';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 100;
      Name := 'Descricao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 2;
      Name := 'Grupo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'Valor';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'custo';
    end;

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'codigo';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaRetiradas;
begin
  with dmModulo.cRetiradas do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'id';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'opcao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'produto';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'qte';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'categoria';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'qtedevolvido';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'qtevendido';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'valor';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'valorprod';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'desconto_item';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'fator';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'desconto';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 5;
      Name := 'hora';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftWideMemo;
      Name := 'Obs';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftWideString;
      Size := 255;
      Name := 'Obs_item';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftWideString;
      Size := 3;
      Name := 'rt';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftWideString;
      Size := 10;
      Name := 'placa';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftWideString;
      Size := 20;
      Name := 'serial';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftWideString;
      Size := 20;
      Name := 'executor';
    end;
    Put_Campo_Padrao(dmModulo.cRetiradas);

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'id';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

procedure TClienteDataSetClass.CriaPagamento;
begin
  with dmModulo.cPagamento do
  begin
    FieldDefs.clear;
    IndexDefs.clear;
    IndexName := '';
    close;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Codigo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 15;
      Name := 'Descricao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'Cliente';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'Valor';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Vencimento';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Pagamento';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'taxa';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'acrescimo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'ClienteCartao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Tipo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Conta';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Tef';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 5;
      Name := 'hora';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'devolucao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'mesa';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Comanda';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'vrservico';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'dias';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Conta_Venda';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'placa';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'veiculo';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'rt';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'boleto';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'opcao';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'paciente';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 50;
      Name := 'ChaveNFec';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'frete';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'tefautorizacao';
    end;

    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 20;
      Name := 'NFC';
    end;

    Put_Campo_Padrao(dmModulo.cPagamento);

    with IndexDefs.AddIndexDef do
    begin
      Fields := 'Codigo';
      Name := 'index1';
    end;
    CreateDataSet;
    Active := True;
    IndexName := 'index1';
  end;
end;

end.
