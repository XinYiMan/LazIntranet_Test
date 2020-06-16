unit uRegister;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleRegister }

  TFPWebModuleRegister = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private
         procedure OnBodyLoad(AResponse: TResponse; mytoken: string);
  public

  end;

var
  FPWebModuleRegister: TFPWebModuleRegister;

implementation
uses
    NGIT_Crypto_JWT, uVerifiedJWT, uGetToken;

{$R *.lfm}

{ TFPWebModuleRegister }

procedure TFPWebModuleRegister.indexRequest(Sender: TObject;
  ARequest: TRequest; AResponse: TResponse; var Handled: Boolean);
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
          AResponse.SendRedirect('index');
     end else begin
              AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + 'register.html');
              OnBodyLoad(AResponse, mytoken);
     end;

     Handled            := true;
end;

procedure TFPWebModuleRegister.OnBodyLoad(AResponse: TResponse; mytoken: string
  );
begin

end;

initialization

end.

