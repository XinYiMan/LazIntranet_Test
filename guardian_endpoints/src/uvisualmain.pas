unit uVisualMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, Grids,
  uSmartTrayIcon, uThreadControl, ExtCtrls, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnHide: TButton;
    ImageList_16: TImageList;
    MenuItem_Show: TMenuItem;
    MenuItem_Close: TMenuItem;
    PopupMenu1: TPopupMenu;
    MyGrid: TStringGrid;
    procedure BtnHideClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem_CloseClick(Sender: TObject);
    procedure MenuItem_ShowClick(Sender: TObject);
    procedure MyGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
  private
         MySmartTrayIcon        : TSmartTrayIcon;
         ThreadControl1         : TThreadControl;
         AbortClose             : boolean;
         GuardianCreateLog      : boolean;
         GuardianShowMsg        : boolean;

         procedure LoadConfig;
         procedure DrawGrid;
         function GetApplicationLocation : string;
  public
        MyCriticalSection      : TRTLCriticalSection;
        IdxUrlNotify           : integer;
        UrlNotify              : string;
        MessageNotify          : string;
        GuardianCount          : integer;
        GuardianUrls           : array of string;
        GuardianPaths          : array of string;
        GuardianUrlsStatus     : array of boolean;
        GuardianRunIfUrlNotRun : boolean;

        procedure NotifyMessage;
  end;

var
  Form1: TForm1;

implementation
uses
    INIFiles, dateutils, strutils;

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
     InitCriticalSection(MyCriticalSection);
     AbortClose        := true;
     MySmartTrayIcon   := TSmartTrayIcon.Create(Self, Self.PopupMenu1);
     ThreadControl1    := TThreadControl.Create();

     IdxUrlNotify      := -1;
     UrlNotify         := '';
     MessageNotify     := 'Start program';
     Self.NotifyMessage;


     Self.LoadConfig;
     ThreadControl1.Start;
end;

procedure TForm1.BtnHideClick(Sender: TObject);
begin
     if Assigned(MySmartTrayIcon) then
     begin
          MySmartTrayIcon.Show(Self.ImageList_16,0,Self.Caption);
     end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
     if AbortClose then
     begin
          CanClose := false;
     end else begin
       if MessageDlg('CLOSING', 'Are you sure you want to leave the program?', mtConfirmation, [mbYes, mbNo],0) = mrNo then
          CanClose := False;
     end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
     if Assigned(ThreadControl1) then
     begin
          ThreadControl1.Terminate;
          Sleep(1000);
     end;

     if Assigned(MySmartTrayIcon) then
     begin
       MySmartTrayIcon.Free;
       MySmartTrayIcon := nil;
     end;
     DoneCriticalSection(MyCriticalSection);

     IdxUrlNotify      := -1;
     UrlNotify         := '';
     MessageNotify     := 'Stop program';
     Self.NotifyMessage;
end;

procedure TForm1.MenuItem_CloseClick(Sender: TObject);
begin
     AbortClose := false;
     Self.Close;
end;

procedure TForm1.MenuItem_ShowClick(Sender: TObject);
begin
     if Assigned(MySmartTrayIcon) then
     begin
          MySmartTrayIcon.Hide;
     end;
end;

procedure TForm1.MyGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
     inherited;
     if (aCol = 0) and (aRow>0) then
     begin
          if Self.GuardianUrlsStatus[aRow-1] then
             MyGrid.Canvas.Brush.Color := clGreen
          else
              MyGrid.Canvas.Brush.Color := clRed;
          MyGrid.Canvas.FillRect(aRect);
     end;
end;

procedure TForm1.LoadConfig;
Var
   INI      : TINIFile;
   filename : string;
   i        : integer;
begin

     GuardianCount := 0;
     filename      := Self.GetApplicationLocation + 'config.ini';
     if FileExists(filename) then
     begin

         INI                    := TINIFile.Create(filename);
         GuardianCount          := StrToIntDef(INI.ReadString('Config','Count','0'),0);
         GuardianCreateLog      := StrToBoolDef(INI.ReadString('Config','CreateLog','FALSE'),false);
         GuardianShowMsg        := StrToBoolDef(INI.ReadString('Config','ShowMsg','FALSE'),false);
         GuardianRunIfUrlNotRun := StrToBoolDef(INI.ReadString('Config','RunIfUrlNotRun','FALSE'),false);

         for i := 0 to GuardianCount-1 do
         begin
              SetLength(GuardianUrlsStatus, Length(GuardianUrlsStatus)+1);
              SetLength(GuardianUrls, Length(GuardianUrls)+1);
              SetLength(GuardianPaths, Length(GuardianPaths)+1);

              GuardianUrlsStatus[Length(GuardianUrlsStatus)-1] := false;
              GuardianUrls[Length(GuardianUrls)-1]             := INI.ReadString('Config','Url_' + IntToStr(i),'');
              GuardianPaths[Length(GuardianPaths)-1]           := INI.ReadString('Config','Path_' + IntToStr(i),'');
         end;

         Ini.Free;

         DrawGrid;

     end else begin

            ShowMessage('Error : File not founded ' + filename);
            Application.Terminate;

     end;


end;

procedure TForm1.DrawGrid;
var
   i : integer;
begin
     MyGrid.RowCount := GuardianCount+1;
     MyGrid.ColCount := 5;
     MyGrid.Cells[0,0] := '-';
     MyGrid.Cells[1,0] := 'Url';
     MyGrid.Cells[2,0] := 'Path';
     MyGrid.Cells[3,0] := 'Status';
     MyGrid.Cells[4,0] := 'Info';

     for i := 0 to GuardianCount-1 do
     begin

            MyGrid.Cells[1,i+1] := GuardianUrls[i];
            MyGrid.Cells[2,i+1] := GuardianPaths[i];
            if GuardianUrlsStatus[i] then
               MyGrid.Cells[3,i+1] := 'active'
            else
                MyGrid.Cells[3,i+1] := 'not active';
            if FileExists(GuardianPaths[i]) then
                MyGrid.Cells[4,i+1] := GuardianPaths[i] + ' exists.'
            else
                MyGrid.Cells[4,i+1] := GuardianPaths[i] + 'not exists.';

     end;

     MyGrid.AutoAdjustColumns;
end;

function TForm1.GetApplicationLocation: string;
begin
     {$ifdef Darwin}
            result := Application.Location + '..' + System.DirectorySeparator + '..' + System.DirectorySeparator + '..' + System.DirectorySeparator;
     {$else}
            result := Application.Location;
     {$endif}
end;

procedure TForm1.NotifyMessage;
var
   app                        : TStringList;
   filename                   : string;
   dirname                    : string;
   YY, MM, DD, HH, NN, SS, MS : word;
begin
     if IdxUrlNotify>-1 then
     begin
          if Length(GuardianUrlsStatus)>IdxUrlNotify then
             Self.GuardianUrlsStatus[IdxUrlNotify] := not Self.GuardianUrlsStatus[IdxUrlNotify];
          Self.DrawGrid;
     end;

     if Self.GuardianCreateLog then
     begin
          DecodeDateTime(now, YY, MM, DD, HH, NN, SS, MS);

          dirname  := Self.GetApplicationLocation + 'log' + System.DirectorySeparator;
          filename := 'notify' + AddCharR('0',IntToStr(YY),4) + AddChar('0',IntToStr(MM),2) + AddChar('0',IntToStr(DD),2) + '.log';
          if not DirectoryExists(dirname) then
          begin
              CreateDir(dirname);
          end;
          if DirectoryExists(dirname) then
          begin
              app := TStringList.Create;
              if FileExists(dirname + filename) then
              begin
                   app.LoadFromFile(dirname + filename);
                   DeleteFile(dirname + filename);
              end;
              if IdxUrlNotify>-1 then
                 app.Append(DateTimeToStr(now) + ' : ' + UrlNotify + ' ' + MessageNotify)
              else
                  app.Append(DateTimeToStr(now) + ' : ' + MessageNotify);
              app.SaveToFile(dirname + filename);
              app.Free;
              app := nil;
          end;
     end;

     if (Self.GuardianShowMsg) and (Assigned(MySmartTrayIcon)) then
     begin
         if IdxUrlNotify>-1 then
            MySmartTrayIcon.ShowBalloonMessage(DateTimeToStr(now), UrlNotify + ' ' + MessageNotify, 3000, bfWarning)
         else
             MySmartTrayIcon.ShowBalloonMessage(DateTimeToStr(now), MessageNotify,3000,bfWarning);
     end;
end;

end.

