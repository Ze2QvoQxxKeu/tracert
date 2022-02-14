unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.Networking.Tracert, Vcl.StdCtrls, System.strutils,
  Vcl.ExtCtrls;

type
  TForm4 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    ListBox1: TListBox;
    Panel1: TPanel;
    Tracert1: TTracert;
    procedure Button1Click(Sender: TObject);
    procedure Tracert1TraceFinish(Sender: TObject; Address: Cardinal);
    procedure Tracert1TraceAttempt(Sender: TObject; TracertReplyAttempt:
      TTracertReplyAttempt; var StopTracing: Boolean);
    procedure Tracert1AfterTraceJumpX(Sender: TObject; TracertReplyJumpX:
      TTracertReplyJumpX; var StopTracing: Boolean);
    procedure Tracert1BeforeTraceJumpX(Sender: TObject; TTL: Cardinal; var StopTracing: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
begin
  Tracert1.Host := Edit1.Text;
  Tracert1.Start;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Tracert1);
end;

procedure TForm4.Tracert1AfterTraceJumpX(Sender: TObject; TracertReplyJumpX:
  TTracertReplyJumpX; var StopTracing: Boolean);
begin
  with TracertReplyJumpX do
    Listbox1.Items.Add(Format('JMP%2d %5s %s', [TTL, BoolToStr(Success, True), ifthen(Address
      <> UNKNOWN_IP, IPv4ToStr(Address), 'Превышен интервал')]));
  SendMessage(Listbox1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TForm4.Tracert1BeforeTraceJumpX(Sender: TObject; TTL: Cardinal; var StopTracing: Boolean);
begin
  Listbox1.Items.Add('Start TTL = ' + TTL.ToString);
  SendMessage(Listbox1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TForm4.Tracert1TraceAttempt(Sender: TObject; TracertReplyAttempt:
  TTracertReplyAttempt; var StopTracing: Boolean);
begin
  with TracertReplyAttempt do
    Listbox1.Items.Add(Format('%2d %d %4dms %s', [TTL, Attempt, RoundTripTime, ifthen(Address
      <> UNKNOWN_IP, IPv4ToStr(Address), 'Превышен интервал')]));
  SendMessage(Listbox1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TForm4.Tracert1TraceFinish(Sender: TObject; Address: Cardinal);
begin
  Listbox1.Items.Add('Finish. IP: ' + ifthen(Address
      <> UNKNOWN_IP, IPv4ToStr(Address), 'Превышен интервал'));
  SendMessage(Listbox1.Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

end.

