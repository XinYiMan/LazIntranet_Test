unit uCookies;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, HTTPDefs;

  function GetCookie(ARequest: TRequest; name : string) : string;
  procedure SetCookie(AResponse: TResponse; name : string; value : string);


implementation
uses
    uSmartDebugLog;

function GetCookie(ARequest: TRequest; name: string): string;
var
   i : integer;
begin
     {for i := 0 to ARequest.CookieFields.Count - 1 do
     begin
         SmartDebugLog.write('uCookies','',{$I %CURRENTROUTINE%},ARequest.CookieFields.Names[i] + ' - ' + IntToStr(i) + ': ' + ARequest.CookieFields.ValueFromIndex[i]);
     end;}
     result := ARequest.CookieFields.values[name];
end;

procedure SetCookie(AResponse: TResponse; name: string; value: string);
var
   C    : TCookie;
   i    : integer;
   exit : boolean;
begin

     try
        try

          i    := AResponse.Request.CookieFields.Count - 1;
          exit := false;
          while (i >= 0) and (not exit) do
          begin

               if lowercase(trim(AResponse.Request.CookieFields.Names[i])) = lowercase(trim(name)) then
               begin
                    AResponse.Request.CookieFields.Delete(i);
                    exit := true;
               end else begin
                   Dec(i);
               end;

          end;

          C       := AResponse.Cookies.Add;
          C.Name  := name;
          C.Value := value;

     finally

    end;
  except
        on E: Exception do
        begin

             SmartDebugLog.write('uCookies','',{$I %CURRENTROUTINE%},'SetCookie: ' + E.Message);

        end;
  end;

end;

end.

