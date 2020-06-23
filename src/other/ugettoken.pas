unit uGetToken;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, HTTPDefs, uCookies;

  function GetToken(ARequest: TRequest) : string;
  procedure SetToken(AResponse: TResponse; mytoken : string);

implementation
uses
    uSmartDebugLog;

function GetToken(ARequest: TRequest): string;
begin
     result := GetCookie(ARequest, 'mytoken');
end;

procedure SetToken(AResponse: TResponse; mytoken : string);
begin
     SetCookie(AResponse, 'mytoken', mytoken);
end;

end.

