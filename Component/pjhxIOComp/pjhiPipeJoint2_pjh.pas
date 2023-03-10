unit pjhiPipeJoint2_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  iPipeJoint_pjh, pjhclasses, pjhDesignCompIntf, pjhPipeFlowInterface, iPipe_pjh,
  pjhiPipe_pjh, pjhiPipe2_pjh,
  pjhxIOCompConst, UnitJHCustomComponent, UnitPipeData, pjhiPipeJoint_pjh,
  UnitRevFlowInterface;

type
  TpjhiPipeJoint2_pjh = class(TpjhiPipeJoint_pjh, IpjhPipeFlowInterface, IpjhPipeRevFlowInterface)
  private
    FRevNextStep: TiPipe_pjh;
    FRevPrevStep: TiPipe_pjh;
    FRevNextStep2: TiPipe_pjh;
    FRevPrevStep2: TiPipe_pjh;
    FRevNextStep3: TiPipe_pjh;
    FRevPrevStep3: TiPipe_pjh;

    //RevNextStep을 사용하기 위해 결정하기 위한 포인터
    //이전 컴포넌트와  FRevPrevStep4Check가 동일하면 RevNextStep 사용함
    FRevPrevStep4Check: TiPipe_pjh;
    FRevPrevStep4Check2: TiPipe_pjh;
    FRevPrevStep4Check3: TiPipe_pjh;

    procedure SetRevNextStep(Value: TiPipe_pjh);
    procedure SetRevPrevStep(Value: TiPipe_pjh);
    procedure SetRevNextStep2(Value: TiPipe_pjh);
    procedure SetRevPrevStep2(Value: TiPipe_pjh);
    procedure SetRevNextStep3(Value: TiPipe_pjh);
    procedure SetRevPrevStep3(Value: TiPipe_pjh);
    procedure ClearRevStep;

    procedure SetRevPrevStep4Check(Value: TiPipe_pjh);
    procedure SetRevPrevStep4Check2(Value: TiPipe_pjh);
    procedure SetRevPrevStep4Check3(Value: TiPipe_pjh);

    function GetpjhValue: string;
    procedure SetpjhValue(AValue: string);
    procedure iDoubleClick; override;
  public
    //For IpjhPipeFlowInterface ====>
    function SetNextStepAuto(ADestComponent: TComponent; AIsReverse: Boolean=false): Boolean; overload;
    function DeleteNextStep(AWillDeleteComponent: TComponent; AIsReverse: Boolean=false): Boolean; overload;
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

    function CheckAutoNextStep(APrevComponent: TJHCustomComponent; AIsReverse: Boolean=false): Boolean; overload;
    function NotifyChangeFromObj(ATriggerObj: TJHCustomComponent; APrevStatus: TPipeInternalStatus): TPipeInternalStatus; override;
    function CallRevNextStepNotifyChange(APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
    function CheckAutoPrevStep(APrevComponent: TJHCustomComponent; AIsReverse: Boolean=false): Boolean;
    function CallNextStepNotifyChangeInRev(APrevStatus: TPipeInternalStatus; ACheckPrevStepStatus: Boolean): TPipeInternalStatus;
  published
    property pjhValue: string read GetpjhValue write SetpjhValue;

    property RevNextStep        : TiPipe_pjh   read FRevNextStep  write SetRevNextStep;
    property RevPrevStep        : TiPipe_pjh   read FRevPrevStep  write SetRevPrevStep;
    property RevNextStep2       : TiPipe_pjh   read FRevNextStep2 write SetRevNextStep2;
    property RevPrevStep2       : TiPipe_pjh   read FRevPrevStep2 write SetRevPrevStep2;
    property RevNextStep3       : TiPipe_pjh   read FRevNextStep3 write SetRevNextStep3;
    property RevPrevStep3       : TiPipe_pjh   read FRevPrevStep3 write SetRevPrevStep3;
    property RevPrevStep4Check  : TiPipe_pjh  read FRevPrevStep4Check  write SetRevPrevStep4Check;
    property RevPrevStep4Check2 : TiPipe_pjh  read FRevPrevStep4Check2 write SetRevPrevStep4Check2;
    property RevPrevStep4Check3 : TiPipe_pjh  read FRevPrevStep4Check3 write SetRevPrevStep4Check3;
  end;

implementation

uses UnitJHIOCompCommon, UnitRevFlowCommon;

{ TpjhiPipeJoint_pjh }

function TpjhiPipeJoint2_pjh.CallNextStepNotifyChangeInRev(
  APrevStatus: TPipeInternalStatus; ACheckPrevStepStatus: Boolean): TPipeInternalStatus;
var
  LPrevStatus: TPipeInternalStatus;
  LOnStatus: Boolean;
begin
  LPrevStatus := APrevStatus;
  //Joint의 입력 3개 중에 한개라도 PressFilled 이면 출력은 PressFilled임
  if Assigned(PrevStep) then
    if PrevStep.PipeInternalStatus = pisPressFilled then
      LPrevStatus := pisPressFilled;

  if Assigned(PrevStep2) then
    if PrevStep2.PipeInternalStatus = pisPressFilled then
      LPrevStatus := pisPressFilled;

  if Assigned(PrevStep3) then
    if PrevStep3.PipeInternalStatus = pisPressFilled then
      LPrevStatus := pisPressFilled;

  if APrevStatus <> LPrevStatus then
    APrevStatus := LPrevStatus;

  if ACheckPrevStepStatus then
    GetPrevStepStatus(LOnStatus, APrevStatus)
  else
    GetRevPrevStepStatus(LOnStatus, APrevStatus);

  if Assigned(NextStep) then
  begin
//    if CheckAutoPrevStep(NextStep, True) then
      if NextStep.ClassType = TpjhiPipe_pjh then  //다음 단계가 TpjhiPipe_pjh 일 때
        Result := TiPipe_pjh(NextStep).NotifyChangeOnStatus(self, LOnStatus, APrevStatus)
      else
      if NextStep.ClassType = TpjhiPipe2_pjh then  //다음 단계가 TpjhiPipe2_pjh 일 때
        Result := TpjhiPipe2_pjh(NextStep).NotifyChangeFromObj(self, APrevStatus);
  end;

  if Assigned(NextStep2) then
  begin
//    if CheckAutoPrevStep(NextStep2, True) then
      if NextStep2.ClassType = TpjhiPipe_pjh then  //다음 2 단계가 TpjhiPipe_pjh 일 때
        Result := TiPipe_pjh(NextStep2).NotifyChangeOnStatus(self, LOnStatus, APrevStatus)
      else
      if NextStep2.ClassType = TpjhiPipe2_pjh then  //다음 2 단계가 TpjhiPipe2_pjh 일 때
        Result := TpjhiPipe2_pjh(NextStep2).NotifyChangeFromObj(self, APrevStatus);
  end;

  if Assigned(NextStep3) then
  begin
//    if CheckAutoPrevStep(NextStep3, True) then
      if NextStep3.ClassType = TpjhiPipe_pjh then  //다음 3 단계가 TpjhiPipe_pjh 일 때
        Result := TiPipe_pjh(NextStep3).NotifyChangeOnStatus(self, LOnStatus, APrevStatus)
      else
      if NextStep3.ClassType = TpjhiPipe2_pjh then  //다음 3 단계가 TpjhiPipe2_pjh 일 때
        Result := TpjhiPipe2_pjh(NextStep3).NotifyChangeFromObj(self, APrevStatus);
  end;
end;

function TpjhiPipeJoint2_pjh.CallRevNextStepNotifyChange(
  APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
var
  LPrevStatus: TPipeInternalStatus;
  LIsNotAssignedRevNextStep: Boolean;//모든 RevNextStep이 Nil 이면 True
  LOnStatus: Boolean;
begin
  LPrevStatus := APrevStatus;
  //Joint의 입력 3개 중에 한개라도 PressFilled 이면 출력은 PressFilled임
  if Assigned(RevPrevStep) then
    if RevPrevStep.PipeInternalStatus = pisPressFilled then
      LPrevStatus := pisPressFilled;

  if Assigned(RevPrevStep2) then
    if RevPrevStep2.PipeInternalStatus = pisPressFilled then
      LPrevStatus := pisPressFilled;

  if Assigned(RevPrevStep3) then
    if RevPrevStep3.PipeInternalStatus = pisPressFilled then
      LPrevStatus := pisPressFilled;

  if APrevStatus <> LPrevStatus then
    APrevStatus := LPrevStatus;

  LIsNotAssignedRevNextStep := True;

  if Assigned(RevNextStep) then
  begin
    LIsNotAssignedRevNextStep := False;

    if RevNextStep.ClassType = TpjhiPipe2_pjh then  //다음 단계가 TpjhiPipe2_pjh 일 때
      Result := TpjhiPipe2_pjh(RevNextStep).RevNotifyChangeFromObj(self, APrevStatus)
    else
    if RevNextStep.ClassType = TpjhiPipe_pjh then
    begin
      GetRevPrevStepStatus(LOnStatus, APrevStatus);
      Result := TpjhiPipe_pjh(RevNextStep).NotifyChangeOnStatus(self, LOnStatus, APrevStatus);
    end;
  end;

  if Assigned(RevNextStep2) then
  begin
    LIsNotAssignedRevNextStep := False;

    if RevNextStep2.ClassType = TpjhiPipe2_pjh then  //다음 2단계가 TpjhiPipe2_pjh 일 때
      Result := TpjhiPipe2_pjh(RevNextStep2).RevNotifyChangeFromObj(self, APrevStatus)
    else
    if RevNextStep2.ClassType = TpjhiPipe_pjh then
    begin
      GetRevPrevStepStatus(LOnStatus, APrevStatus);
      Result := TpjhiPipe_pjh(RevNextStep2).NotifyChangeOnStatus(self, LOnStatus, APrevStatus);
    end;
  end;

  if Assigned(RevNextStep3) then
  begin
    LIsNotAssignedRevNextStep := False;

    if RevNextStep3.ClassType = TpjhiPipe2_pjh then  //다음 3단계가 TpjhiPipe2_pjh 일 때
      Result := TpjhiPipe2_pjh(RevNextStep3).RevNotifyChangeFromObj(self, APrevStatus)
    else
    if RevNextStep3.ClassType = TpjhiPipe_pjh then
    begin
      GetRevPrevStepStatus(LOnStatus, APrevStatus);
      Result := TpjhiPipe_pjh(RevNextStep3).NotifyChangeOnStatus(self, LOnStatus, APrevStatus);
    end;
  end;

  if LIsNotAssignedRevNextStep then
  begin
    if Assigned(NextStep) then
      if CheckAutoPrevStep(NextStep, True) then
        Result := NextStep.NotifyChangeFromObj(Self, APrevStatus);

    if Assigned(NextStep2) then
      if CheckAutoPrevStep(NextStep2, True) then
        Result := NextStep2.NotifyChangeFromObj(Self, APrevStatus);

    if Assigned(NextStep3) then
      if CheckAutoPrevStep(NextStep3, True) then
        Result := NextStep3.NotifyChangeFromObj(Self, APrevStatus);
  end;
end;

function TpjhiPipeJoint2_pjh.CheckAutoNextStep(
  APrevComponent: TJHCustomComponent; AIsReverse: Boolean): Boolean;
begin
  if AIsReverse then
  begin
    Result := RevNextStep <> APrevComponent;

    if Result then
      Result := RevNextStep2 <> APrevComponent
    else
      exit;

    if Result then
      Result := RevNextStep3 <> APrevComponent
    else
      exit;
  end
  else
  begin
    Result := NextStep <> APrevComponent;

    if Result then
      Result := NextStep2 <> APrevComponent
    else
      exit;

    if Result then
      Result := NextStep3 <> APrevComponent
    else
      exit;
  end;
end;

function TpjhiPipeJoint2_pjh.CheckAutoPrevStep(
  APrevComponent: TJHCustomComponent; AIsReverse: Boolean): Boolean;
begin
  if AIsReverse then
  begin
    Result := RevPrevStep <> APrevComponent;

    if Result then
      Result := RevPrevStep2 <> APrevComponent
    else
      exit;

    if Result then
      Result := RevPrevStep3 <> APrevComponent
    else
      exit;
  end
  else
  begin
    Result := PrevStep <> APrevComponent;

    if Result then
      Result := PrevStep2 <> APrevComponent
    else
      exit;

    if Result then
      Result := PrevStep3 <> APrevComponent
    else
      exit;
  end;
end;

procedure TpjhiPipeJoint2_pjh.ClearRevStep;
begin
  if Assigned(RevNextStep) then
    RevNextStep := nil;

  if Assigned(RevPrevStep) then
    RevPrevStep := nil;

  if Assigned(RevNextStep2) then
    RevNextStep2 := nil;

  if Assigned(RevPrevStep2) then
    RevPrevStep2 := nil;

  if Assigned(RevNextStep3) then
    RevNextStep3 := nil;

  if Assigned(RevPrevStep3) then
    RevPrevStep3 := nil;
end;

function TpjhiPipeJoint2_pjh.DeleteNextStep(AWillDeleteComponent: TComponent;
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

    if Assigned(RevNextStep2) then
    begin
      if RevNextStep2.Name = AWillDeleteComponent.Name then
      begin
        RevNextStep2 := nil;
        Result := True;
      end;
    end;

    if Assigned(RevNextStep3) then
    begin
      if RevNextStep3.Name = AWillDeleteComponent.Name then
      begin
        RevNextStep3 := nil;
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
end;

function TpjhiPipeJoint2_pjh.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

function TpjhiPipeJoint2_pjh.GetRevPrevStepFromName(
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

  if Assigned(RevPrevStep2) then
  begin
    if RevPrevStep2.Name = ATriggerName then
    begin
      Result := psvPrevStep2;
      exit;
    end;
  end;

  if Assigned(RevPrevStep3) then
  begin
    if RevPrevStep3.Name = ATriggerName then
    begin
      Result := psvPrevStep3;
      exit;
    end;
  end;
end;

function TpjhiPipeJoint2_pjh.GetRevPrevStepStatus(out AOnStatus: Boolean;
  var APrevStatus: TPipeInternalStatus): TComponent;//TJHCustomComponent
begin
  if Assigned(RevPrevStep) then
  begin
    AOnStatus := RevPrevStep.FlowOn;
    APrevStatus := RevPrevStep.PipeInternalStatus;
    Result := RevPrevStep;
  end;

  if Assigned(RevPrevStep2) then
  begin
    if not AOnStatus then
    begin
      AOnStatus := RevPrevStep2.FlowOn;
      APrevStatus := RevPrevStep2.PipeInternalStatus;
      Result := RevPrevStep2;
    end;
  end;

  if Assigned(RevPrevStep3) then
  begin
    if not AOnStatus then
    begin
      AOnStatus := RevPrevStep3.FlowOn;
      APrevStatus := RevPrevStep3.PipeInternalStatus;
      Result := RevPrevStep3;
    end;
  end;
end;

procedure TpjhiPipeJoint2_pjh.iDoubleClick;
begin
  inherited;

  if pjhValue = '1' then
    pjhValue := '0'
  else
    pjhValue := '1';
end;

function TpjhiPipeJoint2_pjh.NotifyChangeFromObj(ATriggerObj: TJHCustomComponent;
  APrevStatus: TPipeInternalStatus): TPipeInternalStatus;
var
  LPipe: TJHCustomComponent;
  LIsReverseAction,
  LCheckPrevStepStatus: Boolean;
begin
  LIsReverseAction := False;

  if (Assigned(FRevPrevStep4Check)) or (Assigned(FRevPrevStep4Check2)) or
    (Assigned(FRevPrevStep4Check3)) then
  begin
    LPipe := ATriggerObj;

    if (FRevPrevStep4Check = LPipe) or (FRevPrevStep4Check2 = LPipe) or
      (FRevPrevStep4Check3 = LPipe) then
      LIsReverseAction := True;
  end;

  if LIsReverseAction then
  begin
    Result := CallRevNextStepNotifyChange(APrevStatus);
    Result := CallNextStepNotifyChangeInRev(APrevStatus, True);
  end
  else
  begin
    Result := CallNextStepNotifyChangeInRev(APrevStatus, True);
  end;

//  LIsReverseAction := pjhValue = '1';  LCheckPrevStepStatus
end;

function TpjhiPipeJoint2_pjh.SetAutoRevPrevStep(
  AComponent: TComponent): Boolean;
begin
  if not Assigned(FRevPrevStep) then
    FRevPrevStep := TiPipe_pjh(AComponent)
  else
  if not Assigned(FRevPrevStep2) then
    FRevPrevStep2 := TiPipe_pjh(AComponent)
  else
  if not Assigned(FRevPrevStep3) then
    FRevPrevStep3 := TiPipe_pjh(AComponent);
end;

function TpjhiPipeJoint2_pjh.SetNextStepAuto(ADestComponent: TComponent;
  AIsReverse: Boolean): Boolean;
var
  LDestComp: TpjhiPipe_pjh;
//  LDestComp2: TpjhiPipe2_pjh;
  LCheckAutoNextAtep: Boolean;
begin
  Result := False;

  if ADestComponent.ClassType = TpjhiPipe_pjh then
  begin
    LDestComp := ADestComponent as TpjhiPipe_pjh;
    LCheckAutoNextAtep := LDestComp.CheckAutoNextStep(Self)
  end
  else
  if ADestComponent.ClassType = TpjhiPipe2_pjh then
  begin
    LDestComp := ADestComponent as TpjhiPipe2_pjh;
    LCheckAutoNextAtep := TpjhiPipe2_pjh(LDestComp).CheckAutoNextStep(Self, AIsReverse);
  end;

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
        end
        else
        if not Assigned(RevNextStep2) then
        begin
          RevNextStep2 := LDestComp;
          Result := True;
        end
        else
        if not Assigned(RevNextStep3) then
        begin
          RevNextStep3 := LDestComp;
          Result := True;
        end
      end
      else
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
        end
      end;
    end;
  end;
end;

function TpjhiPipeJoint2_pjh.SetNilRevPrevStep(AComponentName: string): Boolean;
var
  LPrevStepVar: TPrevStepVar;
begin
  LPrevStepVar := GetRevPrevStepFromName(AComponentName);

  case LPrevStepVar of
    psvPrevStep : FRevPrevStep := nil;
    psvPrevStep2 : FRevPrevStep2 := nil;
    psvPrevStep3 : FRevPrevStep3 := nil;
  end;
end;

procedure TpjhiPipeJoint2_pjh.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;

    if AValue = '1' then //Notify Reverse
    begin
      CallRevNextStepNotifyChange(pisEmpty);
    end;
  end;
end;

procedure TpjhiPipeJoint2_pjh.SetRevNextStep(Value: TiPipe_pjh);
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

procedure TpjhiPipeJoint2_pjh.SetRevNextStep2(Value: TiPipe_pjh);
begin
  FOldNextStep2 := FRevNextStep2;
  FRevNextStep2 := Value;

  if Assigned(Value) then
  begin
    SetCommonRevPrevStep(Self, Value);

    if Assigned(FOldNextStep2) then
      if FOldNextStep2.Name <> FRevNextStep2.Name then
        SetCommonNilRevPrevStep(Self, FOldNextStep2);
  end
  else
    SetCommonNilRevPrevStep(Self, FOldNextStep2);
end;

procedure TpjhiPipeJoint2_pjh.SetRevNextStep3(Value: TiPipe_pjh);
begin
  FOldNextStep3 := FRevNextStep3;
  FRevNextStep3 := Value;

  if Assigned(Value) then
  begin
    SetCommonRevPrevStep(Self, Value);

    if Assigned(FOldNextStep3) then
      if FOldNextStep3.Name <> FRevNextStep3.Name then
        SetCommonNilRevPrevStep(Self, FOldNextStep3);
  end
  else
    SetCommonNilRevPrevStep(Self, FOldNextStep3);
end;

function TpjhiPipeJoint2_pjh.SetRevNextStepAuto(
  ADestComponent: TComponent): Boolean;
var
  LDestComp: TpjhiPipe_pjh;
//  LDestComp2: TpjhiPipe2_pjh;
  LCheckAutoNextAtep: Boolean;
begin
  Result := False;

  if ADestComponent.ClassType = TpjhiPipe_pjh then
  begin
    LDestComp := ADestComponent as TpjhiPipe_pjh;
    LCheckAutoNextAtep := CheckAutoNextStep(LDestComp, True);
  end
  else
  if ADestComponent.ClassType = TpjhiPipe2_pjh then
  begin
    LDestComp := ADestComponent as TpjhiPipe2_pjh;
    LCheckAutoNextAtep := CheckAutoNextStep(LDestComp, True);
//    LCheckAutoNextAtep := TpjhiPipe2_pjh(LDestComp).CheckAutoNextStep(Self, True);
  end;

  if LCheckAutoNextAtep then
  begin
    if not Assigned(RevNextStep) then
    begin
      RevNextStep := LDestComp;
      Result := True;
    end
    else
    if not Assigned(RevNextStep2) then
    begin
      RevNextStep2 := LDestComp;
      Result := True;
    end
    else
    if not Assigned(RevNextStep3) then
    begin
      RevNextStep3 := LDestComp;
      Result := True;
    end
  end;
end;

procedure TpjhiPipeJoint2_pjh.SetRevPrevStep(Value: TiPipe_pjh);
begin
  FRevPrevStep := Value;
end;

procedure TpjhiPipeJoint2_pjh.SetRevPrevStep2(Value: TiPipe_pjh);
begin
  FRevPrevStep2 := Value;
end;

procedure TpjhiPipeJoint2_pjh.SetRevPrevStep3(Value: TiPipe_pjh);
begin
  FRevPrevStep3 := Value;
end;

procedure TpjhiPipeJoint2_pjh.SetRevPrevStep4Check(Value: TiPipe_pjh);
begin
  FRevPrevStep4Check := Value;
end;

procedure TpjhiPipeJoint2_pjh.SetRevPrevStep4Check2(Value: TiPipe_pjh);
begin
  FRevPrevStep4Check2 := Value;
end;

procedure TpjhiPipeJoint2_pjh.SetRevPrevStep4Check3(Value: TiPipe_pjh);
begin
  FRevPrevStep4Check3 := Value;
end;

function TpjhiPipeJoint2_pjh.SetRevPrevStep4Source(
  ADestComponent: TComponent): Boolean;
var
  LComp: TiPipe_pjh;
begin
  LComp := ADestComponent as TiPipe_pjh;

  if not Assigned(FRevPrevStep4Check) then
    RevPrevStep4Check := LComp
  else
  if not Assigned(FRevPrevStep4Check2) then
    RevPrevStep4Check2 := LComp
  else
  if not Assigned(FRevPrevStep4Check3) then
    RevPrevStep4Check3 := LComp
end;

end.
