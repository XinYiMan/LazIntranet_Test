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
         procedure OnBodyLoad(ARequest: TRequest; AResponse: TResponse; mytoken: string);
  public

  end;

var
  FPWebModuleLogin: TFPWebModuleLogin;

implementation
uses
    NGIT_Crypto_JWT, uVerifiedJWT, uGetToken, uCookies, uWPSInterpreter, uSmartDebugLog;

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
   remember_me        : string;
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
              user        := ARequest.QueryFields.Values['email'];
              pwd         := ARequest.QueryFields.Values['password'];
              remember_me := ARequest.QueryFields.Values['remember_me'];
              id_user := ValidLogin(user, pwd);
              if id_user>0 then
              begin

                   if remember_me<>'' then
                   begin
                        SetCookie(AResponse,'remember_user',user);
                        SetCookie(AResponse,'remember_pwd',pwd);
                   end else begin
                        SetCookie(AResponse,'remember_user','');
                        SetCookie(AResponse,'remember_pwd','');
                   end;

                   mytoken := GenerateJWT(id_user, user);
                   SetToken(AResponse, mytoken);
                   AResponse.SendRedirect('/index');
              end
              else
              begin
                   AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + 'login.html');
                   OnBodyLoad(ARequest, AResponse, mytoken);
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

procedure TFPWebModuleLogin.OnBodyLoad(ARequest: TRequest;
  AResponse: TResponse; mytoken: string);
var
   WPSInterpreter1     : TWPSInterpreter;
   WPSInterpreterItem1 : array of TWPSInterpreterItem;
   code_html           : string;
   remember_user       : string;
   remember_pwd        : string;
begin
     remember_user     := GetCookie(ARequest, 'remember_user');
     remember_pwd      := GetCookie(ARequest, 'remember_pwd');


     SetLength(WPSInterpreterItem1,0);

     SetLength(WPSInterpreterItem1, Length(WPSInterpreterItem1)+1);
     WPSInterpreterItem1[Length(WPSInterpreterItem1)-1].key   := 'user';
     WPSInterpreterItem1[Length(WPSInterpreterItem1)-1].value := remember_user;

     SetLength(WPSInterpreterItem1, Length(WPSInterpreterItem1)+1);
     WPSInterpreterItem1[Length(WPSInterpreterItem1)-1].key   := 'pwd';
     WPSInterpreterItem1[Length(WPSInterpreterItem1)-1].value := remember_pwd;

     SetLength(WPSInterpreterItem1, Length(WPSInterpreterItem1)+1);
     WPSInterpreterItem1[Length(WPSInterpreterItem1)-1].key   := 'remember_checked';
     if (trim(remember_user)<>'') and (trim(remember_pwd)<>'') then
         WPSInterpreterItem1[Length(WPSInterpreterItem1)-1].value := 'checked'
     else
         WPSInterpreterItem1[Length(WPSInterpreterItem1)-1].value := '';

     WPSInterpreter1    := TWPSInterpreter.Create;
     code_html          := AResponse.Contents.Text;
     WPSInterpreter1.Execute(code_html, WPSInterpreterItem1);
     AResponse.Contents.Text := code_html;

     WPSInterpreter1.Free;
     WPSInterpreter1 := nil;
end;

initialization

end.

