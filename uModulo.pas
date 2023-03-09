unit uModulo;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DBClient, Vcl.ExtCtrls,
  ZLIBArchive2, DAScript, UniScript, DASQLMonitor, UniSQLMonitor, Data.DB,
  MemDS, DBAccess, Uni, UniProvider, MySQLUniProvider;

type
  TdmModulo = class(TDataModule)
    MySQLUniProv: TMySQLUniProvider;
    Bancocnx: TUniConnection;
    Query: TUniQuery;
    QueryInc: TUniQuery;
    QueryResult: TUniQuery;
    QueryInt: TUniQuery;
    monitor: TUniSQLMonitor;
    querycmd: TUniScript;
    ZipFec: TZLBArc2;
    Zipar: TZLBArc2;
    CItens: TClientDataSet;
    CPagamento: TClientDataSet;
    Citens_conta: TClientDataSet;
    cSangriaFundo: TClientDataSet;
    cCadastro: TClientDataSet;
    cLinha: TClientDataSet;
    cRetiradas: TClientDataSet;
    cItensRodizio: TClientDataSet;
    cItensPedidoEntregaPontos: TClientDataSet;
    cCadastroProdutos: TClientDataSet;
    cCadastroPet: TClientDataSet;
    procedure monitorSQL(Sender: TObject; Text: string; Flag: TDATraceFlag);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmModulo: TdmModulo;

implementation


{$R *.dfm}


uses uVar;

procedure TdmModulo.monitorSQL(Sender: TObject; Text: string;
  Flag: TDATraceFlag);
const
  LineEnding = #13#10;
var
  Stream: TFileStream;
  Temp: AnsiString;
  Buffer: PAnsiChar;
  FFileName: String;

  function VerificaTipo(fstr: string;
    ferror:
    string): Boolean;
  begin
    result := True;
    if copy(fstr, 1, 11) = 'SHOW TABLES' then
      result := false;
    if copy(fstr, 1, 12) = 'SHOW COLUMNS' then
      result := false;
    if pos('from desliga', LowerCase(fstr)) > 0 then
      result := false;
    if pos('senha =', LowerCase(fstr)) > 0 then
      result := false;
    if ferror <> '' then
      result := True;
  end;

begin
  try
    if pos('from senhas', Text) > 0 then
      exit;

    FFileName := _MonitorFilename;

    { Save the event. }
    if (FFileName <> '') then
    begin
      if not FileExists(FFileName) then
        Stream := TFileStream.create(FFileName, fmCreate)
      else
        Stream := TFileStream.create(FFileName, fmOpenReadWrite or fmShareDenyWrite);
      try
        Stream.Seek(0, soFromEnd);
        Temp := AnsiString(FormatDateTime('yyyy-mm-dd hh:mm:ss', now()) + '   Sql:' + Text + LineEnding);
        Buffer := PAnsiChar(Temp);
        Stream.Write(Buffer^, StrLen(Buffer) * SizeOf(AnsiChar));
      finally
        Stream.Free;
      end;
    end;
  Except
  end;
end;

end.
