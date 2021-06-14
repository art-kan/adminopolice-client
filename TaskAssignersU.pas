unit TaskAssignersU;

interface

uses
  SysUtils,
  Generics.Collections,
  Vcl.Dialogs,
  TimeUtilsU,
  HttpAgentU,
  HttpRequesterU,
  ReportTaskU;

type
  ITaskAssigner = interface
    ['{3388C26F-4803-40D9-B070-01B4D2820DE8}']
    procedure Load(var Queue: TList<TReportTask>);
  end;

  TServerTaskAssigner = class(TInterfacedObject, ITaskAssigner)
    public
      constructor Create();

      procedure Load(var Queue: TList<TReportTask>);
    private
      HttpAgent: THttpAgent;
      LastReportTaskId: string;

      procedure HardLoad(var Queue: TList<TReportTask>; attempts: integer = 2);
  end;

  {FOR BETTA PURPOSES ONLY}
  {IF IT IS GOING TO BE USED IN RELEASE IT SHOULD BE REDESIGNED}
  TLocalTaskAssigner = class(TInterfacedObject, ITaskAssigner)
    public
      constructor Create();

      procedure Load(var Queue: TList<TReportTask>);
    private
      SysinfoTimer: TTimeouter;
      WANSpeedTimer: TTimeouter;
      ActivityMeasureTimer: TTimeouter;

      Counter: integer;

      function CreateReportTask(ScriptName: string): TReportTask;
  end;

implementation

constructor TServerTaskAssigner.Create();
begin
  HttpAgent := THttpAgent.Create;
  LastReportTaskId := '';
end;


procedure TServerTaskAssigner.Load(var Queue: TList<TReportTask>);
begin
  HardLoad(Queue);
end;

procedure TServerTaskAssigner.HardLoad(
  var Queue: TList<TReportTask>;
  attempts: integer = 2
);
var
  Task: TReportTask;
  a: HttpException;
begin
  try
    for Task in HttpAgent.GetReportRequests(LastReportTaskId) do
    begin
      Queue.Add(Task);
      LastReportTaskId := Task.GetId();
    end;
  except
    on e: HttpException do
    begin
      if attempts > 0 then
        HardLoad(Queue, attempts - 1)
      else
        MessageDlg(e.Message, mtError, [mbOK], 0);
    end;
  end;
end;

constructor TLocalTaskAssigner.Create();
begin
  SysinfoTimer := TTimeouter.Create(12 * 60 * 60 * 1000);
  WANSpeedTimer := TTimeouter.Create(1 * 60 * 60 * 1000);
  ActivityMeasureTimer := TTimeouter.Create(1 * 60 * 60 * 1000);

  // hack
  SysinfoTimer.SetOnFire;
  WANSpeedTimer.SetOnFire;
  ActivityMeasureTimer.SetOnFire;

  Counter := 1;
end;

procedure TLocalTaskAssigner.Load(var Queue: TList<TReportTask>);
begin
  if SysinfoTimer.IsExpired then
  begin
    Queue.Add(CreateReportTask('sysinfo.vbs'));
    SysinfoTimer.Start;
  end;

  if WANSpeedTimer.IsExpired then
  begin
    Queue.Add(CreateReportTask('speedtest.py'));
    WANSpeedTimer.Start;
  end;

  if ActivityMeasureTimer.IsExpired then
  begin
    Queue.Add(CreateReportTask('activity.exe'));
    ActivityMeasureTimer.Start;
  end;
end;

function TLocalTaskAssigner.CreateReportTask(ScriptName: string): TReportTask;
begin
  Result := TReportTask.Create(
    'L' + IntToStr(Counter),
    1, // to execute
    ScriptName
  );
end;

end.
