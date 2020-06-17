program httpproject1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  fpwebfile, HTTPDefs, SysUtils, Classes, fphttp, fphttpapp, uCustomException,
  uCustomGetModule, uIndex, uLogin, uProfile, uTable, uRegister, uLogOut, uFavIcon
  {$ifdef ActiveSSL}
  ,opensslsockets
  {$endif}
  ;

procedure MyShowRequestException(AResponse: TResponse; AnException: Exception; var handled: boolean);
var
  filename : string;
  myfile   : TFileStream;
begin
     try
        try

           filename := ExtractFilePath(ParamStr(0)) + 'HTML' + AResponse.Request.URI;
           if FileExists(filename) then
           begin

                //writeln('**' + AResponse.Request.URI);

                myfile          := TFileStream.Create(filename, fmOpenRead + fmShareDenyWrite);
                myfile.Position := 0;

                AResponse.ContentStream := myfile;

                case lowercase(ExtractFileExt(filename)) of

                     '.js' : begin
                             AResponse.ContentType := 'application/javascript; charset=utf-8';
                     end;

                     '.gif' : begin
                             AResponse.ContentType := 'image/gif';
                     end;

                     '.css' : begin
                             AResponse.ContentType := 'text/css; charset=utf-8';
                     end;

                     '.tiff','.tif' : begin
                             AResponse.ContentType := 'image/tiff';
                     end;

                     '.jpg' : begin
                             AResponse.ContentType := 'image/jpeg';
                     end;

                     '.ico' : begin
                             AResponse.ContentType := 'image/ico';
                     end;

                     '.jpeg' : begin
                             AResponse.ContentType := 'image/jpeg';
                     end;

                     '.png' : begin
                             AResponse.ContentType := 'image/png';
                     end;

                     '.html' : begin
                             AResponse.ContentType := 'text/html; charset=utf-8';
                     end;

                     '.json' : begin
                             AResponse.ContentType := 'text/json; charset=utf-8';
                     end;

                     '.txt' : begin
                             AResponse.ContentType := 'text/plain; charset=utf-8';
                     end;

                     '.ttf' : begin
                             AResponse.ContentType := 'text/html; charset=utf-8';
                     end;

                     '.zip' : begin
                             AResponse.ContentType := 'application/zip';
                     end;

                     '.exe' : begin
                             AResponse.ContentType := 'application/octet-stream';
                     end;

                     '.pdf' : begin
                             AResponse.ContentType := 'application/pdf';
                     end;

                     '.mpeg' : begin
                             AResponse.ContentType := 'video/mpeg';
                     end;

                     '.rtf' : begin
                             AResponse.ContentType := 'application/rtf';
                     end;

                     else
                           AResponse.ContentType := 'text/html; charset=utf-8';

                end;

                AResponse.SendContent;
                Handled := true;

                myfile.Free;
                myfile := nil;
           end else begin

               //writeln('--' + AResponse.Request.URI);

               AResponse.SendRedirect('index');
               Handled            := true;

           end;

        finally


       end;
     except
           on E: Exception do
           begin

               writeln('Eccezione MyShowRequestException: ' + E.Message);

               Handled := false;

           end;
     end;
end;

var
   MyCustomException : TCustomException;
   MyCustomGetModule : TCustomGetModule;

begin
  MyCustomException := TCustomException.Create;
  MyCustomGetModule := TCustomGetModule.Create;

  RegisterHTTPModule('favicon.ico', TFPWebModuleFavIcon);
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
  Application.LegacyRouting := false;

  if not Application.UseSSL then
     writeln('http://localhost:' + IntToStr(Application.Port))
  else
      writeln('https://localhost:' + IntToStr(Application.Port));

  writeln('ver 6');

  Application.Threaded:=True;
  Application.Initialize;
  Application.Run;

  MyCustomGetModule.Free;
  MyCustomGetModule := nil;
  MyCustomException.Free;
  MyCustomException := nil;
end.

