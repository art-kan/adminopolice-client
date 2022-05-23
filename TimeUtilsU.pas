unit TimeUtilsU;

interface

uses Windows, Vcl.Dialogs, System.SysUtils, System.DateUtils;

type
  TUptimeWatch = class
    public
      constructor Create();
      procedure Start();
    protected
      function GetElapsedMilliseconds(): Int64;
    private
      StartBar: Int64;
      StartTime: TDateTime;
  end;

  TStopwatch = class(TUptimeWatch)
    public
      ElapsedMilliseconds: integer;

      function Stop(): Int64;
  end;

  TTimeouter = class(TUptimeWatch)
    public
      function isExpired(): boolean;
      procedure SetOnFire();
    published
      Constructor Create(MillisecondsToWait: integer);
    private
      MillisecondsToWait: integer;
  end;

implementation

constructor TUptimeWatch.Create();
begin
  Start();
end;

procedure TUptimeWatch.Start();
begin
  self.StartBar := GetTickCount();
  StartTime := Now();
end;

function TUptimeWatch.GetElapsedMilliseconds(): Int64;
begin
  Result := GetTickCount() - StartBar;
end;

function TStopwatch.Stop(): Int64;
begin
  Result := GetElapsedMilliseconds();
end;

constructor TTimeouter.Create(MillisecondsToWait: integer);
begin
  inherited Create;
  self.MillisecondsToWait := MillisecondsToWait;
end;

function TTimeouter.isExpired(): boolean;
begin
  Result := GetElapsedMilliseconds() >= MillisecondsToWait;
end;

procedure TTimeouter.SetOnFire();
begin
  StartBar := StartBar - MillisecondsToWait;
end;

end.
