unit uProfile;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleProfile }

  TFPWebModuleProfile = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
    procedure upload_fileRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private
         procedure OnBodyLoad(ARequest: TRequest; AResponse: TResponse; mytoken: string);
  public

  end;

var
  FPWebModuleProfile: TFPWebModuleProfile;

implementation
uses
    NGIT_Crypto_JWT, uVerifiedJWT, uGetToken, uSmartDebugLog, md5;

{$R *.lfm}

{ TFPWebModuleProfile }

procedure TFPWebModuleProfile.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
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
          SetToken(AResponse, mytoken);
          AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + 'profile.html');
          OnBodyLoad(ARequest, AResponse, mytoken);
     end else begin
          SetToken(AResponse, '');
          AResponse.SendRedirect('/login');
     end;

     Handled            := true;
end;

procedure TFPWebModuleProfile.upload_fileRequest(Sender: TObject;
  ARequest: TRequest; AResponse: TResponse; var Handled: Boolean);
var
   i        : integer;
   fs       : TFileStream;
   filename : string;
begin

       try
          try


             for i := 0 to ARequest.Files.Count-1 do
             begin

                   filename := ExtractFilePath(ParamStr(0)) + 'FILE' + System.DirectorySeparator + ARequest.Files[i].FileName;

                   SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%},'Upload file: ' + filename);

                   if FileExists(filename) then
                      DeleteFile(filename);

                   fs:= TFileStream.Create(filename , fmCreate);
                   Try
                      ARequest.Files[i].Stream.Position := 0;
                      fs.CopyFrom(ARequest.Files[i].Stream, ARequest.Files[i].Stream.Size);
                   Finally
                     fs.Free;
                   End;
                   writeln('MD5 of ' + filename + ': ' + Md5Print(Md5File(filename)));

             end;


          finally

         end;
       except
             on E: Exception do
             begin

                   writeln(E.Message);
                  SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%},'Upload file error: ' + E.Message);

             end;
       end;





  AResponse.SendRedirect('/profile');

  Handled            := true;
end;

procedure TFPWebModuleProfile.OnBodyLoad(ARequest: TRequest;
  AResponse: TResponse; mytoken: string);
begin
     //AResponse.Contents.Text := stringReplace(AResponse.Contents.Text, '{*mytoken*}', mytoken, [RfReplaceAll, rfIgnoreCase]);
     SetToken(AResponse, mytoken);
end;

initialization

end.

