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
    NGIT_Crypto_JWT, uVerifiedJWT;

{$R *.lfm}

{ TFPWebModuleRegister }

procedure TFPWebModuleRegister.indexRequest(Sender: TObject;
  ARequest: TRequest; AResponse: TResponse; var Handled: Boolean);
var
   mytoken            : string;
   valid_token        : boolean;
begin
     valid_token        := false;
     mytoken            := ARequest.QueryFields.Values['mytoken'];
     if trim(mytoken) = '' then
        mytoken            := ARequest.ContentFields.Values['mytoken'];

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
     AResponse.Contents.Text := stringReplace(AResponse.Contents.Text, '{*mytoken*}', mytoken, [RfReplaceAll, rfIgnoreCase]);
end;

initialization

end.

