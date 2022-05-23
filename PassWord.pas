unit PASSWORD;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons;

type
  TPasswordDlg = class(TForm)
    Label1: TLabel;
    Password: TEdit;
    OKBtn: TButton;
  private
    { Private declarations }
  public
    procedure Reset;
    function GetUserInput: string;
  end;

var
  PasswordDlg: TPasswordDlg;

implementation

{$R *.dfm}

procedure TPasswordDlg.Reset;
begin
  Password.Text := '';
end;

function TPasswordDlg.GetUserInput: string;
begin
  Result := Password.Text;
end;

end.
 
