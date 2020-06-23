unit uNGITJsonDataSet;

{

     Libreria scritta da Sammarco Francesco per trasformare un dataset in una stringa json

}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, typinfo, db;

  type

      { TJsonDataSet }

      { TNGITJsonDataSet }

      TNGITJsonDataSet = class
      private
            function FieldTypeToStr(aFieldType: TFieldType): String;
            function StrToFieldType(aString: String): TFieldType;
      public
            constructor Create();
            destructor  Free();
            function DatasetToJSONString(DataSet: TDataSet; var ret: string;
              var Error: string): boolean;
            function DatasetFieldsTypeToJSONString(DataSet: TDataSet; var ret : string; var Error: string): boolean;
      end;

implementation
uses
    fpjson, jsonparser;

function TNGITJsonDataSet.FieldTypeToStr(aFieldType: TFieldType): String;
begin
  Exit(Fieldtypenames[aFieldType]);
end;

function TNGITJsonDataSet.StrToFieldType(aString: String): TFieldType;
var
  ft: TFieldType;
begin
  aString := LowerCase(aString);
  Delete(aString, 1, 2);
  for ft := Low(TFieldType) to High(TFieldType) do
    if aString = LowerCase(Fieldtypenames[ft]) then
      Exit(ft);
  Result := ftUnknown;
end;

constructor TNGITJsonDataSet.Create();
begin

end;

destructor TNGITJsonDataSet.Free();
begin

end;

function TNGITJsonDataSet.DatasetToJSONString(DataSet: TDataSet;
  var ret: string; var Error: string): boolean;
var
   jArray             : TJSONArray;
   i, j               : integer;
   Concat_Str         : string;
   MyStringList       : TStringList;
begin
     result       := false;
     Error        := '';
     ret          := '';
     Concat_Str   := '';

     try
        try


           if DataSet.Active then
           begin

                if DataSet.RecordCount>0 then
                begin
                     MyStringList       := TStringList.Create;
                     DataSet.First;
                     j := 0;
                     while not DataSet.EOF do
                     begin

                          jArray := TJSONArray.Create;

                          for i :=0 to DataSet.Fields.Count-1 do
                          begin
                                  jArray.Add(DataSet.FieldByName(DataSet.Fields[i].FieldName).AsString);
                          end;

                          if DataSet.RecNo>1 then
                             Concat_Str := Concat(Concat_Str, ', ', jArray.AsJSON)
                          else
                              Concat_Str := Concat(Concat_Str, jArray.AsJSON);

                          jArray.Free;
                          jArray := nil;

                          if (j > 500) then
                          begin
                               MyStringList.Add(Concat_Str);
                               Concat_Str := '';
                               j := 0;
                          end else begin
                               Inc(j);
                          end;


                          DataSet.Next;
                     end;
                     if Length(Concat_Str)>0 then
                     begin
                          MyStringList.Add(Concat_Str);
                          Concat_Str := '';
                     end;

                     ret := Concat('[' , MyStringList.Text , ']');

                     MyStringList.Free;
                     MyStringList := nil;
                end;

           end;

           result                  := true;

        finally

       end;
     except
           on E: Exception do
           begin

                result := false;
                Error  := E.Message;
                ret    := '[]';

           end;
     end;
end;
  // json_str := '{"Token":"ciao","Fields":[{"Name":"Campo1","Type":"ftString", "Length":"50","PrimaryKey":false,"Nullable":false,"DefaultValue":"NULL"},{"Name":"Campo2","Type":"ftInteger", "Length":"0","PrimaryKey":true,"Nullable":false,"DefaultValue":"NULL"}],"RowsCols":[["A",1],["B",2],["C",3],["D",4]]}';

function TNGITJsonDataSet.DatasetFieldsTypeToJSONString(DataSet: TDataSet;
  var ret: string; var Error: string): boolean;
var
   json_da_restituire : TJSONObject;
   row                : string;
   i                  : integer;
begin
     result := false;
     Error  := '';
     ret    := '';

     try
        try


           if DataSet.Active then
           begin

                row := '';

                for i :=0 to DataSet.Fields.Count-1 do
                begin

                     json_da_restituire:=TJSONObject.Create(['Name',DataSet.Fields[i].FieldName,
                                            'Type',FieldTypeToStr(DataSet.Fields[i].DataType),
                                            'Length',IntToSTr(DataSet.Fields[i].DataSize) ]);

                     row := row + json_da_restituire.AsJSON;

                     json_da_restituire.Free;

                     if i<DataSet.Fields.Count-1 then
                        row := row + ', '
                     else
                         row := row + ' ';

                end;

                ret := ret + row;

           end;

           result                  := true;

        finally
               ret := '[' + ret + ']';
       end;
     except
           on E: Exception do
           begin

              result := false;
              Error  := E.Message;
              ret    := '';

           end;
     end;
end;

end.

