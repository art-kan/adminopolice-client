unit WorkProcessorU;

interface

uses
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  System.Generics.Collections,
  Vcl.Dialogs,
  Math,
  ReportTaskU,
  ReportScriptRunnerU,
  HttpAgentU,
  TaskAssignersU,
  TimeUtilsU;

const
  DEFAULT_SLEEP_TIME = 1 * 1000;

type
  TWorkProcessor = class(TThread)
  private
    HttpAgent: THttpAgent;
    TaskQueue: TList<TReportTask>;
    ReportScriptRunner: TReportScriptRunner;
    ExecutionTimeMeter: TStopwatch;

    SleepTime: integer;

    {$IFDEF BETTA}
      LocalTaskAssigner: TLocalTaskAssigner;
    {$ELSE}
      ServerTaskAssigner: TServerTaskAssigner;
    {$ENDIF}
  protected
    procedure Execute; override;
    procedure RunScripts();
    procedure LoadQueue();

    procedure OnExecuting();
  public
    constructor Create();
  end;

implementation

constructor TWorkProcessor.Create();
begin
  inherited Create;

  HttpAgent := THttpAgent.Create;
  TaskQueue := TList<TReportTask>.Create;

  ReportScriptRunner := TReportScriptRunner.Create;
  ExecutionTimeMeter := TStopWatch.Create;

  {$IFDEF BETTA}
    LocalTaskAssigner := TLocalTaskAssigner.Create;
  {$ELSE}
    ServerTaskAssigner := TServerTaskAssigner.Create;
  {$ENDIF}

  SleepTime := DEFAULT_SLEEP_TIME;

  FreeOnTerminate := True;
end;

procedure TWorkProcessor.Execute;
begin
  while not Terminated do
  begin
    ExecutionTimeMeter.Start();

    OnExecuting();

    ExecutionTimeMeter.Stop();
    Sleep(Max(SleepTime, ExecutionTimeMeter.ElapsedMilliseconds));
  end;
end;

procedure TWorkProcessor.OnExecuting();
begin
  LoadQueue();
  RunScripts();
end;

procedure TWorkProcessor.LoadQueue();
var
  Request: TReportTask;
begin
  {$IFDEF BETTA}
    LocalTaskAssigner.Load(TaskQueue);
  {$ELSE}
    ServerTaskAssigner.Load(TaskQueue);
  {$ENDIF}
end;

procedure TWorkProcessor.RunScripts();
var
  Task: TReportTask;
begin
  while TaskQueue.Count > 0 do
  begin
    Task := TReportTask(TaskQueue.First);
    ReportScriptRunner.Run(Task.GetScriptName);
    TaskQueue.Delete(0);
  end;
end;

end.
