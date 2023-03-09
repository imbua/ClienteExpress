program ProcessClient;

uses
  Vcl.Forms,
  MidasLib,
  uMain in 'uMain.pas' {frmMain},
  uModulo in 'uModulo.pas' {dmModulo: TDataModule},
  uClienteDataSetClass in 'uClienteDataSetClass.pas',
  uVar in 'uVar.pas',
  uFuncoes in 'uFuncoes.pas',
  uArqJson in 'uArqJson.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmModulo, dmModulo);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
