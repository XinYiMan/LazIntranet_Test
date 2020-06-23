unit uTable;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, httpdefs, fpHTTP, fpWeb, BufDataset;

type

  { TFPWebModuleTable }

  TFPWebModuleTable = class(TFPWebModule)
    procedure indexRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
    procedure load_data_tableRequest(Sender: TObject; ARequest: TRequest;
      AResponse: TResponse; var Handled: Boolean);
  private
         procedure OnBodyLoad(ARequest: TRequest; AResponse: TResponse; mytoken: string);
  public

  end;

var
  FPWebModuleTable: TFPWebModuleTable;

implementation
uses
    uVerifiedJWT, uGetToken, Character,
    {$ifdef ViewDataFromDataBase} uDbAbstract, {$else}uNGITJsonDataSet, db,{$endif} fpjson, jsonparser, uSmartDebugLog;

{$R *.lfm}

{ TFPWebModuleTable }

procedure TFPWebModuleTable.indexRequest(Sender: TObject; ARequest: TRequest;
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
          AResponse.Contents.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HTML' + System.DirectorySeparator + 'table.html');
          OnBodyLoad(ARequest,AResponse, mytoken);
     end else begin
          SetToken(AResponse,'');
          AResponse.SendRedirect('/login');
     end;

     Handled            := true;
end;

procedure TFPWebModuleTable.load_data_tableRequest(Sender: TObject;
  ARequest: TRequest; AResponse: TResponse; var Handled: Boolean);
var
   mytoken            : string;
   valid_token        : boolean;
   ret                : string;
   json_da_restituire : TJSONObject;
   filter             : string;
   record_count       : integer;
   limit              : integer;
   page_count         : integer;
   page               : integer;
   {$ifdef ViewDataFromDataBase}
   DBAbstract1        : TDBAbstract;
   FieldsList1        : TFieldsList;
   RecordSetList1     : TRecordSetList;
   {$else}
   VDSet              : TBufDataset;
   NGITJsonDataSet1   : TNGITJsonDataSet;
   Error              : string;
   {$endif}
   i, j                  : integer;
   sql                   : string;
   sql_where             : string;

   function StrIsNumeric(value : string) : boolean;
   var
      ch : UnicodeChar;
   begin
        result := true;

        for ch in value do
        begin
             if not TCharacter.IsNumber(ch) then
                result := false;
        end;
   end;

begin
     valid_token        := false;

     mytoken            := GetToken(aRequest);

     record_count       := 0;
     page_count         := 1;
     page               := 1;
     filter             := '';
     limit              := 10;

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

     AResponse.ContentType := 'text/json; charset=utf-8';

     if valid_token then
     begin

          SetToken(AResponse, mytoken);

          filter := lowercase(ARequest.ContentFields.Values['filter']);
          limit  := StrToIntDef(ARequest.ContentFields.Values['limit'],0);
          page   := StrToIntDef(ARequest.ContentFields.Values['page'],1);

          {$ifndef ViewDataFromDataBase}

          VDSet := TBufDataset.Create(nil);
          VDSet.FieldDefs.Add('field1',ftInteger);
          VDSet.FieldDefs.Add('field2',ftString,50);
          VDSet.FieldDefs.Add('field3',ftString,50);
          VDSet.FieldDefs.Add('field4',ftString,50);
          VDSet.FieldDefs.Add('field5',ftString,50);
          VDSet.FieldDefs.Add('field6',ftString,50);
          VDSet.CreateDataset;

          VDSet.Open;
          {$endif}

          record_count := 0;

          {$ifdef ViewDataFromDataBase}
            DBAbstract1        := TDBAbstract.Create;
            if DBAbstract1.Connect then
            begin
                 sql := 'delete from table1;';
                 DBAbstract1.ExecuteSQL(sql);
                 for i := 1 to StrToIntDef(ARequest.ContentFields.Values['max_records'],10) do
                 begin
                     sql := 'insert into table1(field1, field2, field3, field4, field5, field6)values(' + IntToStr(i) + ',''FA_' + IntToStr(i) + ''',''FB_' + IntToStr(i) + ''',''FC_' + IntToStr(i) + ''',''FD_' + IntToStr(i) + ''',''FE_' + IntToStr(i) + ''');';
                     DBAbstract1.ExecuteSQL(sql);
                 end;

                 if filter<>'' then
                 begin
                      sql_where := 'where ';

                      if StrIsNumeric(filter) then
                         sql_where := sql_where + 'field1 = ' + stringReplace(filter, '''', '''''', [RfReplaceAll, rfIgnoreCase]) + ' or ';

                    sql_where := sql_where + 'lower(field2) like lower(''%' + stringReplace(filter, '''', '''''', [RfReplaceAll, rfIgnoreCase]) + '%'') ';
                    sql_where := sql_where + 'or lower(field3) like lower(''%' + stringReplace(filter, '''', '''''', [RfReplaceAll, rfIgnoreCase]) + '%'') ';
                    sql_where := sql_where + 'or lower(field4) like lower(''%' + stringReplace(filter, '''', '''''', [RfReplaceAll, rfIgnoreCase]) + '%'') ';
                    sql_where := sql_where + 'or lower(field5) like lower(''%' + stringReplace(filter, '''', '''''', [RfReplaceAll, rfIgnoreCase]) + '%'') ';
                    sql_where := sql_where + 'or lower(field6) like lower(''%' + stringReplace(filter, '''', '''''', [RfReplaceAll, rfIgnoreCase]) + '%'') ';
                 end else begin
                    sql_where := '';
                 end;

                 {$ifdef FirebirdConn}
                         sql := 'select first ' + IntToStr(limit) + ' skip ' + IntToStr(((page*limit)-limit)) + ' * from table1 ' + sql_where + ';';
                 {$else}
                        sql := 'select * from table1 ' + sql_where + ' limit ' + IntToStr(limit) + ' offset ' + IntToStr(((page*limit)-limit)) + ';';
                 {$endif}
                 ret := DBAbstract1.SelectSQLIntoJson(sql, record_count);
                 if (ret='') or (ret = '[]') then
                 begin
                      record_count := 0;
                 end else begin
                     SetLength(FieldsList1,1);
                     FieldsList1[0] := 'qty';
                     sql := 'select count(*) as qty from table1 ' + sql_where + ';';
                     if DBAbstract1.GetFieldsFromQuery(FieldsList1,sql,RecordSetList1) then
                     begin
                          record_count := StrToIntDef(RecordSetList1[0,0],-1);
                     end else begin
                         record_count := 0;
                     end;
                     SetLength(RecordSetList1,0,0);

                     {SetLength(FieldsList1,6);
                     FieldsList1[0] := 'field1';
                     FieldsList1[1] := 'field2';
                     FieldsList1[2] := 'field3';
                     FieldsList1[3] := 'field4';
                     FieldsList1[4] := 'field5';
                     FieldsList1[5] := 'field6';

                     if DBAbstract1.GetFieldsFromQuery(FieldsList1,'select * from table1;',RecordSetList1) then
                     begin
                          for i := 0 to Length(RecordSetList1)-1 do
                              for j := 0 to Length(RecordSetList1[0])-1 do
                                  writeln(RecordSetList1[i, j]);

                     end;}
                 end;

                 DBAbstract1.Disconnect;
            end;
            DBAbstract1.Free;
            DBAbstract1 := nil;
            if trim(ret) = '' then
               ret := '[]';
            {$else}
          for i := 1 to StrToIntDef(ARequest.ContentFields.Values['max_records'],10) do
          begin

                   if (filter = '') or (pos(filter, lowercase('Field_A_' + IntToStr(i)))>0) or (pos(filter, lowercase('Field_B_' + IntToStr(i)))>0) or (pos(filter, lowercase('Field_C_' + IntToStr(i)))>0) or (pos(filter, lowercase('Field_D_' + IntToStr(i)))>0) or (pos(filter, lowercase('Field_E_' + IntToStr(i)))>0) then
                   begin

                        if (limit = 0) or (VDSet.RecordCount<limit) then
                        begin

                             if i>=(((page*limit)-limit)+1) then
                             begin
                                  VDSet.Append;
                                  VDSet.Fields[0].Value := i;
                                  VDSet.Fields[1].Value := 'Field_A_' + IntToStr(i);
                                  VDSet.Fields[2].Value := 'Field_B_' + IntToStr(i);
                                  VDSet.Fields[3].Value := 'Field_C_' + IntToStr(i);
                                  VDSet.Fields[4].Value := 'Field_D_' + IntToStr(i);
                                  VDSet.Fields[5].Value := 'Field_E_' + IntToStr(i);
                                  VDSet.Post;
                             end;

                        end;

                        Inc(record_count);
                   end;

          end;


          ret   := '';
          Error := '';
          NGITJsonDataSet1   := TNGITJsonDataSet.Create();
          if not NGITJsonDataSet1.DatasetToJSONString(VDSet, ret, Error) then
          begin
               ret := '[]';
          end;
          NGITJsonDataSet1.Free();
          NGITJsonDataSet1 := nil;

          VDSet.Free;
          VDSet := nil;
          {$endif}
     end else begin
         SetToken(AResponse,'');
         ret := '[]';
     end;
     if record_count = 0 then
     begin
        page_count := 0;
     end
     else
     begin
         page_count := trunc(record_count / limit);
         if (record_count mod limit) <> 0 then
            Inc(page_count);
     end;
     json_da_restituire:=TJSONObject.Create(['recordset',ret,
                                             'record_count', record_count,
                                             'page_number', page,
                                             'page_count',page_count
                                                            ]);
     AResponse.Contents.Text := json_da_restituire.AsJSON;
     json_da_restituire.Free;
     json_da_restituire := nil;
     Handled                 := true;
end;

procedure TFPWebModuleTable.OnBodyLoad(ARequest: TRequest;
  AResponse: TResponse; mytoken: string);
begin
     SetToken(AResponse, mytoken);
end;

initialization

end.

