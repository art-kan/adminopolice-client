unit ReportTaskU;

interface

uses SysUtils, DateUtils, TimeUtilsU;

type
  ACTIONS = record
    const
      SYNCHRONIZE = 1;
      EXECUTE = 2;
  end;

  TReportTask = class
  private
    Id: string;
    Action: Cardinal;
    ScriptName: string;
    Arguments: string;
  public
    constructor Create(
      Id: string;
      Action: integer;
      ScriptName: string;
      Arguments: string = ''
    );

    function GetId(): string;
    function GetScriptName(): string;
    function GetArguments(): string;

    function IsToBeSynchronize(): boolean;
    function IsToBeExecuted(): boolean;
  end;

implementation

constructor TReportTask.Create(
  Id: string;
  Action: integer;
  ScriptName: string;
  Arguments: string = ''
);
begin
  self.Id := Id;
  self.Action := Action;
  self.ScriptName := ScriptName;
  self.Arguments := Arguments;
end;


function TReportTask.GetId(): string;
begin
  Result := Id;
end;

function TReportTask.GetScriptName(): string;
begin
  Result := ScriptName;
end;

function TReportTask.GetArguments(): string;
begin
  Result := Arguments;
end;

function TReportTask.IsToBeSynchronize(): boolean;
begin
  Result := Action and ACTIONS.SYNCHRONIZE <> 0;
end;

function TReportTask.IsToBeExecuted(): boolean;
begin
  Result := Action and ACTIONS.EXECUTE <> 0;
end;

end.
