program Demo;

uses
  Vcl.Forms,
  Winapi.Networking.Icmp in '..\Winapi.Networking.Icmp.pas',
  Winapi.Networking.Tracert in '..\Winapi.Networking.Tracert.pas',
  uMain in 'uMain.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.

