unit uGuardianEndPoint;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TGuardianEndPoint }

  TGuardianEndPoint = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private

  public

  end;

var
  GuardianEndPoint: TGuardianEndPoint;

implementation

{$R *.lfm}

{ TGuardianEndPoint }

procedure TGuardianEndPoint.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
begin
     AResponse.Contents.Text:='{"status" : "active"}';
     AResponse.ContentType := 'text/json; charset=utf-8';

     Handled := true;
end;

initialization

end.

