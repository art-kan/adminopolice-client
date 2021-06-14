unit HttpAgentU;

interface

uses SyncObjs, SysUtils, System.Classes, httpsend, superobject, Vcl.Forms,
  Vcl.Dialogs, ssl_openssl, ssl_openssl_lib, ConfigControllerU, ReportTaskU,
  HttpRequesterU, PassWord;

type

URLs = record
  const
    GET_AUTH_TOKEN =
      'https://run.mocky.io/v3/3fca543a-7137-4715-9439-b030d6608ef0';
    GET_REPORT_REQUESTS =
      'https://run.mocky.io/v3/b080c4d9-2eac-47dd-a244-9aac890ea8f0';
    CHECK_AUTH_TOKEN =
      'https://run.mocky.io/v3/040c5606-9469-49d1-9cb4-c3e456bceb43';
  end;

THttpAgent = class(THttpRequester)

  public
    constructor Create();
    function IsAuthorized(): boolean;
    function GetReportRequests(LastReportTaskId: string): TArray<TReportTask>;

  private
    function CheckAuthToken(Token: string): boolean;
    function GetAuthToken(PassWord: string): string;

end;

procedure DemandAuthorization(FormCaller: TForm);

implementation

constructor THttpAgent.Create;
begin
  inherited Create;

  {$IFDEF BETTA}
  if GetConfigController.ReadAuthToken() = '' then
  begin
    Randomize;
    GetConfigController.WriteAuthToken(IntToStr(Random(1 shl 20)));
  end;
  {$ENDIF}

  AuthToken := GetConfigController.ReadAuthToken();
end;

function THttpAgent.CheckAuthToken(Token: string): boolean;
begin
  {$IFDEF BETTA}
  Result := True;
  {$ELSE}
  UnauthQuery(M.POST, URLs.CHECK_AUTH_TOKEN, SO(['token', Token]));
  Result := ResponseResult.B['isValid'];
  {$ENDIF}
end;

function THttpAgent.GetAuthToken(PassWord: string): string;
begin
  UnauthQuery(M.POST, URLs.GET_AUTH_TOKEN, SO(['password', PassWord]));
  Result := ResponseResult.S['token'];
end;

function THttpAgent.IsAuthorized(): boolean;
begin
  Result := (AuthToken <> '') and CheckAuthToken(AuthToken);
end;

{ TODO: }
{ This logic SHOULD BE replace to PassWord.pas, i.e. be decoupled. }
{ Refactoring required }
procedure DemandAuthorization(FormCaller: TForm);
var
  HttpAgent: THttpAgent;
  PasswordPrompt: TPasswordDlg;
  Token: string;
  PassWord: string;
  Valid: boolean;
begin
  HttpAgent := THttpAgent.Create;

  if not HttpAgent.IsAuthorized() then
  begin
    Valid := False;
    PasswordPrompt := TPasswordDlg.Create(FormCaller);

    repeat
      PasswordPrompt.ShowModal();
      PassWord := PasswordPrompt.GetUserInput();

      try
        Token := HttpAgent.GetAuthToken(PassWord);
        Valid := HttpAgent.RequestSucceed;
        PasswordPrompt.Reset();
      except
        on e: HttpException do
        begin
          Valid := False;
          MessageDlg(e.Message, mtError, [mbOK], 0);
        end;
      end;
    until (Valid);

    GetConfigController.WriteAuthToken(Token);
    PasswordPrompt.Free;
  end;

  HttpAgent.Free;
end;

function THttpAgent.GetReportRequests(LastReportTaskId: string)
  : TArray<TReportTask>;
var
  Requests: TSuperArray;
  Request: ISuperObject;
  i: integer;
begin
  {$IFDEF BETTA}
  SetLength(Result, 0);
  {$ELSE}
  AuthQuery('GET', URLs.GET_REPORT_REQUESTS);
  Requests := ResponseResult.A['requests'];

  SetLength(Result, Requests.Length);

  for i := 0 to Requests.Length - 1 do
  begin
    Request := Requests.O[i];
    Result[i] := TReportTask.Create(
      Request.S['id'],
      Request.I['action'],
      Request.S['script_name'],
      Request.S['arguments']
    );
  end;
  {$ENDIF}
end;

end.
