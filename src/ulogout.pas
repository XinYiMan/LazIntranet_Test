unit uLogOut;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleLogOut }

  TFPWebModuleLogOut = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private

  public

  end;

var
  FPWebModuleLogOut: TFPWebModuleLogOut;

implementation
uses
    uGetToken;

{$R *.lfm}

{ TFPWebModuleLogOut }

procedure TFPWebModuleLogOut.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
begin
     SetToken(AResponse,'');
     AResponse.SendRedirect('login');

     Handled := true;
end;

initialization

end.

