unit pjhTCyBevel;

interface

uses SysUtils, Classes, Windows, Messages, Graphics, Controls, Forms,
  pjhclasses, pjhDesignCompIntf, pjhCyCompConst,
  cyBevel, VCL.cyClasses, VCL.cyTypes, TimerPool;

type
  TpjhTCyBevelShapeType = (stRectangle,stEllipse);// stSquare, stRoundRect, stRoundSquare,, stCircle, stTriangle, stStar, stLine

  TpjhTCyBevel = class(cyBevel.TcyBevel, IpjhDesignCompInterface)
  private
    FPJHTimerPool: TPJHTimerPool;
    FPJHTimerHandle: integer;

    FBevelOffColor: TColor;

    procedure ProcessBlink(ACyBevel: VCL.cyClasses.TCyBevel);
    procedure OnBlink(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
    procedure OnCreateFunc(Sender : TObject; Handle : Integer;
            Interval : Cardinal; ElapsedTime : LongInt);
  protected
    //For IpjhDesignCompInterface
    FpjhTagInfo: TpjhTagInfo;
    FpjhValue: string;
    FpjhBplFileName: string;
    //For IpjhDesignCompInterface

    FBevelColor: TColor;
    FBevelWidth: integer;
    FBevelStyle: TcyBevelCut;
    FBlink: Boolean;
    FBlinkTimeInterval: integer;
    FBevelShapeType: TpjhTCyBevelShapeType;

    procedure Paint; override;
    procedure PaintEllipse;

    //For IpjhDesignCompInterface
    function GetpjhValue: string;
    procedure SetpjhValue(AValue: string); virtual;
    function GetpjhTagInfo: TpjhTagInfo;
    procedure SetpjhTagInfo(AValue: TpjhTagInfo);
    function GetBplFileName: string;
    procedure SetBplFileName(AValue: string);
    //For IpjhDesignCompInterface

    function GetBevelColor: TColor;
    procedure SetBevelColor(AValue: TColor); virtual;
    function GetBevelOffColor: TColor;
    procedure SetBevelOffColor(AValue: TColor); virtual;
    function GetBevelWidth: integer;
    procedure SetBevelWidth(AValue: integer); virtual;
    function GetBevelStyle: TcyBevelCut;
    procedure SetBevelStyle(AValue: TcyBevelCut); virtual;
    function GetBlink: Boolean;
    procedure SetBlink(AValue: Boolean); virtual;
    function GetBlinkTimeInterval: integer;
    procedure SetBlinkTimeInterval(AValue: integer); virtual;
    function GetBevelShapeType: TpjhTCyBevelShapeType;
    procedure SetBevelShapeType(AValue: TpjhTCyBevelShapeType); virtual;
  public
    constructor Create(AOwner: TComponent);  override;
    destructor  Destroy;override;

    procedure SetBevelProperty(ACyBevel: VCL.cyClasses.TCyBevel);
  published
    //For IpjhDesignCompInterface
    property pjhTagInfo: TpjhTagInfo read GetpjhTagInfo write SetpjhTagInfo;
    property pjhValue: string read GetpjhValue write SetpjhValue;
    property pjhBplFileName: string read GetBplFileName write SetBplFileName;
    //For IpjhDesignCompInterface

    property BevelColor: TColor read GetBevelColor write SetBevelColor;
    property BevelOffColor: TColor read GetBevelOffColor write SetBevelOffColor;
    property BevelWidth: integer read GetBevelWidth write SetBevelWidth;
    property BevelStyle: TcyBevelCut read GetBevelStyle write SetBevelStyle;
    property Blink: Boolean read GetBlink write SetBlink;
    property BlinkTimeInterval: integer read GetBlinkTimeInterval write SetBlinkTimeInterval;
    property BevelShapeType: TpjhTCyBevelShapeType read GetBevelShapeType write SetBevelShapeType;
  end;

implementation

{ TpjhTCyBevel }

constructor TpjhTCyBevel.Create(AOwner: TComponent);
begin
  inherited;

  FPJHTimerPool := TPJHTimerPool.Create(Self);
  FBlinkTimeInterval := 1000;
  FPJHTimerHandle := 0;
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhCyCompBplFileName;

  FBevelColor := clRed;
  FBevelOffColor := clBtnHighlight;
  FBevelWidth := 2;
  FBevelStyle := bcRaised;

//  if Bevels.Count > 0 then
//    SetBevelProperty(Bevels[0])
//  else
    FPJHTimerPool.AddOneShot(OnCreateFunc, 500);
end;

destructor TpjhTCyBevel.Destroy;
begin
  FpjhTagInfo.Free;
  FPJHTimerPool.RemoveAll;
  FPJHTimerPool.Free;

  inherited;
end;

function TpjhTCyBevel.GetBevelColor: TColor;
begin
  Result := FBevelColor;
end;

function TpjhTCyBevel.GetBevelOffColor: TColor;
begin
  Result := FBevelOffColor;
end;

function TpjhTCyBevel.GetBevelShapeType: TpjhTCyBevelShapeType;
begin
  Result := FBevelShapeType;
end;

function TpjhTCyBevel.GetBevelStyle: TcyBevelCut;
begin
  Result := FBevelStyle;
end;

function TpjhTCyBevel.GetBevelWidth: integer;
begin
  Result := FBevelWidth;
end;

function TpjhTCyBevel.GetBlink: Boolean;
begin
  Result := FBlink;
end;

function TpjhTCyBevel.GetBlinkTimeInterval: integer;
begin
  Result := FBlinkTimeInterval;
end;

function TpjhTCyBevel.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhTCyBevel.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhTCyBevel.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

procedure TpjhTCyBevel.OnBlink(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  ProcessBlink(Bevels[0]);
end;

procedure TpjhTCyBevel.OnCreateFunc(Sender: TObject; Handle: Integer;
  Interval: Cardinal; ElapsedTime: Integer);
begin
  SetBevelProperty(Bevels[0]);
end;

procedure TpjhTCyBevel.Paint;
begin
  case FBevelShapeType of
    stRectangle: inherited;
//    stSquare: ;
//    stRoundRect: ;
//    stRoundSquare: ;
    stEllipse: PaintEllipse;
//    stCircle: ;
//    stTriangle: ;
//    stStar: ;
//    stLine: ;
  end
end;

procedure TpjhTCyBevel.PaintEllipse;
var Rect: TRect;
begin
  Rect := ClientRect;
  Bevels.DrawBevels(Canvas, Rect, false);

  if csDesigning in ComponentState
  then
    if Bevels.Count = 0
    then
      with Canvas do
      begin
        Pen.Style := psDash;
        Brush.Style := bsClear;
        Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
      end;

  if Assigned(OnPaint)
  then OnPaint(Self);
end;

procedure TpjhTCyBevel.ProcessBlink(ACyBevel: VCL.cyClasses.TCyBevel);
begin
  if not Visible then
    exit;

  if ACyBevel.HighlightColor = FBevelColor then
  begin
    ACyBevel.HighlightColor := FBevelOffColor;
    ACyBevel.ShadowColor := FBevelOffColor;
  end
  else
  begin
    ACyBevel.HighlightColor := FBevelColor;
    ACyBevel.ShadowColor := FBevelColor;
  end;
end;

procedure TpjhTCyBevel.SetBevelProperty(ACyBevel: VCL.cyClasses.TCyBevel);
begin
  ACyBevel.HighlightColor := FBevelColor;
  ACyBevel.ShadowColor := FBevelColor;

  ACyBevel.Width := FBevelWidth;
  ACyBevel.Style := FBevelStyle;
end;

procedure TpjhTCyBevel.SetBevelColor(AValue: TColor);
begin
  if FBevelColor <> AValue then
  begin
    FBevelColor := AValue;
    SetBevelProperty(Bevels[0]);
  end;
end;

procedure TpjhTCyBevel.SetBevelOffColor(AValue: TColor);
begin
  if FBevelOffColor <> AValue then
  begin
    FBevelOffColor := AValue;
  end;
end;

procedure TpjhTCyBevel.SetBevelShapeType(AValue: TpjhTCyBevelShapeType);
begin
  if FBevelShapeType <> AValue then
  begin
    FBevelShapeType := AValue;
  end;
end;

procedure TpjhTCyBevel.SetBevelStyle(AValue: TcyBevelCut);
begin
  if FBevelStyle <> AValue then
  begin
    FBevelStyle := AValue;
    SetBevelProperty(Bevels[0]);
  end;
end;

procedure TpjhTCyBevel.SetBevelWidth(AValue: integer);
begin
  if FBevelWidth <> AValue then
  begin
    FBevelWidth := AValue;
    SetBevelProperty(Bevels[0]);
  end;
end;

procedure TpjhTCyBevel.SetBlink(AValue: Boolean);
begin
  if FBlink <> AValue then
  begin
    FBlink := AValue;

    if FPJHTimerHandle > 0 then
      FPJHTimerPool.Enabled[FPJHTimerHandle] := AValue
    else
      FPJHTimerHandle := FPJHTimerPool.Add(OnBlink, FBlinkTimeInterval);
  end;
end;

procedure TpjhTCyBevel.SetBlinkTimeInterval(AValue: integer);
begin
  if FBlinkTimeInterval <> AValue then
  begin
    FBlinkTimeInterval := AValue;
  end;
end;

procedure TpjhTCyBevel.SetBplFileName(AValue: string);
begin
  if FpjhBplFileName <> AValue then
  begin
    FpjhBplFileName := AValue;
  end;
end;

procedure TpjhTCyBevel.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhTCyBevel.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;

    Visible := AValue = '1';
  end;
end;

end.
