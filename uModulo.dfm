object dmModulo: TdmModulo
  OldCreateOrder = False
  Height = 337
  Width = 592
  object MySQLUniProv: TMySQLUniProvider
    Left = 72
    Top = 80
  end
  object Bancocnx: TUniConnection
    Left = 104
    Top = 24
  end
  object Query: TUniQuery
    Connection = Bancocnx
    Left = 152
    Top = 24
  end
  object QueryInc: TUniQuery
    Connection = Bancocnx
    Left = 152
    Top = 56
  end
  object QueryResult: TUniQuery
    Connection = Bancocnx
    Left = 184
    Top = 24
  end
  object QueryInt: TUniQuery
    Connection = Bancocnx
    Left = 224
    Top = 24
  end
  object monitor: TUniSQLMonitor
    OnSQL = monitorSQL
    Left = 248
    Top = 64
  end
  object querycmd: TUniScript
    Debug = True
    Connection = Bancocnx
    Left = 312
    Top = 24
  end
  object ZipFec: TZLBArc2
    Left = 368
    Top = 25
  end
  object Zipar: TZLBArc2
    Left = 496
    Top = 64
  end
  object CItens: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 392
    Top = 144
  end
  object CPagamento: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 328
    Top = 144
  end
  object Citens_conta: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 448
    Top = 144
  end
  object cSangriaFundo: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 280
    Top = 144
  end
  object cCadastro: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 488
    Top = 144
  end
  object cLinha: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 329
    Top = 232
  end
  object cRetiradas: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 449
    Top = 232
  end
  object cItensRodizio: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 184
    Top = 136
  end
  object cItensPedidoEntregaPontos: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 232
    Top = 136
  end
  object cCadastroProdutos: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 8
    Top = 144
  end
  object cCadastroPet: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 96
    Top = 144
  end
end
