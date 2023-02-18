unit pjhiMotor_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  iMotor_smh, pjhclasses, pjhDesignCompIntf, pjhPipeFlowInterface, pjhxIOCompConst;

type
  TpjhiMotor_pjh = class(TiMotor_smh, IpjhDesignCompInterface, IpjhPipeFlowInterface)
  protected
    //For IpjhDesignCompInterface
    FpjhTagInfo: TpjhTagInfo;
    FpjhValue: string;
    FpjhBplFileName: string;

    function GetpjhValue: string;
    procedure SetpjhValue(AValue: string);
    function GetpjhTagInfo: TpjhTagInfo;
    procedure SetpjhTagInfo(AValue: TpjhTagInfo);
    function GetBplFileName: string;
    procedure SetBplFileName(AValue: string);
    //For IpjhDesignCompInterface
    procedure iDoubleClick; override;
  public
    constructor Create(AOwner: TComponent);  override;
    destructor  Destroy;                     override;

    //For IpjhPipeFlowInterface ====>
    function SetNextStepAuto(ADestComponent: TComponent): Boolean;
    function DeleteNextStep(AWillDeleteComponent: TComponent): Boolean;
    function ClearXStep: Boolean;
    function GetXStepNameListWithComma: string;
    function GetNextStepListWithComma: string;
    //For IpjhPipeFlowInterface <====
  published
    //For IpjhDesignCompInterface
    property pjhTagInfo: TpjhTagInfo read GetpjhTagInfo write SetpjhTagInfo;
    property pjhValue: string read GetpjhValue write SetpjhValue;
    property pjhBplFileName: string read GetBplFileName write SetBplFileName;
    //For IpjhDesignCompInterface
  end;

implementation

uses UnitJHCustomComponent;

{ TpjhiMotor }

function TpjhiMotor_pjh.ClearXStep: Boolean;
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

constructor TpjhiMotor_pjh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhxIOCompBplFileName;
end;

function TpjhiMotor_pjh.DeleteNextStep(
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

destructor TpjhiMotor_pjh.Destroy;
begin
  FpjhTagInfo.Free;
  inherited;
end;


function TpjhiMotor_pjh.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhiMotor_pjh.GetNextStepListWithComma: string;
begin
  Result := '';

  if Assigned(NextStep) then
    Result := NextStep.Name;

  if Assigned(NextStep2) then
    Result := Result + ',' + NextStep2.Name;
end;

function TpjhiMotor_pjh.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhiMotor_pjh.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

function TpjhiMotor_pjh.GetXStepNameListWithComma: string;
begin
  Result := 'NextStep,NextStep2,PrevStep,PrevStep2';
end;

procedure TpjhiMotor_pjh.iDoubleClick;
begin
  inherited;

  FpjhValue := IntToStr(Ord(FanOn));
end;

procedure TpjhiMotor_pjh.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

function TpjhiMotor_pjh.SetNextStepAuto(ADestComponent: TComponent): Boolean;
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

procedure TpjhiMotor_pjh.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhiMotor_pjh.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;
    FanOn := StrToBool(AValue);
  end;
end;

end.

