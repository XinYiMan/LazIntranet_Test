program httpproject1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  fpwebfile, HTTPDefs, SysUtils, fphttp, fphttpapp, uAssets, uCustomException,
  uCustomGetModule, uIndex, uLogin, uProfile, uTable, uRegister, uLogOut
  {$ifdef ActiveSSL}
  ,opensslsockets
  {$endif}
  ;

procedure MyShowRequestException(AResponse: TResponse; AnException: Exception; var handled: boolean);
begin
     writeln('MyShowRequestException: ' + AnException.Message);
end;

var
   MyCustomException : TCustomException;
   MyCustomGetModule : TCustomGetModule;

begin
  MyCustomException := TCustomException.Create;
  MyCustomGetModule := TCustomGetModule.Create;

  RegisterHTTPModule('assets', TFPWebModuleAssets);
  RegisterHTTPModule('index', TFPWebModuleIndex);
  RegisterHTTPModule('index.html', TFPWebModuleIndex);
  RegisterHTTPModule('login', TFPWebModuleLogin);
  RegisterHTTPModule('login.html', TFPWebModuleLogin);
  RegisterHTTPModule('profile', TFPWebModuleProfile);
  RegisterHTTPModule('profile.html', TFPWebModuleProfile);
  RegisterHTTPModule('table', TFPWebModuleTable);
  RegisterHTTPModule('table.html', TFPWebModuleTable);
  RegisterHTTPModule('register', TFPWebModuleRegister);
  RegisterHTTPModule('register.html', TFPWebModuleRegister);
  RegisterHTTPModule('logout', TFPWebModuleLogOut);
  RegisterHTTPModule('logout.html', TFPWebModuleLogOut);

  Application.OnShowRequestException := @MyShowRequestException;
  Application.OnException            := @MyCustomException.MyException;
  Application.OnGetModule            := @MyCustomGetModule.MyGetModule;
  {$ifdef ActiveSSL}
  Application.UseSSL                 := true;
  {$endif}

  Application.Title:='httpproject1';
  Application.Port:=3035;

  if not Application.UseSSL then
     writeln('http://localhost:' + IntToStr(Application.Port))
  else
      writeln('https://localhost:' + IntToStr(Application.Port));

  Application.Threaded:=True;
  Application.Initialize;
  Application.Run;

  MyCustomGetModule.Free;
  MyCustomGetModule := nil;
  MyCustomException.Free;
  MyCustomException := nil;
end.

