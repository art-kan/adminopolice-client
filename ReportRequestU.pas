unit ReportRequestU;

interface

uses SysUtils, DateUtils, TimeUtilsU;

type
  TReportRequest = class
  private
    Id: integer;
    ScriptName: string;
  public
    constructor Create(Id: integer; ScriptName: string);

    function GetScriptName(): string;
    function GetId(): integer;
  end;

implementation

constructor TReportRequest.Create(Id: integer; ScriptName: string);
begin
  self.ScriptName := ScriptName;
  self.Id := Id;
end;

function TReportRequest.GetScriptName(): string;
begin
  Result := ScriptName;
end;

function TReportRequest.GetId(): integer;
begin
  Result := Id;
end;

end.
