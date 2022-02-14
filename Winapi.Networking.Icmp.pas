unit Winapi.Networking.Icmp;

interface

uses
  Winapi.Windows, Winapi.Winsock2, Winapi.IpHlpApi, Winapi.IpExport;

const
  //IP_OPTION_INFORMATION->Flags
  IP_FLAG_REVERSE = $01; //This value causes the IP packet to add in an IP routing header with the source.
  {$EXTERNALSYM IP_FLAG_REVERSE}
  IP_FLAG_DF = $02; //This value indicates that the packet should not be fragmented.
  {$EXTERNALSYM IP_FLAG_DF}

  //ICMP_ECHO_REPLY->Status
  IP_STATUS_BASE = 11000;
  {$EXTERNALSYM IP_STATUS_BASE}
  IP_SUCCESS = 0; //The status was success.
  {$EXTERNALSYM IP_SUCCESS}
  IP_BUF_TOO_SMALL = IP_STATUS_BASE + 1; //The reply buffer was too small.
  {$EXTERNALSYM IP_BUF_TOO_SMALL}
  IP_DEST_NET_UNREACHABLE = IP_STATUS_BASE + 2; //The destination network was unreachable.
  {$EXTERNALSYM IP_DEST_NET_UNREACHABLE}
  IP_DEST_HOST_UNREACHABLE = IP_STATUS_BASE + 3; //The destination host was unreachable.
  {$EXTERNALSYM IP_DEST_HOST_UNREACHABLE}
  IP_DEST_PROT_UNREACHABLE = IP_STATUS_BASE + 4; //The destination protocol was unreachable.
  {$EXTERNALSYM IP_DEST_PROT_UNREACHABLE}
  IP_DEST_PORT_UNREACHABLE = IP_STATUS_BASE + 5; //The destination port was unreachable.
  {$EXTERNALSYM IP_DEST_PORT_UNREACHABLE}
  IP_NO_RESOURCES = IP_STATUS_BASE + 6; //Insufficient IP resources were available.
  {$EXTERNALSYM IP_NO_RESOURCES}
  IP_BAD_OPTION = IP_STATUS_BASE + 7; //A bad IP option was specified.
  {$EXTERNALSYM IP_BAD_OPTION}
  IP_HW_ERROR = IP_STATUS_BASE + 8; //A hardware error occurred.
  {$EXTERNALSYM IP_HW_ERROR}
  IP_PACKET_TOO_BIG = IP_STATUS_BASE + 9; //The packet was too big.
  {$EXTERNALSYM IP_PACKET_TOO_BIG}
  IP_REQ_TIMED_OUT = IP_STATUS_BASE + 10; //The request timed out.
  {$EXTERNALSYM IP_REQ_TIMED_OUT}
  IP_BAD_REQ = IP_STATUS_BASE + 11; //A bad request.
  {$EXTERNALSYM IP_BAD_REQ}
  IP_BAD_ROUTE = IP_STATUS_BASE + 12; //A bad route.
  {$EXTERNALSYM IP_BAD_ROUTE}
  IP_TTL_EXPIRED_TRANSIT = IP_STATUS_BASE + 13; //The time to live (TTL) expired in transit.
  {$EXTERNALSYM IP_TTL_EXPIRED_TRANSIT}
  IP_TTL_EXPIRED_REASSEM = IP_STATUS_BASE + 14; //The time to live expired during fragment reassembly.
  {$EXTERNALSYM IP_TTL_EXPIRED_REASSEM}
  IP_PARAM_PROBLEM = IP_STATUS_BASE + 15; //A parameter problem.
  {$EXTERNALSYM IP_PARAM_PROBLEM}
  IP_SOURCE_QUENCH = IP_STATUS_BASE + 16; //Datagrams are arriving too fast to be processed and datagrams may have been discarded.
  {$EXTERNALSYM IP_SOURCE_QUENCH}
  IP_OPTION_TOO_BIG = IP_STATUS_BASE + 17; //An IP option was too big.
  {$EXTERNALSYM IP_OPTION_TOO_BIG}
  IP_BAD_DESTINATION = IP_STATUS_BASE + 18; //A bad destination.
  {$EXTERNALSYM IP_BAD_DESTINATION}
  IP_GENERAL_FAILURE = IP_STATUS_BASE + 50; //A general failure. This error can be returned for some malformed ICMP packets.
  {$EXTERNALSYM IP_GENERAL_FAILURE}
  MAX_IP_STATUS = IP_GENERAL_FAILURE;
  {$EXTERNALSYM MAX_IP_STATUS}
  IP_PENDING = IP_STATUS_BASE + 255;
  {$EXTERNALSYM IP_PENDING}

  //
  IP_OPT_EOL = $00; // End of list option
  {$EXTERNALSYM IP_OPT_EOL}
  IP_OPT_NOP = $01; // No operation
  {$EXTERNALSYM IP_OPT_NOP}
  IP_OPT_SECURITY = $82; // Security option
  {$EXTERNALSYM IP_OPT_SECURITY}
  IP_OPT_LSRR = $83; // Loose source route
  {$EXTERNALSYM IP_OPT_LSRR}
  IP_OPT_SSRR = $89; // Strict source route
  {$EXTERNALSYM IP_OPT_SSRR}
  IP_OPT_RR = $07; // Record route
  {$EXTERNALSYM IP_OPT_RR}
  IP_OPT_TS = $44; // Timestamp
  {$EXTERNALSYM IP_OPT_TS}
  IP_OPT_SID = $88; // Stream ID (obsolete)
  {$EXTERNALSYM IP_OPT_SID}
  IP_OPT_ROUTER_ALERT = $94; // Router Alert Option
  {$EXTERNALSYM IP_OPT_ROUTER_ALERT}

  MAX_OPT_SIZE = 40; // Maximum length of IP options in bytes
  {$EXTERNALSYM MAX_OPT_SIZE}

type
  NTSTATUS = LongInt;
  {$EXTERNALSYM NTSTATUS}

  PIO_STATUS_BLOCK = ^IO_STATUS_BLOCK;
  {$EXTERNALSYM PIO_STATUS_BLOCK}

  IO_STATUS_BLOCK = packed record
    Status: NTSTATUS;
    Information: ULONG;
  end;
  {$EXTERNALSYM IO_STATUS_BLOCK}

  TIoStatusBlock = IO_STATUS_BLOCK;
  {$EXTERNALSYM TIoStatusBlock}

  PIoStatusBlock = ^TIoStatusBlock;
  {$EXTERNALSYM PIoStatusBlock}

  PIO_APC_ROUTINE = ^IO_APC_ROUTINE;
  {$EXTERNALSYM PIO_APC_ROUTINE}

  IO_APC_ROUTINE = procedure(ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Reserved:
    ULONG); stdcall;
  {$EXTERNALSYM IO_APC_ROUTINE}

  TIoApcRoutine = IO_APC_ROUTINE;
  {$EXTERNALSYM TIoApcRoutine}

  PIoApcRoutine = ^TIoApcRoutine;
  {$EXTERNALSYM PIoApcRoutine}

  PIP_OPTION_INFORMATION = ^IP_OPTION_INFORMATION;
  {$EXTERNALSYM PIP_OPTION_INFORMATION}

  IP_OPTION_INFORMATION = packed record
    Ttl: UCHAR;
    Tos: UCHAR;
    Flags: UCHAR;
    OptionsSize: UCHAR;
    OptionsData: Pointer;
  end;
  {$EXTERNALSYM IP_OPTION_INFORMATION}

  PIpOptionInformation = ^TIpOptionInformation;
  {$EXTERNALSYM PIpOptionInformation}

  TIpOptionInformation = IP_OPTION_INFORMATION;
  {$EXTERNALSYM TIpOptionInformation}

  PICMP_ECHO_REPLY = ^ICMP_ECHO_REPLY;
  {$EXTERNALSYM PICMP_ECHO_REPLY}

  ICMP_ECHO_REPLY = packed record
    Address: TInAddr;
    Status: IP_STATUS;
    RoundTripTime: ULONG;
    DataSize: USHORT;
    Reserved: USHORT;
    Data: PVOID;
    Options: IP_OPTION_INFORMATION;
  end;
  {$EXTERNALSYM ICMP_ECHO_REPLY}

  PIcmpEchoReply = ^TIcmpEchoReply;
  {$EXTERNALSYM PIcmpEchoReply}

  TIcmpEchoReply = ICMP_ECHO_REPLY;
  {$EXTERNALSYM TIcmpEchoReply}

  TIcmpCreateFile = function(): THandle; stdcall;
  {$EXTERNALSYM TIcmpCreateFile}

  TIcmpCloseHandle = function(IcmpHandle: THandle): BOOL; stdcall;
  {$EXTERNALSYM TIcmpCloseHandle}

  TIcmpSendEcho = function(IcmpHandle: THandle; DestinationAddress: TInAddr; RequestData:
    LPVOID; RequestSize: WORD; RequestOptions: PIpOptionInformation; ReplyBuffer: LPVOID;ReplySize
  {_In_range_(>=, sizeof(ICMP_ECHO_REPLY) + RequestSize + 8)}: DWORD; Timeout: DWORD):
    DWORD; stdcall;
  {$EXTERNALSYM TIcmpSendEcho}

  TIcmpSendEcho2 = function(IcmpHandle: THandle; Event: THandle; ApcRoutine: TIoApcRoutine;
    ApcContext: PVOID; DestinationAddress: TInAddr; RequestData: LPVOID; RequestSize: WORD;
    RequestOptions: PIpOptionInformation; ReplyBuffer: LPVOID;ReplySize
  {_In_range_(>=, sizeof(ICMP_ECHO_REPLY) + RequestSize + 8)}: DWORD; Timeout: DWORD):
    DWORD; stdcall;
  {$EXTERNALSYM TIcmpSendEcho2}

var
  IcmpCreateFile: TIcmpCreateFile = nil;
  IcmpCloseHandle: TIcmpCloseHandle = nil;
  IcmpSendEcho: TIcmpSendEcho = nil;
  IcmpSendEcho2: TIcmpSendEcho2 = nil;

implementation

const
  IcmpDll = 'icmp.dll';
  IpHlpApiDll = 'iphlpapi.dll';
  szIcmpCreateFile = 'IcmpCreateFile';
  szIcmpCloseHandle = 'IcmpCloseHandle';
  szIcmpSendEcho = 'IcmpSendEcho';
  szIcmpSendEcho2 = 'IcmpSendEcho2';

var
  hLibrary: HMODULE = 0;

procedure InitICMP;
var
  DllExists: Boolean;
begin
  hLibrary := GetModuleHandle(IpHlpApiDll);
  if hLibrary = 0 then
  begin
    DllExists := False;
    hLibrary := LoadLibrary(IpHlpApiDll);
  end
  else
    DllExists := True;
  if hLibrary <> 0 then
  begin
    IcmpCreateFile := GetProcAddress(hLibrary, szIcmpCreateFile);
    if @IcmpCreateFile = nil then
    begin
      if not DllExists then
        FreeLibrary(hLibrary);
      hLibrary := GetModuleHandle(IcmpDll);
      if hLibrary = 0 then
      begin
        DllExists := False;
        hLibrary := LoadLibrary(IcmpDll);
      end
      else
        DllExists := True;
      if hLibrary <> 0 then
      begin
        IcmpCreateFile := GetProcAddress(hLibrary, szIcmpCreateFile);
        if @IcmpCreateFile = nil then
        begin
          if not DllExists then
            FreeLibrary(hLibrary);
          Exit;
        end;
      end;
    end;
    IcmpCloseHandle := GetProcAddress(hLibrary, szIcmpCloseHandle);
    IcmpSendEcho := GetProcAddress(hLibrary, szIcmpSendEcho);
    IcmpSendEcho2 := GetProcAddress(hLibrary, szIcmpSendEcho2);
    if (@IcmpCloseHandle = nil) or (@IcmpSendEcho = nil) or (@IcmpSendEcho2 = nil) then
    begin
      if not DllExists then
        FreeLibrary(hLibrary);
      Exit;
    end;
  end;
end;

initialization
  InitICMP;

finalization
  FreeLibrary(hLibrary);

end.

