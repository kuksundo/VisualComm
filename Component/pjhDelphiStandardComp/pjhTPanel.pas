unit pjhTPanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Extctrls,
  Vcl.AppEvnts, Vcl.Graphics, Generics.Collections, ClipBrd, Forms,
  XBaloon, JvBalloonHint,
  pjhclasses, pjhDesignCompIntf, pjhDelphiStandardCompConst, UnitBalloonConst;

type
  TpjhTPanel = class(TPanel, IpjhDesignCompInterface)
  protected
    //For IpjhDesignCompInterface
    FpjhTagInfo: TpjhTagInfo;
    FpjhValue: string;
    FpjhBplFileName: string;

    function GetpjhValue: string;
    procedure SetpjhValue(AValue: string); virtual;
    function GetpjhTagInfo: TpjhTagInfo;
    procedure SetpjhTagInfo(AValue: TpjhTagInfo);
    function GetBplFileName: string;
    procedure SetBplFileName(AValue: string);
    //For IpjhDesignCompInterface
  public
    constructor Create(AOwner: TComponent);  override;
    destructor  Destroy;                     override;
  published
    //For IpjhDesignCompInterface
    property pjhTagInfo: TpjhTagInfo read GetpjhTagInfo write SetpjhTagInfo;
    property pjhValue: string read GetpjhValue write SetpjhValue;
    property pjhBplFileName: string read GetBplFileName write SetBplFileName;
    //For IpjhDesignCompInterface
  end;

(* == TpjhTPanelWithBalloon ���� ==
  1. TpjhTPanelWithBalloon ������Ʈ�� ������ �߰��Ѵ�.(OI���� Name�� Unique�ϰ� ����)
  2. �߰��� TpjhTPanelWithBalloon ������Ʈ�� Visible �Ӽ��� False�� �����Ѵ�.
  3. Watch2�� FSimulatePropertyValueMode�� ���콺�� �����Ͽ� On ��Ų��.(�̶����� �Ʒ� ������׿� ���� Json�� ������)
  4. ǥ���� ������ �Է��Ѵ�.
    4.1 BalloonHeader�� �ؽ�Ʈ�� �Է��Ѵ�.
    4.2 BalloonText�� �ؽ�Ʈ�� �Է��Ѵ�.
  5. OI���� FBalloonShowOnlyMine=True�� ����(�̰��� True�� �������� ������ ǥ�ð� �ȵ�-�ٸ� TpjhTPanelWithBalloon�� �����ϴ� �� ���� �ϱ� ����)
  6. BalloonKind�� ���ϴ� BalloonType�� �����Ѵ�.
  7. ǥ�õ� ������Ʈ�� ���콺�� �̵� �� F8Ű�� ������(F8 ���� ǥ�õ� ������Ʈ�� Name�� Unique�ϰ� �����Ѵ�)
    7.1 BalloonX, BalloonY(ǳ�������� ǥ�õ� ȭ�� ��ǥ��) ���� �����Ѵ�.
    7.2 OI�� BalloonFindCompName�� Balloon�� ǥ���ϰ��� �ϴ� ������Ʈ �̸��� ���������� �Է� �Ǿ����� Ȯ���Ѵ�.
    7.3 SendData2MainformAsJson�Լ��� Call�Ͽ� Json ���·� Watch2�� �����Ѵ�.(WM_COPYDATA Ȱ��)
    7.4 ���� BalloonFindCompName �Ӽ��� ǥ�õ� ������Ʈ �̸��� ���� ���� ��� Component Name�� ����� �Է��Ѵ�
  8. Watch2���� "Move pjhValue To Item and Save To DB" �޴��� �����Ͽ� CommandJson�� DB�� �����Ѵ�.
*)
  TpjhTPanelWithBalloon = class(TpjhTPanel)
  private
    FBalloonObjList: TObjectList<TBaloonWindow>;
    FBalloon: TBaloonWindow;
    FBalloonjvHint: TJvBalloonHint;
    FBalloonHeader: string;
    FBalloonText: TStrings;
    FIsBalloonShow: Boolean;
    FBalloonKind: TBalloonKind;
    FBalloonActiveColor: TColor;
    FBalloonInActiveColor: TColor;
    FBalloonFont: TFont;
    FBalloonX, FBalloonY: integer;
    FBalloonLastX, FBalloonLastY: Integer;
    FBalloonAlign: TBaloonAlign;
    FBalloonDivisionChar: Char;
    FBalloonShape: TPShape;
    FBalloonTextAlign: TTextAlign;
    FBalloonHideIfMouseMove: Boolean;
    FBalloonUseMousePos, //True = Mouse Pos, False = Find Component Position
    FBalloonFindComponent4Pos: Boolean; //True = Find Component and Set FBalloonX, FBalloonLastY
                                        //False = Use original FBalloonX, FBalloonLastY to Show Balloon
    FBalloonRecord: TBalloonRecord;
    FAppEvent: TApplicationEvents;
    FPanelCaption,
    FBalloonFindCompName: string;

    //Watch2�� ȭ�鸶�� �Ѱ��� TpjhTPanelWithBalloon ������Ʈ�� ���� �����ϸ�,
    //�� ������Ʈ ���� F7/F8 Key�� ���� �����ϹǷ� BalloonShow ���� �ѹ��� ���� ���� ǥ�õ�.
    //�̸� �����ϱ� ���� Object Inspector���� FBalloonShowOnlyMine=True�� �����ϰ� ShowBalloon���� FBalloonShowOnlyMine=False�� ������
    //�� F7Ű�� ������(Watch2���� F7 Ű�� ����) BalloonShow�� ��� FBalloonShowOnlyMine=True ���߸� ������.
    FBalloonShowOnlyMine: Boolean;

//    function GetComponentUnderMouseCursor: TControl;
    procedure GetCurrentMousePos;
    function GetComponentNameFromMousePos: string;
    procedure BalloonShow(AText: String; AX: integer = -1; AY: integer = -1);
    procedure BalloonHide;

    procedure SendData2MainformAsJson(const ACompName, APropName, AValue: string);
  protected
    procedure SetBalloonHideIfMouseMove(const Value: Boolean);
    procedure SetBalloonFont(Value: TFont);
    procedure SetBalloonActiveColor      (const Value: TColor);
    procedure SetBalloonInactiveColor    (const Value: TColor);
    procedure SetBalloonText(const Value: TStrings);
    procedure SetBalloonRecord(const Value: TBalloonRecord);
    procedure AppEventsShortCut(var Msg: TWMKey; var Handled: Boolean);
    function GetBalloonRecordFromPropertyToJson(): string;
    function GetComponentPosition(var APoint: TPoint): Boolean;
    procedure GetTextFromBalloonRecAndShowBalloon;
    procedure GetTextFromClipBoardAndShowBalloon;

    procedure SetpjhValue(AValue: string); override;
  public
    constructor Create(AOwner: TComponent);  override;
    destructor  Destroy;                     override;
  published
    property PanelCaption: string read FPanelCaption write FPanelCaption;
    //pjhValue�� Json���� ����Ǵ� Items -->  Design Form���� F8�� ������ Json ������
    property BalloonHeader: string read FBalloonHeader write FBalloonHeader;
    property BalloonText: TStrings read FBalloonText write SetBalloonText;
    property BalloonIsShow: Boolean read FIsBalloonShow write FIsBalloonShow;
    property BalloonUseMousePos: Boolean read FBalloonUseMousePos write FBalloonUseMousePos;
    property BalloonFindComponent4Pos: Boolean read FBalloonFindComponent4Pos write FBalloonFindComponent4Pos;

    property BalloonKind: TBalloonKind read FBalloonKind write FBalloonKind;
    property BalloonShowOnlyMine: Boolean read FBalloonShowOnlyMine write FBalloonShowOnlyMine;
    //Balloon�� ǥ���� ������Ʈ �̸�
//    property FindCompName: string read FBalloonFindCompName write FBalloonFindCompName;
    property BalloonFindCompName: string read FBalloonFindCompName write FBalloonFindCompName;
    //pjhValue�� Json���� ����Ǵ� Items <--

    property BalloonActiveColor: TColor read FBalloonActiveColor write SetBalloonActiveColor default clLime;
    property BalloonInActiveColor: TColor read FBalloonInActiveColor write SetBalloonInActiveColor default clSilver;
    property BalloonFont: TFont read FBalloonFont write SetBalloonFont stored True;

    property BalloonX: integer read FBalloonX write FBalloonX;
    property BalloonY: integer read FBalloonY write FBalloonY;
    property BalloonAlign: TBaloonAlign read FBalloonAlign write FBalloonAlign;
    property BalloonDivisionChar: Char read FBalloonDivisionChar write FBalloonDivisionChar;
    property BalloonHideIfMouseMove: Boolean read FBalloonHideIfMouseMove write SetBalloonHideIfMouseMove;
    property BalloonShape: TPShape read FBalloonShape write FBalloonShape;
    property BalloonTextAlign: TTextAlign read FBalloonTextAlign write FBalloonTextAlign;
//    property BalloonRecord: TBalloonRecord read FBalloonRecord write SetBalloonRecord;
  end;

  TpjhTransparentPanel = class(TpjhTPanelWithBalloon)
  protected
    procedure Paint; override;
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure WMMove(var Message: TWMMove); Message WM_Move;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Invalidate;override;
  end;

implementation

type   //�Ʒ� ����ü ������ pjhPropInspConst unit�� �����ؾ� ��
  PCopyDataStruct = ^TCopyDataStruct;
  TCopyDataStruct = record
    dwData: LongInt;
    cbData: LongInt;
    lpData: Pointer;
  end;

  PRecToPass = ^TRecToPass;
  TRecToPass = record
    CompName : array[0..255] of char;//astring[255];
    PropName : array[0..255] of char;//string[255];
    Value: array[0..255] of char;//string[255];
    ValueType: integer;
  end;

function GetComponentUnderMouseCursor(AAllowDisabled: Boolean=True; AAllowWinControl: Boolean=True): TControl;
var
  LWindow: TWinControl;
  LControl: TControl;
  LPoint: TPoint;
begin
  Result := nil;
  LPoint := Mouse.CursorPos;
  Result := FindDragTarget(LPoint, True);

  if Result = nil then
    Result := FindVCLWindow(LPoint);

//  if Result <> nil then
//  begin
//    LControl := LWindow.ControlAtPos(LWindow.ScreenToClient(LPoint), AAllowDisabled, AAllowWinControl);
//
//    if LControl <> nil then
//      Result := LControl;
//  end;
end;

{ TpjhadvSmoothGauge }

procedure TpjhTPanelWithBalloon.AppEventsShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if not FBalloonShowOnlyMine then
  begin
    BalloonHide();
    exit;
  end;

  if (Msg.CharCode = VK_F8) then
//  if ((Msg.CharCode = Ord('C')) or (Msg.CharCode = Ord('c')))
//    and ((HiWord(Msg.KeyData) and KF_ALTDOWN) <> 0) then //ALT + 'C'
  begin
    Handled := True;

    GetCurrentMousePos();
    GetComponentNameFromMousePos();
    //Watch2�� FSimulatePropertyValueMode �ÿ� "F8"�� ���� ��� FBalloonX, FBalloonLastY�� Watch2�� Jason���� �����ϱ� ����
    //Property Inspector�� PropInspModified()�� Ʈ���� �ȵǱ� ���� ��
    if FBalloonFindComponent4Pos then
      SendData2MainformAsJson(Self.Name, 'BalloonFindCompName', BalloonFindCompName);

    SendData2MainformAsJson(Self.Name, 'BalloonX', IntToStr(BalloonX));
    SendData2MainformAsJson(Self.Name, 'BalloonY', IntToStr(BalloonY));

    GetTextFromBalloonRecAndShowBalloon;
  end
  else
  if (Msg.CharCode = VK_F7) then //BalloonX,BalloonY ��ǥ�� ����Ͽ� ��Ʈ�� ǥ����
  begin
    Handled := True;
    GetTextFromBalloonRecAndShowBalloon;
  end
  else
  if (Msg.CharCode = VK_F9) then //���� ���콺 ��ǥ�� ����Ͽ� Ŭ�����忡�� ������ ������ ��Ʈ�� ǥ����
  begin
    Handled := True;
    GetTextFromClipBoardAndShowBalloon;
  end
  else
  if (Msg.CharCode = VK_F5) then
    BalloonHide;
end;

procedure TpjhTPanelWithBalloon.BalloonHide;
begin
//  case FBalloonKind of
//    bkBalloonBasic: begin
      if FBalloon <> nil then
       FBalloon.Deactivate;
//    end;
//    bkJvBallonHint:begin
      if FBalloonjvHint <> nil then
       FBalloonjvHint.CancelHint;
//    end;
//  end;
end;

procedure TpjhTPanelWithBalloon.BalloonShow(AText: String; AX, AY: integer);
var
  Point: TPoint;
  LUseCurMousePos: Boolean;
begin
  if FBalloonShowOnlyMine then
    FBalloonShowOnlyMine := False
  else
  begin
    BalloonHide;
    exit;
  end;

  if AText <> '' then
   begin
     LUseCurMousePos := False;
//    if FBalloon <> nil then
//      BalloonHide;
//
//    if FBalloonjvHint <> nil then
      BalloonHide;

    if FBalloonFindComponent4Pos then
    begin
      GetComponentPosition(Point);
    end
    else
    begin
      if AX < 0 then
      begin
        GetCursorPos(Point);
        LUseCurMousePos := True;
      end
      else
      begin
        Point.x := AX;
        Point.y := AY;
      end;

      FBalloonLastX := Point.x;
      FBalloonLastY := Point.y;
    end;

    if not LUseCurMousePos then
      Point := TControl(Self.Owner).ClientToScreen(Point);
//    Point := ScreenToClient(Point);

    case FBalloonKind of
      bkBalloonBasic: begin
        if FBalloon = nil then
          FBalloon := TBaloonWindow.Create(Self);

        FBalloon.Underground.Canvas.Font.Assign(FBalloonFont);
        FBalloon.Color := BalloonActiveColor;
        FBalloon.HideIfMouseMove := FBalloonHideIfMouseMove;

        FBalloon.Align := FBalloonAlign;
        FBalloon.Activate(Point, AText, FBalloonShape, FBalloonTextAlign, FBalloonDivisionChar);
      end;
      bkJvBallonHint:begin
        if FBalloonjvHint = nil then
          FBalloonjvHint := TJvBalloonHint.Create(Self);
        FBalloonjvHint.ActivateHintPos(nil,Point,FBalloonHeader,AText,300000);//+'('+IntToStr(Point.X) + ' : ' + IntToStr(Point.Y)+')'
      end;
    end;
  end;
end;

constructor TpjhTPanelWithBalloon.Create(AOwner: TComponent);
begin
  inherited;

  FBalloonText := TStringList.Create;

  FAppEvent := TApplicationEvents.Create(self);
  FAppEvent.OnShortCut := AppEventsShortCut;

  FBalloonObjList := TObjectList<TBaloonWindow>.Create();

  FBalloon := nil;
  FBalloonjvHint := nil;
  FBalloonFont := TFont.Create;
  FBalloonFont.Name := 'MS Sans Serif';
  FBalloonFont.Size := 10;

  FBalloonActiveColor := clLime;
  FBalloonInActiveColor := clSilver;
  FBalloonHideIfMouseMove := False;
  FBalloonFindComponent4Pos := True;

  FBalloonX := -1;
  FBalloonY := -1;

  Visible := False;
end;

destructor TpjhTPanelWithBalloon.Destroy;
begin
  FBalloonText.Free;
  FAppEvent.Free;
  FBalloonObjList.Free;

  if FBalloon <> nil then BalloonHide();

  if Assigned(FBalloon) then
    FBalloon.Free;

  if Assigned(FBalloonjvHint) then
    FBalloonjvHint.Free;

  FBalloonFont.Free;

  inherited;
end;

constructor TpjhTPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhDelphiStandardBplFileName;
end;

destructor TpjhTPanel.Destroy;
begin
  FpjhTagInfo.Free;

  inherited;
end;

function TpjhTPanelWithBalloon.GetBalloonRecordFromPropertyToJson: string;
begin
  FBalloonRecord.Command := '';
  FBalloonRecord.CompName := BalloonFindCompName;
  FBalloonRecord.Header := FBalloonHeader;
  FBalloonRecord.Text := FBalloonText.Text;
  FBalloonRecord.IsShow := FIsBalloonShow;
  FBalloonRecord.Kind := BalloonKind;
  FBalloonRecord.BalloonShowOnlyMine := BalloonShowOnlyMine;

//  GetCurrentMousePos();
//
  FBalloonRecord.X := BalloonX;
  FBalloonRecord.Y := BalloonY;

  Result := GetBalloonRecordToJson(FBalloonRecord);
end;

function TpjhTPanelWithBalloon.GetComponentNameFromMousePos: string;
var
  LControl: TControl;
begin
  Result := '';
  LControl := GetComponentUnderMouseCursor();

  if Assigned(LControl) then
  begin
    Result := LControl.Name;
    BalloonFindCompName := LControl.Name;
  end;
end;

function TpjhTPanelWithBalloon.GetComponentPosition(var APoint: TPoint): Boolean;
var
  LComponent: TControl;
//  LPoint: TPoint;
begin
  Result := False;
  LComponent := nil;

  if BalloonFindCompName <> '' then
  begin
//    LForm := GetParentForm(Self);
    LComponent := TControl(Self.Owner.FindComponent(BalloonFindCompName));

    if Assigned(LComponent) then
    begin
      FBalloonX := LComponent.Left + (LComponent.Width div 2);
      FBalloonY := LComponent.Top;
      APoint.X := FBalloonX;
      APoint.Y := FBalloonY;

      Result := True;
    end;
  end;
end;

//function TpjhTPanelWithBalloon.GetComponentUnderMouseCursor: TControl;
//begin
////  Result := FindVCLWindow(Mouse.CursorPos);
//
//  Result := FindDragTarget(Mouse.CursorPos, True);
//end;

procedure TpjhTPanelWithBalloon.GetCurrentMousePos;
var
  pt: TPoint;
begin
  GetCursorPos(pt);

  FBalloonX := pt.x;
  FBalloonY := pt.y;
end;

procedure TpjhTPanelWithBalloon.GetTextFromBalloonRecAndShowBalloon;
begin
  FpjhValue := GetBalloonRecordFromPropertyToJson();
  Clipboard.AsText := FpjhValue;
  BalloonShow(FBalloonText.Text, FBalloonX, FBalloonY);
end;

procedure TpjhTPanelWithBalloon.GetTextFromClipBoardAndShowBalloon;
var
  LText: string;
  LOriginFBalloonFindComponent4Pos: Boolean;
begin
  FBalloonShowOnlyMine := True;
  LOriginFBalloonFindComponent4Pos := FBalloonFindComponent4Pos;
  FBalloonFindComponent4Pos := False;

  LText := Clipboard.AsText;
  BalloonShow(LText, -1, -1);

  FBalloonFindComponent4Pos := LOriginFBalloonFindComponent4Pos;
end;

function TpjhTPanel.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhTPanel.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

procedure TpjhTPanelWithBalloon.SendData2MainformAsJson(const ACompName, APropName, AValue: string);
//pjhObjectInspectorBpl.SendCopyData2DesignForm()�� ������
//SimulatorSever���� ���޵� Command�� Watch2���� ShowBalloon�ϱ� ���ؼ���
//BalloonText�� ObjectInspector�� �Է��� �Ŀ� �ݵ�� F8Ű�� ������ BalloonX, BalloonY ����
//������ �Ŀ� �� �Լ��� �̿��Ͽ� CommandJson���� ������ ��� ��.
var
  cd : TCopyDataStruct;
  rec : TRecToPass;
  LForm: TForm;
begin
  with rec, cd do
  begin
    StrPCopy(CompName, ACompName);
    StrPCopy(PropName, APropName);
    StrPCopy(Value, AValue);
    ValueType := 0;//tkInteger;

    dwData := 3232;
    cbData := sizeof(rec);
    lpData := @rec;

    SendMessage(GetParentForm(Self).Handle, WM_COPYDATA, 4, LongInt(@cd));
  end;//with

//  SendCopyData2DesignForm(FDesignForm.Handle,FSelectedControlName,
//    PropInsp.ActiveItem.Caption, LStr, Ord(TELPropEditor(Sender).PropTypeInfo.Kind),4);
end;

procedure TpjhTPanelWithBalloon.SetBalloonActiveColor(const Value: TColor);
begin
  if FBalloonActiveColor <> Value then
    FBalloonActiveColor := Value;
end;

procedure TpjhTPanelWithBalloon.SetBalloonFont(Value: TFont);
begin
  FBalloonFont.Assign(Value);
end;

procedure TpjhTPanelWithBalloon.SetBalloonHideIfMouseMove(const Value: Boolean);
begin
  FBalloonHideIfMouseMove := Value;

  if Assigned(FBalloon) then
    FBalloon.HideIfMouseMove := Value;
end;

procedure TpjhTPanelWithBalloon.SetBalloonInactiveColor(const Value: TColor);
begin
  if FBalloonInActiveColor <> Value then
    FBalloonInActiveColor := Value;
end;

procedure TpjhTPanelWithBalloon.SetBalloonRecord(const Value: TBalloonRecord);
begin
  FBalloonRecord.Command := Value.Command;
  FBalloonRecord.CompName := Value.CompName;
  FBalloonRecord.Text := Value.Text;
  FBalloonRecord.IsShow := Value.IsShow;
  FBalloonRecord.Kind := Value.Kind;
  FBalloonRecord.X := Value.X;
  FBalloonRecord.Y := Value.Y;
end;

procedure TpjhTPanelWithBalloon.SetBalloonText(const Value: TStrings);
begin
  if FBalloonText.Text <> Value.Text then
    FBalloonText.Text := Value.Text;
end;

procedure TpjhTPanelWithBalloon.SetpjhValue(AValue: string);
var
  LPoint: TPoint;
begin
  if FpjhValue <> AValue then
  begin
    if PanelCaption <> '' then
      Caption := PanelCaption;

    FpjhValue := AValue;

    GetBalloonRecordFromJson(FBalloonRecord, AValue);

    if FBalloonRecord.IsShow then
    begin
      if not BalloonUseMousePos then //F8Ű�� ����Ͽ� Balloon Show�Ҷ� �����
        GetComponentPosition(LPoint);

      BalloonShow(FBalloonText.Text, FBalloonX, FBalloonY);
    end
    else
      BalloonHide;
  end;
end;

procedure TpjhTPanel.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

function TpjhTPanel.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

procedure TpjhTPanel.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhTPanel.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;
    Caption := AValue;
  end;
end;

{ TpjhTransparentPanel }

procedure TpjhTransparentPanel.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited;

  Invalidate;
end;

constructor TpjhTransparentPanel.Create(AOwner: TComponent);
begin
  inherited;

  ControlStyle := ControlStyle - [csSetCaption];
  ControlStyle := ControlStyle - [csOpaque];
end;

procedure TpjhTransparentPanel.CreateParams(var Params: TCreateParams);
begin
  inherited;

  with Params do
  begin
    ExStyle := ExStyle or WS_EX_TRANSPARENT;
  end;
end;

destructor TpjhTransparentPanel.Destroy;
begin

  inherited;
end;

procedure TpjhTransparentPanel.Invalidate;
var
  Rect: TRect;
  iLoop: Integer;
begin
  if (Parent<>nil) and(Parent.HandleAllocated) then
  begin
    Rect := BoundsRect;
    InvalidateRect(Parent.Handle,@Rect,False);

    for iLoop := 0 to ControlCount- 1 do
       Controls[iLoop].Invalidate;
  end;
end;

procedure TpjhTransparentPanel.Paint;
var
  ARect: TRect;
  TopColor, BottomColor: TColor;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;
begin
  ARect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, ARect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, ARect, Color, Color, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, ARect, TopColor, BottomColor, BevelWidth);
  end;

  Update;
end;

procedure TpjhTransparentPanel.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

procedure TpjhTransparentPanel.WMMove(var Message: TWMMove);
begin
  inherited;

  Invalidate;
end;

end.