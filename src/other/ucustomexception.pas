unit uCustomException;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

    { TCustomException }

    TCustomException = class
                     constructor Create;
                     destructor Free;
                     procedure MyException(Sender : TObject; E : Exception);
    end;

implementation

{ TCustomException }

constructor TCustomException.Create;
begin

end;

destructor TCustomException.Free;
begin

end;

procedure TCustomException.MyException(Sender: TObject; E: Exception);
begin
     writeln('TCustomException: ' + E.Message);
end;

end.

