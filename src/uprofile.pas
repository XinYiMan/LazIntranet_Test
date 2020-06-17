unit uProfile;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleProfile }

  TFPWebModuleProfile = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private
         procedure OnBodyLoad(AResponse: TResponse; mytoken: string);
  public

  end;

var
  FPWebModuleProfile: TFPWebModuleProfile;

implementation
uses
    NGIT_Crypto_JWT, uVerifiedJWT, uGetToken;

{$R *.lfm}

{ TFPWebModuleProfile }

procedure TFPWebModuleProfile.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
var
   mytoken            : string;
   valid_token        : boolean;
begin
     valid_token        := false;
     mytoken            := GetToken(aRequest);

     if trim(mytoken)='' then
     begin

     end else begin

         mytoken  := VerifiedJWT(mytoken);
         if trim(mytoken)='' then
         begin

         end else begin
             valid_token := true;
         end;

     end;

     if valid_token then
     begin
          SetToken(AResponse, mytoken);
          AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + 'profile.html');
          OnBodyLoad(AResponse, mytoken);
     end else begin
          AResponse.SendRedirect('login');
     end;

     Handled            := true;
end;

procedure TFPWebModuleProfile.OnBodyLoad(AResponse: TResponse; mytoken: string);
begin
     //AResponse.Contents.Text := stringReplace(AResponse.Contents.Text, '{*mytoken*}', mytoken, [RfReplaceAll, rfIgnoreCase]);
     SetToken(AResponse, mytoken);
end;

initialization

end.

