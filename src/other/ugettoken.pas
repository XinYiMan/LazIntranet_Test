unit uGetToken;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, HTTPDefs;

  function GetToken(ARequest: TRequest) : string;
  procedure SetToken(AResponse: TResponse; mytoken : string);

implementation

function GetToken(ARequest: TRequest): string;
begin
     result := ARequest.CookieFields.values['mytoken'];
end;

procedure SetToken(AResponse: TResponse; mytoken : string);
var
   C : TCookie;
begin
     C      := AResponse.Cookies.Add;
     C.Name := 'mytoken';
     C.Value := mytoken;
end;

end.

