program BlickStatus;

uses
  Vcl.Forms,
  MainFormU in 'MainFormU.pas' {MainForm},
  ReportResponserU in 'ReportResponserU.pas',
  ReportScriptRunnerU in 'ReportScriptRunnerU.pas',
  ReportRequestU in 'ReportRequestU.pas',
  HttpAgentU in 'HttpAgentU.pas',
  ConfigControllerU in 'ConfigControllerU.pas',
  PassWord in 'PassWord.pas' {PasswordDlg},
  HttpRequesterU in 'HttpRequesterU.pas',
  TimeUtilsU in 'TimeUtilsU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
