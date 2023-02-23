unit pjhiTank_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  iTank_smh, pjhclasses, pjhDesignCompIntf, pjhPipeFlowInterface, pjhxIOCompConst;

type
  TpjhiTank_pjh = class(TiTank_smh, IpjhDesignCompInterface, IpjhPipeFlowInterface)
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
    function GetPrevStepListWithComma: string;
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

{ TpjhiTank }

function TpjhiTank_pjh.ClearXStep: Boolean;
begin
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

  if Assigned(NextStep3) then
  begin
    NextStep3 := nil;
    Result := True;
  end;
end;

constructor TpjhiTank_pjh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhxIOCompBplFileName;
end;

function TpjhiTank_pjh.DeleteNextStep(
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

  if Assigned(NextStep3) then
  begin
    if NextStep3.Name = AWillDeleteComponent.Name then
    begin
      NextStep3 := nil;
      Result := True;
    end;
  end;
end;

destructor TpjhiTank_pjh.Destroy;
begin
  FpjhTagInfo.Free;
  inherited;
end;


function TpjhiTank_pjh.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhiTank_pjh.GetNextStepListWithComma: string;
begin
  Result := '';

  if Assigned(NextStep) then
    Result := NextStep.Name;

  if Assigned(NextStep2) then
    Result := Result + ',' + NextStep2.Name;
end;

function TpjhiTank_pjh.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhiTank_pjh.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

function TpjhiTank_pjh.GetPrevStepListWithComma: string;
begin
  Result := '';
end;

function TpjhiTank_pjh.GetXStepNameListWithComma: string;
begin
  Result := 'NextStep,NextStep2,NextStep3';
end;

procedure TpjhiTank_pjh.iDoubleClick;
begin
  inherited;

  pjhValue := IntToStr(Ord(Opened));
end;

procedure TpjhiTank_pjh.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

function TpjhiTank_pjh.SetNextStepAuto(ADestComponent: TComponent): Boolean;
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
      Result := True;
    end
    else
    if not Assigned(NextStep2) then
    begin
      NextStep2 := LDestComp;
      Result := True;
    end
    else
    if not Assigned(NextStep3) then
    begin
      NextStep3 := LDestComp;
      Result := True;
    end;
  end;
end;

procedure TpjhiTank_pjh.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhiTank_pjh.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;
    Position := StrToFloatDef(AValue,0.0);

    Opened := Position > 0.0;
  end;
end;

end.
