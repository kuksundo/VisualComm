unit pjhiPipe_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  iPipe_pjh, pjhclasses, pjhDesignCompIntf, pjhPipeFlowInterface, pjhxIOCompConst,
  UnitPipeData;

type
  TpjhiPipe_pjh = class(TiPipe_pjh, IpjhDesignCompInterface, IpjhPipeFlowInterface)
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

{ TpjhiPipe }

function TpjhiPipe_pjh.ClearXStep: Boolean;
begin
  Result := False;

  if Assigned(PrevStep) then
  begin
    PrevStep := nil;
    Result := True;
  end;

  if Assigned(NextStep) then
  begin
    NextStep := nil;
    Result := True;
  end;
end;

constructor TpjhiPipe_pjh.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhxIOCompBplFileName;
end;

function TpjhiPipe_pjh.DeleteNextStep(
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
end;

destructor TpjhiPipe_pjh.Destroy;
begin
  FpjhTagInfo.Free;
  inherited;
end;


function TpjhiPipe_pjh.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhiPipe_pjh.GetNextStepListWithComma: string;
begin
  Result := '';

  if Assigned(NextStep) then
    Result := NextStep.Name;
end;

function TpjhiPipe_pjh.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhiPipe_pjh.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

function TpjhiPipe_pjh.GetXStepNameListWithComma: string;
begin
  Result := 'NextStep,PrevStep';
end;

procedure TpjhiPipe_pjh.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

function TpjhiPipe_pjh.SetNextStepAuto(ADestComponent: TComponent): Boolean;
var
  LDestComp: TJHCustomComponent;
begin
  Result := False;

  if not Assigned(NextStep) then
  begin
    LDestComp := ADestComponent as TJHCustomComponent;

    if LDestComp.CheckAutoNextStep(Self) then
    begin
      NextStep := LDestComp;
      Result := True;;
    end;
  end;
end;

procedure TpjhiPipe_pjh.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhiPipe_pjh.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;
    FlowOn := StrToBool(AValue);
  end;
end;

end.
