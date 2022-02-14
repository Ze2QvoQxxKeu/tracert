unit Winapi.Networking.Tracert;
(*
Tracert ICMP (IPv4)
12.05.2018
Artem P.
*)
interface

uses
  Winapi.Windows, Winapi.Winsock2, Winapi.IpHlpApi, Winapi.IpExport, Winapi.Networking.Icmp,
  System.SysUtils, System.Classes, System.RegularExpressions;

const
  UNKNOWN_IP = DWORD(-1);
  {$EXTERNALSYM UNKNOWN_IP}

type
  TTracertReplyAttempt = packed record
    Success: Boolean;
    TTL: Byte;
    Attempt: Byte;
    Address: DWORD;
    Status: IP_STATUS;
    Result: DWORD;
    RoundTripTime: DWORD;
  end;
  {$EXTERNALSYM TTracertReplyAttempt}

  TTracertReplyJumpX = packed record
    Success: Boolean;
    TTL: Byte;
    Address: DWORD;
  end;
  {$EXTERNALSYM TTracertReplyJumpX}

  TTraceReply = packed record
    Address: DWORD;
    Status: IP_STATUS;
    Result: DWORD;
    RoundTripTime: DWORD;
  end;
  {$EXTERNALSYM TTraceReply}

  TOnBeforeTraceJumpX = procedure(Sender: TObject; TTL: DWORD; var StopTracing: Boolean) of object;
  {$EXTERNALSYM TOnBeforeTraceJumpX}

  TOnTraceAttempt = procedure(Sender: TObject; TracertReplyAttempt: TTracertReplyAttempt;
    var StopTracing: Boolean) of object;
  {$EXTERNALSYM TOnTraceAttempt}

  TOnAfterTraceJumpX = procedure(Sender: TObject; TracertReplyJumpX: TTracertReplyJumpX;
    var StopTracing: Boolean) of object;
  {$EXTERNALSYM TOnAfterTraceJumpX}

  TOnTraceFinish = procedure(Sender: TObject; Address: DWORD) of object;
  {$EXTERNALSYM TOnTraceFinish}

  TTracertThread = class(TThread)
  private
    FStopTracing: Boolean;
    FTraceHandle: THandle;
    FDestAddr: TInAddr;
    function Trace(const TTL: Byte; var Reply: TTraceReply): Boolean;
  public
    FHost: string;
    FMaxJumpsCount: Byte;
    FAttemptsCount: Byte;
    FTimeout: DWORD;
    FParent: TObject;
    FOnTraceAttempt: TOnTraceAttempt;
    FOnBeforeTraceJumpX: TOnBeforeTraceJumpX;
    FOnAfterTraceJumpX: TOnAfterTraceJumpX;
    FOnTraceFinish: TOnTraceFinish;
  protected
    procedure Execute; override;
  end;
  {$EXTERNALSYM TTracertThread}

  TTracert = class(TComponent)
  private
    FTracertThread: TTracertThread;
    function GetAttemptsCount: Byte;
    function GetHost: string;
    function GetMaxJumpsCount: Byte;
    function GetOnBeforeTraceJumpX: TOnBeforeTraceJumpX;
    function GetOnTraceAttempt: TOnTraceAttempt;
    function GetOnAfterTraceJumpX: TOnAfterTraceJumpX;
    function GetOnTraceFinish: TOnTraceFinish;
    function GetTracingActive: Boolean;
    function GetTimeout: DWORD;
    procedure SetAttemptsCount(const Value: Byte);
    procedure SetHost(const Value: string);
    procedure SetMaxJumpsCount(const Value: Byte);
    procedure SetOnBeforeTraceJumpX(const Value: TOnBeforeTraceJumpX);
    procedure SetOnTraceAttempt(const Value: TOnTraceAttempt);
    procedure SetOnAfterTraceJumpX(const Value: TOnAfterTraceJumpX);
    procedure SetOnTraceFinish(const Value: TOnTraceFinish);
    procedure SetTimeout(const Value: DWORD);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
  published
    property Host: string read GetHost write SetHost;
    property MaxJumpsCount: Byte read GetMaxJumpsCount write SetMaxJumpsCount;
    property AttemptsCount: Byte read GetAttemptsCount write SetAttemptsCount;
    property Timeout: DWORD read GetTimeout write SetTimeout;
    property TracingActive: Boolean read GetTracingActive;
    property OnBeforeTraceJumpX: TOnBeforeTraceJumpX read GetOnBeforeTraceJumpX write
      SetOnBeforeTraceJumpX;
    property OnTraceAttempt: TOnTraceAttempt read GetOnTraceAttempt write SetOnTraceAttempt;
    property OnAfterTraceJumpX: TOnAfterTraceJumpX read GetOnAfterTraceJumpX write
      SetOnAfterTraceJumpX;
    property OnTraceFinish: TOnTraceFinish read GetOnTraceFinish write SetOnTraceFinish;
  end;
  {$EXTERNALSYM TTracert}

function IPv4ToStr(const IP: Longint): string;
{$EXTERNALSYM IPv4ToStr}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Networking', [TTracert]);
end;

function IPv4ToStr(const IP: Longint): string;
begin
  Result := Format('%d.%d.%d.%d', [IP and $FF, (IP shr 8) and $FF, (IP shr 16) and $FF, (IP
    shr 24) and $FF]);
end;

constructor TTracert.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTracertThread := TTracertThread.Create(True);
  FTracertThread.FParent := Self;
  with FTracertThread do
  begin
    FreeOnTerminate := False;
    FHost := string.Empty;
    FAttemptsCount := 3;
    FMaxJumpsCount := 30;
    FTimeout := 5000;
  end;
end;

destructor TTracert.Destroy; //Õ≈ “–Œ√¿“‹ ¡Àﬂ“‹!!!
begin
  FTracertThread.FStopTracing := True;
  FTracertThread.Terminate;
  if FTracertThread.Suspended then
    FTracertThread.Resume;
  FTracertThread.WaitFor;
  TerminateThread(FTracertThread.Handle, 0); //›“Œ Œ—Œ¡≈ÕÕŒ Õ≈ “–Œ√¿“‹!!!
  FreeAndNil(FTracertThread);
  inherited Destroy;
end;

function TTracert.GetAttemptsCount: Byte;
begin
  Result := FTracertThread.FAttemptsCount;
end;

function TTracert.GetHost: string;
begin
  Result := FTracertThread.FHost;
end;

function TTracert.GetMaxJumpsCount: Byte;
begin
  Result := FTracertThread.FMaxJumpsCount;
end;

function TTracert.GetOnTraceAttempt: TOnTraceAttempt;
begin
  Result := FTracertThread.FOnTraceAttempt;
end;

function TTracert.GetOnTraceFinish: TOnTraceFinish;
begin
  Result := FTracertThread.FOnTraceFinish;
end;

function TTracert.GetTimeout: DWORD;
begin
  Result := FTracertThread.FTimeout;
end;

function TTracert.GetTracingActive: Boolean;
begin
  Result := FTracertThread.Started;
end;

function TTracert.GetOnAfterTraceJumpX: TOnAfterTraceJumpX;
begin
  Result := FTracertThread.FOnAfterTraceJumpX;
end;

function TTracert.GetOnBeforeTraceJumpX: TOnBeforeTraceJumpX;
begin
  Result := FTracertThread.FOnBeforeTraceJumpX;
end;

procedure TTracert.SetAttemptsCount(const Value: Byte);
begin
  FTracertThread.FAttemptsCount := Value;
end;

procedure TTracert.SetHost(const Value: string);
begin
  FTracertThread.FHost := Value;
end;

procedure TTracert.SetMaxJumpsCount(const Value: Byte);
begin
  FTracertThread.FMaxJumpsCount := Value;
end;

procedure TTracert.SetOnTraceAttempt(const Value: TOnTraceAttempt);
begin
  FTracertThread.FOnTraceAttempt := Value;
end;

procedure TTracert.SetOnTraceFinish(const Value: TOnTraceFinish);
begin
  FTracertThread.FOnTraceFinish := Value;
end;

procedure TTracert.SetTimeout(const Value: DWORD);
begin
  FTracertThread.FTimeout := Value;
end;

procedure TTracert.SetOnAfterTraceJumpX(const Value: TOnAfterTraceJumpX);
begin
  FTracertThread.FOnAfterTraceJumpX := Value;
end;

procedure TTracert.SetOnBeforeTraceJumpX(const Value: TOnBeforeTraceJumpX);
begin
  FTracertThread.FOnBeforeTraceJumpX := Value;
end;

procedure TTracert.Start;
begin
  FTracertThread.Resume;
end;

procedure TTracert.Stop;
begin
  FTracertThread.FStopTracing := True;
end;

procedure TTracertThread.Execute;
var
  i: Byte;
  TTL: Byte;
  WSAData: TWSAData;
  pHostEntry: PHostEnt;
  Reply: TTraceReply;
  TracertReplyAttempt: TTracertReplyAttempt;
  TracertReplyJumpX: TTracertReplyJumpX;
begin
  while not Terminated do
  begin
    if WSAStartup(WINSOCK_VERSION, WSAData) = 0 then
    try
      FTraceHandle := IcmpCreateFile();
      if FTraceHandle <> INVALID_HANDLE_VALUE then
      try
        if TRegEx.IsMatch(FHost, '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b') then
          FDestAddr := TInAddr(inet_addr(PAnsiChar(AnsiString(FHost))))
        else
        begin
          pHostEntry := gethostbyname(PAnsiChar(AnsiString(FHost)));
          if pHostEntry <> nil then
            FDestAddr := PInAddr(pHostEntry.h_addr_list^)^
          else
            FDestAddr.S_addr := UNKNOWN_IP;
        end;
        TTL := 0;
        Reply.Address := UNKNOWN_IP;
        FStopTracing := False;
        if FDestAddr.S_addr <> UNKNOWN_IP then
          while (Reply.Address <> FDestAddr.S_addr) and (TTL <> FMaxJumpsCount) do
          begin
            Inc(TTL);
            if Assigned(FOnBeforeTraceJumpX) then
              Synchronize(
                procedure()
                begin
                  FOnBeforeTraceJumpX(FParent, TTL, FStopTracing);
                end);
            if FStopTracing then
              Break;
            TracertReplyJumpX.TTL := TTL;
            TracertReplyJumpX.Success := False;
            TracertReplyJumpX.Address := UNKNOWN_IP;
            for i := 0 to Pred(FAttemptsCount) do
            begin
              if Trace(TTL, Reply) then
              begin
                TracertReplyJumpX.Success := True;
                TracertReplyJumpX.Address := Reply.Address;
                TracertReplyAttempt.Success := True;
              end
              else
                TracertReplyAttempt.Success := False;
              TracertReplyAttempt.RoundTripTime := Reply.RoundTripTime;
              TracertReplyAttempt.TTL := TTL;
              TracertReplyAttempt.Attempt := Succ(i);
              TracertReplyAttempt.Address := Reply.Address;
              TracertReplyAttempt.Status := Reply.Status;
              TracertReplyAttempt.Result := Reply.Result;
              if Assigned(FOnTraceAttempt) then
                Synchronize(
                  procedure()
                  begin
                    FOnTraceAttempt(FParent, TracertReplyAttempt, FStopTracing);
                  end);
              if FStopTracing then
                Break;
            end;
            if FStopTracing then
              Break;
            if Assigned(FOnAfterTraceJumpX) then
              Synchronize(
                procedure()
                begin
                  FOnAfterTraceJumpX(FParent, TracertReplyJumpX, FStopTracing);
                end);
            if FStopTracing then
              Break;
          end;
        if Assigned(FOnTraceFinish) then
          Synchronize(
            procedure()
            begin
              FOnTraceFinish(FParent, TracertReplyJumpX.Address);
            end);
      finally
        IcmpCloseHandle(FTraceHandle);
      end;
    finally
      WSACleanup;
    end;
    if not Terminated then
      Suspend;
  end;
end;

function TTracertThread.Trace(const TTL: Byte; var Reply: TTraceReply): Boolean;
var
  iop: TIpOptionInformation;
  pReply: PIcmpEchoReply;
begin
  Result := False;
  New(pReply); //Õ≈ “–Œ√¿“‹!!!
  try
    ZeroMemory(pReply, SizeOf(pReply));
    ZeroMemory(@iop, SizeOf(iop));
    iop.Ttl := TTL;
    Reply.Result := IcmpSendEcho(FTraceHandle, FDestAddr, nil, 0, @iop, pReply, SizeOf(TIcmpEchoReply),
      FTimeout);
    if Reply.Result <> 0 then
    begin
      Result := True;
      Reply.Address := pReply.Address.S_addr;
    end
    else
      Reply.Address := UNKNOWN_IP;
    Reply.Status := pReply.Status;
    Reply.RoundTripTime := pReply.RoundTripTime;
  finally
    Dispose(pReply); //Õ≈ “–Œ√¿“‹!!!
  end;
end;

end.

