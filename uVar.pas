unit uVar;

interface

type
  TParametros = record
    isCompraAtualiza: Boolean;
    isCompraAtualizaValorVenda: Boolean;
    isCompraAtualizaValorCusto: Boolean;
    isCompraAtualizaValorVendaManual: Boolean;
    isProdutoPrecoSimples: Boolean;
  end;

Type
  TDiretorio = record
    Dir: string;
    Recebimento: String;
    Feito: String;
    Update: String;
    DirEnvio: String;
    Imagens: String;
    Carga: String;
    Erro: String;
    Fiscal: String;
    Backup: string;
    IP:String;

  end;

Type
  TContagem = record
    Data: String;
    Empresa: String;
    Setor: String;
    Usuario: String;
    Remessa: String;
    Zera: String;

  end;

Type
  TDB = Record
    DB: string;
    Banco: string;
    BancoFinan: string;
    Host: String;
    Usr: String;
    Pwd: String;
    MasterHandle: string;

  end;

type
  TSaldo = record
    Saldo: Double;
    Limite: Double;
    Total: Double;
  end;

type
  TParcelasAreceber = record
    rec_vencimento: string;
    rec_valor: Double;
    rec_itens: integer;
  end;

type
  TConta = record
    Conta: string;
    Descricao: string;
    Tipo: string;
    AReceber: string;
    ContraPartida: String;
  end;

type
  TEmpresa = record
    Codigo: string;
    Conta: string;
    Caixa: string;
  end;

type
  TCliente = record
    Codigo: string;
    Nome: string;
    Cpf: string;
    Cnpj: string;
    senha: string;
    bonus: string;
    NFC: String;
  end;

Type
  TContaFinanceiro = record
    ContaPorProduto_Grupo: string;
    ContaJuros: string;
    ContaMulta: string;
    ContaAbono: string;
    ContaReajuste: string;
    ContaTroca: string;
    ContaCredito: String;
  end;

const
  BufferMemoResposta = 1000; { Maximo de Linhas no MemoResposta }
  sLinefBreak = #13;
  Versao = '14/12/2022';
  _C = 'tYk*5W@';

var
  _DB: TDB;
  _Contagem: TContagem;
  _MonitorFilename: String;
  _Inicio: Boolean;
  _EmCarga: Boolean;
  _Aplicacao: string;
  _Conta: TConta;
  _Cliente: TCliente;
  _Empresa: TEmpresa;
  _Remessa: string;
  _ContaFinanceiro: TContaFinanceiro;
  _Comissao: string;
  _Comissaovr: string;
  _ParcelasAreceber: array of TParcelasAreceber;
  _Dir: TDiretorio;
  _Hora: String;
  _Parametro: TParametros;
  _DataContagem: String;
  pCanClose: Boolean;

implementation

end.
