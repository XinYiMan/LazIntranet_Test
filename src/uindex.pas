unit uIndex;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleIndex }

  TFPWebModuleIndex = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
    procedure set_item_todolistRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private
         procedure OnBodyLoad(AResponse: TResponse; mytoken: string);
  public

  end;

var
  FPWebModuleIndex: TFPWebModuleIndex;

implementation
uses
    NGIT_Crypto_JWT, uVerifiedJWT, uGetToken, fpjson;

{$R *.lfm}

{ TFPWebModuleIndex }

procedure TFPWebModuleIndex.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
var
   mytoken            : string;
   valid_token        : boolean;
begin
     valid_token        := false;
     mytoken            := GetToken(aRequest);
     if mytoken = '' then
     begin
          mytoken := ARequest.QueryFields.Values['mytoken'];
          SetToken(AResponse, mytoken);
     end;

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
          AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + 'index.html');
          OnBodyLoad(AResponse, mytoken);
     end else begin
          AResponse.SendRedirect('login');
     end;

     Handled            := true;
end;

procedure TFPWebModuleIndex.set_item_todolistRequest(Sender: TObject;
  ARequest: TRequest; AResponse: TResponse; var Handled: Boolean);
var
   mytoken            : string;
   valid_token        : boolean;
   key                : integer;
   value              : integer;
   json_ret           : TJSONObject;
   code               : integer;
   description        : string;
begin
     valid_token        := false;
     mytoken            := GetToken(aRequest);
     if mytoken = '' then
     begin
          mytoken := ARequest.QueryFields.Values['mytoken'];
          SetToken(AResponse, mytoken);
     end;

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
          key   := StrToIntDef(ARequest.ContentFields.Values['key'],-1);
          value := StrToIntDef(ARequest.ContentFields.Values['value'],-1);

          code        := 0;
          description := 'valid token';

     end else begin
         code           := -1;
         description    := 'Invalid token';
     end;

     json_ret := TJSONObject.Create(['code',IntToStr(code),
                         'description',description]);

     AResponse.Contents.Text := json_ret.AsJSON;

     json_ret.Free;
     json_ret := nil;

     Handled := true;
end;

procedure TFPWebModuleIndex.OnBodyLoad(AResponse: TResponse; mytoken: string);
begin
     SetToken(AResponse, mytoken);
end;

initialization

end.

