unit CommLogic2;

interface

uses
  ExtCtrls, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, math, GR32, GR32_Polygons, TimerPool;//, ScrollPanel

// Windows message used to initiate state transitions
const
  CL_STATE_TRANSITION = WM_USER;

type
  TLine_pjh = record
    p1,p2:TPoint; {starting and ending points of a line segment}
  end;

  TCustomLogicPanel = class;
  TCustomLogicControl = class;
  TCustomLogicConnector = class;

  // Type of the OnChangeState event
  TChangeStateEvent = procedure(Sender: TCustomLogicPanel;
    FromState, ToState: TCustomLogicControl) of object;

  // Type of the OnException event
  TStateExceptionEvent = procedure(Sender: TCustomLogicPanel; Node: TCustomLogicControl;
    Error: Exception) of object;

  // Run-time options:
  //
  //   soInteractive
  //			If set, the TCustomLogicPanel will be visible at run-time.
  //			The current state will be painted in red and bold.
  //
  //   soSingleStep
  //			If set, the execution will stop after each transition.
  //			Use the Execute method to resume execution.
  //
  //   soVerifyTransitions
  //			If set, transitions (TCustomLogicTransition) will verify their
  //			source states when executed.
  //			An attempt to move through a transition from a state
  //			other than the one specified as the "FromState" will
  //			cause an exception to be raised.
  //			If the transition does not specify a "FromState", the
  //			transition will not be validated.
  //
  TCustomLogicPanelOption = (soInteractive, soSingleStep, soVerifyTransitions);
  TCustomLogicPanelOptions = set of TCustomLogicPanelOption;

  TDesignMove = (dmSource, dmFirstHandle, dmSecondHandle, dmThirdHandle, dmLastHandle, dmDestination, dmNone);//, dmOffset
  TConnectorLines = array[dmSource..dmDestination] of TPoint;
  TStatePath = (spAuto, spDirect, spLL, spLR, spLT, spLB, spRL, spRR, spRT, spRB, spTL, spTR, spTT, spTB, spBL, spBR, spBT, spBB);

  TCustomLogicPanel = class(TForm)
  //TCustomLogicPanel = class(TCustomAdvancedScroller_pjh)
  private
    FState: TCustomLogicControl;
    FInitialState: TCustomLogicControl;//Reset�� True�϶� ���۵Ǵ� State�� ����Ŵ
    FOnChangeState: TChangeStateEvent;
    FOnException: TStateExceptionEvent;
    FActive: boolean;
    StateChanged: boolean;
    FConnector: TCustomLogicConnector;
    FDesignMoving: TDesignMove;
    Lines: TConnectorLines;
    FStopSignalled: Boolean;
    FOptions: TCustomLogicPanelOptions;
    FStartExec: Boolean;//True�̸� �����
    FReset: Boolean;//True�̸� Execute�ÿ� ó��(TCustomLogicPanel�� State
    FNewPath			: TStatePath;//���콺�� Path ���� ����
  protected
    function pointinpoly(x,y:integer):boolean; {to recognize mouse clicks}
    procedure SetState(Value :TCustomLogicControl);
    procedure SetTimerPool(Value :TpjhTimerPool);
    procedure SetInitialState(Value :TCustomLogicControl);
    procedure SetStartExec(Value :Boolean);
    procedure SetReset(Value :Boolean);
    procedure DoSetState(Value :TCustomLogicControl);
    function NewState(NewHandle: TPoint): TStatePath;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoOnChangeState(FromState, ToState: TCustomLogicControl); dynamic;
    procedure DoOnException(Node: TCustomLogicControl; E: Exception); dynamic;
    procedure SMStateTransition(var Message: TMessage); message CL_STATE_TRANSITION;
    procedure CMDesignHitTest(var Msg: TWMMouse); message cm_DesignHitTest;
    property Active: boolean read FActive write FActive default False;
    property StartExec: boolean read FStartExec write SetStartExec default False;
    property StopSignalled: Boolean read FStopSignalled;
    property OnChangeState: TChangeStateEvent read FOnChangeState write FOnChangeState;
    property OnException: TStateExceptionEvent read FOnException write FOnException;
  public
    FTimerPool: TpjhTimerPool;

    procedure Execute; virtual;
    procedure Stop;
    procedure ChangeState(Transition: TCustomLogicControl);
    procedure PostStateChange(State: TCustomLogicControl);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Options: TCustomLogicPanelOptions read FOptions write FOptions;
    property State: TCustomLogicControl read FState write SetState;
    //property TimerPool: TpjhTimerPool read FTimerPool write FTimerPool;
  published
    property StartPoint: TCustomLogicControl read FInitialState write SetInitialState;
    property Reset: boolean read FReset write SetReset default False;
    property NewPath: TStatePath read FNewPath write FNewPath;
    property Align;
    property Color;
    property Font;

  end;

  TTransitionDirection = (tdFrom, tdTo);
  TVisualElement = (veShadow, veFrame, vePanel, veText, veConnector);
  TStatePathOwner = (poOwnedBySource, poOwnedByDestination);
  TDiagramType = (dtDefault, dtStart, dtStop, dtProcess, dtIf, dtData, dtInput, dtOutput, dtDelay);
  TIACheckControlTextHAlign = (iaccthaLeft,iaccthaRight,iaccthaCenter);
  TIACheckControlTextVAlign = (iacctvaTop,iacctvaBottom,iacctvaCenter);
  TIACheckControlText3DStyle =(iscct3dsSimple,iscct3dsUp,iscct3dsDown);
  TColorScheme = (csNeoDesert, csNeoSky, csNeoGrass, csNeoSilver,
       csNeoRose, csNeoSun,
       csDesert, csGrass, csSky, csSun, csRose, csSilver, csCustom);
  TMouseState = (bsNormal, bsOver, bsDown);

  TCustomLogicControl = class(TGraphicControl)
  private
    { Private declarations }
    FColorFace: TColor;
    FColorGrad: TColor;
    FColorBorder: TColor;
    FColorLight: TColor;
    FColorDark: TColor;
    FColorText: TColor;

    FGradient: Boolean;
    FMouseState: TMouseState;
    FClicked: Boolean;
    FHotTrack: Boolean;

    FStateMachine: TCustomLogicPanel;
    FConnectors: TList;
    FDiagramType: TDiagramType;
    FRoundSize: integer;
    FText: TStringList;
    FTextFieldHorizontalAlign: TIACheckControlTextHAlign;
    FTextFieldVerticalAlign: TIACheckControlTextVAlign;
    FText3DStyle: TIACheckControlText3DStyle;
    FTextAlign: TIACheckControlTextHAlign;
    FDownColorText: TColor;
    FDownColorGrad: TColor;
    FDisabledColorLight: TColor;
    FDownColorBorder: TColor;
    FDisabledColorDark: TColor;
    FDisabledColorGrad: TColor;
    FOverColorDark: TColor;
    FDisabledColorText: TColor;
    FDisabledColorBorder: TColor;
    FOverColorFace: TColor;
    FDownColorFace: TColor;
    FOverColorText: TColor;
    FOverColorBorder: TColor;
    FOverColorLight: TColor;
    FColorFocusRect: TColor;
    FDownColorLight: TColor;
    FDisabledColorFace: TColor;
    FDownColorDark: TColor;
    FOverColorGrad: TColor;
    FColorScheme: TColorScheme;

    procedure ReadConnectors(Reader: TReader);
    procedure WriteConnectors(Writer: TWriter);

  protected
    { Protected declarations }
    FFaceColor: TColor;
    FGradColor: TColor;
    FBorderColor: TColor;
    FLightColor: TColor;
    FDarkColor: TColor;
    FTextColor: TColor;

    FBreakPoint: Boolean;

    //procedure CMTextChanged (var msg: TMessage); message CM_TEXTCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure DefineProperties(Filer: TFiler); override;
    procedure SetHint(Value: string);
    function GetHint: string;
    procedure SetText(Value: TStringList);
    procedure SetActive(Value: boolean); virtual;
    function GetActive: boolean; virtual;
    procedure SetParent(AParent: TWinControl); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetDiagramType(Value: TDiagramType);
    procedure SetRoundSize(Value: integer);
    procedure SetTextFieldHorizontalAlign(Value: TIACheckControlTextHAlign);
    procedure SetTextFieldVerticalAlign(Value: TIACheckControlTextVAlign);
    procedure SetText3DStyle(Value: TIACheckControlText3DStyle);
    procedure SetTextAlign(Value: TIACheckControlTextHAlign);
    procedure SetColors(Index: integer; Value: TColor);
    procedure SetColorScheme(Value: TColorScheme);
    procedure SetGradient(Value: Boolean);
    procedure SetMouseState(Value: TMouseState);

    procedure Click; override;
    function GetCheckStateMachine: TCustomLogicPanel;
    property CheckStateMachine: TCustomLogicPanel read GetCheckStateMachine;
    procedure Paint; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure DoOnEnter; virtual;
    procedure DoOnExit; virtual;
    procedure DoOnReset; virtual;
    function DoDefault: Boolean; virtual;
    procedure PrepareCanvas(Element: TVisualElement; Canvas: TCanvas); virtual;
    procedure DrawText(TextRect: TRect; ACanvas: TCanvas); virtual;
    procedure DoPaint; virtual;
    function AddConnector(OwnerRole: TStatePathOwner): TCustomLogicConnector;

    Procedure DoOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    Procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    Procedure DoOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GradientFillRect(Canvas: TCanvas; Rect: TRect;
                   StartColor, EndColor: TColor);

    //DrawText���� �Լ���
    function  GetTextSize : TSize;
    function  GetFullSize : TSize;
    function  GetBasis : TSize;
    function  GetOffset : TSize;
    function  GetCurrOffset(i : Integer) : TSize;

    property TextFieldVerticalAlign : TIACheckControlTextVAlign read FTextFieldVerticalAlign write SetTextFieldVerticalAlign;
    property TextFieldHorizontalAlign : TIACheckControlTextHAlign read FTextFieldHorizontalAlign write SetTextFieldHorizontalAlign;
    property Text3DStyle : TIACheckControlText3DStyle read FText3DStyle write SetText3DStyle default iscct3dsSimple;
    property TextAlign : TIACheckControlTextHAlign read FTextAlign write SetTextAlign;

    property ColorFace: TColor index 0 read FColorFace write SetColors;
    property ColorGrad: TColor index 1 read FColorGrad write SetColors;
    property ColorDark: TColor index 2 read FColorDark write SetColors;
    property ColorLight: TColor index 3 read FColorLight write SetColors;
    property ColorBorder: TColor index 4 read FColorBorder write SetColors;
    property ColorText: TColor index 5 read FColorText write SetColors;
    property OverColorFace: TColor index 6 read FOverColorFace write SetColors;
    property OverColorGrad: TColor index 7 read FOverColorGrad write SetColors;
    property OverColorDark: TColor index 8 read FOverColorDark write SetColors;
    property OverColorLight: TColor index 9 read FOverColorLight write SetColors;
    property OverColorBorder: TColor index 10 read FOverColorBorder write SetColors;
    property OverColorText: TColor index 11 read FOverColorText write SetColors;
    property DownColorFace: TColor index 12 read FDownColorFace write SetColors;
    property DownColorGrad: TColor index 13 read FDownColorGrad write SetColors;
    property DownColorDark: TColor index 14 read FDownColorDark write SetColors;
    property DownColorLight: TColor index 15 read FDownColorLight write SetColors;
    property DownColorBorder: TColor index 16 read FDownColorBorder write SetColors;
    property DownColorText: TColor index 17 read FDownColorText write SetColors;
    property DisabledColorFace: TColor index 18 read FDisabledColorFace write SetColors;
    property DisabledColorGrad: TColor index 19 read FDisabledColorGrad write SetColors;
    property DisabledColorDark: TColor index 20 read FDisabledColorDark write SetColors;
    property DisabledColorLight: TColor index 21 read FDisabledColorLight write SetColors;
    property DisabledColorBorder: TColor index 22 read FDisabledColorBorder write SetColors;
    property DisabledColorText: TColor index 23 read FDisabledColorText write SetColors;
    property ColorFocusRect: TColor index 24 read FColorFocusRect write SetColors;
    property ColorScheme: TColorScheme read FColorScheme write SetColorScheme;
    property Gradient: Boolean read FGradient write SetGradient;
    property HotTrack: Boolean read FHotTrack write FHotTrack;
    property MouseState: TMouseState read FMouseState write SetMouseState;
  public
    FLabelBmp: TBitmap;
    FDC      : hDC;
    FShowLabelBmp: Boolean;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property StateMachine: TCustomLogicPanel read FStateMachine;
    procedure PaintConnector; virtual;
    function HitTest(Mouse: TPoint): TCustomLogicConnector; virtual;
    procedure CheckTransition(Transition: TCustomLogicControl; Direction: TTransitionDirection); virtual;
    property Active: boolean read GetActive write SetActive default False;
    property Connectors: TList read FConnectors;
    property DiagramType: TDiagramType read FDiagramType write SetDiagramType;
    property RoundSize: integer read FRoundSize write SetRoundSize;
  published
    property Hint: string read GetHint write SetHint;
    property Text: TStringList read FText write SetText;
    property BreakPoint: Boolean read FBreakPoint write FBreakPoint;
    //property Caption;
  end;

  TCustomLogicNodeBase = class(TCustomLogicControl)
  protected
    procedure SetParent(AParent: TWinControl); override;
  end;

  TCustomLogicConnector = class(TGraphicControl)
  private
    FSelected: Boolean;
    FOffset: integer;
    FPath: TStatePath;
    FActualPath: TStatePath;
    FOwner: TStatePathOwner;
    FSource: TCustomLogicControl;
    FDestination: TCustomLogicControl;
    BoundsRect: TRect;
  protected
    procedure SetPeer(Index: integer; Value: TCustomLogicControl);
    function GetPeer(Index: integer): TCustomLogicControl;
    function LineIntersect(L1,L2:TLine_pjh; var PointOnBorder:boolean):boolean;
    function CohrenSutherlandLine(var p1,p2: TPoint; Diagonal1, Diagonal2:TPoint): Boolean;
    function CheckConnectorCollision(Lines: TConnectorLines;r1,r2: TRect): Boolean;
    function PolyLineDistance(Lines: TConnectorLines;var LineCount: integer;
                                            var PointOnLine: Boolean): integer;
  public
    constructor Create(AOwner: TComponent);override;
    //constructor Create(AOwner: TCustomLogicControl; OwnerRole: TStatePathOwner);override;
    //destructor Destroy; override;
    procedure CreateInit(AOwner:TCustomLogicControl; AOwnerRole: TStatePathOwner);
    procedure Paint;
    procedure PaintFlipLine(Lines: TConnectorLines);
    function HitTest(Mouse: TPoint): Boolean;
    function GetLines(var Lines: TConnectorLines): Boolean;
    class function MakeRect(pa, pb: TPoint): TRect;
    class function RectCenter(r: TRect): TPoint;
    property Source: TCustomLogicControl index 1 read FSource write SetPeer;
    property Destination: TCustomLogicControl index 2 read FDestination write SetPeer;
    property PeerNode: TCustomLogicControl index 0 read GetPeer write SetPeer;
    property ActualPath: TStatePath read FActualPath;
    property Selected: Boolean read FSelected write FSelected;
  published
    property Path: TStatePath read FPath write FPath;
    property Offset: integer read FOffset write FOffset;
  end;

  TCustomLogicBoolean = class;
  TBooleanStateEvent = procedure(Sender: TCustomLogicBoolean; var Result: Boolean) of Object;

  TCustomLogicBoolean = class(TCustomLogicNodeBase)
  private
    { Private declarations }
    FOnEnterState: TBooleanStateEvent;
    FOnExitState: TNotifyEvent;
    FTrueState: TCustomLogicControl;
    FFalseState: TCustomLogicControl;
    FTrueConnector: TCustomLogicConnector;
    FFalseConnector: TCustomLogicConnector;
    FResult: Boolean;
    FDefault: Boolean;
    FBeforeDelay,
    FAfterDelay: Longint;
    FOwner: TForm;

  protected
    { Protected declarations }
    procedure DoPaint; override;
    procedure PrepareCanvas(Element: TVisualElement; Canvas: TCanvas); override;
    procedure SetTrueState(Value :TCustomLogicControl);
    procedure SetFalseState(Value :TCustomLogicControl);
    procedure SetDefault(Value :Boolean);
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure DoOnEnter; override;
    procedure DoOnExit; override;
    function DoDefault: Boolean; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintConnector; override;
    function HitTest(Mouse: TPoint): TCustomLogicConnector; override;

    //procedure AALine(x1,y1,x2,y2 : single; color : tcolor);
    //procedure PolyLine(Arr:array of TPoint);

    property OnEnterState: TBooleanStateEvent read FOnEnterState write FOnEnterState;
    property OnExitState: TNotifyEvent read FOnExitState write FOnExitState;
    property DefaultState: Boolean read FDefault write SetDefault default True;
  published
    { Published declarations }
    property TrueStep: TCustomLogicControl read FTrueState write SetTrueState;
    property FalseStep: TCustomLogicControl read FFalseState write SetFalseState;
    property BeforeDelay: LongInt read FBeforeDelay write FBeforeDelay default 0;
    property AfterDelay: LongInt read FAfterDelay write FAfterDelay default 0;
  end;

  TCustomLogicNode = class(TCustomLogicNodeBase)
  private
    { Private declarations }
    FOnEnterState: TNotifyEvent;
    FOnExitState: TNotifyEvent;
    FDefaultTransition: TCustomLogicControl;
    FToConnector: TCustomLogicConnector;
    FBeforeDelay,
    FAfterDelay: Longint;
  protected
    { Protected declarations }
    procedure PrepareCanvas(Element: TVisualElement; Canvas: TCanvas); override;
    procedure SetDefaultTransition(Value: TCustomLogicControl);
    procedure SetNextState(Value :TCustomLogicControl);
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure DoOnEnter; override;
    procedure DoOnExit; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function DoDefault: Boolean; override;
  public
    { Public declarations }
    FIsInitialize: Bool; //Logic�� Reset �Ǿ��� �� Node�� �ʱ�ȭ �ϱ� ����  

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintConnector; override;
    function HitTest(Mouse: TPoint): TCustomLogicConnector; override;
    // NextState is obsolete!
    property NextState: TCustomLogicControl read FDefaultTransition write SetNextState stored False;
  published
    { Published declarations }
    property OnEnterState: TNotifyEvent read FOnEnterState write FOnEnterState;
    property OnExitState: TNotifyEvent read FOnExitState write FOnExitState;
    property NextStep: TCustomLogicControl read FDefaultTransition write SetDefaultTransition;
    property BeforeDelay: LongInt read FBeforeDelay write FBeforeDelay default 0;
    property AfterDelay: LongInt read FAfterDelay write FAfterDelay default 0;
  end;

  TCustomLogicStart = class(TCustomLogicNode)
  protected
    { Protected declarations }
    procedure PrepareCanvas(Element: TVisualElement; Canvas: TCanvas); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TCustomLogicStop = class(TCustomLogicControl)
  protected
    { Protected declarations }
    procedure PrepareCanvas(Element: TVisualElement; Canvas: TCanvas); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TCustomLogicTransition = class(TCustomLogicControl)
  private
    { Private declarations }
    FFromState: TCustomLogicControl;
    FToState: TCustomLogicControl;
    FOnTransition: TNotifyEvent;
    FToConnector: TCustomLogicConnector;
    FFromConnector: TCustomLogicConnector;
  protected
    { Protected declarations }
    procedure DoPaint; override;
    procedure PrepareCanvas(Element: TVisualElement; Canvas: TCanvas); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetFromState(Value :TCustomLogicControl);
    procedure SetToState(Value :TCustomLogicControl);
    procedure DoOnEnter; override;
    function DoDefault: Boolean; override;
    procedure CheckTransition(Transition: TCustomLogicControl; Direction: TTransitionDirection); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintConnector; override;
    function HitTest(Mouse: TPoint): TCustomLogicConnector; override;
  published
    { Published declarations }
    property FromStep: TCustomLogicControl read FFromState write SetFromState;
    property ToStep: TCustomLogicControl read FToState write SetToState;
    property OnTransition: TNotifyEvent read FOnTransition write FOnTransition;
  end;

  TLinkDirection = (ldIncoming, ldOutgoing);

  TCustomLogicLinkBase = class(TCustomLogicControl)
  end;

  TCustomLogicLink = class(TCustomLogicLinkBase)
  private
    { Private declarations }
    FDestination: TCustomLogicControl;
    FConnector: TCustomLogicConnector;
    FDirection: TLinkDirection;
  protected
    { Protected declarations }
    procedure PrepareCanvas(Element: TVisualElement; Canvas: TCanvas); override;
    procedure DoPaint; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetDestination(Value :TCustomLogicControl);
    procedure SetDirection(Value :TLinkDirection);
    function DoDefault: Boolean; override;
    procedure CheckTransition(Transition: TCustomLogicControl; Direction: TTransitionDirection); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintConnector; override;
    function HitTest(Mouse: TPoint): TCustomLogicConnector; override;

    property NextStep: TCustomLogicControl read FDestination write SetDestination;
    property Direction: TLinkDirection read FDirection write SetDirection;
  published
    { Published declarations }
  end;

//procedure Register;

var
  Arrow	: array[0..2] of TPoint;

implementation

{$DEBUGINFO ON}

uses
{$IFDEF DEBUG}
  //debugit,
{$ENDIF}
  TypInfo;

{$IFNDEF DEBUG}
procedure DebugStr(s: string);
begin
end;
{$ENDIF}


const
  ShadowHeight = 2;
  OverlapXMargin = 0;
  OverlapYMargin = 0;
  SelectMarginX = 4;
  SelectMarginY = 4;
  DefaultMargin = 20;//add 2004.1.20 ������ġ ����� �ڵ����� �������� ��ġ

//******************************************************************************
//**
//**			Component Registration
//**
//******************************************************************************
(*
type
  TConnectorProperty = class(TClassProperty)
  protected
    Connector: TCustomLogicConnector;
  public
    procedure GetProperties(Proc: TGetPropEditProc); override;
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
  end;

function TConnectorProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paSubProperties, paValueList, paSortList];
end;

procedure TConnectorProperty.GetProperties(Proc: TGetPropEditProc);
var
  I: Integer;
  Components: TComponentList;
  StateControl: TCustomLogicControl;
begin
  Components := TComponentList.Create;
  try
    StateControl := TCustomLogicControl(GetOrdValue);
    // Find all properties of type
function GetPropList(TypeInfo: PTypeInfo; TypeKinds: TTypeKinds;
  PropList: PPropList): Integer;
    Components.Add(TComponent(GetOrdValueAt(I)));
    GetComponentProperties(Components, tkProperties, Designer, Proc);
  finally
    Components.Free;
  end;
end;

procedure TConnectorProperty.GetValues(Proc: TGetStrProc);
begin
  Designer.GetComponentNames(GetTypeData(TypeInfo(TCustomLogicControl)), Proc);
end;

function TConnectorProperty.GetValue: string;
begin
  if (TCustomLogicConnector(GetOrdValue).PeerNode <> nil) then
    FmtStr(Result, '(%s)', [TCustomLogicControl(GetOrdValue).Name])
  else
    Result := '';
end;

procedure TConnectorProperty.SetValue(const Value: string);
var
  Component: TComponent;
begin
  if Value = '' then Component := nil else
  begin
    Component := Designer.GetComponent(Value);
    if not (Component is TCustomLogicControl) then
      raise EPropertyError.Create(SInvalidPropertyValue);
  end;
  SetOrdValue(LongInt(Component));
end;
*)
//procedure Register;
//begin
//  RegisterComponents('Logic',
//    [TCustomLogicPanel, TCustomLogicNode, TCustomLogicTransition, TCustomLogicBoolean, TCustomLogicLink,
//     TCustomLogicStart, TCustomLogicStop]);
//  RegisterPropertyEditor(TypeInfo(TCustomLogicControl), TCustomLogicControl, '', TConnectorProperty);
//end;

function Min(a,b: integer): integer;
begin
  if (a <= b) then
    Result := a
  else
    Result := b;
end;

function Max(a,b: integer): integer;
begin
  if (a >= b) then
    Result := a
  else
  Result := b;
end;

function GetCColor(Color01,Color02: Tcolor;R,i :integer): Tcolor;
var
  C1,C2 : Tcolor;
  R1,G1,B1,R2,G2,B2 : Byte;
  Nr,Ng,Nb : Integer;
begin
  c1:=ColorTorgb(Color01);
  c2:=ColorTorgb(Color02);
  R1:=Pbyte(@C1)^;
  G1:=Pbyte(integer(@C1)+1)^;
  B1:=Pbyte(integer(@C1)+2)^;
  R2:=Pbyte(@C2)^;
  G2:=Pbyte(integer(@C2)+1)^;
  B2:=Pbyte(integer(@C2)+2)^;
  if R<>0 then
  begin
    Nr:=(R1+(R2-R1)*i div R);
    Ng:=(G1+(G2-G1)*i div R);
    Nb:=(B1+(B2-B1)*i div R);
    if Nr<0   then Nr:=0;
    if Nr>255 then Nr:=255;
    if Ng<0   then Ng:=0;
    if Ng>255 then Ng:=255;
    if Nb<0   then Nb:=0;
    if Nb>255 then Nb:=255;
    Result:=RGB(Nr,Ng,Nb);
  end else result:=Color01;
end;
//******************************************************************************
//**
//**			TCustomLogicPanel
//**
//******************************************************************************
constructor TCustomLogicPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle-[csSetCaption, csReplicatable]+[csDesignInteractive];
  FDesignMoving := dmNone;
  //BevelInner := bvLowered;
  //BorderStyle := bsSingle;
  FOptions := [soVerifyTransitions, soInteractive];//designer������ soInteractive �߰���
  Visible := (soInteractive in FOptions);
  FActive := False;

  //ReadDFM �ÿ� ���� �߻� - "Class TpjhTimerPool not found"
  //Create function ���� parameter �� Self �� �ƴ� nil�� �ִ� �ذ��
  FTimerPool := TpjhTimerPool.Create(nil);

end;

destructor TCustomLogicPanel.Destroy;
begin
  //Parent�� Form�� ��쿡�� �ڵ� ���� �ǹǷ� Free�� ���ص� ��
  FTimerPool.Free;
  
  inherited Destroy;
end;

procedure TCustomLogicPanel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent is TCustomLogicControl) and (TCustomLogicControl(AComponent).StateMachine = self) then
    case Operation of
      opRemove:
        begin
          Invalidate;
//        FConnector: TCustomLogicConnector;
        end;
    end;
end;

procedure TCustomLogicPanel.Execute;
var
  InitialState		: TCustomLogicControl;
  i: integer;
begin
  if (State = nil) then
    raise Exception.Create('No initial state specified');

  InitialState := FState;
  FState := nil;
  FActive := True;
  FStopSignalled := False;
  SetState(InitialState);
end;

procedure TCustomLogicPanel.Stop;
begin
  FStopSignalled := True;
//  Active := False;
  Application.ProcessMessages;
end;

{returns true if passed point is inside of piece }
function TCustomLogicPanel.pointinpoly(x, y: integer): boolean;
  function sameside(L:TLine_pjh; p1,p2:TPoint):int64;
  {same side =>result>0
   opposite sides => result <0
   a point on the line => result=0 }
  var
    dx,dy,dx1,dy1,dx2,dy2:int64;
  begin
    dx:=L.p2.x-L.P1.x;
    dy:=L.p2.y-L.P1.y;
    dx1:=p1.x-L.p1.x;
    dy1:=p1.y-L.p1.y;
    dx2:=p2.x-L.p2.x;
    dy2:=p2.y-L.p2.y;
    result:=(dx*dy1-dy*dx1)*(dx*dy2-dy*dx2);
  end;

  function  intersect(L1,L2:TLine_pjh):boolean;
  var
    a,b:int64;
  begin
    a:=sameside(L1,L2.p1,L2.p2);
    b:=sameside(L2,L1.p1,L1.p2);
    result:=(a<=0) and (b<=0);
  end;

var
  count,i,j:integer;
  lt,lp:TLine_pjh;
begin
  count:=0;
  j:=3;
  lt.p1:=point(x,y);
  lt.p2:=point(x,y);
  lt.p2.x:=2000;
  for i:= 1 to 3 do
  begin
    Lp.p1:=Arrow[i];
    Lp.p2:=Arrow[i];
    if not intersect(Lp,Lt) then
    begin
      Lp.p2:=Arrow[j];
      j:=i;
      if intersect(Lp,lT) then inc(count);
    end;
  end;
  result:=count mod 2 =1;
end;

function TCustomLogicPanel.NewState(NewHandle: TPoint): TStatePath;
var
  Diagonal, LeftRegion, RightRegion, TopRegion, BottomRegion: TRect;
  LI,LI2: integer;
  Lb, Lb2: Byte;
begin
  if FDesignMoving = dmDestination then
  begin
    case FConnector.ActualPath of
      spLL, spLR, spLT, spLB: Lb := 0;
      spRL, spRR, spRT, spRB: Lb := 1;
      spTL, spTR, spTT, spTB: Lb := 2;
      spBL, spBR, spBT, spBB: Lb := 3;
    end;//case

    Lb := Lb Shl 2;
    Diagonal := FConnector.Destination.BoundsRect;
  end//if
  else
  if FDesignMoving = dmSource then
  begin
    case FConnector.ActualPath of
      spLL, spRL, spTL, spBL: Lb2 := 0;
      spLR, spRR, spTR, spBR: Lb2 := 1;
      spLT, spRT, spTT, spBT: Lb2 := 2;
      spLB, spRB, spTB, spBB: Lb2 := 3;
    end;//case
    Diagonal := FConnector.Source.BoundsRect;
  end;//else if

  with Diagonal do
  begin
    LI := (Right - Left) DIV 4;
    LI2 := (Bottom - Top) DIV 2;
    LeftRegion := Rect(Left, Top, Left + LI, Bottom);
    RightRegion := Rect(Right - LI, Top, Right, Bottom);
    TopRegion := Rect(Left + LI, Top, Right - LI, Top + LI2);
    BottomRegion := Rect(Left + LI, Bottom - LI2, Right - LI, Bottom);
  end;//with

  if PtInRect(LeftRegion, NewHandle) then
  begin
    Lb2 := Lb2 + $0;
    Lb := Lb + 0;
  end
  else if PtInRect(RightRegion, NewHandle) then
  begin
    Lb2 := Lb2 + $4;
    Lb := Lb + 1;
  end
  else if PtInRect(TopRegion, NewHandle) then
  begin
    Lb2 := Lb2 + $8;
    Lb := Lb + 2;
  end
  else if PtInRect(BottomRegion, NewHandle) then
  begin
    Lb := Lb + 3;
    Lb2 := Lb2 + $C;
  end
  else
    Lb := $FF;

  if Lb = $FF then
    Result := FConnector.ActualPath
  else
  if FDesignMoving = dmDestination then
    Result := TStatePath(Lb+2)
  else
  if FDesignMoving = dmSource then
    Result := TStatePath(Lb2+2);
end;

procedure TCustomLogicPanel.SetState(Value :TCustomLogicControl);
begin
  if (Active) and ([csLoading, csDesigning] * ComponentState = []) then
    DoOnChangeState(State, Value);
  DoSetState(Value);
//  PostStateChange(Value);
end;

procedure TCustomLogicPanel.SetInitialState(Value: TCustomLogicControl);
begin
  if FInitialState <> Value then
  begin
    FInitialState := Value;
    State := Value;
  end;//if

end;

procedure TCustomLogicPanel.SetTimerPool(Value: TpjhTimerPool);
begin
  if FTimerPool <> Value then
    FTimerPool := Value;
end;

procedure TCustomLogicPanel.SetStartExec(Value: Boolean);
begin
  if FStartExec <> Value then
    FStartExec := Value;

  if FStartExec then
    Execute
  else
    Stop;
end;

procedure TCustomLogicPanel.SetReset(Value: Boolean);
var i: integer;
begin
  if FReset <> Value then
    FReset := Value;

  if (FReset) and Assigned(FInitialState) then
  begin
    State := FInitialState;
    FTimerPool.RemoveAll;
  	for i := 0 to ComponentCount - 1 do
      if Components[i].ClassName = 'TpjhSetTimer' then
        TCustomLogicNode(Components[i]).FIsInitialize := True;
    FReset := False;
  end;//if
end;

procedure TCustomLogicPanel.DoSetState(Value :TCustomLogicControl);
var
  OldState		: TCustomLogicControl;
begin
  if (Value <> nil) and (Value.FStateMachine <> self) then
    raise Exception.Create('Cannot change to state in other state machine');

  OldState := FState;
  FState := Value;

  // Repaint old and new state
  if (OldState <> nil) then
  begin
    OldState.Invalidate;
    OldState.Update;
  end;

  if (FState <> nil) then
  begin
    FState.Invalidate;
    FState.Update;
  end;

  if not(Active) then
    exit;

  // State change without transition
  if ([csLoading, csDesigning] * ComponentState = []) then
  begin
    if (OldState <> nil) then
      try
        OldState.DoOnExit;
      except
        on E: Exception do
          DoOnException(OldState, E);
      end;

    if (FStopSignalled) or (State = nil) or (State.BreakPoint) then
    begin
      Active := False;
      exit;
    end;

    StateChanged := False;
    try
      State.DoOnEnter;
    except
      on E: Exception do
        DoOnException(State, E);
    end;

    if (FStopSignalled) then
    begin
      Active := False;
      exit;
    end;

    if not(StateChanged) then
      if not(State.DoDefault) then
        Active := False;

    if (soSingleStep in FOptions) then
      FStopSignalled := True;

  end;
end;

procedure TCustomLogicPanel.ChangeState(Transition: TCustomLogicControl);
begin
  // State change with transition
  if (Transition = nil) then
    raise Exception.Create('Invalid transition');
  if not(Active) then
    raise Exception.Create('Cannot execute transition in stopped state');

  // Check transitions
  if (soVerifyTransitions in FOptions) then
    try
      State.CheckTransition(Transition, tdFrom);
      Transition.CheckTransition(State, tdTo);
    except
      on E: Exception do
        raise Exception.CreateFmt('Invalid transition from %s to %s:'+#13+'%s',
          [State.Name, Transition.Name, E.Message]);
    end;

  StateChanged := True;

  DoOnChangeState(State, Transition);

  PostStateChange(Transition);
end;

procedure TCustomLogicPanel.PostStateChange(State: TCustomLogicControl);
begin
  PostMessage(Handle, CL_STATE_TRANSITION, 0, LongInt(State));
end;

procedure TCustomLogicPanel.DoOnChangeState(FromState, ToState: TCustomLogicControl);
begin
  if (Assigned(FOnChangeState)) then
    try
      FOnChangeState(self, FromState, ToState);
    except
      on E: Exception do
        DoOnException(nil, E);
    end;
end;

procedure TCustomLogicPanel.DoOnException(Node: TCustomLogicControl; E: Exception);
begin
  if (Assigned(FOnException)) then
    FOnException(self, Node, E)
  else
  begin
    ShowMessage(E.Message);
    Raise E;
  end;
end;

procedure TCustomLogicPanel.SMStateTransition(var Message: TMessage);
begin
  if (Message.LParam <> 0) then
    DoSetState(TCustomLogicNode(Message.LParam));
end;

procedure TCustomLogicPanel.Paint;
begin

  if (soInteractive in FOptions) or (csDesigning in ComponentState) then
  begin
    inherited Paint;
    if (FDesignMoving in [dmFirstHandle, dmLastHandle]) then
      FConnector.PaintFlipLine(Lines);
  end;

end;

procedure TCustomLogicPanel.CMDesignHitTest(var Msg: TWMMouse);
var
  NewPnt: TPoint;
  i			: integer;
  Connector		: TCustomLogicConnector;

  function TestConnector(Connector: TCustomLogicConnector; p: TPoint): boolean;
  var
    HandleRect		: TRect;
    j			: TDesignMove;
  begin
    Result := False;
    if (Connector = nil) or not(Connector.GetLines(Lines)) then
      exit;

    for j := Low(Lines) to Pred(High(Lines)) do
    begin
      HandleRect := TCustomLogicConnector.MakeRect(Lines[j], Lines[Succ(j)]);
      InflateRect(HandleRect, SelectMarginX, SelectMarginY);
      if (PtInRect(HandleRect, p)) then
      begin
        Result := True;
        exit;
      end;
    end;
  end;

begin
{$IFDEF WIN32}
  NewPnt := SmallPointToPoint(Msg.Pos);
{$ELSE}
  NewPnt := Msg.Pos;
{$ENDIF}
  if (FDesignMoving <> dmNone) then
  begin
    Msg.Result := 1;
    exit;
  end;

  Msg.Result := 0;//pjh �ӽ÷� 0���� 1�� ������

  if not(ssLeft in KeysToShiftState(Msg.Keys)) then
    exit;

  if (TestConnector(FConnector, NewPnt)) then
  begin
    Msg.Result := 1;
    exit;
  end;

  for i := 0 to ControlCount-1 do
    if (Controls[i] is TCustomLogicControl) then
    begin
      Connector := (TCustomLogicControl(Controls[i]).HitTest(NewPnt));

      //���콺�� Connector�� �����ϸ� True�� ��ȯ��
      if not(TestConnector(Connector, NewPnt)) then
        continue;

      if (FConnector <> nil) and (FConnector <> Connector) then
      begin
        FConnector.Selected := False;
        Invalidate;
      end;

      FConnector := Connector;
      Connector.Selected := True;
      Connector.Paint;
      Msg.Result := 1;
      exit;
    end;

  if (FConnector <> nil) then
  begin
    FConnector.Selected := False;
    FConnector := nil;
    invalidate;
  end;
end;

procedure TCustomLogicPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i			: TDesignMove;
  HandleRect		: TRect;
  r			: TRect;
begin
  if (csDesigning in ComponentState) and (FConnector <> nil) and
    (FConnector.GetLines(Lines)) then
  begin
    //
    for i := dmSource to dmDestination do
    begin
      //if (i = dmOffset) and (FConnector.ActualPath in [spTL, spRB]) then
      //  continue;
      HandleRect.TopLeft := Lines[i];
      HandleRect.BottomRight := HandleRect.TopLeft;
      InflateRect(HandleRect, SelectMarginX, SelectMarginY);
      if (PtInRect(HandleRect, Point(X,Y))) then
      begin
        FDesignMoving := i;
        MouseCapture := True;
        Canvas.Pen.Width := 3;
        Canvas.Pen.Mode := pmNotXor;
        FConnector.Paint;
        if (FDesignMoving in [dmFirstHandle, dmLastHandle]) then
        begin
          if (Lines[dmDestination].y > Lines[dmSource].y) then
          begin
            if (Lines[dmDestination].x > Lines[dmSource].x) then
              Screen.Cursor := crSizeNESW
            else
              Screen.Cursor := crSizeNWSE;
          end else
          begin
            if (Lines[dmDestination].x > Lines[dmSource].x) then
              Screen.Cursor := crSizeNWSE
            else
              Screen.Cursor := crSizeNESW;
          end;
          //���콺 ��ư ������ �������� ǥ����
          //FConnector.PaintFlipLine;
        end else
        begin

          { Confine cursor }
          //r := FConnector.MakeRect(ClientToScreen(Lines[dmSource]),
          //  ClientToScreen(Lines[dmDestination]));
          if FDesignMoving = dmDestination then
            r := FConnector.MakeRect(
                    ClientToScreen(FConnector.Destination.BoundsRect.TopLeft),
                    ClientToScreen(FConnector.Destination.BoundsRect.BottomRight))
          else
          if FDesignMoving = dmSource then
            r := FConnector.MakeRect(
                    ClientToScreen(FConnector.Source.BoundsRect.TopLeft),
                    ClientToScreen(FConnector.Source.BoundsRect.BottomRight));

          ClipCursor(@r);

          if (FConnector.ActualPath = spLR) then
            Screen.Cursor := crHSplit
          else if (FConnector.ActualPath = spTB) then
            Screen.Cursor := crVSplit;
        end;
        Canvas.Pen.Width := 1;
        Canvas.Pen.Mode := pmCopy;
        Canvas.Pen.Style := psSolid;
        Canvas.Pen.Color := clBlack;
        exit;
      end;//if
    end;//for
  end;//if

  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TCustomLogicPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  //Vector			: TRect;
  NewOffset			: integer;
  DoPaint			: Boolean;

  // Function to determine on which side of the vector c1->c2 the point a lies
  {function cross(a: TPoint; c: TRect): integer;
  var
    b			: TPoint;
  begin
    a := Point(a.x-c.Left, a.y-c.Top);
    b := Point(c.Right-c.Left, c.Bottom-c.Top);
    Result := (a.x*b.y)-(a.y*b.x);
  end;
  }

begin
  if  (csDesigning in ComponentState) and (FDesignMoving <> dmNone) and
    (FConnector <> nil) then
  begin
{    DoPaint := False;
    NewOffset := FConnector.Offset;
    NewPath := FConnector.Path;
    if (FDesignMoving in [dmFirstHandle, dmLastHandle]) then
    begin
      Vector.TopLeft :=  TCustomLogicConnector.RectCenter(FConnector.Source.BoundsRect);
      Vector.BottomRight :=  TCustomLogicConnector.RectCenter(FConnector.Destination.BoundsRect);
      NewPath := NewState(FConnector.ActualPath, FDesignMoving, Vector,
        Lines[FDesignMoving], Point(X,Y));
      if (NewPath <> FConnector.ActualPath) then
      begin
        DebugStr('Flip:'+IntToStr(Ord(NewPath)));
        DoPaint := True;
      end else
        DebugStr('Back:'+IntToStr(Ord(FConnector.ActualPath)));
    end else
    begin
      case (FConnector.ActualPath) of
        spLeftRight:
          NewOffset := FConnector.Offset+X-Lines[dmOffset].x;
        spTopBottom:
          NewOffset := FConnector.Offset+Y-Lines[dmOffset].y;
      end;
      DebugStr('Change offset:'+IntToStr(NewOffset));
      if (NewOffset <> FConnector.Offset) then
      begin
        DoPaint := True;
      end;
    end;
}
    DoPaint := False;

    //if pointinpoly(x,y) then
    if FDesignMoving in [dmSource, dmDestination]  then
    begin
      Screen.cursor := crCross;
      NewPath := NewState(Point(X,Y));
      DoPaint := True;
    end
    else
      Screen.cursor := crDefault;


    if (DoPaint) then
    begin
      Canvas.Pen.Width := 3;
      Canvas.Pen.Mode := pmNotXor;
      FConnector.Paint;  // Erase previous

      FConnector.Offset := NewOffset;
      FConnector.Path := NewPath;
      FConnector.GetLines(Lines);
      FConnector.PaintFlipLine(Lines);
      //FConnector.Paint; // Paint new
      Canvas.Pen.Width := 1;
      Canvas.Pen.Mode := pmCopy;
    end;
  end;

  inherited MouseMove(Shift, X, Y);
end;

procedure TCustomLogicPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
{$IFNDEF VER90}
  Form			: TCustomForm;
{$ELSE}
  Form			: TForm;
{$ENDIF}

  NewPath: TStatePath;
begin
  if (csDesigning in ComponentState) and (FDesignMoving <> dmNone) then
  begin
    //DebugStr('StateMachine.MouseUp');

    if FDesignMoving in [dmSource, dmDestination] then
    begin
      NewPath := NewState(Point(X,Y));

      if FConnector.ActualPath <> NewPath then
      begin
        Canvas.Pen.Width := 3;
        Canvas.Pen.Mode := pmNotXor;
        FConnector.Paint;  // Erase previous

        //FConnector.Offset := NewOffset;
        FConnector.Path := NewPath;
        FConnector.GetLines(Lines);

        FConnector.Paint; // Paint new
        Canvas.Pen.Width := 1;
        Canvas.Pen.Mode := pmCopy;
      end;//if
    end;//if

    Canvas.Pen.Mode := pmCopy;
    Form := GetParentForm(self);
    if (Form <> nil) and (Form.Designer <> nil) then
      Form.Designer.Modified;
    FDesignMoving := dmNone;
    Screen.Cursor := crDefault;
    ClipCursor(nil);
    MouseCapture := false;
    Invalidate;
  end;
  inherited MouseUp(Button, Shift, X, Y);
  Repaint;
end;

//******************************************************************************
//**
//**			TCustomLogicConnector
//**
//******************************************************************************
constructor TCustomLogicConnector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

//destructor TCustomLogicConnector.Destroy;
//begin
//  inherited;
//end;

procedure TCustomLogicConnector.SetPeer(Index: integer; Value: TCustomLogicControl);
begin
  if ((Index = 1) and (FOwner = poOwnedBySource)) or
    ((Index = 2) and (FOwner = poOwnedByDestination)) then
    raise Exception.Create('Cannot modify owner of connector');
  case (Index) of
    0: if (FOwner = poOwnedBySource) then
         FDestination := Value
       else
         FSource := Value;
    1: FSource := Value;
    2: FDestination := Value;
  end;
end;

function TCustomLogicConnector.GetPeer(Index: integer): TCustomLogicControl;
begin
  if (FOwner = poOwnedBySource) then
    Result := FDestination
  else
    Result := FSource;
end;

{
Cohen-Sutherland Cliping Algorithm for find p1(x,y),p2(x,y) and clip window
with diagonal from Diagonal1(x,y) to Diagonal2(x,y)
Diagonal1 : �������� TopLeft
Diagonal2 : �������� BottomRight

   1001 | 0001 | 0101
   ------------------
   1000 | 0000 | 0100
   ------------------
   1010 | 0010 | 0110

  * 0000: window
  * First bit set 1 : Point lies left of window x < xmin
  * Second bit set 1 : Point lies right of window x > xmax
  * Third bit set 1 : Point lies below(Bottom) window y < ymin
  * Forth bit set 1 : Point lies above(Top) window y > xmax

  *Logical AND operation�� ������ �����쿡 ������ ���������� ���θ� �Ǵ���
   endpoint�� AND �������� 0�� �ƴϸ� ������ �������� �ǹ���
  *Logical OR operation�� ������ �����쿡 ������ ���ԵǾ������� ���θ� �Ǵ���
   endpoint�� OR �������� 0�̸� ������ ���Ե��� �ǹ���

  *) �簢���� ������ ��ġ�� True�� ��ȯ��
  *) ���������p1, p2�� �������� ����(p1.x, p1.y), (p2.x, p2.y)���� ��
}
function TCustomLogicConnector.CohrenSutherlandLine(var p1,p2: TPoint; Diagonal1, Diagonal2:TPoint): Boolean;
type
  Edge = (Left, Right, Top, Bottom);
  Outcode = set of edge;
var
  accept, done: Boolean;
  //OutCodes for p1,p2 and whichever point lies outside the clip window
  OutCode0, OutCode1, OutCodeOut: OutCode;

  x,y: integer;

  //Compute outcode for the point(x,y)
  procedure CompOutCode(x,y: integer; var code: OutCode);
  begin
    code := [];

    //y ���������� �Ϲ� ��ǥ��� �ݴ��̱� ������ ������
    //Top -> Bottom, Bottom -> Top
    if y > Diagonal2.Y then code := [Bottom]
    else if y < Diagonal1.Y then code := [Top];

    if x > Diagonal2.X then code := code + [Right]
    else if x < Diagonal1.X then code := Code + [Left];
  end;

begin
  accept := False;
  done := False;

  CompOutCode(p1.x, p1.Y, OutCode0);
  CompOutCode(p2.X, p2.Y, OutCode1);

  repeat
    if (OutCode0 = []) and (OutCode1 = []) then //trivial accept and exit
    begin
      accept := True;
      done := True;
    end
    else if (OutCode0 * OutCode1) <> [] then
      done := True//Logical Intersection is true, so trivial reject and exit
    else
    //failed both tests, so calculate the line segment to clip:
    //from an outside point to an intersection with clip edge
    begin
      //at least one endpoint is outside the clip window. pick it
      if OutCode0 <> [] then
        OutCodeOut := OutCode0
      else
        OutCodeOut := OutCode1;

      //Now find intersection point:
      //Use formulas y = y0 + slope * (x-x0), x = x0 + (1/slope) * (y-y0)
      if Top in OutCodeOut then
      begin //Divide line at top of clip window
        x := p1.x + Round((p2.x - p1.x) * (Diagonal2.Y - p1.Y)/(p2.Y - p1.Y));
        y := Diagonal2.y;
      end
      else if Bottom in OutCodeOut then
      begin //Divide line at Bottom of clip window
        x := p1.x + Round((p2.x - p1.x) * (Diagonal1.Y - p1.Y)/(p2.Y - p1.Y));
        y := Diagonal1.y;
      end
      else if Right in OutCodeOut then
      begin //Divide line at Right edge of clip window
        y := p1.y + Round((p2.y - p1.y) * (Diagonal2.x - p1.x)/(p2.x - p1.x));
        x := Diagonal2.x;
      end
      else if Left in OutCodeOut then
      begin //Divide line at Left edge of clip window
        y := p1.y + Round((p2.y - p1.y) * (Diagonal1.x - p1.x)/(p2.x - p1.x));
        x := Diagonal1.x;
      end;

      //Now we move outside point to intersection point to clip,
      //and get ready for next pass
      if (OutCodeOut = OutCode0) then
      begin
        p1 := point(x,y);
        CompOutCode(p1.x, p1.Y, OutCode0);
      end
      else
      begin
        p2 := Point(x,y);
        CompOutCode(p2.X, p2.y, OutCode1);
      end;
    end;//if
  until done;

  Result := Accept;
  //version for real coordinate
  //if accept then MidPointLineReal(p1,p2,Value);
end;//CohrenSutherlandLineAndDraw

//������ �簢���� �������� True�� ��ȯ��
function TCustomLogicConnector.CheckConnectorCollision(Lines: TConnectorLines;r1,r2: TRect): Boolean;
var i: TDesignMove;
begin
  Result := False;
  for i := dmFirstHandle to dmThirdHandle do  //2004.4.1 dmOffset -> dmThirdHandle
  begin
    if (Lines[i].x = Lines[Succ(i)].x) and (Lines[i].y = Lines[Succ(i)].y) then
      Continue;

    if CohrenSutherlandLine(Lines[i], Lines[Succ(i)], r1.TopLeft, r1.BottomRight) then
    begin
      Result := True;
      exit;
    end;

    if CohrenSutherlandLine(Lines[i], Lines[Succ(i)], r2.TopLeft, r2.BottomRight) then
    begin
      Result := True;
      exit;
    end;
  end;//for
end;

//PolyLine�� ���̸� ��ȯ��
//������ ��ø�Ǿ� ������ PointOnLine = True
//LintCount = PolyLine�� ������ ����
function TCustomLogicConnector.PolyLineDistance(Lines: TConnectorLines;
                    var LineCount: integer; var PointOnLine: Boolean): integer;
  function Distance(p1,p2:TPoint):integer;
  begin
    result:=Round(sqrt(sqr(p1.x-p2.x)+sqr(p1.y-p2.y)));
  end;
var
  i,k: TDesignMove;
  j: integer;
  L1, L2: TLine_pjh;
  //BeforeEqualX,BeforeEqualY: Bool;
begin
  Result := 0;
  LineCount := 0;
  k := dmSource;
  //BeforeEqualX := False;
  //BeforeEqualY := False;

  for i := Low(Lines) to Pred(High(Lines)) do
  begin
    j := Distance(Lines[i],Lines[Succ(i)]);

    if j <> 0 then
    begin
      Result := Result + j;

{      if (BeforeEqualX) then
      begin
        if (Lines[i].x <> Lines[Succ(i)].x) and (Lines[i].y = Lines[Succ(i)].y) then
          Inc(LineCount);
      end
      else
      if (BeforeEqualY) then
      begin
        if (Lines[i].x = Lines[Succ(i)].x) and (Lines[i].y <> Lines[Succ(i)].y)then
          Inc(LineCount);
      end
      else
        Inc(LineCount);

      if (Lines[i].x <> Lines[Succ(i)].x) then
        BeforeEqualX := False
      else
        BeforeEqualX := True;

      if (Lines[i].y <> Lines[Succ(i)].y) then
        BeforeEqualY := False
      else
        BeforeEqualY := True;
}
    end;

    if (i <= dmLastHandle) and (k = i) and (PointOnLine)then
    begin
      while (Lines[k].X = Lines[Succ(k)].X) and (Lines[k].y = Lines[Succ(k)].Y) do
        if k <= dmLastHandle then
          k := Succ(k);

      if k = dmLastHandle then
        Continue;

      L1.p1 := Lines[k];
      L1.p2 := Lines[Succ(k)];

      k := Succ(k);
      while (Lines[k].X = Lines[Succ(k)].X) and (Lines[k].y = Lines[Succ(k)].Y) do
        //if k <= dmLastHandle then
          k := Succ(k);

      L2.p1 := L1.p2;

      //if k <= dmLastHandle then
        L2.p2 := Lines[Succ(k)];
      //else
      //  L2.p2 := Lines[k];

      LineInterSect(L1,L2,PointOnLine);

      //if PointOnLine then
      if (L1.p1.x <> L2.p2.x) and (L1.p1.y <> L2.p2.y) then
        Inc(LineCount);

{      if k < dmLastHandle then
        for i := Low(OffsetList) to High(OffSetList) do
          if OffSetList[i] < 0 then
            OffSetList[i] := L2;
}
    end;//if

  end;//for
end;

{*************** Intersect ***************}
//�μ��� �־��� �ΰ��� ������ �����ϸ� True�� ��ȯ��
//pointToOnBorder���� True�̸� �ΰ��� ������ ��ġ�� �ϰ� Cross������ ����
function TCustomLogicConnector.LineIntersect(L1,L2:TLine_pjh; var PointOnBorder:boolean):boolean;
{Return true if line segments L1 and L2 intersect,
 also indicate if just touching}

 {***************** SameSide ************}
  function sameside(L:TLine_pjh; p1,p2:TPoint; var PointOnBorder:boolean):int64;
  {������ �־��� ������ �߽�����
  same side => result>0
  opposite sides => result <0
  a point on the line => result=0 }
  var dx,dy,dx1,dy1,dx2,dy2:int64;
  begin
    dx:=L.p2.x-L.P1.x;  //L1�� X�� ����
    dy:=L.p2.y-L.P1.y;  //L1�� Y�� ����
    dx1:=p1.x-L.p1.x;
    dy1:=p1.y-L.p1.y;
    dx2:=p2.x-L.p2.x;
    dy2:=p2.y-L.p2.y;
    //result:=(dx*dy1-dy*dx1)*(dx*dy2-dy*dx2);
    result:=(dx*dy1-dy*dx1);

    //�񱳴���� ���� �ƴ� ���� ���((dx = 0) and (dy = 0))���� True�� ��ȯ��
    if (dx = 0) and (dy = 0) then
    begin
      PointOnBorder:=true;
      exit;
    end;

    if result = 0 then
    begin
      //p1,p2 ��� Line���� ������� PointOnBorder = False�� ��ȯ��
      if (dx*dy2-dy*dx2) = 0 then
        if ((Min(L.p1.x, L.p2.x) <= p1.x) and (Max(L.p1.x, L.p2.x) >= p1.x)) and
          ((Min(L.p1.x, L.p2.x) <= p2.x) and (Max(L.p1.x, L.p2.x) >= p2.x)) and
          ((Min(L.p1.y, L.p2.y) <= p1.y) and (Max(L.p1.y, L.p2.y) >= p1.y)) and
          ((Min(L.p1.y, L.p2.y) <= p2.y) and (Max(L.p1.y, L.p2.y) >= p2.y)) then
        result := 1
    end
    else
      result := (dx*dy2-dy*dx2);

    if (((dx<>0) or (dy<>0)) and (result=0)) then
      PointOnBorder:=true
    else
      PointOnBorder:=false;
  end;
var
  a,b:int64;
  pb:boolean;
begin
  PointOnBorder := false;
  a:=sameside(L1,L2.p1,L2.p2, pb);

  if pb then
    PointOnBorder:=true
  else//���� �������� ���� ���ٸ� �ݴ��� ������ ���� �ʿ� ����
    exit;

  b:=sameside(L2,L1.p1,L1.p2,pb);

  PointOnBorder := pb;

  result:=(a<=0) and (b<=0);
end;

function TCustomLogicConnector.GetLines(var Lines: TConnectorLines): Boolean;
const DefaultMargin = 20;
var
  OverlapX		,
  OverlapY		: Boolean;
  p1			,
  p2			: TPoint;
  r1			,
  r2			: TRect;
  dx			,
  dy			: integer;
  d2x			,
  d2y			: integer;
  DirectionX		,
  DirectionY		: Shortint;
  tmpPoint: array[0..1,0..15] of TPoint;
  //Non Collision Shortest Path ������, Collision �� Shortest Path�� ������
  tmpPoint2: array[0..1,0..1] of TPoint;
  tmpDistance, tmpDistance2: integer;//��������� ���� ª�� �Ÿ�
  tmpLineCount, tmpLineCount2: integer;//Lines�� ����� ������ ����
  tmpConnector1: array[0..7] of integer;
  tmpConnector2: array[0..7] of integer;
  i,j,k,m: integer;
  L1,L2: TLine_pjh;
  LPointOnLine: Boolean;
//                   +--------+
//                   |  Dest  |
//                d1 |   p2   | ^
//                   |        | |
//                   +--------+ |
//          ^            d2     |
//          |                   |
//         d2y                  |
//          |                   dy
//     s2   v                   |
// +--------+<--d2x->           |
// | Source |                   |
// |   p1   | s1                v
// |        |
// +--------+
//      <------- dx ----->

begin
  if (Source = nil) or (Destination = nil) then
  begin
    Result := False;
    exit;
  end;

  Result := True;

  //�ִܰŸ� ��ǥ �� �Ÿ��� ������
  tmpDistance := $FFFF;
  tmpDistance2 := $FFFF;
  tmpLineCount := $FFFF;
  tmpLineCount2 := $FFFF;

  //Non Collision �ִܰŸ�
  tmpPoint2[0][0] := Point(-1,-1);
  tmpPoint2[0][1] := Point(-1,-1);

  //Collision �ִܰŸ�
  tmpPoint2[1][0] := Point(-1,-1);
  tmpPoint2[1][1] := Point(-1,-1);

  r1 := Source.BoundsRect;
  r2 := Destination.BoundsRect;
  p1 := Point(r1.Left+Source.Width DIV 2,r1.Top+(Source.Height) DIV 2);
  p2 := Point(r2.Left+Destination.Width DIV 2,r2.Top+Destination.Height DIV 2);

  dx := p2.x-p1.x;
  dy := p2.y-p1.y;

{  if (dx = 0) then
    DirectionX := 0
  else
    DirectionX := dx DIV ABS(dx);

  if (dy = 0) then
    DirectionY := 0
  else
    DirectionY := dy DIV ABS(dy);
}
  d2x := ABS(dx)-(Source.Width+Destination.Width) DIV 2;
  d2y := ABS(dy)-(Source.Height+Destination.Height) DIV 2;

  OverlapX := (d2x <= OverlapXMargin);
  OverlapY := (d2y <= OverlapYMargin);

  FActualPath := Path;
  // Switch to auto if position makes path impossible
  //comment 2004.1.19 ó�� ������ �� �ѹ��� spAuto�̸� ��
  {if ((ActualPath = spRightBottom) and
      ((ABS(dx) - (Source.Width DIV 2) < OverlapXMargin) or
       (d2y + (Source.Height DIV 2) < OverlapYMargin)) or
     ((ActualPath = spTopLeft) and
      ((ABS(dy) - (Source.Height DIV 2) < OverlapYMargin) or
       (d2x + (Source.Width DIV 2) < OverlapXMargin)))) then
    FActualPath := spAuto;
  }
  if (ActualPath in [spAuto, spDirect]) then
  begin
    if (OverlapY) or (d2x > d2y) then
      //FActualPath := spLeftRight
      Path := spLR
    else
      //FActualPath := spTopBottom;
      Path := spBT;
  end;
  //end else

  //path := spLR;
  FActualPath := Path;

  case ActualPath of
    spLL, spLR, spLT, spLB: Lines[dmSource] := Point(r1.Left, p1.y);
    spRL, spRR, spRT, spRB: Lines[dmSource] := Point(r1.right, p1.y);
    spTL, spTR, spTT, spTB: Lines[dmSource] := Point(p1.x, r1.Top);
    spBL, spBR, spBT, spBB: Lines[dmSource] := Point(p1.x, r1.Bottom);
  end;//case

  case ActualPath of
    spLL, spRL, spTL, spBL: Lines[dmDestination] := Point(r2.Left, p2.y);
    spLR, spRR, spTR, spBR: Lines[dmDestination] := Point(r2.Right, p2.y);
    spLT, spRT, spTT, spBT: Lines[dmDestination] := Point(p2.x, r2.Top);
    spLB, spRB, spTB, spBB: Lines[dmDestination] := Point(p2.x, r2.Bottom);
  end;//case

  dx := Lines[dmDestination].x - Lines[dmSource].x;
  dy := Lines[dmDestination].y - Lines[dmSource].y;

  if ( dx = 0) then
    DirectionX := 0
  else
    DirectionX := dx DIV ABS(dx);

  if (dy = 0) then
    DirectionY := 0
  else
    DirectionY := dy DIV ABS(dy);

  case ActualPath of
    spLL, spLR, spLT, spLB:
      if not OverLapX and (DirectionX < 0) then
        Lines[dmFirstHandle] := Point(Lines[dmSource].x - ABS(d2x DIV 2), p1.y)
      else
        Lines[dmFirstHandle] := Point(Lines[dmSource].x - DefaultMargin, p1.y);
    spRL, spRR, spRT, spRB:
      if not OverLapX and (DirectionX > 0) then
        Lines[dmFirstHandle] := Point(Lines[dmSource].x + d2x DIV 2, p1.y)
      else
        Lines[dmFirstHandle] := Point(Lines[dmSource].x + DefaultMargin, p1.y);
    spTL, spTR, spTT, spTB:
      if not OverLapY and (DirectionY < 0) then
        Lines[dmFirstHandle] := Point(p1.x, Lines[dmSource].y - d2y DIV 2)
      else
        Lines[dmFirstHandle] := Point(p1.x, Lines[dmSource].y - DefaultMargin);
    spBL, spBR, spBT, spBB:
      if not OverLapY and (DirectionY > 0) then
        Lines[dmFirstHandle] := Point(p1.x, Lines[dmSource].y + d2y DIV 2)
      else
        Lines[dmFirstHandle] := Point(p1.x, Lines[dmSource].y + DefaultMargin);
  end;//case

  case ActualPath of
    spLL, spRL, spTL, spBL:
      if not OverLapX and (DirectionX > 0) then
        Lines[dmLastHandle] := Point(Lines[dmDestination].x - Round(d2x/2), p2.y)
      else
        Lines[dmLastHandle] := Point(Lines[dmDestination].x - DefaultMargin, p2.y);
    spLR, spRR, spTR, spBR:
      if not OverLapX and (DirectionX < 0) then
        Lines[dmLastHandle] := Point(Lines[dmDestination].x + Round(d2x/2), p2.y)
      else
        Lines[dmLastHandle] := Point(Lines[dmDestination].x + DefaultMargin, p2.y);
    spLT, spRT, spTT, spBT:
      if not OverLapY and (DirectionY > 0) then
        Lines[dmLastHandle] := Point(p2.x, Lines[dmDestination].y - Round(d2y/2))
      else
        Lines[dmLastHandle] := Point(p2.x, Lines[dmDestination].y - DefaultMargin);
    spLB, spRB, spTB, spBB:
      if not OverLapY and (DirectionY < 0) then
        Lines[dmLastHandle] := Point(p2.x, Lines[dmDestination].y + Round(d2y/2))
      else
        Lines[dmLastHandle] := Point(p2.x, Lines[dmDestination].y + DefaultMargin);
  end;//case

  Lines[dmThirdHandle] := Point(0,0);
  //Lines[dmOffset] := Point(0,0);//2004.4.1

  tmpConnector1[0] := ABS(Lines[dmFirstHandle].X);
  tmpConnector1[1] := ABS(Lines[dmLastHandle].X);
  tmpConnector1[2] := ABS(r1.Right + DefaultMargin);
  tmpConnector1[3] := ABS(r1.Left - DefaultMargin);
  tmpConnector1[4] := ABS(r2.Right + DefaultMargin);
  tmpConnector1[5] := ABS(r2.Left - DefaultMargin);
  tmpConnector1[6] := ABS(r1.Right + (d2x div 2));
  tmpConnector1[7] := ABS(r1.Left - (d2x div 2));

  tmpConnector2[0] := ABS(Lines[dmFirstHandle].y);
  tmpConnector2[1] := ABS(Lines[dmLastHandle].y);
  tmpConnector2[2] := ABS(r1.Top - DefaultMargin);
  tmpConnector2[3] := ABS(r1.Bottom + DefaultMargin);
  tmpConnector2[4] := ABS(r2.Top - DefaultMargin);
  tmpConnector2[5] := ABS(r2.Bottom + DefaultMargin);
  tmpConnector2[6] := ABS(r1.Top - (d2y div 2));
  tmpConnector2[7] := ABS(r1.Bottom + (d2y div 2));

  for i := Low(tmpConnector2) to High(tmpConnector2) do
  begin
    tmpPoint[0][i] := Point(Lines[dmFirstHandle].X,tmpConnector2[i]);
    tmpPoint[0][i+High(tmpConnector2)+1] := Point(tmpConnector1[i], Lines[dmFirstHandle].Y);
    tmpPoint[1][i] := Point(Lines[dmLastHandle].X,tmpConnector2[i]);
    tmpPoint[1][i+High(tmpConnector2)+1] := Point(tmpConnector1[i], Lines[dmLastHandle].Y);
  end;

  for i:= Low(tmpPoint[0]) to High(tmpPoint[0]) do
  begin
    //(x,y) ���� FirstHandle�� �ٸ� ��쿡�� ����
    //if (Lines[dmFirstHandle].x = tmpPoint[0][i].x) and
    //                            (Lines[dmFirstHandle].y = tmpPoint[0][i].y)then
    //  Continue;

    //L1.p1 := Lines[dmSource];
    //L1.p2 := Lines[dmFirstHandle];
    //L2.p1 := Lines[dmFirstHandle];
    //L2.p2 := tmpPoint[0][i];
    //�ΰ��� ������ ���� �Ǿ��ٸ�
    //LineInterSect(L1, L2, LPointOnLine);
    //if not LPointOnLine then //Cross �Ǵ� ������ ���¶�� �ǳʶ�
    //  Continue;

      Lines[dmSecondHandle] := tmpPoint[0][i];

      for k := Low(tmpPoint[1]) to High(tmpPoint[1]) do
        begin
        //(x,y) ���� FirstHandle�� �ٸ� ��쿡�� ����
        //if (Lines[dmSecondHandle].x = tmpPoint[1][k].x) and
        //                        (Lines[dmSecondHandle].y = tmpPoint[1][k].y)then
        //  Continue;
          //if k <> j then
          //begin
            //������ P
            if ((Lines[dmSecondHandle].X = tmpPoint[1][k].X) or
              (Lines[dmSecondHandle].Y = tmpPoint[1][k].Y)) and
              ((Lines[dmLastHandle].X = tmpPoint[1][k].X) or
              (Lines[dmLastHandle].y = tmpPoint[1][k].y)) then
            begin
              Lines[dmThirdHandle] := tmpPoint[1][k];
              //Lines[dmOffset] := Lines[dmThirdHandle];//2004.4.1

              LPointOnLine := True;
              j := PolyLineDistance(Lines, m, LPointOnLine);

              if not LPointonLine then
                Continue;

              //������ ��ġ�� �ʾ����� exit
              if not CheckConnectorCollision(Lines, r1,r2) then
              begin
                //exit;
                //�Ÿ��� �� ª���� ������
                //�Ǵ� ���� ���尪(x,y)�� ������ ������ ���(ȭ�鿡 �Ⱥ��̴� �κ��� ����) ������
                if (tmpDistance >= j) then
                begin
                  if tmpDistance = j then
                    //�Ÿ��� ���� ��� ������ ������ ������ ������
                    if tmpLineCount <= m then
                      Continue;

                  tmpLineCount := m;
                  tmpDistance := j;
                  tmpPoint2[0][0] := Lines[dmSecondHandle];
                  tmpPoint2[0][1] := Lines[dmThirdHandle];
                end;
              end
              else
              begin
                if tmpDistance2 >= j then
                begin
                  tmpDistance2 := j;
                  tmpPoint2[1][0] := Lines[dmSecondHandle];
                  tmpPoint2[1][1] := Lines[dmThirdHandle];
                end;
              end;
                //exit;
            end;//if
          //end;//if
        end;//for
  end;//for

  //�浹�� �߻����� ���� ������ ������
  if tmpPoint2[0][0].x > 0 then
  begin
    Lines[dmSecondHandle] := tmpPoint2[0][0];
    Lines[dmThirdHandle] := tmpPoint2[0][1];
    //Lines[dmOffset] := Lines[dmThirdHandle];//2004.4.1
  end
  else//�浹�� �߻��� �����߿��� ����
  if tmpPoint2[1][0].x > 0 then
  begin
    Lines[dmSecondHandle] := tmpPoint2[1][0];
    Lines[dmThirdHandle] := tmpPoint2[1][1];
    //Lines[dmOffset] := Lines[dmThirdHandle];//2004.4.1
  end
  else
  if (Lines[dmThirdHandle].x = 0) and (Lines[dmThirdHandle].y = 0) then
  begin
    Lines[dmSecondHandle] := Lines[dmFirstHandle];
    Lines[dmThirdHandle] := Lines[dmLastHandle];
    //Lines[dmOffset] := Lines[dmThirdHandle];//2004.4.1
  end;
end;

class function TCustomLogicConnector.MakeRect(pa, pb: TPoint): TRect;
begin
  Result.TopLeft := Point(Min(pa.x, pb.x), Min(pa.y, pb.y));
  Result.BottomRight := Point(Max(pa.x, pb.x), Max(pa.y, pb.y));
end;

class function TCustomLogicConnector.RectCenter(r: TRect): TPoint;
begin
  Result.x := r.Left+(r.Right-r.Left) DIV 2;
  Result.y := r.Top+(r.Bottom-r.Top) DIV 2;
end;

procedure TCustomLogicConnector.Paint;
var
  Lines			: TConnectorLines;
  i			: TDesignMove;
  Direction		: integer;
  Size			: integer;
  SaveWidth		: integer;
  WorkPath		: TStatePath;
//  LogBrush		: TLogBrush;

begin
  if not(GetLines(Lines)) then
    exit;

  with Source.StateMachine.Canvas do
  begin
    Pen.Style := psSolid;
  //Pen.Color := clBlack;

    Brush.Style := bsSolid;
    Brush.Color := Pen.Color;

    Size := Pen.Width DIV 2;
  end;//with

  Arrow[0] := Lines[dmDestination];

{  if (ActualPath = spDirect) then
  begin
    if (ABS(Lines[dmDestination].x-Lines[dmSource].x) >
      ABS(Lines[dmDestination].y-Lines[dmSource].y)) then
      WorkPath := spLR
    else
      WorkPath := spTB;
  end else
    WorkPath := ActualPath;
}
  case ActualPath of
    spLL,spRL,spTL,spBL,
    spLR,spRR,spTR,spBR:
      begin
        Direction := Lines[dmDestination].x-Lines[dmLastHandle].x;
        if (Direction <> 0) then
          Direction := Direction DIV ABS(Direction);

        Lines[dmDestination].x :=
          Lines[dmDestination].x-Source.StateMachine.Canvas.Pen.Width*Direction;
        Arrow[1] := Point(Arrow[0].x-(3+Size)*Direction, Arrow[0].y-(3+Size));
        Arrow[2] := Point(Arrow[0].x-(3+Size)*Direction, Arrow[0].y+(3+Size));
      end;
    spLB,spRB,spTB,spBB,
    spLT,spRT,spTT,spBT:
      begin
        Direction := Lines[dmDestination].y-Lines[dmLastHandle].y;
        if (Direction <> 0) then
          Direction := Direction DIV ABS(Direction);

        Lines[dmDestination].y :=
          Lines[dmDestination].y-Source.StateMachine.Canvas.Pen.Width*Direction;
        Arrow[1] := Point(Arrow[0].x-(3+Size), Arrow[0].y-(3+Size)*Direction);
        Arrow[2] := Point(Arrow[0].x+(3+Size), Arrow[0].y-(3+Size)*Direction);
      end;
  end;

{
  LogBrush.lbStyle := BS_SOLID;
  LogBrush.lbColor := clGreen;

  Source.StateMachine.Canvas.Pen.Handle := ExtCreatePen(
    PS_GEOMETRIC or PS_SOLID or PS_ENDCAP_FLAT or PS_JOIN_ROUND, // PS_JOIN_BEVEL,
    Source.StateMachine.Canvas.Pen.Width,
    LogBrush, // CONST LOGBRUSH *  lplb,	// address of structure for brush attributes
    0, nil);
}
  with Source.StateMachine.Canvas do
  begin
    //������ �׸�
    PolyLine(Lines);

    SaveWidth := Pen.Width;
    Pen.Width := 1;
    //ȭ��ǥ ����� �׷���
    Polygon(Arrow);
    Pen.Width := SaveWidth;
  end;//with

  //���콺�� ȭ��ǥ�� ���������� �׷��ִ� �۾�
  if (csDesigning in Source.StateMachine.ComponentState) then
  begin
    if (Selected) and (Source.StateMachine.FConnector = self) then
    begin
      for i := dmFirstHandle to dmLastHandle do
      begin
        //������ Ÿ�ӿ� ���콺�� ȭ��ǥ ���ýÿ� 3���� ���� �����
        Source.StateMachine.Canvas.Rectangle(Lines[i].x-2, Lines[i].y-2,
                                                  Lines[i].x+2, Lines[i].y+2);
      end;

      //ȭ��ǥ �糡���� ���λ� ���� �׷���
      Source.StateMachine.Canvas.Brush.Color := clLime;
      i := dmSource;
      Source.StateMachine.Canvas.Ellipse(Lines[i].X-4, Lines[i].Y-4,
                                                  Lines[i].x+4, Lines[i].y+4);

      i := dmDestination;
      Source.StateMachine.Canvas.Ellipse(Lines[i].X-4, Lines[i].Y-4,
                                                  Lines[i].x+4, Lines[i].y+4);
    end;

    //���콺�� ������ ���õǴ� ���� ���
    BoundsRect := MakeRect(Lines[dmSource], Lines[dmDestination]);
    InflateRect(BoundsRect, SelectMarginX, SelectMarginY);

    Invalidate;
  end;
end;

//���콺 ��ư ������ �������� ǥ����
procedure TCustomLogicConnector.PaintFlipLine(Lines: TConnectorLines);
begin
  if (Source <> nil) and (Destination <> nil) then
  begin
    with Source.StateMachine.Canvas do
    begin
      Pen.Width := 1;
      Pen.Mode := pmXor;
      Pen.Style := psDot;
      Pen.Color := clWhite;
      //������ �׸�
      PolyLine(Lines);
    end;//with
  end;
end;

function TCustomLogicConnector.HitTest(Mouse: TPoint): Boolean;
begin
  Result := PtInRect(BoundsRect, Mouse);
end;

//******************************************************************************
//**
//**			TCustomLogicControl
//**
//******************************************************************************
constructor TCustomLogicControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inherited SetBounds(0, 0, 69, 41);

  FConnectors := TList.Create;
  ShowHint := True;
  FRoundSize := 30;
  FClicked:= False;
  FHotTrack:= True;
  ColorScheme := csGrass;
  MouseState:= bsNormal;
  OnMouseMove := DoOnMouseMove;
  OnMouseDown := DoOnMouseDown;
  OnMouseUp := DoOnMouseUp;

  FText := TStringList.Create;
  FTextFieldVerticalAlign := iacctvaCenter;
  FTextFieldHorizontalAlign := iaccthaCenter;
  FTextAlign := iaccthaCenter;

  FBreakPoint := False;
  
{  if (ClassName = 'TpjhWriteComport') or (ClassName = 'TpjhReadComport') or
    (ClassName = 'TpjhWriteFile') or (ClassName = 'TpjhWriteFAMem') or
    (ClassName = 'TpjhSetTimer') or (ClassName = 'TpjhIFTimer') then
    FShowLabelBmp := True
  else
    FShowLabelBmp := False;
}
  if FShowLabelBmp then
  begin
    FLabelBmp := TBitMap.Create;
    FLabelBmp.Transparent := true;
    FLabelBmp.Width := 50;
    FLabelBmp.Height:= 50;
    FLabelBmp.Handle := LoadBitmap(hInstance, PChar(String(ClassName)) );
  end;
end;

destructor TCustomLogicControl.Destroy;
var i: integer;
begin
  if FShowLabelBmp then
    FLabelBmp.Free;

  FText.Free;
  //FConnectors�� �� Item���� �� Component�� �Ҹ��ڿ��� Free�� ������.
  //���� TList���� FConnectors�� Free�ϸ� ��.
  FConnectors.Free;
  inherited Destroy;
end;

function TCustomLogicControl.AddConnector(OwnerRole: TStatePathOwner): TCustomLogicConnector;
begin
  Result := TCustomLogicConnector.Create(self);
  Result.CreateInit(self, OwnerRole);
  Connectors.Add(Result);
end;

procedure TCustomLogicControl.DoOnMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
{var i: integer;}
begin
{  i := y;
  i := i shl 16;
  i := i + x;
  SendMessage(Self.Parent.Handle, WM_MOUSEMOVE, MK_LBUTTON, i);
}
  if not (csDesigning in ComponentState) then
  begin
  end;

  inherited;
end;

procedure TCustomLogicControl.DoOnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not (csDesigning in ComponentState) then
  begin
  inherited;
    if Button <> mbLeft then Exit;
    FClicked:= True;
    //MouseState:= bsDown;
    invalidate;
  end;

  inherited;
end;

procedure TCustomLogicControl.DoOnMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not (csDesigning in ComponentState) then
  begin
    inherited;
    FClicked:= False;
    
    if (x>0) and (y>0) and (x<width) and (y<height) then
      if FHotTrack then MouseState:= bsOver
    else
      MouseState:= bsNormal;

    Invalidate;
  end;

  inherited;
end;

procedure TCustomLogicControl.GradientFillRect(Canvas: TCanvas;
  Rect: TRect; StartColor, EndColor: TColor);
var
  Steps: Integer;
  StartR, StartG, StartB, EndR, EndG, EndB: Byte;
  CrrR, CrrG, CrrB: Double;
  IncR, IncG, incB: Double;
  i: integer;
begin
  Steps:= Rect.Bottom - Rect.Top;

  StartR:= GetRValue(StartColor);  EndR:= GetRValue(EndColor);
  StartG:= GetGValue(StartColor);  EndG:= GetGValue(EndColor);
  StartB:= GetBValue(StartColor);  EndB:= GetBValue(EndColor);

  IncR:= (EndR - StartR) / steps;
  IncG:= (EndG - StartG) / steps;
  IncB:= (EndB - StartB) / steps;

  CrrR:= StartR;
  CrrG:= StartG;
  CrrB:= StartB;

  for i:= 0 to Steps do begin
    Canvas.Pen.Color:= RGB(Round(CrrR), Round(CrrG), Round(CrrB));
    Canvas.MoveTo(0, i);
    Canvas.LineTo(Width, i);
    CrrR:= CrrR + IncR;
    CrrG:= CrrG + IncG;
    CrrB:= CrrB + IncB;
  end;
end;

procedure TCustomLogicControl.CMMouseEnter(var Message: TMessage);
begin
  if csDesigning in ComponentState then exit;
  if not FHotTrack then exit;

  if FClicked then
    //MouseState:= bsDown
  else
    MouseState:= bsOver;

  Invalidate;
end;

procedure TCustomLogicControl.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  MouseState:= bsNormal;
  Invalidate;
end;

procedure TCustomLogicControl.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('Connectors', ReadConnectors, WriteConnectors,
    (Connectors.Count > 0));
end;

procedure TCustomLogicControl.WriteConnectors(Writer: TWriter);
var
  i			: integer;
begin
  Writer.WriteListBegin;
  try
    for i := 0 to Connectors.Count-1 do
    begin
      Writer.WriteInteger(ord(TCustomLogicConnector(Connectors[i]).Path));
      Writer.WriteInteger(TCustomLogicConnector(Connectors[i]).Offset);
    end;
  finally
    Writer.WriteListEnd;
  end;
end;

procedure TCustomLogicControl.ReadConnectors(Reader: TReader);
var
  i			: integer;
begin
  Reader.ReadListBegin;
  try
    i := 0;
    while not(Reader.EndOfList) do
    begin
      if (i < Connectors.Count) then
      begin
        TCustomLogicConnector(Connectors[i]).Path := TStatePath(Reader.ReadInteger);
        TCustomLogicConnector(Connectors[i]).Offset := Reader.ReadInteger;
      end else
        Reader.ReadInteger;
      inc(i);
    end;
  finally
    Reader.ReadListEnd;
  end;
end;

procedure TCustomLogicControl.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not(AParent is TCustomLogicPanel) then
    raise Exception.Create(ClassName+' must have a TCustomLogicPanel as parent')
  else
    FStateMachine := TCustomLogicPanel(AParent);
end;

procedure TCustomLogicControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if (FStateMachine <> nil) then
    FStateMachine.Invalidate;
end;

procedure TCustomLogicControl.SetDiagramType(Value: TDiagramType);
begin
  if Value <> FDiagramType then
  begin
    FDiagramType := Value;
    Invalidate;
  end;
end;

procedure TCustomLogicControl.SetRoundSize(Value: integer);
begin
  if Value <> FRoundSize then
  begin
    FRoundSize := Value;
    Invalidate;
  end;
end;

procedure TCustomLogicControl.SetTextFieldHorizontalAlign(
  Value: TIACheckControlTextHAlign);
begin
  if (Value<>FTextFieldHorizontalAlign) then
  begin
    FTextFieldHorizontalAlign := Value;
    //SetProperlyRGN;
    invalidate;
  end;
end;

procedure TCustomLogicControl.SetTextFieldVerticalAlign(
  Value: TIACheckControlTextVAlign);
begin
  if (Value<>FTextFieldVerticalAlign) then
  begin
    FTextFieldVerticalAlign := Value;
    //SetProperlyRGN;
    invalidate;
  end;
end;

procedure TCustomLogicControl.SetText3DStyle(
  Value: TIACheckControlText3DStyle);
begin
  if Value<>FText3DStyle then
  begin
    FText3DStyle := Value;
    invalidate;
  end;
end;

procedure TCustomLogicControl.SetTextAlign(
  Value: TIACheckControlTextHAlign);
begin
  if Value<>FTextAlign then
  begin
    FTextAlign := Value;
    //SetProperlyRGN;
    invalidate;
  end;
end;

procedure TCustomLogicControl.SetColors(Index: integer; Value: TColor);
begin
  case Index of
    0: FColorFace:= Value;
    1: FColorGrad:= Value;
    2: FColorDark:= Value;
    3: FColorLight:= Value;
    4: FColorBorder:= Value;
    5: FColorText:= Value;
    6: FOverColorFace:= Value;
    7: FOverColorGrad:= Value;
    8: FOverColorDark:= Value;
    9: FOverColorLight:= Value;
    10: FOverColorBorder:= Value;
    11: FOverColorText:= Value;
    12: FDownColorFace:= Value;
    13: FDownColorGrad:= Value;
    14: FDownColorDark:= Value;
    15: FDownColorLight:= Value;
    16: FDownColorBorder:= Value;
    17: FDownColorText:= Value;
    18: FDisabledColorFace:= Value;
    19: FDisabledColorGrad:= Value;
    20: FDisabledColorDark:= Value;
    21: FDisabledColorLight:= Value;
    22: FDisabledColorBorder:= Value;
    23: FDisabledColorText:= Value;
    24: FColorFocusRect:= Value;
  end;
  //ColorScheme:= csCustom;
  Invalidate;
end;

procedure TCustomLogicControl.SetColorScheme(Value: TColorScheme);
begin
  FColorScheme:= Value;
  case FColorScheme of
  csDesert:      begin
                   ColorFace:=$0095DDFF;
                   ColorLight:=$00B9E7FF;
                   ColorDark:=$00009CE8;
                   ColorBorder:=$00005680;
                   ColorText:=clBlack;
                   OverColorFace:=$006FD0FF;
                   OverColorLight:=$0095DAFF;
                   OverColorDark:=$00008ED2;
                   OverColorBorder:=$00005680;
                   OverColorText:=clBlack;
                   DownColorFace:=$006FD0FF;
                   DownColorLight:=$000077B7;
                   DownColorDark:=$008AD9FF;
                   DownColorBorder:=$000070A6;
                   DownColorText:=clBlack;
                   DisabledColorFace:=$00E2E2E2;
                   DisabledColorLight:=$00EAEAEA;
                   DisabledColorDark:=$00D8D8D8;
                   DisabledColorBorder:=$00C4C4C4;
                   DisabledColorText:=clGray;
                   ColorFocusRect:= $004080FF;
                   Gradient:= False;
                 end;
  csGrass:       begin
                   ColorFace:=$0098EBB7;
                   ColorLight:=$00CBF5DB;
                   ColorDark:=$0024B95C;
                   ColorBorder:=$00156F37;
                   ColorText:=clBlack;
                   OverColorFace:=$0068E196;
                   OverColorLight:=$00B5F0CB;
                   OverColorDark:=$0023B459;
                   OverColorBorder:=$0017793D;
                   OverColorText:=clBlack;
                   DownColorFace:=$004EDC83;
                   DownColorLight:=$00177D3E;
                   DownColorDark:=$0089E7AC;
                   DownColorBorder:=$00167439;
                   DownColorText:=clBlack;
                   DisabledColorFace:=$00E2E2E2;
                   DisabledColorLight:=$00EAEAEA;
                   DisabledColorDark:=$00D8D8D8;
                   DisabledColorBorder:=$00C4C4C4;
                   DisabledColorText:=clGray;
                   ColorFocusRect:= $0000A421;
                   Gradient:= False;
                 end;
   csSky:        begin
                   ColorFace:=$00FFE0C1;
                   ColorLight:=$00FFECD9;
                   ColorDark:=$00FFA953;
                   ColorBorder:=$00B35900;
                   ColorText:=clBlack;
                   OverColorFace:=$00FFCD9B;
                   OverColorLight:=$00FFE4CA;
                   OverColorDark:=$00FFB164;
                   OverColorBorder:=$00B35900;
                   OverColorText:=clBlack;
                   DownColorFace:=$00FFC082;
                   DownColorLight:=$00FF9122;
                   DownColorDark:=$00FFD3A8;
                   DownColorBorder:=$00B35900;
                   DownColorText:=clBlack;
                   DisabledColorFace:=$00E2E2E2;
                   DisabledColorLight:=$00EAEAEA;
                   DisabledColorDark:=$00D8D8D8;
                   DisabledColorBorder:=$00C4C4C4;
                   DisabledColorText:=clGray;
                   ColorFocusRect:= $00DC9B14;
                   Gradient:= False;
                 end;
   csRose:  begin
                   ColorFace:=$00C6C6FF;
                   ColorLight:=$00DDDDFF;
                   ColorDark:=$008282FF;
                   ColorBorder:=$0000009D;
                   ColorText:=clBlack;
                   OverColorFace:=$00B0B0FF;
                   OverColorLight:=$00D7D7FF;
                   OverColorDark:=$006A6AFF;
                   OverColorBorder:=$0000009D;
                   OverColorText:=clBlack;
                   DownColorFace:=$009F9FFF;
                   DownColorLight:=$005E5EFF;
                   DownColorDark:=$008888FF;
                   DownColorBorder:=$0000009D;
                   DownColorText:=clBlack;
                   DisabledColorFace:=$00E2E2E2;
                   DisabledColorLight:=$00EAEAEA;
                   DisabledColorDark:=$00D8D8D8;
                   DisabledColorBorder:=$00C4C4C4;
                   DisabledColorText:=clGray;
                   ColorFocusRect:= $005E5EFF;
                   Gradient:= False;
                 end;
  csSun:         begin
                   ColorFace:=$00A8FFFF;
                   ColorLight:=$00F2FFFF;
                   ColorDark:=$0000BBBB;
                   ColorBorder:=$00006464;
                   ColorText:=clBlack;
                   OverColorFace:=$0066F3FF;
                   OverColorLight:=$00CCFFFF;
                   OverColorDark:=$0000A6A6;
                   OverColorBorder:=$00006464;
                   OverColorText:=clBlack;
                   DownColorFace:=$0022EEFF;
                   DownColorLight:=$00008484;
                   DownColorDark:=$0066F3FF;
                   DownColorBorder:=$00006464;
                   DownColorText:=clBlack;
                   DisabledColorFace:=$00E2E2E2;
                   DisabledColorLight:=$00EAEAEA;
                   DisabledColorDark:=$00D8D8D8;
                   DisabledColorBorder:=$00C4C4C4;
                   DisabledColorText:=clGray;
                   ColorFocusRect:= $00008CF4;
                   Gradient:= False;
                 end;
  csSilver:      begin
                   ColorFace:=$00E0E0E0;
                   ColorLight:=$00F7F7F7;
                   ColorDark:=$00AEAEAE;
                   ColorBorder:=$00626262;
                   ColorText:=clBlack;
                   OverColorFace:=$00CFCFCF;
                   OverColorLight:=$00EEEEEE;
                   OverColorDark:=$00797979;
                   OverColorBorder:=$00757575;
                   OverColorText:=clBlack;
                   DownColorFace:=$00D3D3D3;
                   DownColorLight:=$007C7C7C;
                   DownColorDark:=$00E9E9E9;
                   DownColorBorder:=$004E4E4E;
                   DownColorText:=clBlack;
                   DisabledColorFace:=$00E2E2E2;
                   DisabledColorLight:=$00EAEAEA;
                   DisabledColorDark:=$00D8D8D8;
                   DisabledColorBorder:=$00C4C4C4;
                   DisabledColorText:=clGray;
                   ColorFocusRect:= $008A8A8A;
                   Gradient:= False;
                 end;

  csNeoDesert:   begin
                   ColorFace:= $00C6ECFF;
                   ColorGrad:= $0037BEFF;
                   ColorLight:= $00B9E7FF;
                   ColorDark:= $00009CE8;
                   ColorBorder:= $00005680;
                   ColorText:= clBlack;
                   OverColorFace:= $00B3E7FF;
                   OverColorGrad:= $0000A3F0;
                   OverColorLight:= $0095DAFF;
                   OverColorDark:= $00008ED2;
                   OverColorBorder:= $00005680;
                   OverColorText:= clBlack;
                   DownColorFace:= $002BBAFF;
                   DownColorGrad:= $0077D2FF;
                   DownColorLight:= $000077B7;
                   DownColorDark:= $008AD9FF;
                   DownColorBorder:= $000070A6;
                   DownColorText:= clBlack;
                   DisabledColorFace:= $00EEEEEE;
                   DisabledColorGrad:= clWhite;
                   DisabledColorLight:= clWhite;
                   DisabledColorDark:= $00D2D2D2;
                   DisabledColorBorder:= clGray;
                   DisabledColorText:= clGray;
                   ColorFocusRect:=  $004080FF;
                   Gradient:= true;
                 end;
  csNeoSky:      begin
                   ColorFace:= $00FFEEDD;
                   ColorGrad:= $00FFB66C;
                   ColorLight:= $00FFECD9;
                   ColorDark:= $00FFA851;
                   ColorBorder:= $00B35900;
                   ColorText:= clBlack;
                   OverColorFace:= $00FFEBD7;
                   OverColorGrad:= $00FFA346;
                   OverColorLight:= $00FFE4CA;
                   OverColorDark:= $00FF9E3E;
                   OverColorBorder:= $00B35900;
                   OverColorText:= clBlack;
                   DownColorFace:= $00FFB366;
                   DownColorGrad:= $00FFCE9D;
                   DownColorLight:= $00FF9E3E;
                   DownColorDark:= $00FFD3A8;
                   DownColorBorder:= $00B35900;
                   DownColorText:= clBlack;
                   DisabledColorFace:= $00EEEEEE;
                   DisabledColorGrad:= clWhite;
                   DisabledColorLight:= clWhite;
                   DisabledColorDark:= $00D2D2D2;
                   DisabledColorBorder:= clGray;
                   DisabledColorText:= clGray;
                   ColorFocusRect:=  $00FFA953;
                   Gradient:= true;
                 end;
  csNeoGrass:    begin
                   ColorFace:= $00DDF9E8;
                   ColorGrad:= $005EDF8E;
                   ColorLight:= $00CBF5DB;
                   ColorDark:= $0024B95C;
                   ColorBorder:= $00156F37;
                   ColorText:= clBlack;
                   OverColorFace:= $00BFF2D2;
                   OverColorGrad:= $003DD877;
                   OverColorLight:= $00B5F0CB;
                   OverColorDark:= $0023B459;
                   OverColorBorder:= $0017793D;
                   OverColorText:= clBlack;
                   DownColorFace:= $004EDC83;
                   DownColorGrad:= $0080E6A6;
                   DownColorLight:= $00177D3E;
                   DownColorDark:= $0089E7AC;
                   DownColorBorder:= $00167439;
                   DownColorText:= clBlack;
                   DisabledColorFace:= $00EEEEEE;
                   DisabledColorGrad:= clWhite;
                   DisabledColorLight:= clWhite;
                   DisabledColorDark:= $00D2D2D2;
                   DisabledColorBorder:= clGray;
                   DisabledColorText:= clGray;
                   ColorFocusRect:=  $0024B95C;
                   Gradient:= true;
                 end;
  csNeoSilver:   begin
                   ColorFace:= $00F3F3F3;
                   ColorGrad:= $00BCBCBC;
                   ColorLight:= $00F7F7F7;
                   ColorDark:= $00A7A7A7;
                   ColorBorder:= $00626262;
                   ColorText:= clBlack;
                   OverColorFace:= $00F0F0F0;
                   OverColorGrad:= $00A6A6A6;
                   OverColorLight:= $00EEEEEE;
                   OverColorDark:= $00A2A2A2;
                   OverColorBorder:= $00757575;
                   OverColorText:= clBlack;
                   DownColorFace:= $00CACACA;
                   DownColorGrad:= $00DADADA;
                   DownColorLight:= $007C7C7C;
                   DownColorDark:= $00E9E9E9;
                   DownColorBorder:= $004E4E4E;
                   DownColorText:= clBlack;
                   DisabledColorFace:= $00EEEEEE;
                   DisabledColorGrad:= clWhite;
                   DisabledColorLight:= clWhite;
                   DisabledColorDark:= $00D2D2D2;
                   DisabledColorBorder:= clGray;
                   DisabledColorText:= clGray;
                   ColorFocusRect:=  $00ADADAD;
                   Gradient:= true;
                 end;
  csNeoRose:     begin
                   ColorFace:= $00E8E8FF;
                   ColorGrad:= $009595FF;
                   ColorLight:= $00DDDDFF;
                   ColorDark:= $008282FF;
                   ColorBorder:= $0000009D;
                   ColorText:= clBlack;
                   OverColorFace:= $00DFDFFF;
                   OverColorGrad:= $007777FF;
                   OverColorLight:= $00D7D7FF;
                   OverColorDark:= $006A6AFF;
                   OverColorBorder:= $0000009D;
                   OverColorText:= clBlack;
                   DownColorFace:= $00A6A6FF;
                   DownColorGrad:= $00B9B9FF;
                   DownColorLight:= $005E5EFF;
                   DownColorDark:= $00CECEFF;
                   DownColorBorder:= $0000009D;
                   DownColorText:= clBlack;
                   DisabledColorFace:= $00EEEEEE;
                   DisabledColorGrad:= clWhite;
                   DisabledColorLight:= clWhite;
                   DisabledColorDark:= $00D2D2D2;
                   DisabledColorBorder:= clGray;
                   DisabledColorText:= clGray;
                   ColorFocusRect:=  $005E5EFF;
                   Gradient:= true;
                 end;
  csNeoSun:      begin
                   ColorFace:= $00F0FFFF;
                   ColorGrad:= $0020D8F9;
                   ColorLight:= $00F2FFFF;
                   ColorDark:= $0000BBBB;
                   ColorBorder:= $00006464;
                   ColorText:= clBlack;
                   OverColorFace:= $00D5FCFF;
                   OverColorGrad:= $0005BCDC;
                   OverColorLight:= $00CCFFFF;
                   OverColorDark:= $0000A6A6;
                   OverColorBorder:= $00006464;
                   OverColorText:= clBlack;
                   DownColorFace:= $0005D1F5;
                   DownColorGrad:= $0066F0FB;
                   DownColorLight:= $00008484;
                   DownColorDark:= $0066F3FF;
                   DownColorBorder:= $00006464;
                   DownColorText:= clBlack;
                   DisabledColorFace:= $00EEEEEE;
                   DisabledColorGrad:= clWhite;
                   DisabledColorLight:= clWhite;
                   DisabledColorDark:= $00D2D2D2;
                   DisabledColorBorder:= clGray;
                   DisabledColorText:= clGray;
                   ColorFocusRect:=  $0000BBBB;
                   Gradient:= true;
                 end;
  end;
  Invalidate;
  FColorScheme:= Value;
end;

procedure TCustomLogicControl.SetGradient(Value: Boolean);
begin
  FGradient:= Value;
  Invalidate;
end;

procedure TCustomLogicControl.SetMouseState(Value: TMouseState);
begin
  //if FMouseState <> Value then
  //begin
    FMouseState := Value;

    case FMouseState of
      bsNormal: begin
                  FFaceColor:= FColorFace;
                  FGradColor:= FColorGrad;
                  FLightColor:= FColorLight;
                  FDarkColor:= FColorDark;
                  FBorderColor:= FColorBorder;
                  FTextColor:= FColorText;
                end;

      bsOver:   begin
                  FFaceColor:= FOverColorFace;
                  FGradColor:= FOverColorGrad;
                  FLightColor:= FOverColorLight;
                  FDarkColor:= FOverColorDark;
                  FBorderColor:= FOverColorBorder;
                  FTextColor:= FOverColorText;
                end;

      bsDown:   begin
                  FFaceColor:= FDownColorFace;
                  FGradColor:= FDownColorGrad;
                  FLightColor:= FDownColorLight;
                  FDarkColor:= FDownColorDark;
                  FBorderColor:= FDownColorBorder;
                  FTextColor:= FDownColorText;
                end;
    end;//case
  //end;//if
end;

//procedure TCustomLogicControl.CMTextChanged(var msg: TMessage);
//begin
//  Invalidate;
//end;

procedure TCustomLogicControl.Click;
begin
  //if (FStateMachine <> nil) then
  //  FStateMachine.ChangeState(self);
end;

function TCustomLogicControl.GetCheckStateMachine: TCustomLogicPanel;
begin
  if (FStateMachine = nil) then
    raise Exception.Create('Orphan '+ClassName);
  Result := FStateMachine;
end;

procedure TCustomLogicControl.SetHint(Value: string);
begin
  inherited Hint := Value;
  invalidate;
end;

function TCustomLogicControl.GetHint: string;
begin
  Result := inherited Hint;
end;

procedure TCustomLogicControl.SetText(Value: TStringList);
begin
  if FText <> Value then begin
    FText.Assign(Value);
    invalidate;
    //inv;
  end;
  //if Caption <> Value then
  //  Caption := Value;
  //invalidate;
end;

procedure TCustomLogicControl.SetActive(Value: boolean);
begin
  if not(Value) then
    CheckStateMachine.State := nil
  else
    CheckStateMachine.State := self;
end;

function TCustomLogicControl.GetActive: boolean;
begin
  Result := (CheckStateMachine.State = self);
end;

procedure TCustomLogicControl.PrepareCanvas(Element: TVisualElement; Canvas: TCanvas);
begin
  with Canvas do
  begin
    case (Element) of
      veShadow:
        begin
          Pen.Width := 1;
          Pen.Color := clGray;
          Pen.Style := psSolid;
          Pen.Mode := pmCopy;
          Brush.Style := bsSolid;
          Brush.Color := clGray;
        end;
      veFrame:
        begin
          //Pen.Style:= psSolid;
          Pen.Color:= FBorderColor;
          Pen.Style := psInsideFrame;
          Pen.Mode := pmCopy;
          if (Active) then
            Pen.Width := 2
          else
            Pen.Width := 1;
        end;
      vePanel:
        begin
          Brush.Style := bsSolid;
          //Brush.Style:= bsClear;
          if (Active) then
            Brush.Color := clRed
          else
            Brush.Color:= FFaceColor;
        end;
      veText:
        begin
          Brush.Style := bsClear;
          if (Active) then
            Font.Color := clWhite
          else
            Font.Color := clBlack;
        end;
      veConnector:
        begin
          Pen.Width := 1;
          Pen.Color := clBlack;
        end;
    end;
  end;//with
end;

procedure TCustomLogicControl.DrawText(TextRect: TRect; ACanvas: TCanvas);
var
  ABase,AOffset,ACurrOffset : TSize;
  i	: integer;
  DC,LC : TColor;
begin
  ABase:=GetBasis;
  AOffset:=GetOffset;
  LC:=GetCColor(Color,clWhite,100,30);
  DC:=GetCColor(Color,clBlack,100,30);
  ABase.cx := ClientWidth div 2 - (ABase.cx);
  ABase.cy := ClientHeight div 2 - (ABase.cy);

  with ACanvas do
  begin
    for i:=0 to FText.Count-1 do
    begin
      ACurrOffset:=GetCurrOffset(i);
      font.Assign(Font);

      case FText3DStyle of
        iscct3dsSimple :
          begin
            Font.Color:=Font.Color;

            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx,ABase.cy+AOffset.Cy+ACurrOffset.cy,FText[i]);
          end;
        iscct3dsUp :
          begin
            Font.Color:=DC;
            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx+1,ABase.cy+AOffset.Cy+ACurrOffset.cy+1,FText[i]);
            Font.Color:=LC;
            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx-1,ABase.cy+AOffset.Cy+ACurrOffset.cy-1,FText[i]);
            Font.Color:=Font.Color;

            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx,ABase.cy+AOffset.Cy+ACurrOffset.cy,FText[i]);
          end;
        iscct3dsDown :
          begin
            Font.Color:=LC;
            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx+1,ABase.cy+AOffset.Cy+ACurrOffset.cy+1,FText[i]);
            Font.Color:=DC;
            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx-1,ABase.cy+AOffset.Cy+ACurrOffset.cy-1,FText[i]);
            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx,ABase.cy+AOffset.Cy+ACurrOffset.cy,FText[i]);
            Font.Color:=Font.Color;

            TextOut(ABase.Cx+AOffset.Cx+ACurrOffset.cx,ABase.cy+AOffset.Cy+ACurrOffset.cy,FText[i]);
          end;
      end;

    end;
  end;//with
end;

procedure TCustomLogicControl.DoPaint;
var
  r: TRect;
  i,j,k: integer;
  rgn0,rgn1,rgn2,rgn3,rgn4 :Hrgn;
begin
  //LBmp:= TBitmap.Create;
  //LBmp.Width:= Width;
  //LBmp.Height:= Height;
  //LBmp.Transparent := True;
  r.TopLeft :=  Point(0,0);
  r.BottomRight := Point(Width, Height);

  // Draw rectangle
  PrepareCanvas(veFrame, Canvas);
  PrepareCanvas(vePanel, Canvas);
  //OffsetRect(r, -ShadowHeight, -ShadowHeight);

  with r, Canvas do
//  with r do
  begin
    case FDiagramType of
      dtStart, dtStop:
        begin
          RoundRect(Left, Top, Right, Bottom, FRoundSize, FRoundSize);
          //Pen.Color:= FLightColor;
          //MoveTo(1, Right-2);
          //LineTo(1, 1);
          //LineTo(Width -1 , 1);
          //RoundRect(Left+1, Top, Right, Bottom-2, FRoundSize, FRoundSize);
          //Pen.Color:= FDarkColor;
          //RoundRect(Left, Top+1, Right-2, Bottom-2, FRoundSize, FRoundSize);
        end;
      dtDelay:
        begin
          //k := Left - ShadowConst;
          //j := Right - ShadowConst;
          rgn0 := CreateEllipticRgn(Left, Top, Right, Bottom);
          rgn1 := CreateEllipticRgn(Left, Top, Right, Bottom);
          i := Round(Width div 2);
          rgn2 := CreateRectRgn(Left + i, Top, Right, Bottom);
          combineRgn(rgn0,rgn1,rgn2,RGN_And);
          rgn3 := CreateRectRgn(Left, Top, Right, Bottom);
          rgn4 := CreateRectRgn(Left, Top, Right - i + 2, Bottom);
          combineRgn(rgn3,rgn4,rgn0,RGN_OR);
          FillRgn(Handle,rgn3,Brush.Handle);
          FrameRgn(Handle, rgn3, Pen.Handle,Pen.Width, Pen.Width);
          DeleteObject(rgn4);
          DeleteObject(rgn3);
          DeleteObject(rgn2);
          DeleteObject(rgn1);
          DeleteObject(rgn0);
        end;
      else
      begin
        Rectangle(Left, Top, Right, Bottom);

        if FGradient then
          GradientFillRect(Canvas, Rect(0, 0, Width, Height), FFaceColor, FGradColor);

        Pen.Color:= FLightColor;
        MoveTo(1, Height-2);
        LineTo(1, 1);
        LineTo(Width -1 , 1);

        Pen.Color:= FDarkColor;
        MoveTo(Width-2, 1);
        LineTo(Width-2, Height-2);
        LineTo(1, Height-2);
      end;
    end;//case
  end;//with

  // Draw name
  PrepareCanvas(veText, Canvas);
  // Margin for text
  InflateRect(r, Canvas.Pen.Width, Canvas.Pen.Width);
  DrawText(r, Canvas);

  if FShowLabelBmp then
    Canvas.Draw(2, 2, FLabelBmp);
//  if LBmp.Handle > 0 then
//  begin
//    DC := GetDC(canvas.Handle);
//    BitBlt(DC, 0, 0, 50,50,LBmp.Canvas.Handle,0,0,SrcPAINT);
//    ReleaseDC(0, DC);
//  end;


//  Canvas.Draw(0, 0, LBmp);
//  LBmp.Free;
end;

procedure TCustomLogicControl.PaintConnector;
begin
  PrepareCanvas(veConnector, StateMachine.Canvas);
end;

procedure TCustomLogicControl.Paint;
var
  Painting: Boolean;	// To avoide recursion by accidentally calling
  				// inherited Paint in overloaded DoPaint
begin
  Painting := False;

  if (Painting) then
    raise Exception.Create('Recursion detected in TCustomLogicControl.Paint');
  Painting := True;
  try
    inherited Paint;
    DoPaint;
    PaintConnector;
    // StateMachine.Canvas.Pen.Width := 1;
  finally
    Painting := False;
  end;
end;

procedure TCustomLogicControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = self) and (FStateMachine <> nil) then
    StateMachine.Invalidate;
end;

procedure TCustomLogicControl.DoOnEnter;
begin
  Application.ProcessMessages;
end;

procedure TCustomLogicControl.DoOnExit;
begin
  // Nothing to do here
end;

procedure TCustomLogicControl.DoOnReset;
begin
  // Nothing to do here
end;

function TCustomLogicControl.DoDefault: Boolean;
begin
  Result := False;
end;

procedure TCustomLogicControl.CheckTransition(Transition: TCustomLogicControl; Direction: TTransitionDirection);
begin
  if (self = nil) then
    raise Exception.Create('nil State');
end;

function TCustomLogicControl.HitTest(Mouse: TPoint): TCustomLogicConnector;
begin
  Result := nil;
end;

function TCustomLogicControl.GetBasis: TSize;
var S1 : TSize;
begin
  S1:=GetTextSize;

  case FTextFieldVerticalAlign of
    iacctvaTop :
      begin
        case FTextFieldHorizontalAlign of
          iaccthaLeft :
            begin
              result.cx:=s1.cx;
              result.cy:=0;
            end;
          iaccthaRight :
            begin
              result.cx:=0;
              result.cy:=0;
            end;
          iaccthaCenter :
            begin
              result.cx:=Max(0,s1.cx div 2);
              result.cy:=s1.cy;
            end;
        end;
      end;
    iacctvaBottom :
      begin
        case FTextFieldHorizontalAlign of
          iaccthaLeft :
            begin
              result.cx:=s1.cx;
              result.cy:=Max(0,s1.cy);
            end;
          iaccthaRight :
            begin
              result.cx:=0;
              result.cy:=Max(0,s1.cy);
            end;
          iaccthaCenter :
            begin
              result.cx:=Max(0,(s1.cx) div 2);
              result.cy:=0;
            end;
        end;
      end;
    iacctvaCenter :
      begin
        result.cy := s1.cy div 2;

        case FTextFieldHorizontalAlign of
          iaccthaLeft :
            begin
              result.cx:=s1.cx;
            end;
          iaccthaRight :
            begin
              result.cx:=0;
            end;
          iaccthaCenter :
            begin
              result.cx:=s1.cx div 2;
            end;
         end;
      end;
  end;
end;

function TCustomLogicControl.GetCurrOffset(i: Integer): TSize;
var s1,s2 : TSize;
    j,dx,dy, Oldcy  : integer;
    s : string;
begin
  if i<=(FText.Count-1) then
  begin
    dx:=0;dy:=0;Oldcy:=0;
    s2:=GetTextSize;
    for j:=0 to i do
    begin
      s:=FText.Strings[j];
      if s = '' then
        s1.cy := Oldcy
      else
      begin
        Canvas.Font.Assign(Font);
        GetTextExtentPoint32(Canvas.Handle,PChar(@s[1]),length(s),s1);
        Oldcy := s1.cy;
      end;
      
      if j<>i then
      begin
        dy:=dy+s1.cy;
      end
      else
      begin
        case TextAlign of
          iaccthaLeft :
          begin
            dx:=0;
          end;
          iaccthaRight :
          begin
            dx:=s2.cx-s1.cx;
          end;
          iaccthaCenter :
          begin
            dx:=(s2.cx-s1.cx) div 2;
          end;
        end;
      end;

    end;//for

    Result.cx:=dx;
    Result.cy:=dy;
  end
  else
  begin
    Result.cx:=0;
    Result.cy:=0;
  end;
end;

function TCustomLogicControl.GetFullSize: TSize;
begin
  result := GetTextSize;
end;

function TCustomLogicControl.GetOffset: TSize;
begin
  Result.cx := 0;
  Result.cy := 0;
end;

function TCustomLogicControl.GetTextSize: TSize;
var i, Oldcy : integer;
    s : string;
    S1 : TSize;
begin
  result.cx:=0;
  result.cy:=0;
  Oldcy := 0;
  for i:=0 to FText.Count-1 do
  begin
    s:=FText.Strings[i];
    if s = '' then
      Result.cy := Result.cy + Oldcy
    else
    begin
      Canvas.Font.Assign(Font);
      GetTextExtentPoint32(Canvas.Handle,PChar(@s[1]),length(s),s1);
      Oldcy := s1.cy;
      if result.cx<s1.cx then result.cx:=s1.cx;
      result.cy:=result.cy+s1.cy;
    end;
  end;
end;


//******************************************************************************
//**
//**			TCustomLogicNodeBase
//**
//******************************************************************************
procedure TCustomLogicNodeBase.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);

  // First state will be used as default
  //if (StateMachine <> nil) and (StateMachine.State = nil) then
  //  StateMachine.State := self;
end;

//******************************************************************************
//**
//**			TCustomLogicNode
//**
//******************************************************************************
constructor TCustomLogicNode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DiagramType := dtDefault;
  FToConnector := AddConnector(poOwnedBySource);
  FIsInitialize := False;
//  ControlStyle := [csCaptureMouse, { csOpaque, } csDoubleClicks];
end;

destructor TCustomLogicNode.Destroy;
begin
  FToConnector.Free;
  inherited Destroy;
end;

procedure TCustomLogicNode.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  FToConnector.Offset := 0;
end;

procedure TCustomLogicNode.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = FDefaultTransition) then
    begin
      FDefaultTransition := nil;
      FToConnector.Destination := nil;
    end;
  end;
end;

procedure TCustomLogicNode.PaintConnector;
begin
  inherited PaintConnector;
  StateMachine.Canvas.Pen.Width := 2;
  FToConnector.Paint;
end;

function TCustomLogicNode.HitTest(Mouse: TPoint): TCustomLogicConnector;
begin
  Result := nil;
  if (FToConnector.HitTest(Mouse)) then
    Result := FToConnector;
end;

procedure TCustomLogicNode.PrepareCanvas(Element: TVisualElement; Canvas: TCanvas);
begin
  inherited PrepareCanvas(Element, Canvas);
  if (Element = veText) and
    not(Assigned(OnEnterState) or (csDesigning in ComponentState)) then
    Canvas.Font.Color := clGray;
end;

procedure TCustomLogicNode.SetDefaultTransition(Value: TCustomLogicControl);
begin
  FDefaultTransition := Value;
  FToConnector.Destination := Value;
  if (FStateMachine <> nil) then
    StateMachine.Invalidate;
end;

// NextState is obsolete!
procedure TCustomLogicNode.SetNextState(Value :TCustomLogicControl);
begin
  if not(csLoading in ComponentState) then
    ShowMessage('The NextState property is obsolete!'+#13+'Use DefaultTransition instead');
  // Only assign value if non-nil
  if (Value <> nil) then
    FDefaultTransition := Value;
end;

procedure TCustomLogicNode.DoOnEnter;
begin
  inherited;
  
  Sleep(FBeforeDelay);

  if (Assigned(FOnEnterState)) then
    FOnEnterState(self);

  Sleep(FAfterDelay);
end;

procedure TCustomLogicNode.DoOnExit;
begin
  if (Assigned(FOnExitState)) then
    FOnExitState(self);
end;

function TCustomLogicNode.DoDefault: Boolean;
begin
  Result := True;
  if Assigned(FDefaultTransition) then
    StateMachine.ChangeState(FDefaultTransition)
  else
    Result := False;
end;

//******************************************************************************
//**
//**			TCustomLogicStart
//**
//******************************************************************************
constructor TCustomLogicStart.Create(AOwner: TComponent);
begin
  inherited;
  DiagramType := dtStart;
  Text.Add('����');
end;

procedure TCustomLogicStart.PrepareCanvas(Element: TVisualElement; Canvas: TCanvas);
begin
  inherited PrepareCanvas(Element, Canvas);
  case (Element) of
    veText:
      Canvas.Font.Style := [fsBold];
    veFrame:
      Canvas.Pen.Color := FBorderColor;
  end;
end;

//******************************************************************************
//**
//**			TCustomLogicStop
//**
//******************************************************************************
constructor TCustomLogicStop.Create(AOwner: TComponent);
begin
  inherited;
  DiagramType := dtStop;
  Text.Add('��');
end;

procedure TCustomLogicStop.PrepareCanvas(Element: TVisualElement; Canvas: TCanvas);
begin
  inherited PrepareCanvas(Element, Canvas);
  case (Element) of
    veText:
      Canvas.Font.Style := [fsBold];
    veFrame:
      Canvas.Pen.Color := clRed;
  end;
end;

//******************************************************************************
//**
//**			TCustomLogicBoolean
//**
//******************************************************************************
constructor TCustomLogicBoolean.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FOwner := TForm(AOwner);
  FDefault := True;
  FTrueConnector := AddConnector(poOwnedBySource);
  FFalseConnector := AddConnector(poOwnedBySource);

end;

destructor TCustomLogicBoolean.Destroy;
begin

  FTrueConnector.Free;
  FFalseConnector.Free;

  inherited Destroy;
end;

procedure TCustomLogicBoolean.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  FTrueConnector.Offset := 0;
  FFalseConnector.Offset := 0;
end;

procedure TCustomLogicBoolean.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = FTrueState) then
    begin
      FTrueState := nil;
      FTrueConnector.Destination := nil;
    end;
    if (AComponent = FFalseState) then
    begin
      FFalseState := nil;
      FFalseConnector.Destination := nil;
    end;
  end;
end;

procedure TCustomLogicBoolean.PaintConnector;
begin
  inherited PaintConnector;
  if (DefaultState) then
    StateMachine.Canvas.Pen.Width := 2
  else
    StateMachine.Canvas.Pen.Width := 1;
  StateMachine.Canvas.Pen.Color := clGreen;
  FTrueConnector.Paint;

  if not(DefaultState) then
    StateMachine.Canvas.Pen.Width := 2
  else
    StateMachine.Canvas.Pen.Width := 1;
  StateMachine.Canvas.Pen.Color := clRed;
  FFalseConnector.Paint;
end;

function TCustomLogicBoolean.HitTest(Mouse: TPoint): TCustomLogicConnector;
begin
  Result := nil;
  if (FTrueConnector.HitTest(Mouse)) then
    Result := FTrueConnector
  else if (FFalseConnector.HitTest(Mouse)) then
    Result := FFalseConnector;
end;

//draw smooth lines in my apps like photoshop
{procedure TCustomLogicBoolean.AALine(x1, y1, x2, y2: single; color: tcolor);
  function CrossFadeColor(FromColor,ToColor : TColor; Rate : Single) : TColor;
  var r,g,b : byte;
  begin
    r:=Round(GetRValue(FromColor)*Rate+GetRValue(ToColor)*(1-Rate));
    g:=Round(GetGValue(FromColor)*Rate+GetGValue(ToColor)*(1-Rate));
    b:=Round(GetBValue(FromColor)*Rate+GetBValue(ToColor)*(1-Rate));
    Result:=RGB(r,g,b);
  end;

  procedure hpixel(x : single; y : integer);
  var FadeRate : single;
  begin
    FadeRate:=x-trunc(x);
    with canvas do
    begin
      pixels[trunc(x),y]:=CrossFadeColor(Color,Pixels[Trunc(x),y],1-FadeRate);
      pixels[trunc(x)+1,y]:=CrossFadeColor(Color,Pixels[Trunc(x)+1,y],FadeRate);
    end;
  end;

  procedure vpixel(x : integer; y : single);
  var FadeRate : single;
  begin
    FadeRate:=y-trunc(y);
    with canvas do
    begin
      pixels[x,trunc(y)]:=CrossFadeColor(Color,Pixels[x,Trunc(y)],1-FadeRate);
      pixels[x,trunc(y)+1]:=CrossFadeColor(Color,Pixels[x,Trunc(y)+1],FadeRate);
    end;
  end;

var i : integer;
    ly,lx,currentx,currenty,deltax,deltay,l,skipl : single;
begin
  if (x1<>x2) or (y1<>y2) then
  begin
    currentx:=x1;
    currenty:=y1;
    lx:=abs(x2-x1);
    ly:=abs(y2-y1);

    if lx>ly then
    begin
      l:=trunc(lx);
      deltay:=(y2-y1)/l;
      if x1>x2 then
      begin
        deltax:=-1;
        skipl:=(currentx-trunc(currentx));
      end else
      begin
        deltax:=1;
        skipl:=1-(currentx-trunc(currentx));
      end;
    end else
    begin
      l:=trunc(ly);
      deltax:=(x2-x1)/l;
      if y1>y2 then
      begin
        deltay:=-1;
        skipl:=(currenty-trunc(currenty));
      end else
      begin
        deltay:=1;
        skipl:=1-(currenty-trunc(currenty));
      end;
    end;

    currentx:=currentx+deltax*skipl;
    currenty:=currenty+deltay*skipl;{}

{    for i:=1 to trunc(l) do
    begin
      if lx>ly then
        vpixel(trunc(currentx),currenty)
      else
        hpixel(currentx,trunc(currenty));

      currentx:=currentx+deltax;
      currenty:=currenty+deltay;
    end;
  end;
end;

procedure TCustomLogicBoolean.PolyLine(Arr: array of TPoint);
var
  J,K : integer;
begin
  K := Length(Arr);

  for J := 0 to K-2 do
    AALine(Arr[j].X, Arr[j].Y, Arr[j+1].X, Arr[j+1].Y, FBorderColor);

  //������ ���� �ϳ� �� �׷��� ������ �ϼ���
  AALine(Arr[j].X, Arr[j].Y, Arr[0].X, Arr[0].Y, FBorderColor)

end;
}
procedure TCustomLogicBoolean.PrepareCanvas(Element: TVisualElement; Canvas: TCanvas);
begin
  inherited PrepareCanvas(Element, Canvas);
  case (Element) of
    veText:
      if not(Assigned(OnEnterState) or (csDesigning in ComponentState)) then
        Canvas.Font.Color := clGray;
    veShadow:
      Canvas.Pen.Color := clBlack;
  end;
end;

procedure TCustomLogicBoolean.DoPaint;
var
  r			: TRect;
  Diamond		: array[0..7] of TPoint;
  LBmp: TBitmap32;
  Polygon: TPolygon32;
begin
  // Draw shadow
  //PrepareCanvas(veShadow, Canvas);
  // Draw rectangle
  LBmp:= TBitmap32.Create;
  LBmp.Width:= Width;
  LBmp.Height:= Height;
  Polygon := TPolygon32.Create;
  Polygon.Antialiased := True;
  Polygon.FillMode := pfAlternate;

  PrepareCanvas(veFrame, Canvas);
  PrepareCanvas(vePanel, Canvas);
  r := Rect(Width DIV 7, Height DIV 7,Width-(Width DIV 7), Height-(Height DIV 7));

  Polygon.Add(FixedPoint(0, Height DIV 2));
  Polygon.Add(FixedPoint(r.left, r.top));
  Polygon.Add(FixedPoint(Width DIV 2, 0));
  Polygon.Add(FixedPoint(r.right, r.top));
  Polygon.Add(FixedPoint(Width-1, Height DIV 2));
  Polygon.Add(FixedPoint(r.right, r.bottom));
  Polygon.Add(FixedPoint(Width DIV 2, Height-1));
  Polygon.Add(FixedPoint(r.left, r.bottom));

  r := BoundsRect;

  LBmp.Canvas.CopyRect(LBmp.BoundsRect, FOwner.Canvas, r);

  Polygon.DrawFill(LBmp, Color32(Canvas.Brush.Color));//SetAlpha(Canvas.Brush.Color, 255));
  Polygon.DrawEdge(LBmp, Color32(Canvas.Pen.Color));//SetAlpha(Canvas.Pen.Color, 255));
{
  Diamond[0] := Point(0, Height DIV 2);
  Diamond[1] := Point(r.left, r.top);
  Diamond[2] := Point(Width DIV 2, 0);
  Diamond[3] := Point(r.right, r.top);
  Diamond[4] := Point(Width-1, Height DIV 2);
  Diamond[5] := Point(r.right, r.bottom);
  Diamond[6] := Point(Width DIV 2, Height-1);
  Diamond[7] := Point(r.left, r.bottom);
}

  //Canvas.Polygon(Diamond);
  // Draw rectangle
  //PrepareCanvas(veFrame, Canvas);
  //PrepareCanvas(vePanel, Canvas);
  //Canvas.Rectangle(r.left, r.top, r.right, r.bottom);
  // Draw name
  //Canvas.Draw(0, 0, LBmp);
  LBmp.DrawTo(Canvas.Handle,0,0);
  Polygon.Free;
  LBmp.Free;

  if FShowLabelBmp then
    Canvas.Draw(2, 2, FLabelBmp);

  PrepareCanvas(veText, Canvas);
  InflateRect(r, -Canvas.Pen.Width, -Canvas.Pen.Width);
  DrawText(r, canvas);
end;

 procedure TCustomLogicBoolean.SetTrueState(Value :TCustomLogicControl);
begin
  FTrueState := Value;
  FTrueConnector.Destination := Value;
  // True and False should not be the same
  if (Value <> nil) and (FFalseState = Value) and
                                            (csDesigning in ComponentState) then
  begin
    ShowMessage('TrueStep and FalseStep should not be the same');
    //FTrueState := nil;
    //exit;
  end;

  if (FStateMachine <> nil) then
    StateMachine.Invalidate;
end;

procedure TCustomLogicBoolean.SetFalseState(Value :TCustomLogicControl);
begin
  FFalseState := Value;
  FFalseConnector.Destination := Value;
  // True and False should not be the same
  if (Value <> nil) and (FtrueState = Value) and
                                            (csDesigning in ComponentState) then
  begin
    ShowMessage('TrueStep and FalseStep should not be the same');
    //FFalseState := nil;
    //exit;
  end;

  if (FStateMachine <> nil) then
    StateMachine.Invalidate;
end;

procedure TCustomLogicBoolean.SetDefault(Value :Boolean);
begin
  if (Value <> FDefault) then
  begin
    FDefault := Value;
    StateMachine.Invalidate; // To erase previous fat line
    // Invalidate;
  end;
end;

procedure TCustomLogicBoolean.DoOnEnter;
begin
  Sleep(FBeforeDelay);

  FResult := FDefault;
  if (Assigned(FOnEnterState)) then
  begin
    FOnEnterState(self, FResult);
    if not(StateMachine.StateChanged) then
    begin
      if (FResult) and (Assigned(FTrueState)) then
        StateMachine.ChangeState(FTrueState)
      else if (not FResult) and (Assigned(FFalseState)) then
        StateMachine.ChangeState(FFalseState);
    end;
  end;

  Sleep(FAfterDelay);
end;

procedure TCustomLogicBoolean.DoOnExit;
begin
  if (Assigned(FOnExitState)) then
    FOnExitState(self);
end;

function TCustomLogicBoolean.DoDefault: Boolean;
begin
  Result := True;
  if (DefaultState) and (Assigned(FTrueState)) then
    StateMachine.ChangeState(FTrueState)
  else if (not DefaultState) and (Assigned(FFalseState)) then
    StateMachine.ChangeState(FFalseState)
  else
    Result := False;
end;

//******************************************************************************
//**
//**			TCustomLogicTransition
//**
//******************************************************************************
constructor TCustomLogicTransition.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FToConnector := AddConnector(poOwnedBySource);
  FFromConnector := AddConnector(poOwnedByDestination);
  SetBounds(0, 0, 89, 41);
end;

destructor TCustomLogicTransition.Destroy;
begin
  FFromState := nil;
  FFromConnector.Free;
  FToState := nil;
  FToConnector.Free;
  inherited Destroy;
end;

procedure TCustomLogicTransition.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
end;

procedure TCustomLogicTransition.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  FToConnector.Offset := 0;
  FFromConnector.Offset := 0;
end;

procedure TCustomLogicTransition.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FFromState = AComponent) then
    begin
      FFromState := nil;
      FFromConnector.Source := nil;
    end;
    if (FToState = AComponent) then
    begin
      FToState := nil;
      FToConnector.Destination := nil;
    end;
  end;
end;

procedure TCustomLogicTransition.PaintConnector;
begin
  inherited PaintConnector;
  StateMachine.Canvas.Pen.Width := 1;
  FFromConnector.Paint;
  FToConnector.Paint;
end;

function TCustomLogicTransition.HitTest(Mouse: TPoint): TCustomLogicConnector;
begin
  Result := nil;
  if (FToConnector.HitTest(Mouse)) then
    Result := FToConnector
  else
    if (FFromConnector.HitTest(Mouse)) then
      Result := FFromConnector;
end;

procedure TCustomLogicTransition.PrepareCanvas(Element: TVisualElement; Canvas: TCanvas);
begin
  inherited PrepareCanvas(Element, Canvas);
  case (Element) of
    veText:
      if not((Assigned(FFromState)) and (Assigned(FToState)) or
        (csDesigning in ComponentState)) then
        Canvas.Font.Color := clGray;
  end;
end;

procedure TCustomLogicTransition.DoPaint;
var
  RoundSize		: integer;
  r			: TRect;
begin
  RoundSize := 16;
  if (Height < RoundSize) then
    RoundSize := Height;
  if (Width < RoundSize) then
    RoundSize := Width;

  // Draw shadow
  PrepareCanvas(veShadow, Canvas);
  Canvas.RoundRect(ShadowHeight,ShadowHeight, Width, Height, RoundSize,RoundSize);
  // Draw rectangle
  PrepareCanvas(veFrame, Canvas);
  PrepareCanvas(vePanel, Canvas);
  Canvas.RoundRect(0,0, Width-ShadowHeight,Height-ShadowHeight, RoundSize,RoundSize);
  // Draw name
  PrepareCanvas(veText, Canvas);
  r := Rect(ShadowHeight+1,ShadowHeight+1,Width-(Canvas.Pen.Width+1), Height-(Canvas.Pen.Width+1));
  DrawText(r, Canvas);
end;

procedure TCustomLogicTransition.SetFromState(Value :TCustomLogicControl);
begin
  if (Value <>  nil) and (Value.StateMachine <> CheckStateMachine) then
    raise Exception.Create('Cannot link to state in other state machine');
  FFromState := Value;
  FFromConnector.Source := Value;
  if (FStateMachine <> nil) then
    StateMachine.Invalidate;
end;

procedure TCustomLogicTransition.SetToState(Value :TCustomLogicControl);
begin
  if (Value <>  nil) and (Value.StateMachine <> CheckStateMachine) then
    raise Exception.Create('Cannot link to state in other state machine');
  FToState := Value;
  FToConnector.Destination := Value;
  if (FStateMachine <> nil) then
    StateMachine.Invalidate;
end;

procedure TCustomLogicTransition.DoOnEnter;
begin
  if (Assigned(FOnTransition)) then
    FOnTransition(self);
end;

function TCustomLogicTransition.DoDefault: Boolean;
begin
  Result := True;
  if Assigned(ToStep) then
    StateMachine.ChangeState(ToStep)
  else
    Result := False;
end;

procedure TCustomLogicTransition.CheckTransition(Transition: TCustomLogicControl; Direction: TTransitionDirection);
begin
  inherited CheckTransition(Transition, Direction);
  if (Direction = tdTo) and Assigned(FFromState) and (Transition <> FFromState) then
    raise Exception.Create('FromState does not match');
  if (Direction = tdFrom) and Assigned(FToState) and (Transition <> FToState) then
    raise Exception.Create('ToState does not match');
end;

//******************************************************************************
//**
//**			TCustomLogicLink
//**
//******************************************************************************
constructor TCustomLogicLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDirection := ldOutgoing;
  FConnector := AddConnector(poOwnedBySource);
  SetBounds(0, 0, 41, 41);
end;

destructor TCustomLogicLink.Destroy;
begin
  FConnector.Free;
  FDestination := nil;
  inherited Destroy;
end;

procedure TCustomLogicLink.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
end;

procedure TCustomLogicLink.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if (AWidth <> Width) then
    AHeight := AWidth
  else if (AHeight <> Height) then
    AWidth := AHeight;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  FConnector.Offset := 0;
end;

procedure TCustomLogicLink.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FDestination = AComponent) then
    begin
      if (Direction = ldOutgoing) then
        FConnector.Destination := nil;
      FDestination := nil;
    end;
  end;
end;

procedure TCustomLogicLink.PaintConnector;
begin
  inherited PaintConnector;
  FConnector.Paint;
end;

function TCustomLogicLink.HitTest(Mouse: TPoint): TCustomLogicConnector;
begin
  Result := nil;
  if (FConnector.HitTest(Mouse)) then
    Result := FConnector;
end;

procedure TCustomLogicLink.PrepareCanvas(Element: TVisualElement; Canvas: TCanvas);
begin
  inherited PrepareCanvas(Element, Canvas);
  case (Element) of
    veText:
      if not(Assigned(FDestination) or (csDesigning in ComponentState)) then
        Canvas.Font.Color := clGray;
  end;
end;

procedure TCustomLogicLink.DoPaint;
var
  r			: TRect;
begin
  // Draw shadow
  PrepareCanvas(veShadow, Canvas);
  r.TopLeft :=  Point(ShadowHeight,ShadowHeight);
  r.BottomRight := Point(Width, Height);
  Canvas.Ellipse(r.Left, r.Top, r.Right, r.Bottom);
  // Draw rectangle
  PrepareCanvas(veFrame, Canvas);
  PrepareCanvas(vePanel, Canvas);
  OffsetRect(r, -r.Left, -r.Top);
  Canvas.Ellipse(r.Left, r.Top, r.Right, r.Bottom);
  // Draw name
  PrepareCanvas(veText, Canvas);
  // Margin for text
  InflateRect(r, -Canvas.Pen.Width, -Canvas.Pen.Width);
  DrawText(r, Canvas);
end;

procedure TCustomLogicLink.SetDestination(Value :TCustomLogicControl);
begin
  if (Value <>  nil) and (Value.StateMachine <> CheckStateMachine) then
    raise Exception.Create('Cannot connect to node in other state machine');

  if (Value = Self) then
    raise Exception.Create('Cannot connect link to self');

  FDestination := Value;

  if (Value <>  nil) then
  begin
    if (Value is TCustomLogicLink) then
    begin
      FDirection := ldOutgoing;
      FConnector.Destination := nil;
    end else
    begin
      FDirection := ldIncoming;
      FConnector.Destination := Value;
    end;

    FConnector.Paint;
  end;
  StateMachine.Invalidate;
end;

procedure TCustomLogicLink.SetDirection(Value :TLinkDirection);
begin
  if (Value <> FDirection) then
  begin
    FDirection := Value;
    NextStep := nil;
    StateMachine.Invalidate;
  end;
end;

procedure TCustomLogicLink.CheckTransition(Transition: TCustomLogicControl; Direction: TTransitionDirection);
begin
  inherited CheckTransition(Transition, Direction);
  if (Direction = tdTo) and
  (((FDirection = ldOutgoing) and (Transition is TCustomLogicLink)) or
   ((FDirection = ldIncoming) and not(Transition is TCustomLogicLink))) then
    raise Exception.Create('Direction and previous state type is illegal');

  if (Direction = tdFrom) and
  (((FDirection = ldOutgoing) and not(Transition is TCustomLogicLink)) or
   ((FDirection = ldIncoming) and (Transition is TCustomLogicLink))) then
    raise Exception.Create('Direction and next state type is illegal');
end;

function TCustomLogicLink.DoDefault: Boolean;
begin
  Result := True;
  if Assigned(NextStep) then
    StateMachine.ChangeState(NextStep)
  else
    Result := False;
end;

procedure TCustomLogicConnector.CreateInit(AOwner:TCustomLogicControl;AOwnerRole: TStatePathOwner);
begin
  FOwner := AOwnerRole;
  if (FOwner = poOwnedBySource) then
    FSource := AOwner
  else
    FDestination := AOwner;
  FPath := spAuto;
  FActualPath := FPath;

end;

end.
