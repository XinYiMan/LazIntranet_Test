unit uDbAbstract;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils , SQLDB
  {$ifdef PostgresConn}
          , PQConnection
  {$else}
    {$ifdef FirebirdConn}
            , IBConnection
    {$else}
            , SQLite3Conn
    {$endif}
  {$endif}

  ;

type
    TFieldsList    = array of string;
    TRecordSetList = array of array of string;
type

    { TDBAbstract }

    TDBAbstract = class
    private
          {$ifdef PostgresConn}
                  FConn          : TPQConnection;
          {$else}
              {$ifdef FirebirdConn}
                      FConn          : TIBConnection;
              {$else}
                      FConn          : TSQLite3Connection;
              {$endif}
          {$endif}
          FTransaction          : TSQLTransaction;
          FException            : boolean;
          FExceptionDescription : string;
          FAutoCommit           : boolean;

    public
          constructor Create;
          destructor Free;
          function Connect : boolean;
          procedure Disconnect;
          function ExecuteSQL(sql : string) : boolean;
          function SelectSQLIntoJson(sql: string; var record_count: integer): string;
          function GetFieldsFromQuery(FieldsList: TFieldsList; sql: string; out
            RecordSetList: TRecordSetList): boolean;
    published
             property AutoCommit           : boolean read FAutoCommit write FAutoCommit;
             property Exception            : boolean read FException  write FException;
             property ExceptionDescription : string  read FExceptionDescription write FExceptionDescription;
    end;

implementation
uses
    uSmartDebugLog, uNGITJsonDataSet;

{ TDBAbstract }

constructor TDBAbstract.Create;
begin
     {$ifdef PostgresConn}
             FConn             := TPQConnection.Create(nil);
     {$else}
       {$ifdef FirebirdConn}
               FConn             := TIBConnection.Create(nil);
       {$else}
               FConn             := TSQLite3Connection.Create(nil);
       {$endif}
     {$endif}
     FTransaction      := TSQLTransaction.Create(nil);
     FConn.Transaction := FTransaction;
     FAutoCommit       := true;

     FException            := false;
     FExceptionDescription := '';
end;

destructor TDBAbstract.Free;
begin
     try
        try
           FException            := false;
           FExceptionDescription := '';


           FTransaction.Commit;
           FTransaction.Free;
           FTransaction := nil;

           FConn.Free;
           FConn := nil;
        finally

        end;
     except
           on E: Exception do
           begin
                FException            := true;
                FExceptionDescription := E.Message;
                SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%}, E.Message);
           end;
     end;

end;

function TDBAbstract.Connect: boolean;
begin
          result := false;
          try
             try
                FException            := false;
                FExceptionDescription := '';
                {$ifdef PostgresConn}
                  FConn.HostName      := '';
                  FConn.DatabaseName  := '';
                  FConn.UserName      := '';
                  FConn.Password      := '';
                {$else}
                    {$ifdef FirebirdConn}
                      FConn.HostName      := '';
                      FConn.Port          := 3050;
                      FConn.DatabaseName  := '';
                      FConn.UserName      := '';
                      FConn.Password      := '';
                    {$else}
                      FConn.HostName      := 'localhost';
                      FConn.DatabaseName  := ExtractFilePath(ParamStr(0)) + 'DB' + System.DirectorySeparator + 'db.sqlite3';
                      FConn.UserName      := '';
                      FConn.Password      := '';
                    {$endif}
                {$endif}

                FConn.Open;
                result              := true;

             finally

             end;
          except
                on E: Exception do
                begin
                    FException            := true;
                    FExceptionDescription := E.Message;
                    SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%}, E.Message);
                end;
          end;

end;

procedure TDBAbstract.Disconnect;
begin

     try
        try
           FException            := false;
           FExceptionDescription := '';
           FConn.Close(true);

        finally

        end;
     except
           on E: Exception do
           begin
               FException            := true;
               FExceptionDescription := E.Message;
               SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%}, E.Message);
           end;
     end;

end;

function TDBAbstract.ExecuteSQL(sql: string): boolean;
var
   Query : TSQLQuery;
begin
     result := false;
     try
        try
           FException            := false;
           FExceptionDescription := '';
           Query := TSQLQuery.Create(nil);
           Query.SQLConnection := Self.FConn;
           Query.SQL.Text      := sql;
           Query.ExecSQL;

           if FAutoCommit then
              FTransaction.Commit;

           result := true;
        finally

          if Assigned(Query) then
          begin
               Query.Free;
               Query := nil;
          end;

        end;
     except
           on E: Exception do
           begin
               FException            := true;
               FExceptionDescription := E.Message;
               SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%}, E.Message + ' --> ' + sql);
           end;
     end;

end;

function TDBAbstract.SelectSQLIntoJson(sql: string; var record_count : integer): string;
var
   Query              : TSQLQuery;
   ret                : string;
   NGITJsonDataSet1   : TNGITJsonDataSet;
   Error              : string;
begin
     ret          := '';
     record_count := 0;
     try
        try
           FException            := false;
           FExceptionDescription := '';
           Query := TSQLQuery.Create(nil);
           Query.SQLConnection := Self.FConn;
           Query.PacketRecords := -1;
           Query.SQL.Text      := sql;
           Query.Open;
           if Query.RecordCount>0 then
           begin
                record_count       := Query.RecordCount;
                Query.First;
                NGITJsonDataSet1   := TNGITJsonDataSet.Create();
                if not NGITJsonDataSet1.DatasetToJSONString(Query, ret, Error) then
                begin
                     ret          := '';
                     record_count := 0;
                     SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%}, 'DatasetToJSONString: ' + Error);
                end;
                NGITJsonDataSet1.Free();
                NGITJsonDataSet1 := nil;
           end;

           Query.Close;
        finally
          if Assigned(Query) then
          begin
               Query.Free;
               Query := nil;
          end;

        end;
     except
           on E: Exception do
           begin
                ret := '';
                FException            := true;
                FExceptionDescription := E.Message;
                SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%}, E.Message + ' --> ' + sql);
           end;
     end;
     if ret = '' then
        ret := '[]';
     result := ret;
end;

function TDBAbstract.GetFieldsFromQuery(FieldsList: TFieldsList; sql: string;
  out RecordSetList: TRecordSetList): boolean;
var
   Query              : TSQLQuery;
   i                  : integer;
begin
     result := false;
     SetLength(RecordSetList,0,0);
     try
        try
           FException            := false;
           FExceptionDescription := '';
           Query := TSQLQuery.Create(nil);
           Query.SQLConnection := Self.FConn;
           Query.PacketRecords := -1;
           Query.SQL.Text      := sql;
           Query.Open;
           if Query.RecordCount>0 then
           begin
                SetLength(RecordSetList, Query.RecordCount, Length(FieldsList));

                Query.First;
                while not Query.EOF do
                begin
                     for i := 0 to Length(FieldsList)-1 do
                     begin
                         if Assigned(Query.Fields.FindField(FieldsList[i])) then
                         begin
                              RecordSetList[Query.RecNo-1,i] := Query.FieldByName(FieldsList[i]).AsString;
                         end;
                     end;

                     Query.Next;
                end;

           end;

           Query.Close;
           result := true;
        finally
          if Assigned(Query) then
          begin
               Query.Free;
               Query := nil;
          end;

        end;
     except
           on E: Exception do
           begin
               FException            := true;
               FExceptionDescription := E.Message;
               SetLength(RecordSetList,0,0);
               SmartDebugLog.write(Self.UnitName,Self.ClassName,{$I %CURRENTROUTINE%}, E.Message + ' --> ' + sql);
           end;
     end;
end;

end.

