unit pjhiValve2_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  Vcl.Graphics, iTypes, UnitGPFunction, iValve_smh, pjhPipeFlowInterface,
  pjhclasses, pjhDesignCompIntf, pjhxIOCompConst, pjhiValve_pjh;

type
  TValveKnobPosition = (vdTop, vdBottom, vdLeft, vdRight);
  TValveWayKind = (vwk2Way, vwk3Way, vwk3To2Way);
  {
     |\  /|
   1 | \/ | 2
     |/ \ |
       3
  }
  TValveFlow = (vf1_2, vf1_3, vf1_23, vf2_1, vf2_3, vf2_13, vf3_1, vf3_2, vf3_12);

  TpjhiValve2_pjh = class(TpjhiValve_pjh, IpjhDesignCompInterface, IpjhPipeFlowInterface)
  protected
    FValveKnobPosition: TValveKnobPosition;
    FValveWayKind: TValveWayKind;
    FValveFlow: TValveFlow;
    //For IpjhDesignCompInterface ===>
    FpjhTagInfo: TpjhTagInfo;
    FpjhValue: string;
    FpjhBplFileName: string;
    FShowFocusFadeInOut,
    FHideKnob: Boolean;

    function GetpjhValue: string;
    procedure SetpjhValue(AValue: string);
    function GetpjhTagInfo: TpjhTagInfo;
    procedure SetpjhTagInfo(AValue: TpjhTagInfo);
    function GetBplFileName: string;
    procedure SetBplFileName(AValue: string);
    //For IpjhDesignCompInterface <===

    procedure iDoubleClick; override;

    procedure SetValveKnobPosition(const Value: TValveKnobPosition);
    procedure SetValveWayKind(const Value: TValveWayKind);
    procedure SetValveFlow(const Value: TValveFlow);
    procedure SetShowFocus(const Value: Boolean);

    procedure DrawVertical  (Canvas: TCanvas); override;
    procedure DrawHorizontal(Canvas: TCanvas); override;

    function GetBodyColorFromWay(AWay: integer; ADefaultColor: TColor): TColor;
  public
    constructor Create(AOwner: TComponent);  override;
    destructor  Destroy;                     override;

    //For IpjhPipeFlowInterface ====>
    function SetNextStepAuto(ADestComponent: TComponent): Boolean;
    function DeleteNextStep(AWillDeleteComponent: TComponent): Boolean;
    function ClearXStep: Boolean;
    //For IpjhPipeFlowInterface <====
  published
    //For IpjhDesignCompInterface
    property pjhTagInfo: TpjhTagInfo read GetpjhTagInfo write SetpjhTagInfo;
    property pjhValue: string read GetpjhValue write SetpjhValue;
    property pjhBplFileName: string read GetBplFileName write SetBplFileName;
    //For IpjhDesignCompInterface

    //Orientation을 변경하지 말고 ValveKnobPosition을 변경하여 밸브를 회전 시켜야 함.
    property ValveKnobPosition: TValveKnobPosition read FValveKnobPosition write SetValveKnobPosition;
    property ValveWayKind : TValveWayKind read FValveWayKind write SetValveWayKind;
    property ValveFlow : TValveFlow read FValveFlow write SetValveFlow;
    property ShowFocus : Boolean read FShowFocusFadeInOut write SetShowFocus;
    property HideKnob : Boolean read FHideKnob write FHideKnob;
  end;

implementation

uses UnitJHCustomComponent;

{ TpjhiValve }

function TpjhiValve2_pjh.ClearXStep: Boolean;
begin
  Result := False;

  if Assigned(PrevStep) then
  begin
    PrevStep := nil;
    Result := True;
  end;

  if Assigned(PrevStep2) then
  begin
    PrevStep2 := nil;
    Result := True;
  end;

  if Assigned(NextStep) then
  begin
    NextStep := nil;
    Result := True;
  end;

  if Assigned(NextStep2) then
  begin
    NextStep2 := nil;
    Result := True;
  end;
end;

constructor TpjhiValve2_pjh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhxIOCompBplFileName;
end;

function TpjhiValve2_pjh.DeleteNextStep(
  AWillDeleteComponent: TComponent): Boolean;
begin
  Result := False;

  if Assigned(NextStep) then
  begin
    if NextStep.Name = AWillDeleteComponent.Name then
    begin
      NextStep := nil;
      Result := True;
    end;
  end;

  if Assigned(NextStep2) then
  begin
    if NextStep2.Name = AWillDeleteComponent.Name then
    begin
      NextStep2 := nil;
      Result := True;
    end;
  end;
end;

destructor TpjhiValve2_pjh.Destroy;
begin
  FpjhTagInfo.Free;
  inherited;
end;


procedure TpjhiValve2_pjh.DrawHorizontal(Canvas: TCanvas);
var
  DrawRect   : TRect;
  BodyMidX   : Integer;
  BodyMidY   : Integer;
  BodyTop    : Integer;

  StemLeft   : Integer;
  StemRight  : Integer;
  StemTop    : Integer;
  StemBottom : Integer;

  KnobRadius : Integer;
  KnobRect   : TRect;

  KnobColor  : TColor;
  LBodyColor : TColor;
begin
  DrawRect := Rect(0, 0, Self.Width - 1, Self.Height -1);

  with Canvas, DrawRect do
  begin
    DrawBackGround(Canvas, BackGroundColor);

    BodyMidX   := Self.Width div 2;

    if FHideKnob then
    begin
      BodyTop    := 0;//Self.Height;
      BodyMidY   := Self.Height div 2;
    end
    else
    begin
      BodyTop    := Self.Height div 2;
      KnobRadius := Self.Width div 4;

      if FValveKnobPosition = vdTop then
      begin
        BodyMidY   := (Self.Height div 4)*3;
        KnobRect   := Rect(BodyMidX - KnobRadius, Top, BodyMidX + KnobRadius, 2*KnobRadius);
        StemLeft   := BodyMidX - 2;
        StemRight  := BodyMidX + 2;
        StemTop    := KnobRadius;
        StemBottom := BodyMidY;
      end
      else
      if FValveKnobPosition = vdBottom then
      begin
        BodyMidY   := Self.Height div 4;
        KnobRect   := Rect(BodyMidX - KnobRadius, Bottom - (2*KnobRadius), BodyMidX + KnobRadius, Bottom);
        StemLeft   := BodyMidX - 2;
        StemRight  := BodyMidX + 2;
        StemTop    := BodyMidY;
        StemBottom := Bottom - (KnobRadius);
      end;
    end;

    if Opened then KnobColor := OpenedColor else KnobColor := ClosedColor;

    if not FHideKnob then
      DrawValveKnob(Canvas, BackGroundColor, KnobColor, KnobRect, False, Ord(ValveKind));

    Brush.Style := bsSolid;
    Brush.Color := BackGroundColor;
    Pen.Style   := psClear;

    if not FHideKnob then
    begin
      if FValveKnobPosition = vdTop then
        KnobRect.Top := KnobRadius
      else
      if FValveKnobPosition = vdBottom then
        KnobRect.Bottom := Bottom - KnobRadius;

      FillRect(KnobRect);
      Rectangle(StemLeft, StemTop, StemRight, StemBottom);
    end;

    if ChangeBodyColor then Brush.Color := KnobColor else Brush.Color := clBtnFace;

    LBodyColor := Brush.Color;

    //Draw Body
    if FValveKnobPosition = vdTop then
    begin
      //Way 1
      Brush.Color := GetBodyColorFromWay(1, LBodyColor);
      Polygon([Point(Left,  BodyTop), Point(Left,  Bottom), Point(BodyMidX, BodyMidY)]); //Left Body
      //Way2
      Brush.Color := GetBodyColorFromWay(2, LBodyColor);
      Polygon([Point(Right, BodyTop), Point(Right, Bottom), Point(BodyMidX, BodyMidY)]); //Right Body

      //Way3
      if (FValveWayKind = vwk3Way) or (FValveWayKind = vwk3To2Way) then
      begin
        Brush.Color := GetBodyColorFromWay(3, LBodyColor);
        Polygon([Point(Left+7,   Bottom), Point(Right-7, Bottom), Point(BodyMidX, BodyMidY)]); //Bottom Body
      end;
    end
    else
    if FValveKnobPosition = vdBottom then
    begin
      //Way 1
      Brush.Color := GetBodyColorFromWay(1, LBodyColor);
      Polygon([Point(Left, Top), Point(Left, BodyTop), Point(BodyMidX, BodyMidY)]); //Left Body
      //Way2
      Brush.Color := GetBodyColorFromWay(2, LBodyColor);
      Polygon([Point(Right, Top), Point(Right, BodyTop), Point(BodyMidX, BodyMidY)]); //Right Body

      //Way3
      if (FValveWayKind = vwk3Way) or (FValveWayKind = vwk3To2Way) then
      begin
        Brush.Color := GetBodyColorFromWay(3, LBodyColor);
        Polygon([Point(Left+7, Top), Point(Right-7, Top), Point(BodyMidX, BodyMidY)]); //Bottom Body
      end;
    end;

    Pen.Style := psSolid;
    Pen.Color := clWhite;
    Line(Canvas, BodyMidX, BodyMidY, Right, BodyTop);

    if FValveKnobPosition = vdTop then
    begin
      Line(Canvas, Left, BodyTop, Left, Bottom);
      Line(Canvas, Left, BodyTop, BodyMidX, BodyMidY);

      Pen.Color := clGray;
      Line(Canvas, Left, Bottom, BodyMidX, BodyMidY);
      Line(Canvas, BodyMidX, BodyMidY, Right, Bottom);

      Pen.Color := clBlack;
      Line(Canvas, Right, Bottom, Right, BodyTop);
      Line(Canvas, StemRight, StemTop, StemRight, StemBottom);
    end
    else
    if FValveKnobPosition = vdBottom then
    begin
      Line(Canvas, Right, BodyTop, Right, Top);
      Line(Canvas, Right, BodyTop, BodyMidX, BodyMidY);

      Pen.Color := clGray;
      Line(Canvas, Right, Top, BodyMidX, BodyMidY);
      Line(Canvas, BodyMidX, BodyMidY, Left, Top);

      Pen.Color := clBlack;
      Line(Canvas, Left, Top, Left, BodyTop);
      Line(Canvas, StemRight, StemTop, StemRight, StemBottom);
    end;

    Line(Canvas, StemLeft, StemTop, StemLeft, StemBottom);
  end;
end;

procedure TpjhiValve2_pjh.DrawVertical(Canvas: TCanvas);
var
  DrawRect   : TRect;
  BodyMidX   : Integer;
  BodyMidY   : Integer;
  BodyTop    : Integer;

  StemLeft   : Integer;
  StemRight  : Integer;
  StemTop    : Integer;
  StemBottom : Integer;

  KnobRadius : Integer;
  KnobRect   : TRect;

  KnobColor,
  LBodyColor : TColor;
begin
  DrawRect := Rect(0, 0, Width - 1, Height -1);

  with Canvas, DrawRect do
  begin
    DrawBackGround(Canvas, BackGroundColor);

    BodyMidY   := Self.Height div 2;

    if FHideKnob then
    begin
      BodyTop    := 0;//Self.Width;
      BodyMidX   := Self.Width div 2;
    end
    else
    begin
      BodyTop    := Self.Width div 2;
      KnobRadius := Self.Height div 4;

      if FValveKnobPosition = vdLeft then
      begin
        BodyMidX   := (Self.Width div 4)*3;
        KnobRect   := Rect(Left, BodyMidY - KnobRadius, 2*KnobRadius, BodyMidY + KnobRadius);
        StemLeft   := KnobRadius;
        StemRight  := BodyMidX;
        StemTop    := BodyMidY - 2;
        StemBottom := BodyMidY + 2;
      end
      else
      if FValveKnobPosition = vdRight then
      begin
        BodyMidX   := (Self.Width div 4);
        KnobRect   := Rect(Right-(2*KnobRadius), BodyMidY - KnobRadius, Right, BodyMidY + KnobRadius);
        StemLeft   := BodyMidX;
        StemRight  := Right - KnobRadius;
        StemTop    := BodyMidY - 2;
        StemBottom := BodyMidY + 2;
      end;
    end;

    if Opened then KnobColor := OpenedColor else KnobColor := ClosedColor;

      //Valve 손잡이 그리기
    if not FHideKnob then
      DrawValveKnob(Canvas, BackGroundColor, KnobColor, KnobRect, False);

    Brush.Style := bsSolid;
    Brush.Color := BackGroundColor;
    Pen.Style   := psClear;

    if not FHideKnob then
    begin
      if FValveKnobPosition = vdLeft then
        KnobRect.Left := KnobRadius
      else
      if FValveKnobPosition = vdRight then
        KnobRect.Right := Right - KnobRadius;

      FillRect(KnobRect);
      Rectangle(StemLeft, StemTop, StemRight, StemBottom);
    end;

    if ChangeBodyColor then Brush.Color := KnobColor else Brush.Color := clBtnFace;

    LBodyColor := Brush.Color;

    //Draw Body
    if FValveKnobPosition = vdLeft then
    begin
      //Way 1
      Brush.Color := GetBodyColorFromWay(1, LBodyColor);
      Polygon([Point(BodyMidX,  BodyMidY), Point(BodyTop,  Top   ), Point(Right, Top   )]);
      //Way2
      Brush.Color := GetBodyColorFromWay(2, LBodyColor);
      Polygon([Point(BodyMidX,  BodyMidY), Point(BodyTop,  Bottom), Point(Right, Bottom)]);
      //Way3
      if (FValveWayKind = vwk3Way) or (FValveWayKind = vwk3To2Way) then
      begin
        Brush.Color := GetBodyColorFromWay(3, LBodyColor);
        Polygon([Point(BodyMidX,  BodyMidY), Point(Right+7,  Top   ), Point(Right+7, Bottom)]);
      end;
    end
    else
    if FValveKnobPosition = vdRight then
    begin
      //Way 1
      Brush.Color := GetBodyColorFromWay(1, LBodyColor);
      Polygon([Point(BodyMidX,  BodyMidY), Point(BodyTop,  Top   ), Point(Left, Top   )]);
      //Way2
      Brush.Color := GetBodyColorFromWay(2, LBodyColor);
      Polygon([Point(BodyMidX,  BodyMidY), Point(BodyTop,  Bottom), Point(Left, Bottom)]);

      //Way3
      if (FValveWayKind = vwk3Way) or (FValveWayKind = vwk3To2Way) then
      begin
        Brush.Color := GetBodyColorFromWay(3, LBodyColor);
        Polygon([Point(BodyMidX,  BodyMidY), Point(Left-7,  Top   ), Point(Left-7, Bottom)]);
      end;
    end;

    Pen.Style := psSolid;
    Pen.Color := clWhite;
    Line(Canvas, BodyMidX, BodyMidY, BodyTop,  Bottom);
    Line(Canvas, BodyMidX, BodyMidY, BodyTop,  Top);

    if FValveKnobPosition = vdLeft then
      Line(Canvas, BodyTop,  Top,      Right, Top)
    else
    if FValveKnobPosition = vdRight then
      Line(Canvas, BodyTop,  Top,      Left, Top);

    Line(Canvas, StemLeft, StemTop, StemRight, StemTop);

    Pen.Color := clGray;

    if FValveKnobPosition = vdLeft then
    begin
      Line(Canvas, BodyMidX, BodyMidY, Right, Bottom);
      Line(Canvas, BodyMidX, BodyMidY, Right, Top);
    end
    else
    if FValveKnobPosition = vdRight then
    begin
      Line(Canvas, BodyMidX, BodyMidY, Left, Bottom);
      Line(Canvas, BodyMidX, BodyMidY, Left, Top);
    end;

    Pen.Color := clBlack;

    if FValveKnobPosition = vdLeft then
    begin
      Line(Canvas, BodyTop, Bottom, Right, Bottom);
    end
    else
    if FValveKnobPosition = vdRight then
    begin
      Line(Canvas, BodyTop, Bottom, Left, Bottom);
    end;

    Line(Canvas, StemLeft, StemBottom, StemRight, StemBottom);
  end;
end;

function TpjhiValve2_pjh.GetBodyColorFromWay(AWay: integer; ADefaultColor: TColor): TColor;
begin
//    vf1_2, vf1_3, vf1_23, vf2_1, vf2_3, vf2_13, vf3_1, vf3_2, vf3_12

  Result := ADefaultColor;

  case AWay of
    1: begin
      if FValveWayKind = vwk3To2Way then
        if (FValveFlow = vf2_3) or (FValveFlow = vf3_2) then
          Result := ClosedColor;
    end;

    2: begin
      if FValveWayKind = vwk3To2Way then
        if (FValveFlow = vf1_3) or (FValveFlow = vf3_1) then
          Result := ClosedColor;
    end;

    3: begin
      if FValveWayKind = vwk3To2Way then
        if (FValveFlow = vf1_2) or (FValveFlow = vf2_1) then
          Result := ClosedColor;
    end;
  end;
end;

function TpjhiValve2_pjh.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhiValve2_pjh.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhiValve2_pjh.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

procedure TpjhiValve2_pjh.iDoubleClick;
begin
  inherited;

  FpjhValue := IntToStr(Ord(Opened));
end;

procedure TpjhiValve2_pjh.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

function TpjhiValve2_pjh.SetNextStepAuto(ADestComponent: TComponent): Boolean;
var
  LDestComp: TJHCustomComponent;
begin
  Result := False;
  LDestComp := ADestComponent as TJHCustomComponent;

  if LDestComp.CheckAutoNextStep(Self) then
  begin
    if not Assigned(NextStep) then
    begin
      NextStep := LDestComp;
      Result := True;;
    end
    else
    if not Assigned(NextStep2) then
    begin
      NextStep2 := LDestComp;
      Result := True;
    end;
  end
end;

procedure TpjhiValve2_pjh.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhiValve2_pjh.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;
    Opened := StrToBool(AValue);
  end;
end;

procedure TpjhiValve2_pjh.SetShowFocus(const Value: Boolean);
begin

end;

procedure TpjhiValve2_pjh.SetValveKnobPosition(const Value: TValveKnobPosition);
begin
  if FValveKnobPosition <> Value then
  begin
//    if Orientation = ioHorizontal then
//    begin
      if (Value = vdTop) or (Value = vdBottom) then
      begin
        FValveKnobPosition := Value;
        Orientation := ioHorizontal;
      end;
//    end
//    else
//    if Orientation = ioVertical then
//    begin
      if (Value = vdLeft) or (Value = vdRight) then
      begin
        FValveKnobPosition := Value;
        Orientation := ioVertical;
      end;
//    end;
    InvalidateChange;
  end;
end;

procedure TpjhiValve2_pjh.SetValveFlow(const Value: TValveFlow);
begin
  if FValveFlow <> Value then
  begin
    case FValveWayKind of
      vwk3To2Way: begin
        if (Value = vf1_2) or (Value = vf1_3) or (Value = vf2_1) or
          (Value = vf2_3) or (Value = vf3_1) or (Value = vf3_2) then
        begin
          FValveFlow := Value;
          InvalidateChange;
        end;
      end;

      else //vwk3Way,
      begin
        if (Value = vf1_23) or (Value = vf2_13) or (Value = vf3_12) then
        begin
          FValveFlow := Value;
          InvalidateChange;
        end;
      end;
    end;
  end;
end;

procedure TpjhiValve2_pjh.SetValveWayKind(const Value: TValveWayKind);
begin
  if FValveWayKind <> Value then
  begin
    FValveWayKind := Value;
    InvalidateChange;
  end;
end;

end.
