unit ConfigControllerU;

interface

uses System.IOUtils, SysUtils, SyncObjs, Forms, IniFiles, Vcl.Dialogs;

const
  AUTH_SECTION = 'AUTHENTICATION';
  AUTH_TOKEN_IDENT = 'AUTH_TOKEN';

type
  TConfigController = class
  private
    IniFile: TIniFile;
    AppDataDirPath: string;
    AppName: string;
    constructor MakeSingleton;
  public
    constructor Create; deprecated;
    function ReadAuthToken: string;
    procedure WriteAuthToken(Token: string);
  end;

function GetConfigController: TConfigController;

var
  Lock: TCriticalSection;
  _Singleton: TConfigController;

implementation

constructor TConfigController.Create;
begin
  raise Exception.Create
    ('TConfigController is Singleton. Use GetConfigController instead');
end;

function GetConfigController: TConfigController;
begin
  Lock.Acquire;
  Try
    if not Assigned(_Singleton) then
      _Singleton := TConfigController.MakeSingleton;
    Result := _Singleton;
  Finally
    Lock.Release;
  End;
end;

constructor TConfigController.MakeSingleton;
begin
  AppName := TPath.GetFileNameWithoutExtension(Application.ExeName);

  {$IFDEF BETTA}
    AppDataDirPath := ExtractFileDir(Application.ExeName);
  {$ELSE}
    AppDataDirPath := TPath.Combine(TPath.GetPublicPath, AppName);
  {$ENDIF}

  if not ForceDirectories(AppDataDirPath) then
  begin
    ShowMessage('Couldn''t initilize config.ini. Contact your vendor');
  end;
  IniFile := TIniFile.Create(TPath.Combine(AppDataDirPath, 'config.ini'));
  { TODO: Encrypt/decrypt config file }

end;

function TConfigController.ReadAuthToken: string;
begin
  Result := IniFile.ReadString(AUTH_SECTION, AUTH_TOKEN_IDENT, '');
end;

procedure TConfigController.WriteAuthToken(Token: string);
begin
  IniFile.WriteString(AUTH_SECTION, AUTH_TOKEN_IDENT, Token);
end;

initialization

Lock := TCriticalSection.Create;

finalization

Lock.Free;

end.
