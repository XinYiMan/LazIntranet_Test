unit uThreadControl;

interface

uses
  Classes, sysutils, Process;

type

  { TThreadControl }

  TThreadControl = class(TThread)
  private
         procedure NotifyMessage(IdxUrl: integer; Url: string; Msg: string);
         procedure RunMicroService(Path : string);
  public
    constructor Create();
    Destructor Destroy; override;
    procedure Execute; override;
  end;

implementation
uses
    uVisualMain, uGetHtml;

{ TEchoDaemon }

procedure TThreadControl.NotifyMessage(IdxUrl : integer; Url : string; Msg: string);
begin
  EnterCriticalSection(Form1.MyCriticalSection);
  Form1.IdxUrlNotify  := IdxUrl;
  Form1.UrlNotify     := Url;
  Form1.MessageNotify := Msg;
  Synchronize(@Form1.NotifyMessage);
  LeaveCriticalsection(Form1.MyCriticalSection);
end;

procedure TThreadControl.RunMicroService(Path: string);
var
   AProcess: TProcess;
begin
     if FileExists(Path) then
     begin
          AProcess := TProcess.Create(nil);

          AProcess.Executable := Path;
          AProcess.Options    := [poNoConsole];
          AProcess.Execute;

          AProcess.Free;
          AProcess := nil;
     end;
end;

constructor TThreadControl.Create();
begin
  inherited create(true);
  FreeOnTerminate:=true;
end;

destructor TThreadControl.Destroy;
begin
end;

procedure TThreadControl.Execute;
var
   i   : integer;
   ret : string;
begin

  repeat
    if terminated then break;

    for i := 0 to Form1.GuardianCount-1 do
    begin
         ret := GetHTML(Form1.GuardianUrls[i],[]);
         if (trim(ret)='') and (Form1.GuardianUrlsStatus[i]) then
         begin
              Self.NotifyMessage(i, Form1.GuardianUrls[i], 'unexpectedly stopped.');
         end;
         if (trim(ret)<>'') and (not Form1.GuardianUrlsStatus[i]) then
         begin
              Self.NotifyMessage(i, Form1.GuardianUrls[i], 'started.');
         end;
         if (trim(ret)='') and (Form1.GuardianRunIfUrlNotRun) then
            RunMicroService(Form1.GuardianPaths[i]);
    end;

    Sleep(1000);

  until false;

end;

end.
