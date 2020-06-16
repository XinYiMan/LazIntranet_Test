unit uLogin;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleLogin }

  TFPWebModuleLogin = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private
         function ValidLogin(username: string; password: string): integer;
  public

  end;

var
  FPWebModuleLogin: TFPWebModuleLogin;

implementation
uses
    NGIT_Crypto_JWT, uVerifiedJWT, uGetToken;

{$R *.lfm}

{ TFPWebModuleLogin }

procedure TFPWebModuleLogin.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
var
   mytoken            : string;
   valid_token        : boolean;
   user               : string;
   pwd                : string;
   id_user            : integer;
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
          AResponse.SendRedirect('index');
     end else begin

              user    := ARequest.QueryFields.Values['email'];
              pwd     := ARequest.QueryFields.Values['password'];
              id_user := ValidLogin(user, pwd);
              if id_user>0 then
              begin
                   mytoken := GenerateJWT(id_user, user);
                   SetToken(AResponse, mytoken);
                   AResponse.SendRedirect('index');
              end
              else
              begin
                   AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + 'login.html');
              end;
     end;

     Handled  := true;
end;

function TFPWebModuleLogin.ValidLogin(username: string; password: string
  ): integer;
begin
     if (username = 'root@root.com') and (password = 'toor') then
        result := 1
     else
         result := 0;
end;

initialization

end.

