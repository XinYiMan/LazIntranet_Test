unit uCustomGetModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, HTTPDefs, fphttp;

type

    { TCustomGetModule }

    TCustomGetModule = class
                     constructor Create;
                     destructor Free;
                     Procedure MyGetModule(Sender : TObject; ARequest : TRequest;
                               Var ModuleClass : TCustomHTTPModuleClass);
    end;

implementation

{ TCustomGetModule }

constructor TCustomGetModule.Create;
begin

end;

destructor TCustomGetModule.Free;
begin

end;

procedure TCustomGetModule.MyGetModule(Sender: TObject; ARequest: TRequest;
  var ModuleClass: TCustomHTTPModuleClass);
begin
     writeln('TCustomGetModule: ' + ARequest.URI);
end;


end.

