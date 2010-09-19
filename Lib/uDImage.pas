//* File:     Lib\uDImage.pas
//* Created:  2000-07-01
//* Modified: 2005-11-26
//* Version:  X.X.35.X
//* Author:   Safranek David (Safrad)
//* E-Mail:   safrad at email.cz
//* Web:      http://safrad.webzdarma.cz

unit uDImage;

interface

{$R *.RES}
uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
	ExtCtrls, StdCtrls,
	uDBitmap, uTypes, uMath, uDTimer;

type
	TZoomMenu = (
		zmIn, zmOut,
		zm12, zm1, zm2,
		zmFitImage, zmFitWidth, zmFitHeight,
		zmCustom,
		zmCenter, zmGrate, zmGrateColor, zmCopy);

type
	TMouseAction = (mwNone, mwScroll,
		mwScrollH, mwScrollHD, mwScrollHU, mwScrollHD2, mwScrollHU2,
		mwScrollV, mwScrollVD, mwScrollVU, mwScrollVD2, mwScrollVU2);

	TZoom = FG;

	TDImage = class(TWinControl)
	private
		FTimer: TTimer;
		FBitmap: TDBitmap;

		FNeedFill: BG;
		FHandScroll: BG;
		{$ifopt d+}
		FFillCount, FPaintCount: U4;
		{$endif}

		FHotTrack: Boolean;

		FDrawFPS: Boolean;
		FOnFill: TNotifyEvent;
		FOnPaint: TNotifyEvent;
		FOnMouseEnter: TNotifyEvent;
		FOnMouseLeave: TNotifyEvent;
		BOfsX, BOfsY: Integer;
		HType, VType: U1;
		NowMaxWidth, NowMaxHeight: Integer;
		SliderHX1,
		SliderHX2,
		SliderVY1,
		SliderVY2: Integer;
		FCanvas: TCanvas;
		LCursor: TCursor;
		LMouseX, LMouseY: SG;

		FFramePerSec: Extended;

		// Zoom
		V, A: TZoom;
		LastTickCount: U4;
		TargetZoom: TZoom;
		FEnableZoom: BG;
		ZoomMenu: TMenuItem;
		M: array[TZoomMenu] of TMenuItem;
		BmpS, BmpSourceS: TDBitmap;

		procedure SetZoom(Value: TZoom);
		procedure SetHotTrack(Value: Boolean);
		procedure ChangeZoom(NewZoom: TZoom);
		procedure InitZoomMenu;
		procedure ZoomClick(Sender: TObject);

		procedure InitScrolls;
		procedure FillBitmap;
		procedure FillUserBitmap;

		procedure AdvancedDraw(Sender: TObject; ACanvas: TCanvas;
			ARect: TRect; State: TOwnerDrawState);
		procedure Timer1Timer(Sender: TObject);

		procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
		procedure WMSize(var Message: TWMSize); message WM_SIZE;
		procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
		procedure CMMouseEnter(var Message: TWMMouse); message CM_MOUSEENTER;
		procedure CMMouseLeave(var Message: TWMMouse); message CM_MOUSELEAVE;
	protected
		{ Protected declarations }
		FCur: TCursor;

		procedure CreateParams(var Params: TCreateParams); override;
//		procedure PaintWindow(DC: HDC); override;
		property Canvas: TCanvas read FCanvas;
		function MouseWh(const X, Y: Integer): TMouseAction;
	public
		{ Public declarations }
		MouseX, MouseY: Integer;

		ActualZoom: TZoom;
		MouseL, MouseM, MouseR: Boolean;
		MouseAction: TMouseAction;
		MouseWhere: TMouseAction;
		MouseOn: Boolean;

		// Input
		UserBitmap: TDBitmap;
		UserWidth, UserHeight: SG; // Can be 0 if there is no borders
		UserMouseX, UserMouseY: SG;
		SX, SY, SW, SH: SG;

		// Output
		Center, Grate: BG;
		Grating: B1;
		GrateColor: TColor;
		DX, DY, DW, DH: SG;

		OfsX, OfsY: SG;
		MaxOfsX, MaxOfsY: SG;

		// Scrolls
		ScrollBarHWidth, ScrollBarHHeight,
		ScrollBarVWidth, ScrollBarVHeight: Integer;

		constructor Create(AOwner: TComponent); override;
		procedure CreateZoom(Zoom1: TMenuItem);
		destructor Destroy; override;

		function GetPosX(X: SG): SG;
		function GetPosY(Y: SG): SG;

		procedure OffsetRange(var NOfsX, NOfsY: Integer);
		procedure ScrollTo(NOfsX, NOfsY: Integer);
		procedure Invalidate; override; // Invalidate (Fill and Paint)

		// override
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
		function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
		property Bitmap: TDBitmap read FBitmap;
	published

		property Zoom: TZoom read TargetZoom write SetZoom;
		property DrawFPS: Boolean read FDrawFPS write FDrawFPS default False;
		property HandScroll: Boolean read FHandScroll write FHandScroll default False;
		property HotTrack: Boolean read FHotTrack write SetHotTrack default True;
		property OnFill: TNotifyEvent read FOnFill write FOnFill;
		property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;

		property Align;
		property Anchors;
		property BiDiMode;
		property Constraints;
		property Ctl3D;
		property DragCursor;
		property DragKind;
		property DragMode;
		property Enabled;
		property ParentBiDiMode;
		property ParentCtl3D;
		property ParentShowHint;
		property PopupMenu;
		property ShowHint;
		property TabOrder;
		property TabStop default True;
		property Visible;
		property OnContextPopup;
		property OnDragDrop;
		property OnDragOver;
		property OnEndDock;
		property OnEndDrag;
		property OnEnter;
		property OnExit;
		property OnMouseDown;
		property OnMouseUp;
		property OnMouseMove;
		property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
		property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
		property OnMouseWheel;
		property OnMouseWheelDown;
		property OnMouseWheelUp;

		property OnKeyDown;
		property OnKeyPress;
		property OnKeyUp;
		property OnStartDock;
		property OnStartDrag;

		property OnDblClick;
	end;

{procedure ZoomMake(
	BmpSource: TDBitmap;
	VisX, VisY: Integer;
	AsWindow: Boolean; Zoom: TZoom; XYConst: Boolean; QualityResize: Boolean;
	var OX, OY: Integer;
	out SourceWidth, SourceHeight: Integer;
	out SX1, SY1, SXW, SYH: Integer;
	out DX1, DY1, DXW, DYH: Integer;
	var BmpSource2: TDBitmap);}

procedure Register;

implementation

uses
	Math, ClipBrd,
	uMenus, uGraph, uSysInfo, uStrings, uGetInt, uGColor, uFormat, uError;

const
//	ZoomDiv = 2520;
	MenuNames: array[TZoomMenu] of string = (
		'Zoom In', 'Zoom Out',
		'1:2', '1:1', '2:1',
		'Fit Image', 'Fit Width', 'Fit Height',
		'Zoom To' + cDialogSuffix,
		'Center', 'Grate', 'Grate Color' + cDialogSuffix, 'Copy');
	MenuShort: array[TZoomMenu] of Char = (
		'I', 'U',
		#0, 'Q', #0,
		#0, #0, #0,
		#0,
		#0, #0, #0, 'C');

procedure TDImage.AdvancedDraw(Sender: TObject; ACanvas: TCanvas;
	ARect: TRect; State: TOwnerDrawState);
begin
	MenuAdvancedDrawItem(Sender, ACanvas, ARect, State);
end;

procedure TDImage.CreateZoom(Zoom1: TMenuItem);
var
	i: TZoomMenu;
	j: SG;
	MS: TMenuItem;
begin
	PopupMenu := TPopupMenu.Create(Self);
	ZoomMenu := Zoom1;

	j := 0;
	for i := Low(TZoomMenu) to High(TZoomMenu) do
	begin
		if i in [zm12, zmCenter] then
		begin
			MS := TMenuItem.Create(nil);
			MS.Caption := '-';
{			if ZoomMenu <> nil then
				ZoomMenu.Insert(j, MS);}
			PopupMenu.Items.Insert(j, MS);
			Inc(j);
		end;
		M[i] := TMenuItem.Create(nil);
		M[i].Tag := SG(i);
		M[i].Caption := MenuNames[i];
		M[i].Name := ComponentName(MenuNames[i]);// 'Zoom' + IntToStr(SG(i));
		if M[i].Name = 'ZoomIn' then M[i].Name := 'InZoom'
		else if M[i].Name = 'ZoomOut' then M[i].Name := 'OutZoom';
		if MenuShort[i] <> #0 then
			M[i].ShortCut := ShortCut(Ord(MenuShort[i]), [ssCtrl]);

		M[i].OnClick := ZoomClick;
{		if ZoomMenu <> nil then
			ZoomMenu.Insert(j, M[i]);}
		PopupMenu.Items.Insert(j, M[i]);
		Inc(j);
	end;
	FEnableZoom := True;
	if ZoomMenu <> nil then
	begin
		MenuCreate(PopupMenu.Items, ZoomMenu);
		MenuUpdate(PopupMenu.Items, ZoomMenu);
	end;
	MenuSet(PopupMenu, AdvancedDraw);
end;

const
	OfsS = 20; // ms; FPS = 1000 / OfsS
	ScrollEf = ef14;
	ScrollEf2 = ef12;

var Slf: TDImage;

procedure OnApplyNum(Value: S8);
begin
	Slf.ChangeZoom(Value / 1000);
	Slf.Invalidate;
end;

procedure OnApplyColor(Color: TColor);
begin
	Slf.GrateColor := Color;
	Slf.Invalidate;
end;

procedure TDImage.Timer1Timer(Sender: TObject);
const
	A0 = 1;
var
	DT: TZoom;
	Dif, Dif2: TZoom;
	k: TZoom;
begin
//	DT := FTimer.ElapsedTime / PerformanceFrequency;
	DT := FTimer.Interval / 1000;
	Dif := TargetZoom - ActualZoom;
	Dif2 := Dif / TargetZoom;
	if (Abs(Dif2) < 0.01){Distance is small} and (V < 100){Speed is slow} then
	begin
		// Parking
		ActualZoom := TargetZoom;
		V := 0;
		A := 0;
		FTimer.Enabled := False;
	end
	else
	begin
		k := 1 * V - 2300{Value < 2000 is unstable!} * (1.1 * Dif2);
{		if Abs(k) < 100 then
			A := 0
		else} if k > 0 then
			A := -A0
		else
			A := A0;
		if Sgn(A) = Sgn(V) then
			if Abs(A) > A0 div 2 then A := Sgn(A) * A0 / 4; // Slows acceleration
	end;

//	if V < 100 then A := A0;

	V := V + A * DT * 1000; if Abs(V) > 500 then V := Sgn(V) * 500;
	ActualZoom := ActualZoom * (1 + 0.003 * V * DT);
{	if S > MaxS then S := MaxS;
	ActualZoom := ((MaxS - S) * StartZoom + S * NewZoom) / MaxS;}

	Invalidate;
end;


procedure TDImage.InitZoomMenu;
begin
	if Assigned(M[zmCenter]) = False then Exit;
	M[zmCenter].Checked := Center;
	M[zmGrate].Checked := Grate;

	M[zmIn].Enabled := TargetZoom < 256;
	M[zmOut].Enabled := TargetZoom > 1 / 256;

	M[zm12].Enabled := TargetZoom <> 1 / 2;
	M[zm12].Checked := not M[zm12].Enabled;

	M[zm1].Enabled := TargetZoom <> 1;
	M[zm1].Checked := not M[zm1].Enabled;

	M[zm2].Enabled := TargetZoom <> 2;
	M[zm2].Checked := not M[zm2].Enabled;
	if ZoomMenu <> nil then
		MenuUpdate(PopupMenu.Items, ZoomMenu);
end;

procedure TDImage.ChangeZoom(NewZoom: TZoom);
begin
	if NewZoom <> TargetZoom then
	begin
		TargetZoom := NewZoom;
		InitZoomMenu;
		if FTimer = nil then
		begin
			FTimer := TTimer.Create(Self);
			FTimer.Enabled := False;
//			FTimer.EventStep := esFrequency;
//			FTimer.Interval := 25;
			FTimer.Interval := 40;
			FTimer.OnTimer := Timer1Timer;
		end;
		FTimer.Enabled := True;
		LastTickCount := GetTickCount;
	end;
end;

procedure TDImage.ZoomClick(Sender: TObject);
var ZoomI: SG;
begin
	Slf := Self;
	case TZoomMenu(TMenuItem(Sender).Tag) of
	zmIn:
	begin
		ChangeZoom(TargetZoom * 2);
	end;
	zmOut:
	begin
		ChangeZoom(TargetZoom / 2);
	end;
	zmFitImage: if UserBitmap <> nil then ChangeZoom(Min(FBitmap.Width / UserBitmap.Width, FBitmap.Height / UserBitmap.Height));
	zmFitWidth: if UserBitmap <> nil then ChangeZoom(FBitmap.Width / UserBitmap.Width);
	zmFitHeight: if UserBitmap <> nil then ChangeZoom(FBitmap.Height / UserBitmap.Height);
	zm12: ChangeZoom(1 / 2);
	zm1: ChangeZoom(1);
	zm2: ChangeZoom(2);
	zmCustom:
	begin
		ZoomI := Round(TargetZoom * 1000);
		if GetNumber('Zoom To (' + CharTimes + '1000)', ZoomI, 1, 1000, 256 * 1000, OnApplyNum) then
			TargetZoom := ZoomI / 1000;
	end;
	zmCenter:
	begin
		Center := not Center;
		Invalidate;
		M[zmCenter].Checked := Center;
	end;
	zmGrate:
	begin
		Grate := not Grate;
		Invalidate;
		M[zmGrate].Checked := Grate;
	end;
	zmGrateColor:
		GetColor('Grate Color', GrateColor, clWhite, OnApplyColor);
	zmCopy:
		Clipboard.Assign(TBitmap(Bitmap));
	end;
end;

procedure TDImage.WMPaint(var Message: TWMPaint);
begin
	inherited;
	{$ifopt d+}
	Inc(FPaintCount);
	{$endif}
	if FNeedFill then FillBitmap;

	if FBitmap.Empty then
	begin
		FCanvas.Brush.Style := bsSolid;
		FCanvas.Brush.Color := clAppWorkSpace;
		PatBlt(
			FCanvas.Handle,
			0,
			0,
			Width,
			Height,
			PATCOPY
		);
	end
	else
	begin
		FBitmap.DrawToDC(FCanvas.Handle, 0, 0);
	end;
	if Assigned(FOnPaint) then
	begin
		try
			FOnPaint(Self);
		except
			on E: Exception do
				MessageD(E.Message, mtError, [mbOk]);
		end;
	end;
	{$ifopt d+}
	Canvas.Brush.Style := bsClear;
	Canvas.Font.Color := clWhite;
	Canvas.TextOut(0, 0, IntToStr(FFillCount) + '/' + IntToStr(FPaintCount));
	{$endif}
end;

procedure TDImage.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
	Message.Result := 1;
end;

procedure TDImage.CMMouseEnter(var Message: TWMMouse);
begin
	inherited;
	MouseOn := True;
	if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TDImage.CMMouseLeave(var Message: TWMMouse);
begin
	inherited;
	MouseOn := False;
	if MouseWhere <> mwNone then
	begin
		if MouseWhere <> mwScroll then
		begin
			MouseWhere := mwNone;
			Invalidate;
		end
		else
			MouseWhere := mwNone;
	end;
	if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TDImage.WMSize(var Message: TWMSize);
begin
	inherited;
	Invalidate;
end;

constructor TDImage.Create(AOwner: TComponent);
begin
	inherited;
	ActualZoom := 1;
	TargetZoom := 1;

	FCanvas := TControlCanvas.Create;
	TControlCanvas(FCanvas).Control := Self;

	FHotTrack := True;

	FBitmap := TDBitmap.Create;
	FBitmap.Canvas.Font := Font;

	TabStop := True;
	//	ControlStyle := [csDoubleClicks, csOpaque, csAcceptsControls, csMenuEvents, csDisplayDragImage, csReflector];
	ControlStyle := ControlStyle + [csOpaque, csMenuEvents, csDisplayDragImage, csReflector] - [csSetCaption];
end;

destructor TDImage.Destroy;
begin
	FreeAndNil(FTimer);

	FreeAndNil(FCanvas);
	FreeAndNil(FBitmap);
	BmpS := nil;
	UserBitmap := nil;
	FreeAndNil(BmpSourceS);
	inherited;
end;

procedure TDImage.CreateParams(var Params: TCreateParams);
{const
	BorderStyles: array[TBorderStyle] of U4 = (0, );}
begin
	inherited;
	LCursor := Cursor;
	with Params do
	begin
//		Style := Style or WS_BORDER;
		WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
//		ExStyle := ExStyle or WS_EX_CLIENTEDGE;
//		WindowClass.style := WindowClass.style or CS_KEYCVTWINDOW;
		Style := Style or BS_OWNERDRAW;
	end;
end;

function TDImage.MouseWh(const X, Y: Integer): TMouseAction;
begin
	if (X < 0) or (X >= FBitmap.Width) or (Y < 0) or (Y >= FBitmap.Height) then
		Result := mwScroll
	else
	begin
		Result := mwScroll;
		if VType <> 0 then
		if X + ScrollBarVWidth > FBitmap.Width then
		begin // V
			if Y < ScrollBarHHeight then
				Result := mwScrollVD
			else if Y < SliderVY1 then
				Result := mwScrollVD2
			else if Y <= SliderVY2 then
				Result := mwScrollV
			else if Y < ScrollBarVHeight - ScrollBarHHeight then
				Result := mwScrollVU2
			else if Y < ScrollBarVHeight then
				Result := mwScrollVU;
		end;
		if HType <> 0 then
		if Y + ScrollBarHHeight > FBitmap.Height then
		begin // H
			if X < ScrollBarVWidth then
				Result := mwScrollHD
			else if X < SliderHX1 then
				Result := mwScrollHD2
			else if X <= SliderHX2 then
				Result := mwScrollH
			else if X < ScrollBarHWidth - ScrollBarVWidth then
				Result := mwScrollHU2
			else if X < ScrollBarHWidth then
				Result := mwScrollHU;
		end;
	end;
end;

procedure TDImage.OffsetRange(var NOfsX, NOfsY: Integer);
begin
	if NOfsX > UserWidth - NowMaxWidth then
		NOfsX := UserWidth - NowMaxWidth;
	if NOfsX < 0 then
		NOfsX := 0;

	if NOfsY > UserHeight - NowMaxHeight then
		NOfsY := UserHeight - NowMaxHeight;
	if NOfsY < 0 then
		NOfsY := 0;
end;

procedure TDImage.ScrollTo(NOfsX, NOfsY: Integer);
begin
	OffsetRange(NOfsX, NOfsY);
	if (OfsX <> NOfsX) or (OfsY <> NOfsY) then
	begin
		OfsX := NOfsX;
		OfsY := NOfsY;
		Invalidate;
	end;
end;

procedure TDImage.MouseDown(Button: TMouseButton; Shift: TShiftState;
	X, Y: Integer);
const
	Speed1 = 65536 div 8; // Pixels / ms (x65536)
	StepInt = 500;
var
	Speed: Int64;
	TimeO, LastTickCount, FrameTickCount: U4;
	Cycle: UG;
	NOfsX, NOfsY: Integer;
	MouseA: TMouseAction;
begin
	SetFocus;

	MouseX := X;
	MouseY := Y;

	case Button of
	mbLeft:
	begin
		MouseL := True;
		MouseA := MouseWh(X, Y);
		case MouseA of
		mwScrollH:
		begin
			MouseAction := mwScrollH;
			MouseX := X;
			BOfsX := OfsX;
			Invalidate;
		end;
		mwScrollV:
		begin
			MouseAction := mwScrollV;
			MouseY := Y;
			BOfsY := OfsY;
			Invalidate;
		end;
		mwScrollHD, mwScrollHU,
		mwScrollVD, mwScrollVU,
		mwScrollHD2, mwScrollHU2,
		mwScrollVD2, mwScrollVU2:
		begin
			MouseAction := MouseA;
			LastTickCount := GetTickCount;
			case MouseA of
{     mwScrollHD, mwScrollHU,
			mwScrollVD, mwScrollVU: Speed := Speed1;}
			mwScrollHD2, mwScrollHU2: Speed := 64 * Int64(MaxOfsX);
			mwScrollVD2, mwScrollVU2: Speed := 64 * Int64(MaxOfsY);
			else Speed := Speed1;
			end;
			if Speed = 0 then Speed := 1;

			TimeO := 10; // ms
			NOfsX := RoundDivS8(65536 * S8(OfsX), Speed);
			NOfsY := RoundDivS8(65536 * S8(OfsY), Speed);
{     case MouseW of
			mwScrollHD, mwScrollHU,
			mwScrollHD2, mwScrollHU2:
			begin
			else
			begin
			end;}
//      MouseW := mdScrollB;
			Cycle := 0;
			FrameTickCount := 0;
			while MouseAction <> mwNone do
			begin
				case MouseA of
				mwScrollHD, mwScrollHD2: Dec(NOfsX, TimeO);
				mwScrollHU, mwScrollHU2: Inc(NOfsX, TimeO);
				mwScrollVD, mwScrollVD2: Dec(NOfsY, TimeO);
				mwScrollVU, mwScrollVU2: Inc(NOfsY, TimeO);
				end;
				ScrollTo(RoundDivS8(S8(Speed) * S8(NOfsX), 65536),
					RoundDivS8(S8(Speed) * S8(NOfsY), 65536));
//				Application.HandleMessage; no
				Application.ProcessMessages;
				if GetTickCount >= LastTickCount then
				begin
					TimeO := GetTickCount - LastTickCount;
					if TimeO < OfsS then
					begin
						Sleep(OfsS - TimeO);
						TimeO := OfsS;
					end;
					Inc(LastTickCount, TimeO);
				end;
				Inc(Cycle);
				if LastTickCount >= FrameTickCount then
				begin
					FFramePerSec := 1000 * Cycle / (LastTickCount - FrameTickCount + StepInt);
					FrameTickCount := LastTickCount + StepInt;
					Cycle := 0;
				end;
			end;
			MouseAction := MouseA;
			MouseAction := mwNone;
			FFramePerSec := 0;
			Exit;
		end;
		mwScroll:
		begin
			if ((MaxOfsX > 0) or (MaxOfsY > 0)) and (HandScroll or (ssShift in Shift)) then
			begin
				Screen.Cursor := 2;
				MouseAction := mwScroll;
				MouseX := OfsX + X;
				MouseY := OfsY + Y;
			end
			else
			begin
				MouseAction := mwNone;
			end;
		end;
		end;
	end;
	mbRight: MouseR := True;
	mbMiddle: MouseM := True;
	end;

	inherited;
end;

procedure TDImage.MouseMove(Shift: TShiftState; X, Y: Integer);
var
	NOfsX, NOfsY: Integer;
	Sc: Boolean;
	MouseW: TMouseAction;
begin
	if (X = LMouseX) and (Y = LMouseY) then Exit;
	LMouseX := X;
	LMouseY := Y;

	Sc := True;
	if MouseAction = mwNone then
	begin
		MouseW := MouseWh(X, Y);
		case MouseW of
		mwScrollH, mwScrollV,
		mwScrollHD, mwScrollHU,
		mwScrollVD, mwScrollVU,
		mwScrollHD2, mwScrollHU2,
		mwScrollVD2, mwScrollVU2:
		begin
			Sc := False;
			if Cursor <> crArrow then
				Cursor := crArrow;
		end
		else
		begin
			Sc := (HandScroll or (ssShift in Shift)) and ((UserWidth - NowMaxWidth > 0) or (UserHeight - NowMaxHeight > 0));
			if Sc then
				FCur := 1 + SG(MouseL)
			else
				FCur := LCursor;
			if {(Cursor = crArrow) and} (Cursor <> FCur) then
				Cursor := FCur;
		end;
		end;

		if MouseWhere <> MouseW then
		begin
			if ((MouseWhere = mwNone) and (MouseW = mwScroll)) or
			((MouseWhere = mwScroll) and (MouseW = mwNone)) then
				MouseWhere := MouseW
			else
			begin
				MouseWhere := MouseW;
				Invalidate;
			end;
		end;
	end;

	NOfsX := OfsX;
	NOfsY := OfsY;

	if FEnableZoom then
	case MouseAction of
	mwNone, mwScroll:
	begin
		if DW <> 0 then
			UserMouseX := Trunc((X + OfsX) / ActualZoom);
		if DH <> 0 then
			UserMouseY := Trunc((Y + OfsY) / ActualZoom);
	end;
	end;

	case MouseAction of
	mwScroll:
	begin
		if Sc then
		begin
			NOfsX := MouseX - X;
			NOfsY := MouseY - Y;
		end;
	end;
	mwScrollH:
	begin
		NOfsX := BOfsX + RoundDivS8(S8(UserWidth) * S8(X - MouseX), NowMaxWidth - 2 * ScrollBarHHeight);
		NOfsY := OfsY;
	end;
	mwScrollV:
	begin
		NOfsX := OfsX;
		NOfsY := BOfsY + RoundDivS8(S8(UserHeight) * S8(Y - MouseY), NowMaxHeight - 2 * ScrollBarVWidth);
	end;
	end;
{	TickCount := GetTickCount;
	if TickCount < LTickCount + OfsS then
	begin
		Sleep(LTickCount + OfsS - TickCount);
		TickCount := LTickCount + OfsS;
	end;
	LTickCount := TickCount;}
	ScrollTo(NOfsX, NOfsY);
//  if (MouseW = mwNone){ or (MouseW = mwScroll)} then
	inherited;
end;

procedure TDImage.MouseUp(Button: TMouseButton; Shift: TShiftState;
	X, Y: Integer);
begin
	Screen.Cursor := crDefault;
	case Button of
	mbLeft:
	begin
		MouseL := False;
		case MouseAction of
		mwScrollHD, mwScrollHU,
		mwScrollVD, mwScrollVU,
		mwScrollHD2, mwScrollHU2,
		mwScrollVD2, mwScrollVU2,
		mwScrollH, mwScrollV:
		begin
			if MouseAction <> mwNone then
			begin
				MouseAction := mwNone;
				Invalidate;
			end;
		end;
		mwScroll:
		begin
			MouseAction := mwNone;
			if (HandScroll or (ssShift in Shift)) and ((UserWidth - NowMaxWidth > 0) or (UserHeight - NowMaxHeight > 0)) then
				Cursor := 1
			else
				Cursor := LCursor;
		end;
		end;
	end;
	mbRight: MouseR := False;
	mbMiddle: MouseM := False;
	end;
	inherited;
end;

function TDImage.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
	inherited DoMouseWheelDown(Shift, MousePos);
	if [] = Shift then
	begin
		ScrollTo(OfsX, OfsY + RoundDiv(MaxOfsY, 32));
	end
	else if ssCtrl in Shift then
	begin
		if FEnableZoom then
			ChangeZoom(TargetZoom / 2);
	end;
	Result := False;
end;

function TDImage.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
	inherited DoMouseWheelUp(Shift, MousePos);
	if [] = Shift then
	begin
		ScrollTo(OfsX, OfsY - RoundDiv(MaxOfsY, 32));
	end
	else if ssCtrl in Shift then
	begin
		if FEnableZoom then
			ChangeZoom(TargetZoom * 2);
	end;
	Result := False;
end;

procedure TDImage.InitScrolls;
begin
	ScrollBarVWidth := GetSystemMetrics(SM_CXVSCROLL);
	if UserWidth > FBitmap.Width then
		HType := 1
	else if UserWidth > FBitmap.Width - ScrollBarVWidth then
		HType := 2
	else
		HType := 0;

	ScrollBarHHeight := GetSystemMetrics(SM_CYHSCROLL);
	if UserHeight > FBitmap.Height then
	begin
		VType := 1;
		if HType = 2 then HType := 1;
	end
	else if UserHeight > FBitmap.Height - ScrollBarHHeight then
	begin
		case HType of
		0:
			VType := 0;
		2:
		begin
			VType := 0;
			HType := 0;
		end;
		else
			VType := 1;
		end;
	end
	else
	begin
		VType := 0;
		if HType = 2 then HType := 0;
	end;

	NowMaxWidth := FBitmap.Width - ScrollBarVWidth * VType;
	NowMaxHeight := FBitmap.Height - ScrollBarHHeight * HType;
	MaxOfsX := UserWidth - NowMaxWidth;
	MaxOfsY := UserHeight - NowMaxHeight;
//	OffsetRange(OfsX, OfsY);
end;

procedure ZoomMake(
	BmpSource: TDBitmap;
	VisX, VisY: Integer;
	AsWindow, Center:BG; Zoom: TZoom; XYConst: Boolean; QualityResize: Boolean;
	var OX, OY: Integer;
	out SourceWidth, SourceHeight: Integer;
	out SX1, SY1, SXW, SYH: Integer;
	out DX1, DY1, DXW, DYH: Integer;
	var BmpSource2: TDBitmap);

var
	SX, SY: Integer;
//	LastCursor: TCursor;
begin
	if AsWindow then
	begin
		if XYConst = False then
		begin
			SX := VisX;
			SY := VisY;
		end
		else
		begin
			if VisY * BmpSource.Width >=
				VisX * BmpSource.Height then
			begin
				SX := VisX;
				SY := RoundDiv(VisX * BmpSource.Height,
					BmpSource.Width);
			end
			else
			begin
				SX := RoundDiv(VisY * BmpSource.Width,
					BmpSource.Height);
				SY := VisY;
			end;
		end;

		SX1 := 0;
		SY1 := 0;
		SXW := BmpSource.Width;
		SYH := BmpSource.Height;

		DX1 := 0;
		DY1 := 0;
		DXW := SX;
		DYH := SY;
{   ZoomedWidth := BmpSource.Width;
		ZoomedHeight := BmpSource.Height;}

		SourceWidth := SX;
		SourceHeight := SY;
	end
	else
	begin
		SX := Round(Zoom * BmpSource.Width);
		SY := Round(Zoom * BmpSource.Height);

		DX1 := 0;
		DY1 := 0;

//		Smaller := False;
		if VisX > SourceWidth then
		begin
//			Smaller := True;
			if Center then
				DX1 := (VisX - SourceWidth) div 2;
		end;
		if VisY > SourceHeight then
		begin
//			Smaller := True;
			if Center then
				DY1 := (VisY - SourceHeight) div 2;
		end;


		SourceWidth := SX;
		SourceHeight := SY;

		// D???
		if OX > SX then OX := 0;//SX;
		if OY > SY then OY := 0;//SY;

		{   if SX > VisX then SX := VisX;
		if SY > VisY then SY := VisY;}
		if Zoom <= 1 then
		begin

		end
		else
		begin
			DX1 := DX1 - Round(Zoom * Frac(OX / Zoom));
			DY1 := DY1 - Round(Zoom * Frac(OY / Zoom));
		end;

		SXW := Ceil(VisX / Zoom - DX1);
		SYH := Ceil(VisY / Zoom - DY1);
		DXW := Round(Zoom * SXW);
		DYH := Round(Zoom * SYH);

		if Zoom <= 1 then
		begin
			SX1 := OX;
			SY1 := OY;
		end
		else
		begin
			SX1 := Trunc(OX / Zoom);
			SY1 := Trunc(OY / Zoom);
		end;


		{   if (DX1 < 0) then
		begin
			Inc(SXW);
		end;
		if (DY1 < 0) then
		begin
			Inc(SYH);
		end;}


	end;

	if (SourceWidth < BmpSource.Width) or (SourceHeight < BmpSource.Height) then
	begin
		// D??? Zoom Part
		// D??? Update problem!
		if not Assigned(BmpSource2) then
		begin
			BmpSource2 := TDBitmap.Create;
		end;
		if (BmpSource2.Width <> SourceWidth)
		or (BmpSource2.Height <> SourceHeight) then
		begin
			BmpSource2.SetSize(SourceWidth, SourceHeight);
			if (QualityResize = False) {or (Zoom > 1)} then
			begin
				SetStretchBltMode(BmpSource2.Canvas.Handle, COLORONCOLOR);
				StretchBlt(BmpSource2.Canvas.Handle,
					0, 0,
					BmpSource2.Width, BmpSource2.Height,
					BmpSource.Canvas.Handle,
					0, 0,
					BmpSource.Width, BmpSource.Height,
					SRCCOPY);
	{     BmpSource2.Canvas.StretchDraw(Rect(0, 0,
					BmpSource2.Width, BmpSource2.Height), BmpSource);}
			end
			else
			begin
{				LastCursor := Screen.Cursor;
				Screen.Cursor := crHourGlass;}
				BmpSource2.Resize(SourceWidth, SourceHeight, BmpSource);
//				Screen.Cursor := LastCursor;
			end;
		end;
		SXW := DXW;
		SYH := DYH;
	end
	else
	begin
		if Assigned(BmpSource2) then
		begin
			FreeAndNil(BmpSource2);
		end;
	end;
end;

function TDImage.GetPosX(X: SG): SG;
begin
	Result := RoundSG(ActualZoom * X - OfsX);
end;

function TDImage.GetPosY(Y: SG): SG;
begin
	Result := RoundSG(ActualZoom * Y - OfsY);
end;

procedure TDImage.FillUserBitmap;
var
	e: FA;
	i: SG;
begin
	if UserBitmap <> nil then
	begin
		if Center then
			FBitmap.AntiBar(DX, DY, DW - 1, DH - 1, clAppWorkSpace, ef16)
		else
			FBitmap.Bar(DX, DY, DW - 1, DH - 1, clAppWorkSpace, ef16); // D??? Temp
		SetStretchBltMode(FBitmap.Canvas.Handle, COLORONCOLOR);
		StretchBlt(FBitmap.Canvas.Handle,
			DX, DY,
			DW, DH,
			BmpS.Canvas.Handle,
			SX, SY,
			SW, SH,
			SRCCOPY);

		if Grate then
		begin
			if ActualZoom >= 3 then
			begin
				e := (Round(ActualZoom) - OfsX) mod Round(ActualZoom);
				i := Round(e);
				while i < UserWidth do
				begin
					FBitmap.Line(i, 0, i, UserHeight - 1, GrateColor, ef12);
					e := e + ActualZoom;
					i := RoundSG(e);
				end;
				e := (Round(ActualZoom) - OfsY) mod Round(ActualZoom);
				i := RoundSG(e);
				while i < UserHeight do
				begin
					FBitmap.Line(0, i, UserWidth - 1, i, GrateColor, ef12);
					e := e + ActualZoom;
					i := Round(e);
				end;
			end;
		end;
	end;
end;

procedure TDImage.Invalidate;
begin
	FNeedFill := True;
	inherited Invalidate;
end;

procedure TDImage.FillBitmap;
var
	ScrollLen, ScrollLenS: Integer;
	X1, Y1, X2, Y2: Integer;
	C: TColor;
	Co: array[0..3] of TColor;
	I1, I2: SG;
	SliderC1, SliderC2: TColor;
	s: string;
	i, x, y: SG;
  FontColor: TColor;
	FontSize: SG;
//	FontName: TFontName;
	R: TRect;
	{$ifopt d+}
	StartTickCount: U4;
	{$endif}
begin
	{$ifopt d+}StartTickCount := GetTickCount;{$endif}
	FNeedFill := False;
	if (FBitmap.Width <> Width) or (FBitmap.Height <> Height) then
		Bitmap.SetSize(Width, Height);

{	Smaller := False;
	DW := Round(UserWidth * Zoom);
	if DW > Width then
	begin
		DX := 0;
		DW := Width;
	end
	else
	begin
		DX := (Width - DW) div 2;
		Smaller := True;
	end;
	DH := Round(UserHeight * Zoom);
	if DH > Height then
	begin
		DY := 0;
		DH := Height;
	end
	else
	begin
		DY := (Height - DH) div 2;
		Smaller := True;
	end;}

	if FEnableZoom then
	begin
		SX := 0;
		SY := 0;
		SW := 0;
		SH := 0;
		DX := 0;
		DY := 0;
		DX := 0;
		DH := 0;
		if UserBitmap <> nil then
		begin
			ZoomMake(
				UserBitmap,
				Width, Height,
				False, Center, ActualZoom, False, False{True},
				OfsX, OfsY,
				UserWidth, UserHeight,
				SX, SY, SW, SH,
				DX, DY, DW, DH,
				BmpSourceS);

			if Assigned(BmpSourceS) then
				BmpS := BmpSourceS
			else
				BmpS := UserBitmap;
		end;
	end;

	FillUserBitmap;
	if Assigned(FOnFill) then
	begin
		try
			FOnFill(Self);
		except
			on E: Exception do
				MessageD(E.Message, mtError, [mbOk]);
		end;
	end;
	InitScrolls;

	SliderC1 := DarkerColor(clScrollBar);
	SliderC2 := LighterColor(clScrollBar);

	// H
	if (UserWidth > 0) and (HType = 1) and (NowMaxWidth > 2 * ScrollBarHHeight) then
	begin
		ScrollBarHWidth := NowMaxWidth;
		Y1 := Integer(Bitmap.Height) - ScrollBarHHeight;
		Y2 := Bitmap.Height - 1;

		X1 := 0;
		X2 := ScrollBarVWidth - 1;
//			Bitmap.Line(X1, Y1, NowMaxWidth - 1, Y1, RColor(238, 237, 229).L, ScrollEf);

{   Bitmap.Border(X1, Y1, X2, Y2, DepthColor(3), DepthColor(0), 1, ScrollEf);
		Bitmap.Bar(clNone, X1 + 1 , Y1 + 1, X2 - 1, Y2 - 1, clBtnFace, ScrollEf);}
		Bitmap.DrawArrow(X1, Y1, X2, Y2, MouseAction = mwScrollHD, FHotTrack and (MouseWhere = mwScrollHD), 1, ScrollEf);

		X1 := NowMaxWidth - ScrollBarVWidth;
		X2 := NowMaxWidth - 1;
{   Bitmap.Border(X1, Y1, X2, Y2, DepthColor(3), DepthColor(0), 1, ScrollEf);
		Bitmap.Bar(clNone, X1 + 1 , Y1 + 1, X2 - 1, Y2 - 1, clBtnFace, ScrollEf);}
		Bitmap.DrawArrow(X1, Y1, X2, Y2, MouseAction = mwScrollHU, FHotTrack and (MouseWhere = mwScrollHU), 3, ScrollEf);

		// TScrollBoxSlider
		ScrollLen := NowMaxWidth - 2 * ScrollBarVWidth;
		ScrollLenS := NowMaxWidth * ScrollLen div UserWidth;
		if ScrollLenS < ScrollBarHHeight div 2 then ScrollLenS := ScrollBarHHeight div 2;

		Y1 := Integer(Bitmap.Height) - ScrollBarHHeight + 1;
		Y2 := Bitmap.Height - 1 - 1;
		X1 := ScrollBarVWidth + RoundDivS8(S8(ScrollLen - ScrollLenS) * S8(OfsX), UserWidth - NowMaxWidth);
		X2 := X1 + ScrollLenS - 1;
		SliderHX1 := X1;
		SliderHX2 := X2;

		if MouseAction = mwScrollH then
		begin
			I1 := 0;
			I2 := 3;
		end
		else
		begin
			I1 := 3;
			I2 := 0;
		end;
		Bitmap.Border(X1, Y1, X2, Y2, clDepth[I1], clDepth[I2], 1, ScrollEf);
//			Bitmap.Bar(clNone, X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, C, ScrollEf);
		if FHotTrack and (MouseWhere = mwScrollH) then
		begin
			Co[0] := $fffffd;
			Co[1] := $fbdab9;
			Co[2] := Co[0];
			Co[3] := Co[1];
		end
		else
		begin
			Co[0] := $ffe6d6;
			Co[1] := $f1c3ae;
			Co[2] := Co[0];
			Co[3] := Co[1];
		end;
		Bitmap.GenerateRGBEx(X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, gfFade2x, Co, 0, ScrollEf, 0, nil);
		x := (X1 + X2) div 2 - RoundDiv(ScrollBarHHeight, 6);
		for i := 0 to RoundDiv(ScrollBarHHeight, 6) - 1 do
		begin
			Bitmap.Line(x, Y1 + 4, x, Y2 - 5, $fef4ee, ef16);
			Inc(x);
			Bitmap.Line(x, Y1 + 5, x, Y2 - 4, $d0b08c, ef16);
			Inc(x);
		end;


		// =
		X1 := ScrollBarVWidth;
		X2 := SliderHX1 - 1;
		Y1 := Integer(Bitmap.Height) - ScrollBarHHeight;
		Y2 := Bitmap.Height - 1;

		if X2 >= X1 then
		begin
			if (MouseAction <> mwScrollHD2) then
				C := clScrollBar
			else
				C := clHighlight;
			Bitmap.Line(X1, Y1, X2, Y1, SliderC1, ScrollEf2);
			Bitmap.Line(X1, Y2, X2, Y2, SliderC2, ScrollEf2);
			Bitmap.Bar(
				X1, Y1 + 1,
				X2, Y2 - 1, C, ScrollEf2);
		end;

		X1 := SliderHX2 + 1;
		X2 := NowMaxWidth - ScrollBarVWidth - 1;
		Y1 := Integer(Bitmap.Height) - ScrollBarHHeight;
		Y2 := Bitmap.Height - 1;

		if X2 >= X1 then
		begin
			if (MouseAction <> mwScrollHU2) then
				C := clScrollBar
			else
				C := clHighlight;
			Bitmap.Line(X1, Y1, X2, Y1, SliderC1, ScrollEf2);
			Bitmap.Line(X1, Y2, X2, Y2, SliderC2, ScrollEf2);
			Bitmap.Bar(
				X1, Y1 + 1,
				X2, Y2 - 1, C, ScrollEf2);
		end;
	end
	else
		ScrollBarHWidth := 0;

	// V
	if (UserHeight > 0) and (VType = 1) and (NowMaxHeight > 2 * ScrollBarVWidth) then
	begin
		ScrollBarVHeight := NowMaxHeight;
		X1 := Integer(Bitmap.Width) - ScrollBarVWidth;
		X2 := Bitmap.Width - 1;
		if (X1 >= 0) and (X2 > X1) then
		begin
			Y1 := 0;
			Y2 := ScrollBarHHeight - 1;
//			Bitmap.Line(X1, Y1, X1, NowMaxHeight - 1, RColor(238, 237, 229).L, ScrollEf);
	{   Bitmap.Border(X1, Y1, X2, Y2, DepthColor(3), DepthColor(0), 1, ScrollEf);
			Bitmap.Bar(clNone, X1 + 1 , Y1 + 1, X2 - 1, Y2 - 1, clBtnFace, ScrollEf);}
			Bitmap.DrawArrow(X1, Y1, X2, Y2, MouseAction = mwScrollVD, FHotTrack and (MouseWhere = mwScrollVD), 0, ScrollEf);

			Y1 := NowMaxHeight - ScrollBarHHeight;
			Y2 := NowMaxHeight - 1;
	{   Bitmap.Border(X1, Y1, X2, Y2, DepthColor(3), DepthColor(0), 1, ScrollEf);
			Bitmap.Bar(clNone, X1 + 1 , Y1 + 1, X2 - 1, Y2 - 1, clBtnFace, ScrollEf);}
			Bitmap.DrawArrow(X1, Y1, X2, Y2, MouseAction = mwScrollVU, FHotTrack and (MouseWhere = mwScrollVU), 2, ScrollEf);
		end;

		// TScrollBoxSlider
		ScrollLen := NowMaxHeight - 2 * ScrollBarHHeight;
		ScrollLenS := NowMaxHeight * ScrollLen div UserHeight;
		if ScrollLenS < ScrollBarVWidth div 2 then ScrollLenS := ScrollBarVWidth div 2;

		X1 := Integer(Bitmap.Width) - ScrollBarVWidth + 1;
		X2 := Bitmap.Width - 1 - 1;
		Y1 := ScrollBarHHeight + (ScrollLen - ScrollLenS) * Int64(OfsY) div (UserHeight - NowMaxHeight);
		Y2 := Y1 + ScrollLenS - 1;
		SliderVY1 := Y1;
		SliderVY2 := Y2;

		if MouseAction = mwScrollV then
		begin
			I1 := 0;
			I2 := 3;
		end
		else
		begin
			I1 := 3;
			I2 := 0;
		end;
		Bitmap.Border(X1, Y1, X2, Y2, clDepth[I1], clDepth[I2], 1, ScrollEf);
//			if FHotTrack and (MouseWhere = mwScrollV) then C := clHighlight else C := clBtnFace;
//			Bitmap.Bar(clNone, X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, C, ScrollEf);
		if FHotTrack and (MouseWhere = mwScrollV) then
		begin
			Co[0] := $fffffd;
			Co[1] := $fbdab9;
			Co[2] := Co[0];
			Co[3] := Co[1];
		end
		else
		begin
			Co[0] := $ffe6d6;
			Co[1] := $f1c3ae;
			Co[2] := Co[0];
			Co[3] := Co[1];
		end;
		Bitmap.GenerateRGBEx(X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, gfFade2x, Co, 0, ScrollEf, 0, nil);
		y := (Y1 + Y2) div 2 - RoundDiv(ScrollBarVWidth, 6);
		for i := 0 to RoundDiv(ScrollBarVWidth, 6) - 1 do
		begin
			Bitmap.Line(X1 + 4, y, X2 - 5, y, $fef4ee, ef16);
			Inc(y);
			Bitmap.Line(X1 + 5, y, X2 - 4, y, $d0b08c, ef16);
			Inc(y);
		end;

		// ||
		Y1 := ScrollBarHHeight;
		Y2 := SliderVY1 - 1;
		X1 := Integer(Bitmap.Width) - ScrollBarVWidth;
		X2 := Bitmap.Width - 1;

		if Y2 >= Y1 then
		begin
			if (MouseAction <> mwScrollVD2) then
				C := clScrollBar
			else
				C := clHighlight;
			Bitmap.Line(X1, Y1, X1, Y2, SliderC1, ScrollEf2);
			Bitmap.Line(X2, Y1, X2, Y2, SliderC2, ScrollEf2);
			Bitmap.Bar(
				X1 + 1, Y1,
				X2 - 1, Y2, C, ScrollEf2);
		end;

		Y1 := SliderVY2 + 1;
		Y2 := NowMaxHeight - ScrollBarHHeight - 1;
		X1 := Integer(Bitmap.Width) - ScrollBarVWidth;
		X2 := Bitmap.Width - 1;

		if Y2 >= Y1 then
		begin
			if (MouseAction <> mwScrollVU2) then
				C := clScrollBar
			else
				C := clHighlight;
			Bitmap.Line(X1, Y1, X1, Y2, SliderC1, ScrollEf2);
			Bitmap.Line(X2, Y1, X2, Y2, SliderC2, ScrollEf2);
			Bitmap.Bar(
				X1 + 1, Y1,
				X2 - 1, Y2, C, ScrollEf2);
		end;
	end
	else
		ScrollBarVHeight := 0;

	{$ifopt d-}
	if FDrawFPS then
	{$endif}
	begin
		FontColor := Bitmap.Canvas.Font.Color;
		FontSize := Bitmap.Canvas.Font.Size;
//		FontName := Bitmap.Canvas.Font.Name;
		Bitmap.Canvas.Font.Color := clWhite;
		Bitmap.Canvas.Font.Height := -Range(8, Min(Width, Height) div 4, 11);
		Bitmap.Canvas.Brush.Style := bsClear;
//		Bitmap.Canvas.Font.Name := 'Sans Serif';

		R := Rect(2, 2, Width - 1 - 2, Height - 1 - 2);

		{$ifopt d+}
		if (OfsX <> 0) or (OfsY <> 0) then
			s := NToS(OfsX) + CharTimes + NToS(OfsY)
		else
			s := '';
		if ActualZoom <> 1 then s := s + ', Zoom=' + FToS(ActualZoom) + ':1' + LineSep + 'V=' + FToS(V) + LineSep + 'A=' + FToS(A);
		DrawCutedText(Bitmap.Canvas, R, taLeftJustify, tlTop, s, True, 1);
		StartTickCount := GetTickCount - StartTickCount;
		if StartTickCount > 15 then
			s := MsToStr(StartTickCount, True, diSD, 3, False)
		else
			s := '';
		Inc(FFillCount);
		{$endif}
		if FFramePerSec >= 0.1 then
		begin
			s := s + {$ifopt d+} ', ' +{$endif}NToS(Round(100 * FFramePerSec), 2);
		end;
		DrawCutedText(Bitmap.Canvas, R, taRightJustify, tlTop, s, True, 1);
		Bitmap.Canvas.Font.Color := FontColor;
		Bitmap.Canvas.Font.Size := FontSize;
//		Bitmap.Canvas.Font.Name := FontName;
	end;
end;

procedure TDImage.SetZoom(Value: TZoom);
begin
	if TargetZoom <> Value then
	begin
		TargetZoom := Value;
		ActualZoom := Value;
		Invalidate;
	end;
end;

procedure TDImage.SetHotTrack(Value: Boolean);
begin
	if FHotTrack <> Value then
	begin
		FHotTrack := Value;
		Invalidate;
	end;
end;

procedure Register;
begin
	RegisterComponents('DComp', [TDImage]);
end;

{
procedure TfMain.InitOXY;
begin
	if ZoomR > 1 then
		OX2 := ZoomR * fMap.ScrollImageM.OfsX
	else
		OX2 := fMap.ScrollImageM.OfsX;
	if ZoomR > 1 then
		OY2 := ZoomR * fMap.ScrollImageM.OfsY
	else
		OY2 := fMap.ScrollImageM.OfsY;
end;

	if Zoom = 0 then
	begin
		BmpRWidth := ImageWorldWidth;
		BmpRHeight := ImageWorldHeight;
		ZoomR := ZoomDiv;
	end
	else
	begin
		if Zoom > 10 * ZoomDiv then Zoom := 10 * ZoomDiv;
		BmpRWidth := Zoom * BmpFile.Width div ZoomDiv;
		BmpRHeight := Zoom * BmpFile.Height div ZoomDiv;
		ZoomR := Zoom;
	end;

	if (BmpRWidth < BmpFile.Width) or (BmpRHeight < BmpFile.Height) then
	begin
		if not Assigned(BmpRFile) then
		begin
			BmpRFile := TDBitmap.Create;
		end;

		if (QualityResize1.Checked = False) or (ZoomR > ZoomDiv) then
		begin
			BmpRFile.SetSize(BmpRWidth, BmpRHeight);

			SetStretchBltMode(BmpRFile.Canvas.Handle, COLORONCOLOR);
			StretchBlt(BmpRFile.Canvas.Handle,
				0, 0,
				BmpRFile.Width, BmpRFile.Height,
				BmpFile.Canvas.Handle,
				0, 0,
				BmpFile.Width, BmpFile.Height,
				SRCCOPY);
		end
		else
		begin
			BmpRFile.SetSize(BmpRWidth, BmpRHeight);
			BmpRFile.Resize(BmpFile, BmpRWidth, BmpRHeight, nil);
		end;
	end
	else
	begin
		if Assigned(BmpRFile) then
		begin
			FreeAndNil(BmpRFile);
		end;
	end;

	procedure TfMain.OffsetRange(var OX, OY: Integer);
begin
	if OX < 0 then
		OX := 0
	else if OX > fMap.ScrollImageM.MaxOfsX then
		OX := fMap.ScrollImageM.MaxOfsX;
	if OY < 0 then
		OY := 0
	else if OY > fMap.ScrollImageM.MaxOfsY then
		OY := fMap.ScrollImageM.MaxOfsY;
end;

	Dec(OX2, ImageWorldWidth div 2);
	Dec(OY2, ImageWorldHeight div 2);
	if ZoomR > ZoomDiv then
	begin
		fMap.ScrollImageM.OfsX := ZoomDiv * OX2 div ZoomR;
		fMap.ScrollImageM.OfsY := ZoomDiv * OY2 div ZoomR;
	end
	else
	begin
		fMap.ScrollImageM.OfsX := OX2;
		fMap.ScrollImageM.OfsY := OY2;
	end;
	OffsetRange(fMap.ScrollImageM.OfsX, fMap.ScrollImageM.OfsY);
}

initialization
	Screen.Cursors[1] := LoadCursor(HInstance, PChar('HANDPOINT'));
	Screen.Cursors[2] := LoadCursor(HInstance, PChar('HANDPOINTDOWN'));
end.
