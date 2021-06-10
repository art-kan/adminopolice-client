unit MainFormU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ReportResponserU, Vcl.ExtCtrls, HttpAgentU, Password;

type
  TMainForm = class(TForm)
    TrayIcon: TTrayIcon;
    procedure OnCreate(Sender: TObject);
    procedure OnCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OnTrayClick(Sender: TObject);
  private
    ReportResponser: TReportResponser;

    procedure InitializeInner;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.OnTrayClick(Sender: TObject);
begin
  if Visible then Hide else Show;
end;

procedure TMainForm.OnCloseQuery(Sender: TObject; var CanClose: Boolean);
begin

{$IFDEF DEBUG}
  CanClose := mrYes = MessageDlg(
    'This is DEBUG version of the program, so you can close it easily',
    mtCustom, [mbYes, mbCancel], 0);
  if not CanClose then
    Hide;
{$ELSE}
  Hide;
  CanClose := False;
{$ENDIF}

end;

procedure TMainForm.OnCreate(Sender: TObject);
begin
  InitializeInner();
  TrayIcon.Visible := True;
end;

procedure TMainForm.InitializeInner();
begin
  DemandAuthorization(self);
  ReportResponser := TReportResponser.Create;
end;

end.
