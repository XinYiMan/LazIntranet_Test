unit uSmartTrayIcon;

{$mode objfpc}{$H+}

{

Osservazioni TrayIcon

Darwin  : Ballon title e messaggio hint non funzionano (cocoa)
Windows :
Ubuntu  :

}

interface

uses
  Classes, SysUtils, ExtCtrls, Menus, Forms, Controls, dialogs;

type

    { TSmartTrayIcon }

    TSmartTrayIcon = class

    private
           MyTrayIcon : TTrayIcon;
           MyForm     : TForm;

    public
          constructor Create(Sender: TForm; TrayMenu: TPopupMenu);
          destructor Free;
          procedure Show(ImageList: TImageList; ImageIndex: integer; Hint: string = '');
          procedure ShowBalloonMessage(title: string; message: string; timeout: integer = 3000;
            Flags: TBalloonFlags = bfInfo);
          procedure Hide;
    end;


implementation

{ TSmartTrayIcon }

constructor TSmartTrayIcon.Create(Sender: TForm; TrayMenu : TPopupMenu);
begin
     MyTrayIcon           := TTrayIcon.Create(Sender);
     MyTrayIcon.PopUpMenu := TrayMenu;
     MyForm               := Sender;
end;

destructor TSmartTrayIcon.Free;
begin
     MyTrayIcon.Free;
     MyTrayIcon := nil;
end;

procedure TSmartTrayIcon.Show(ImageList : TImageList; ImageIndex : integer; Hint : string);
begin
     MyTrayIcon.Hint:=Hint;
     MyTrayIcon.Show;
     ImageList.GetIcon(ImageIndex, MyTrayIcon.Icon);
     MyForm.Visible:=false;
end;

procedure TSmartTrayIcon.ShowBalloonMessage(title : string; message: string; timeout : integer; Flags : TBalloonFlags);
begin
     MyTrayIcon.BalloonTitle   := title;
     MyTrayIcon.BalloonHint    := message;
     MyTrayIcon.BalloonTimeout := timeout;
     MyTrayIcon.BalloonFlags   := Flags;
     MyTrayIcon.ShowBalloonHint;
end;

procedure TSmartTrayIcon.Hide;
begin
     MyTrayIcon.Hide;
     MyForm.Visible:=true;
end;

end.

