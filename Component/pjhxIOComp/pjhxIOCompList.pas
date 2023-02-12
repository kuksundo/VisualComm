unit pjhxIOCompList;

interface

uses Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
    pjhxIOCompConst, pjhiLedArrow_pjh, pjhiMotor_pjh, pjhiPipe_pjh,
    pjhiPipeJoint_pjh, pjhiTank_pjh, pjhiValve_pjh, pjhjvGIFAnimator_pjh,
    pjhiPanel_jvGIFAni_pjh, pjhiValve2_pjh, pjhiTank2_pjh, pjhiPipeJoint2_pjh,
    pjhiPipe2_pjh;

  function GetPaletteList: TStringList;
  function GetBplFileName: string;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents ('pjhxIOComp', [TpjhiLedArrow_pjh,TpjhiPipe_pjh]);
  RegisterComponents ('pjhxIOComp', [TpjhiPipeJoint_pjh,TpjhiTank_pjh]);
  RegisterComponents ('pjhxIOComp', [TpjhiValve_pjh,TpjhiValve2_pjh,TpjhiMotor_pjh]);
  RegisterComponents ('pjhxIOComp', [TpjhjvGIFAnimator_pjh,TpjhiPanel_jvGIFAni_pjh]);
  RegisterComponents ('pjhxIOComp2', [TpjhiTank2_pjh, TpjhiPipeJoint2_pjh]);
  RegisterComponents ('pjhxIOComp2', [TpjhiPipe2_pjh]);
end;

function GetPaletteList: TStringList;
var
  LStr: string;
begin
  Result := TStringList.Create;
  LStr := 'xIOComp=';
  LStr := LStr + 'TpjhiLedArrow_pjh;TpjhiPipe_pjh;';
  LStr := LStr + 'TpjhiPipeJoint_pjh;TpjhiTank_pjh;';
  LStr := LStr + 'TpjhiValve_pjh;TpjhiMotor_pjh;';
  LStr := LStr + 'TpjhjvGIFAnimator_pjh;TpjhiPanel_jvGIFAni_pjh;';
  Result.Add(LStr);

  LStr := 'xIOComp2=';
  LStr := LStr + 'TpjhiValve2_pjh;TpjhiTank2_pjh;';
  LStr := LStr + 'TpjhiPipeJoint2_pjh;TpjhiPipe2_pjh;';
  Result.Add(LStr);
end;

function GetBplFileName: string;
begin
  Result := pjhxIOCompBplFileName;
end;

exports
  GetPaletteList,
  GetBplFileName;

initialization
//bpl�� �������� �ε��� RegisterClass�ص� GetClass�ÿ� nil�� return �Ǵ� ���� �߻�
//�ذ�: exe�� bpl project option���� vcl.dcp�� rtl.dcp�� ��������(release version)
  RegisterClasses([TpjhiLedArrow_pjh,TpjhiPipe_pjh]);
  RegisterClasses([TpjhiPipeJoint_pjh,TpjhiTank_pjh]);
  RegisterClasses([TpjhiValve_pjh,TpjhiValve2_pjh,TpjhiMotor_pjh]);
  RegisterClasses([TpjhjvGIFAnimator_pjh,TpjhiPanel_jvGIFAni_pjh]);
  RegisterClasses([TpjhiTank2_pjh,TpjhiPipeJoint2_pjh,TpjhiPipe2_pjh]);

finalization
  //UnRegisterClasses([TpjhIfControl,TpjhGotoControl,TpjhStartControl,TpjhStopControl,TpjhDelay,TpjhSetTimer,TpjhIFTimer]);
  UnRegisterClasses([TpjhiLedArrow_pjh,TpjhiPipe_pjh]);
  UnRegisterClasses([TpjhiPipeJoint_pjh,TpjhiTank_pjh]);
  UnRegisterClasses([TpjhiValve_pjh,TpjhiValve2_pjh,TpjhiMotor_pjh]);
  UnRegisterClasses([TpjhjvGIFAnimator_pjh,TpjhiPanel_jvGIFAni_pjh]);
  UnRegisterClasses([TpjhiTank2_pjh,TpjhiPipeJoint2_pjh,TpjhiPipe2_pjh]);

end.