unit uWPSInterpreter; //Web Pascal Script

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

    { TWPSInterpreterItem }

    TWPSInterpreterItem = object
          key   : string;
          value : string;
    end;

type
    TWPSInterpreter = class

    public
          constructor Create;
          destructor Free;
          procedure Execute(var Contents: string; parameters: array of TWPSInterpreterItem
            );

    end;

implementation
uses
    uSmartDebugLog;

{ TWPSInterpreter }

constructor TWPSInterpreter.Create;
begin

end;

destructor TWPSInterpreter.Free;
begin

end;

procedure TWPSInterpreter.Execute(var Contents: string;
  parameters: array of TWPSInterpreterItem);
var
   i : integer;
begin

     try
        try

           for i := 0 to Length(parameters) - 1 do
           begin
                Contents := stringReplace(Contents, '{*BEGIN_WRITE ' + parameters[i].key + ' END_WRITE*}', parameters[i].value, [RfReplaceAll,rfIgnoreCase]);
                Contents := stringReplace(Contents, '{* BEGIN_WRITE ' + parameters[i].key + ' END_WRITE*}', parameters[i].value, [RfReplaceAll,rfIgnoreCase]);
                Contents := stringReplace(Contents, '{*BEGIN_WRITE ' + parameters[i].key + ' END_WRITE *}', parameters[i].value, [RfReplaceAll,rfIgnoreCase]);
                Contents := stringReplace(Contents, '{* BEGIN_WRITE ' + parameters[i].key + ' END_WRITE *}', parameters[i].value, [RfReplaceAll,rfIgnoreCase]);
           end;

        finally

       end;
     except
           on E: Exception do
           begin



           end;
     end;



end;

end.

