unit HttpRequesterU;

interface

uses Sysutils, System.Classes, httpsend, superobject;

type
  M = record
  const
    GET = 'GET';
    POST = 'POST';
  end;

  ErrorMessages = record
  const
    SERVER_IS_NOT_RESPONDING =
      'Сервер не отвечает. Проверьте соединение с Интернетом.';
  end;

  HttpException = class(Exception);

  THttpRequester = class
  protected
    AuthToken: string;
    httpsend: THttpSend;

    RequestSucceed: boolean;
    ErrorMessage: string;

    StringStreamResponse: TStringStream;
    Response: ISuperObject;
    ResponseResult: ISuperObject;

    constructor Create;

    procedure AuthQuery(
      const Method: string;
      const URL: string;
      data: ISuperObject = nil
    );

    procedure UnauthQuery(
      const Method: string;
      const URL: string;
      data: ISuperObject = nil
    );

    private
      procedure PrepareAgent();
      procedure SetAuthorizationHeader();
      procedure SetJsonData(Data: ISuperObject);
      procedure ParseResponse();

      function Request(const Method: string; const URL: string): boolean;


      procedure Query(
        const Method: string;
        const URL: string;
        data: ISuperObject = nil;
        UseAuth: boolean = true
      );
  end;

implementation

constructor THttpRequester.Create;
begin
  StringStreamResponse := TStringStream.Create();
  httpsend := THttpSend.Create();
end;

procedure THttpRequester.PrepareAgent();
begin
  httpsend.Clear();
  StringStreamResponse.Clear();
end;

procedure THttpRequester.SetAuthorizationHeader();
begin
  { Issue: When new auth token is saved to Config file }
  { THttpRequester will continue using old one reserved in AuthToken }
  { Possible solution: always read AuthToken from Config file }
  httpsend.Headers.Add('Authorization: Bearer ' + AuthToken);
end;

procedure THttpRequester.SetJsonData(Data: ISuperObject);
var
  DataStream: TMemoryStream;
begin
  DataStream := TMemoryStream.Create();
  Data.SaveTo(DataStream);
  httpsend.Document.LoadFromStream(DataStream);
end;

function THttpRequester.Request(const Method: string;
  const URL: string): boolean;
begin
  Result := httpsend.HttpMethod(Method, URL);
  if Result then
  begin
    httpsend.Document.SaveToStream(StringStreamResponse);
    Response := SO(StringStreamResponse.DataString);
    ParseResponse();
  end;
end;

procedure THttpRequester.ParseResponse();
begin
  RequestSucceed := Response.B['success'];
  if RequestSucceed then
  begin
    ResponseResult := Response.O['result'];
    ErrorMessage := '';
  end
  else
  begin
    ResponseResult := nil;
    ErrorMessage := Response.S['error_message'];
  end;
end;

procedure THttpRequester.Query(
  const Method: string;
  const URL: string;
  Data: ISuperObject = nil;
  UseAuth: boolean = true
);
begin
  PrepareAgent();

  if UseAuth then
    SetAuthorizationHeader();

  if Data <> nil then
    SetJsonData(Data);

  if not Request(Method, URL) then
    raise HttpException.Create(ErrorMessages.SERVER_IS_NOT_RESPONDING);
end;

procedure THttpRequester.AuthQuery(
  const Method: string;
  const URL: string;
  Data: ISuperObject = nil
);
begin
  Query(Method, URL, Data, true);
end;

procedure THttpRequester.UnauthQuery(
  const Method: string;
  const URL: string;
  Data: ISuperObject = nil
);
begin
  Query(Method, URL, Data, False);
end;

end.
