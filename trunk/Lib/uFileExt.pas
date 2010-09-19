//* File:     Lib\uFileExt.pas
//* Created:  2006-02-04
//* Modified: 2006-02-04
//* Version:  X.X.35.X
//* Author:   Safranek David (Safrad)
//* E-Mail:   safrad at email.cz
//* Web:      http://safrad.webzdarma.cz

unit uFileExt;

interface

uses
	uDForm,
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, uDImage, uDView, Menus;

type
	TfFileExt = class(TDForm)
    DViewFE: TDView;
		PopupMenuFE: TPopupMenu;
		Register1: TMenuItem;
		Unregister1: TMenuItem;
    N1: TMenuItem;
    RegisterAll1: TMenuItem;
    UnregisterAll1: TMenuItem;
		procedure Register1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure PopupMenuFEPopup(Sender: TObject);
		procedure DViewFEGetData(Sender: TObject; var Data: String; ColIndex,
      RowIndex: Integer; Rect: TRect);
	private
		{ Private declarations }
		procedure Init(Sender: TObject);
	public
		{ Public declarations }
	end;

procedure AddFileType(
	const FileType, FileTypeCaption, Icon: string;
	const MenuCaptions: array of ShortString;
	const OpenPrograms: array of ShortString
	);

procedure FormFileExt;
procedure FreeFileExt;

implementation

{$R *.dfm}
uses uTypes, uReg, uDIni, uMenus;

type
	TFileType = packed record // 24
		FileType, FileTypeCaption, Icon: string; // 12
		Exists: B4;
		MenuCaptions: array of ShortString; // 4
		OpenPrograms: array of ShortString // 8
	end;
var
	FileTypes: array of TFileType;
	FileTypeCount: SG;

	fFileExt: TfFileExt;

procedure FormFileExt;
begin
	if not Assigned(fFileExt) then fFileExt := TfFileExt.Create(nil);
	fFileExt.DViewFE.RowCount := FileTypeCount;
	fFileExt.Init(nil);
	fFileExt.Show;
end;

procedure FreeFileExt;
begin
	FormFree(TForm(fFileExt));
end;

procedure AddFileType(
	const FileType, FileTypeCaption, Icon: string;
	const MenuCaptions: array of ShortString;
	const OpenPrograms: array of ShortString
	);
var j: SG;
begin
	SetLength(FileTypes, FileTypeCount + 1);
	FileTypes[FileTypeCount].FileType := FileType;
	FileTypes[FileTypeCount].FileTypeCaption := FileTypeCaption;
	FileTypes[FileTypeCount].Icon := Icon;
	SetLength(FileTypes[FileTypeCount].MenuCaptions, Length(MenuCaptions));
	for j := 0 to Length(MenuCaptions) - 1 do
		FileTypes[FileTypeCount].MenuCaptions[j] := MenuCaptions[j];

	SetLength(FileTypes[FileTypeCount].OpenPrograms, Length(OpenPrograms));
	for j := 0 to Length(OpenPrograms) - 1 do
		FileTypes[FileTypeCount].OpenPrograms[j] := OpenPrograms[j];
	Inc(FileTypeCount);
end;

procedure TfFileExt.Init(Sender: TObject);
var i: SG;
begin
	for i := 0 to FileTypeCount - 1 do
		FileTypes[i].Exists := CustomFileType(
			foExists,
			FileTypes[i].FileType,
			FileTypes[i].FileTypeCaption,
			FileTypes[i].Icon,
			FileTypes[i].MenuCaptions,
			FileTypes[i].OpenPrograms);
end;

procedure TfFileExt.Register1Click(Sender: TObject);
var i, Tg: SG;
begin
	Tg := TComponent(Sender).Tag;
	for i := 0 to FileTypeCount - 1 do
	begin
		if (Tg >= 2) or (DViewFE.SelRows[i]) then
			CustomFileType(
				TFileTypesOperation(Tg and 1),
				FileTypes[i].FileType,
				FileTypes[i].FileTypeCaption,
				FileTypes[i].Icon,
				FileTypes[i].MenuCaptions,
				FileTypes[i].OpenPrograms);
	end;
	Init(Sender);
	DViewFE.Fill;
end;

procedure TfFileExt.FormCreate(Sender: TObject);
begin
//	MenuSet(PopupMenuFE, OnAdvancedMenuDraw); D???
	DViewFE.ColumnCount := 2;
	DViewFE.Columns[0].Caption := 'Extension';
	DViewFE.Columns[0].Width := 64;
	DViewFE.Columns[1].Caption := 'Description';
	DViewFE.Columns[1].Width := 256;

	MainIni.RWFormPos(Self, False);
	MainIni.RWDView(DViewFE, False);
end;

procedure TfFileExt.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	MainIni.RWFormPos(Self, True);
	MainIni.RWDView(DViewFE, True);
end;

procedure TfFileExt.PopupMenuFEPopup(Sender: TObject);
var
	i: SG;
	C, E: BG;
begin
	i := DViewFE.ActualRow;
	if (i >= 0) and (i < FileTypeCount) then
	begin
		C := FileTypes[i].Exists;
		E := True;
	end
	else
	begin
		E := False;
		C := False;
	end;
	Register1.Enabled := E;
	Unregister1.Enabled := E;
	Register1.Checked := C;
	Unregister1.Checked := not C;
end;

procedure TfFileExt.DViewFEGetData(Sender: TObject; var Data: String;
  ColIndex, RowIndex: Integer; Rect: TRect);
begin
	if FileTypes[RowIndex].Exists then
		DViewFE.Bitmap.Canvas.Font.Style := []
	else
		DViewFE.Bitmap.Canvas.Font.Style := [fsStrikeOut];
	case ColIndex of
	0: Data := FileTypes[RowIndex].FileType;
	1: Data := FileTypes[RowIndex].FileTypeCaption;
	end;
end;

initialization

finalization
	SetLength(FileTypes, 0);
end.