unit ReportScriptRunnerU;

interface

uses Vcl.Dialogs;

type
  TReportScriptRunner = class
    public
      procedure Run(ScriptName: string);
      procedure Prepare(ScriptName: string);
  end;

implementation

procedure TReportScriptRunner.Run(ScriptName: string);
begin
  ShowMessage('[' + ScriptName + '] Running...');
end;

procedure TReportScriptRunner.Prepare(ScriptName: string);
begin
  ShowMessage('[' + ScriptName + '] Preparing...');
end;

end.
