unit uAssets;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleAssets }

  TFPWebModuleAssets = class(TFPWebModule)
    procedure get_fileRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private

  public

  end;

var
  FPWebModuleAssets: TFPWebModuleAssets;

implementation

{$R *.lfm}

{ TFPWebModuleAssets }

procedure TFPWebModuleAssets.get_fileRequest(Sender: TObject;
  ARequest: TRequest; AResponse: TResponse; var Handled: Boolean);
var
  filename : string;
begin
     filename := ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + ARequest.URI;
     if FileExists(filename) then
     begin

          AResponse.ContentStream := TFileStream.Create(filename, fmOpenRead + fmShareDenyWrite);

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

          Handled := true;
     end else begin

         Handled := false;
     end;
end;

initialization

end.

