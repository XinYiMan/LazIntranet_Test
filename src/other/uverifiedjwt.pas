unit uVerifiedJWT;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, NGIT_Crypto_JWT;

function VerifiedJWT(mytoken: string): string;
function GenerateJWT(id_user : integer; username : string) : string;

const
     jwt_password = '123HelloWorld456';
     jwt_timeout  = 15;

implementation

function VerifiedJWT(mytoken: string): string;
var
   output          : string;
   id_user_str     : string;
   error           : string;
   id_user         : integer;
   str_expired     : string;
   date_expired    : TDateTime;
   ret             : string;
   username        : string;
begin
  //user logged

  ret := '';
  if NGITJWTParse(mytoken, jwt_password, Output) then
  begin
       //valid token
       //refresh token exp value
        if NGITExtractValue(mytoken, 'iduser',id_user_str, error) then
        begin

                  id_user := StrToIntDef(id_user_str , -1);
                  if id_user <> -1 then
                  begin

                       NGITExtractValue(mytoken, 'username',username, error);
                       date_expired := IncMinute(Now,jwt_timeout);
                       str_expired  := IntToStr(MillisecondsBetween(date_expired,0));
                       ret := NGITJWTSign(jwt_password,'{ "iduser" : "' + IntToStr(id_user) + '" , "username" : "' + username + '" , "exp" : "' + str_expired + '" }');

                  end;


        end;

  end;
  result := ret;
end;

function GenerateJWT(id_user: integer; username: string): string;
var
   date_expired : TDateTime;
   str_expired  : string;
begin
     date_expired := IncMinute(Now,jwt_timeout);
     str_expired  := IntToStr(MillisecondsBetween(date_expired,0));
     result := NGITJWTSign(jwt_password,'{ "iduser" : "' + IntToStr(id_user) + '" , "username" : "' + username + '" , "exp" : "' + str_expired + '" }');
end;

end.

