unit uFavIcon;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModuleFavIcon }

  TFPWebModuleFavIcon = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private

  public

  end;

var
  FPWebModuleFavIcon: TFPWebModuleFavIcon;

implementation

{$R *.lfm}

{ TFPWebModuleFavIcon }

procedure TFPWebModuleFavIcon.indexRequest(Sender: TObject; ARequest: TRequest;
  AResponse: TResponse; var Handled: Boolean);
var
   filename : string;
begin
     filename := ExtractFilePath(ParamStr(0)) + 'HTML' + AResponse.Request.URI;
     if FileExists(filename) then
     begin
          AResponse.ContentStream := TFileStream.Create(filename, fmOpenRead + fmShareDenyWrite);
          AResponse.ContentType := 'image/ico';
          Handled := true;
     end else begin
         Handled := false;
     end;
end;

initialization

end.

