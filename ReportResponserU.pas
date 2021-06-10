unit ReportResponserU;

interface

uses
  System.SysUtils,
  System.DateUtils,
  Vcl.Dialogs, Math,
  System.Classes, ReportRequestU, ReportScriptRunnerU, HttpAgentU, TimeUtilsU,
  System.Generics.Collections;

const
  DEFAULT_SLEEP_TIME = 60 * 1000;

type
  TReportResponser = class(TThread)
  private
    HttpAgent: THttpAgent;
    ReportsWaitingQueue: TList<TReportRequest>;
    ReportScriptRunner: TReportScriptRunner;
    ExecutionTimeMeter: TStopwatch;

    LastReportRequestId: integer;
    SleepTime: integer;
  protected
    procedure Execute; override;
    procedure RunScripts();
    procedure LoadQueue();

    procedure OnExecuting();
  public
    constructor Create();
  end;

implementation

constructor TReportResponser.Create();
begin
  inherited Create;

  HttpAgent := THttpAgent.Create;
  ReportsWaitingQueue := TList<TReportRequest>.Create;
  ReportScriptRunner := TReportScriptRunner.Create;
  ExecutionTimeMeter := TStopWatch.Create;

  LastReportRequestId := 0;
  SleepTime := DEFAULT_SLEEP_TIME;

  FreeOnTerminate := True;
end;

procedure TReportResponser.Execute;
begin
  while not Terminated do
  begin
    ExecutionTimeMeter.Start();

    OnExecuting();

    ExecutionTimeMeter.Stop();
    Sleep(Max(SleepTime, ExecutionTimeMeter.ElapsedMilliseconds));
  end;
end;

procedure TReportResponser.OnExecuting();
begin
  LoadQueue();
  RunScripts();
end;

procedure TReportResponser.LoadQueue();
var
  Request: TReportRequest;
begin
  for Request in HttpAgent.GetReportRequests(LastReportRequestId) do
  begin
    ReportsWaitingQueue.Add(Request);
    LastReportRequestId := Request.GetId();
  end;
end;

procedure TReportResponser.RunScripts();
var
  Request: TReportRequest;
begin
  while ReportsWaitingQueue.Count > 0 do
  begin
    Request := TReportRequest(ReportsWaitingQueue.First);
    ReportScriptRunner.Run(Request.GetScriptName);
    ReportsWaitingQueue.Delete(0);
  end;
end;

end.
