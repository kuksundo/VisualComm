unit pjhiPipeJoint_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  iPipeJoint_pjh, pjhclasses, pjhDesignCompIntf, pjhPipeFlowInterface, pjhxIOCompConst,
  UnitPipeData;

type
  TpjhiPipeJoint_pjh = class(TiPipeJoint_pjh, IpjhDesignCompInterface, IpjhPipeFlowInterface)
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

uses pjhiPipe_pjh, UnitJHCustomComponent;

{ TpjhiPipeJoint }

function TpjhiPipeJoint_pjh.ClearXStep: Boolean;
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

  if Assigned(PrevStep3) then
  begin
    PrevStep3 := nil;
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

  if Assigned(NextStep3) then
  begin
    NextStep3 := nil;
    Result := True;
  end;
end;

constructor TpjhiPipeJoint_pjh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhxIOCompBplFileName;
end;

function TpjhiPipeJoint_pjh.DeleteNextStep(
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

destructor TpjhiPipeJoint_pjh.Destroy;
begin
  FpjhTagInfo.Free;
  inherited;
end;


function TpjhiPipeJoint_pjh.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhiPipeJoint_pjh.GetNextStepListWithComma: string;
begin
  Result := '';

  if Assigned(NextStep) then
    Result := NextStep.Name;

  if Assigned(NextStep2) then
    Result := Result + ',' + NextStep2.Name;

  if Assigned(NextStep3) then
    Result := Result + ',' + NextStep3.Name;
end;

function TpjhiPipeJoint_pjh.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhiPipeJoint_pjh.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

function TpjhiPipeJoint_pjh.GetPrevStepListWithComma: string;
begin
  Result := '';

  if Assigned(PrevStep) then
    Result := PrevStep.Name;

  if Assigned(PrevStep2) then
    Result := Result + ',' + PrevStep2.Name;

  if Assigned(PrevStep3) then
    Result := Result + ',' + PrevStep3.Name;
end;

function TpjhiPipeJoint_pjh.GetXStepNameListWithComma: string;
begin
  Result := 'NextStep,NextStep2,NextStep3,PrevStep,PrevStep2,PrevStep3';
end;

procedure TpjhiPipeJoint_pjh.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

function TpjhiPipeJoint_pjh.SetNextStepAuto(
  ADestComponent: TComponent): Boolean;
var
//  LpjhiPipe_pjh: TpjhiPipe_pjh;
  LDestComp: TJHCustomComponent;
begin
  Result := False;
  LDestComp := ADestComponent as TJHCustomComponent;

  //DestComp?? NextStep?? Self ?? ???? ???? ???? ?? ????
  if LDestComp.CheckAutoNextStep(Self) then
  begin
    //Self?? NextStep?? DestComp?? ???? ???? ???? ?? ????
    if CheckAutoNextStep(LDestComp) then
    begin
      if not Assigned(NextStep) then
      begin
        NextStep := LDestComp as TpjhiPipe_pjh;
        Result := True;
      end
      else
      if not Assigned(NextStep2) then
      begin
        NextStep2 := LDestComp as TpjhiPipe_pjh;
        Result := True;
      end
      else
      if not Assigned(NextStep3) then
      begin
        NextStep3 := LDestComp as TpjhiPipe_pjh;
        Result := True;
      end
    end;
  end;
end;

procedure TpjhiPipeJoint_pjh.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhiPipeJoint_pjh.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;
  end;
end;

end.

