unit ReportScriptRunnerU;

interface

uses
  Windows,
  SysUtils,
  ShellApi,
  Vcl.Dialogs;

type
  TReportScriptRunner = class
    public
      procedure Run(ScriptName: string);
      procedure Prepare(ScriptName: string);
  end;

implementation

{FOR BETTA ONLY}
{FOR RELEASE REQUIRES REDESIGN}
procedure TReportScriptRunner.Run(ScriptName: string);
var Executor: string;
begin

  if ExtractFileExt(ScriptName) = '.vbs' then
     Executor := 'cscript //nologo'
  else if ExtractFileExt(ScriptName) = '.py' then
     Executor := 'py'
  else if ExtractFileExt(ScriptName) = '.exe' then
  begin
     Executor := '';
  end;

  {ISSUE: COULD REWRITE EXISTING DATA}
  ShellExecute(0, nil, 'cmd.exe',
    PChar(
      '/C ' + Executor + ' scripts\' + ScriptName + ' > ' + 'data\' + ScriptName + '\' +
      FormatDateTime('yy-mm-dd_hh-nn-ss', Now)),
    nil, SW_HIDE);
end;

procedure TReportScriptRunner.Prepare(ScriptName: string);
begin
  {$IFDEF DEBUG}
  ShowMessage('[' + ScriptName + '] Preparing...');
  {$ENDIF}
end;

end.
