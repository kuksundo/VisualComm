unit pjhiPipe2_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus, Vcl.Graphics,
  iPipeJoint_pjh, pjhclasses, pjhDesignCompIntf, pjhPipeFlowInterface,
  pjhiPipe_pjh, pjhxIOCompConst, UnitJHCustomComponent, UnitPipeData,
  pjhiPipeJoint_pjh, UnitRevFlowInterface;

type
  TpjhiPipe2_pjh = class(TpjhiPipe_pjh, IpjhPipeFlowInterface, IpjhPipeRevFlowInterface)
  private
    FRevNextStep: TJHCustomComponent;
    FRevPrevStep: TJHCustomComponent;
    FAlphaBlend: Boolean;
    FAlphaBlendValue: word;

    procedure SetRevNextStep(Value: TJHCustomComponent);
    procedure SetRevPrevStep(Value: TJHCustomComponent);
    procedure ClearRevStep;

    procedure SetAlphaBlend(AValue: Boolean);
    procedure SetAlphaBlendValue(AValue: Word);
  protected
    procedure PipeOnPaintAfter(Sender: TObject; Bitmap: TBitmap); override;
  public
    //For IpjhPipeFlowInterface ====>
    function SetNextStepAuto(ADestComponent: TComponent; AIsReverse: Boolean=false): Boolean;
    function DeleteNextStep(AWillDeleteComponent: TComponent; AIsReverse: Boolean=false): Boolean;
//    function ClearXStep: Boolean;
    //For IpjhPipeFlowInterface <====

    //For IpjhPipeRevFlowInterface ====>
    function SetRevNextStepAuto(ADestComponent: TComponent): Boolean;
    function SetAutoRevPrevStep(AComponent: TComponent): Boolean;
    function SetNilRevPrevStep(AComponentName: string): Boolean;
    function GetRevPrevStepFromName(ATriggerName: string): TPrevStepVar;
    function SetRevPrevStep4Source(ADestComponent: TComponent): Boolean;
    function GetRevPrevStepStatus(out AOnStatus: Boolean; var APrevStatus: TPipeInternalStatus): TComponent;
    //For IpjhPipeRevFlowInterface <====

    procedure SetAutoPrevStep(AComponent: TComponent); override;
    procedure SetNilPrevStep(AComponentName: string); override;

    function CheckAutoNextStep(APrevComponent: TJHCustomComponent; AIsReverse: Boolean=false): Boolean; overload;
    function NotifyChangeFromObj(ATriggerObj: TJHCustomComponent; APrevStatus: TPipeInternalStatus): TPipeInternalStatus; override;
    function RevNotifyChangeFromObj(ATriggerObj: TJHCustomComponent; APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
    function CallRevNextStepNotifyChange(APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
    function CheckAutoPrevStep(APrevComponent: TJHCustomComponent; AIsReverse: Boolean=false): Boolean;
  published
    property RevNextStep        : TJHCustomComponent   read FRevNextStep  write SetRevNextStep;
    property RevPrevStep        : TJHCustomComponent   read FRevPrevStep  write SetRevPrevStep;
    property AlphaBlend         : Boolean              read FAlphaBlend  write SetAlphaBlend;
    property AlphaBlendValue    : word                 read FAlphaBlendValue  write SetAlphaBlendValue;
  end;

implementation

uses pjhiPipeJoint2_pjh, UnitJHIOCompCommon, UnitRevFlowCommon, UnitVCLUtil;

{ TpjhiPipe2_pjh }

function TpjhiPipe2_pjh.CallRevNextStepNotifyChange(
  APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
begin
  if Assigned(RevNextStep) then
  begin
    if RevNextStep.ClassType = TpjhiPipeJoint2_pjh then
      Result := TpjhiPipeJoint2_pjh(RevNextStep).CallRevNextStepNotifyChange(APrevStatus);
  end
  else
  begin
    Result := SetVenting;
  end;
end;

function TpjhiPipe2_pjh.CheckAutoNextStep(APrevComponent: TJHCustomComponent;
  AIsReverse: Boolean): Boolean;
begin
  if AIsReverse then
  begin
    Result := RevNextStep <> APrevComponent;
  end
  else
  begin
    Result := NextStep <> APrevComponent;
  end;
end;

function TpjhiPipe2_pjh.CheckAutoPrevStep(APrevComponent: TJHCustomComponent;
  AIsReverse: Boolean): Boolean;
begin
  if AIsReverse then
  begin
    Result := RevPrevStep <> APrevComponent;
  end
  else
  begin
    Result := PrevStep <> APrevComponent;
  end;
end;

procedure TpjhiPipe2_pjh.ClearRevStep;
begin
  if Assigned(RevNextStep) then
    RevNextStep := nil;

  if Assigned(RevPrevStep) then
    RevPrevStep := nil;
end;

function TpjhiPipe2_pjh.DeleteNextStep(AWillDeleteComponent: TComponent;
  AIsReverse: Boolean): Boolean;
begin
  Result := False;

  if AIsReverse then
  begin
    if Assigned(RevNextStep) then
    begin
      if RevNextStep.Name = AWillDeleteComponent.Name then
      begin
        RevNextStep := nil;
        Result := True;
      end;
    end;
  end
  else
  begin
    if Assigned(NextStep) then
    begin
      if NextStep.Name = AWillDeleteComponent.Name then
      begin
        NextStep := nil;
        Result := True;
      end;
    end;
  end;
end;

function TpjhiPipe2_pjh.GetRevPrevStepFromName(
  ATriggerName: string): TPrevStepVar;
begin
  Result := psvNull;

  if Assigned(RevPrevStep) then
  begin
    if RevPrevStep.Name = ATriggerName then
    begin
      Result := psvPrevStep;
      exit;
    end;
  end;
end;

function TpjhiPipe2_pjh.GetRevPrevStepStatus(out AOnStatus: Boolean;
  var APrevStatus: TPipeInternalStatus): TComponent;
begin

end;

function TpjhiPipe2_pjh.NotifyChangeFromObj(ATriggerObj: TJHCustomComponent;
  APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
var
  LOnStatus: Boolean;
begin
  if Assigned(ATriggerObj) then
  begin
    if ATriggerObj.InheritsFrom(TpjhiPipeJoint2_pjh) then
    begin
//      FlowReverse := FOriginalReverseFlow;
      //Pipe를 Notify한 이전 TiPipeJoint_pjh의 입력 파이프 상태를 가져옴
      TpjhiPipeJoint2_pjh(ATriggerObj).GetPrevStepStatus(LOnStatus, APrevStatus);
      //Joint이므로 Valve 입력 파이프와 Valve 출력 파이프가 상태가 동일 해야 함
      SetPipeStatus(LOnStatus, APrevStatus);

      Result := CallNextStepNotifyChange(APrevStatus)
    end
    else
      inherited;
  end;
end;

procedure TpjhiPipe2_pjh.PipeOnPaintAfter(Sender: TObject; Bitmap: TBitmap);
var
  LRect: TRect;
begin
  if FAlphaBlend then
  begin
    LRect.Top := 0;
    LRect.Left := 0;
    LRect.Bottom := Bitmap.Height;
    LRect.Right := Bitmap.Width;

    MakeAlphaOnRect2Bitmap(Bitmap, LRect, FAlphaBlendValue);
  end
  else
  begin

  end;
end;

function TpjhiPipe2_pjh.RevNotifyChangeFromObj(ATriggerObj: TJHCustomComponent;
  APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
var
  LOnStatus: Boolean;
begin
  if Assigned(ATriggerObj) then
  begin
    if ATriggerObj.InheritsFrom(TpjhiPipeJoint2_pjh) then
    begin
      FlowReverse := not FOriginalReverseFlow;
      //Pipe를 Notify한 이전 TiPipeJoint_pjh의 입력 파이프 상태를 가져옴
      TpjhiPipeJoint2_pjh(ATriggerObj).GetRevPrevStepStatus(LOnStatus, APrevStatus);
      //Joint이므로 Valve 입력 파이프와 Valve 출력 파이프가 상태가 동일 해야 함
      SetPipeStatus(LOnStatus, APrevStatus);

      Result := CallRevNextStepNotifyChange(APrevStatus)
    end;

//    if Result = pisFinal then
//    begin
//      SetPipeStatus(LOnStatus, APrevStatus);
//    end;
//
//    FFinishProgress := True;
  end;
end;

procedure TpjhiPipe2_pjh.SetAlphaBlend(AValue: Boolean);
begin
  if FAlphaBlend <> AValue then
  begin
    FAlphaBlend := AValue;
  end;
end;

procedure TpjhiPipe2_pjh.SetAlphaBlendValue(AValue: Word);
begin
  if FAlphaBlendValue <> AValue then
  begin
    FAlphaBlendValue := AValue;
  end;
end;

procedure TpjhiPipe2_pjh.SetAutoPrevStep(AComponent: TComponent);
begin
  inherited;

end;

function TpjhiPipe2_pjh.SetAutoRevPrevStep(AComponent: TComponent): Boolean;
begin
  FRevPrevStep := TJHCustomComponent(AComponent);
end;

function TpjhiPipe2_pjh.SetNextStepAuto(ADestComponent: TComponent;
  AIsReverse: Boolean): Boolean;
var
  LDestComp: TJHCustomComponent;
  LCheckAutoNextAtep: Boolean;
begin
  Result := False;

  LDestComp := ADestComponent as TJHCustomComponent;

  if ADestComponent.ClassType = TpjhiPipeJoint2_pjh then
    LCheckAutoNextAtep :=  TpjhiPipeJoint2_pjh(LDestComp).CheckAutoNextStep(Self, AIsReverse)
  else
    LCheckAutoNextAtep :=  LDestComp.CheckAutoNextStep(Self);

  //DestComp의 NextStep에 Self 가 이미 존재 하는 지 확인
  if LCheckAutoNextAtep then
  begin
    //Self의 NextStep에 DestComp가 이미 존재 하는 지 확인
    if CheckAutoNextStep(Self, AIsReverse) then
    begin
      if AIsReverse then
      begin
        if not Assigned(RevNextStep) then
        begin
          RevNextStep := LDestComp;
          Result := True;
        end;
      end
      else
      begin
        if not Assigned(NextStep) then
        begin
          NextStep := LDestComp;
          Result := True;
        end;
      end;
    end;
  end;
end;

procedure TpjhiPipe2_pjh.SetNilPrevStep(AComponentName: string);
begin
  inherited;

end;

function TpjhiPipe2_pjh.SetNilRevPrevStep(AComponentName: string): Boolean;
var
  LPrevStepVar: TPrevStepVar;
begin
  LPrevStepVar := GetPrevStepFromName(AComponentName);

  case LPrevStepVar of
    psvPrevStep : FRevPrevStep := nil;
  end;
end;

procedure TpjhiPipe2_pjh.SetRevNextStep(Value: TJHCustomComponent);
begin
  FOldNextStep := FRevNextStep;
  FRevNextStep := Value;

  if Assigned(Value) then
  begin
    SetCommonRevPrevStep(Self, Value);

    if Assigned(FOldNextStep) then
      if FOldNextStep.Name <> FRevNextStep.Name then
        SetCommonNilRevPrevStep(Self, FOldNextStep);
  end
  else
    SetCommonNilRevPrevStep(Self, FOldNextStep);
end;

function TpjhiPipe2_pjh.SetRevNextStepAuto(ADestComponent: TComponent): Boolean;
var
  LDestComp: TpjhiPipeJoint2_pjh;
  LCheckAutoNextAtep: Boolean;
begin
  Result := False;
  LCheckAutoNextAtep := False;

  if ADestComponent.ClassType = TpjhiPipeJoint2_pjh then
  begin
    LDestComp := ADestComponent as TpjhiPipeJoint2_pjh;
    LCheckAutoNextAtep := LDestComp.CheckAutoNextStep(Self, True)
  end;

  if LCheckAutoNextAtep then
  begin
    if not Assigned(RevNextStep) then
    begin
      RevNextStep := LDestComp;
      Result := True;
    end;
  end;
end;

procedure TpjhiPipe2_pjh.SetRevPrevStep(Value: TJHCustomComponent);
begin
  FRevPrevStep := Value;
end;

function TpjhiPipe2_pjh.SetRevPrevStep4Source(ADestComponent: TComponent): Boolean;
begin
  Result := False;
end;

end.
