unit UnitRevFlowCommon;

interface

uses classes, System.SysUtils,
  pjhiPipe2_pjh, pjhiPipeJoint2_pjh, UnitRevFlowInterface;

procedure SetCommonRevPrevStep(ASrc, ADest: TComponent);
procedure SetCommonNilRevPrevStep(ASrc, ADest: TComponent);

implementation

procedure SetCommonRevPrevStep(ASrc, ADest: TComponent);
var
  LPFI: IpjhPipeRevFlowInterface;
begin
  if Supports(ADest, IpjhPipeRevFlowInterface, LPFI) then
    LPFI.SetAutoRevPrevStep(ASrc);
end;

procedure SetCommonNilRevPrevStep(ASrc, ADest: TComponent);
var
  LPFI: IpjhPipeRevFlowInterface;
begin
  if Supports(ADest, IpjhPipeRevFlowInterface, LPFI) then
    LPFI.SetNilRevPrevStep(ASrc.Name);
end;

end.
