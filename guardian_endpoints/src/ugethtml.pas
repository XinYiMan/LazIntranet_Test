{

Libreria realizzata da Sammarco Francesco
Mail: francesco.sammarco@gmail.com
Utilità: recuperare codice html

}



unit ugethtml;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, httpsend, ssl_openssl, synacode, synautil;

type
    TPostItem = object
          name  : string;
          value : string;
    end;

type TArrayOfPostItem = array of TPostItem;

     function GetHTML(Url: string; itemsPost : TArrayOfPostItem): string;

implementation

    //per gestione timeout guardare https://forum.lazarus.freepascal.org/index.php/topic,40167.0.html
    //Copia della funzione HttpGetText nella unit httpsend di synapse in modo da gestirmi il timeout
    {function MyHttpGetText(const URL: string; const Response: TStrings): Boolean;
    var
      HTTP : THTTPSend;
      valT : integer;
      valK : integer;
    begin
      HTTP := THTTPSend.Create;
      try
        Result := HTTP.HTTPMethod('GET', URL);
        if Result then
          Response.LoadFromStream(HTTP.Document);
      finally
        HTTP.Free;
      end;
    end; }

    //Copia della funzione HttpPostURL nella unit httpsend di synapse in modo da gestirmi il timeout
    {function MyHttpPostURL(const URL, URLData: string; const Data: TStream): Boolean;
    var
      HTTP: THTTPSend;
    begin
      HTTP := THTTPSend.Create;
      try
        WriteStrToStream(HTTP.Document, URLData);
        HTTP.MimeType := 'application/x-www-form-urlencoded';
        Result := HTTP.HTTPMethod('POST', URL);
        if Result then
          Data.CopyFrom(HTTP.Document, 0);
      finally
        HTTP.Free;
      end;
    end;  }

    function GetHTML(Url: string; itemsPost: TArrayOfPostItem): string;
  var
    L        : TStrings;
    postStr  : string;
    i        : integer;
    Response : TStringStream;
  begin
    Result :='';

    if Length(itemsPost)<=0 then
    begin
      try
        L := TStringlist.Create;
        if HttpGetText(Url,L) then Result := L.Text;
      finally
        L.Free;
      end;
    end else begin
      try
        L := TStringlist.Create;

        postStr := '';
        for i := 0 to Length(itemsPost)-1 do
        begin

             if i>0 then
                postStr := postStr + '&';
             postStr := postStr + itemsPost[i].name + '=' + EncodeURLElement(itemsPost[i].value);

        end;
        Response := TStringStream.Create('');
        if HttpPostURL(Url, postStr,Response) then Result := L.Text;
        result := Response.DataString;
        Response.Free;
        Response := nil;
      finally
        L.Free;
      end;
    end;


  end;

end.
