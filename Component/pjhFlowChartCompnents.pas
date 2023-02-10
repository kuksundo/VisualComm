unit pjhFlowChartCompnents;

interface

uses Windows, Messages, SysUtils, Classes, Controls, StdCtrls, Menus,
    FlowChartLogic, pjhStartButton;

  function GetPaletteList: TStringList;

implementation

function GetPaletteList: TStringList;
var
  LStr: string;
begin
  Result := TStringList.Create;
  LStr := 'FlowChart=';
  LStr := LStr + 'TpjhStartButton;';
  LStr := LStr + 'TpjhIfControl;TpjhGotoControl;TpjhStartControl;TpjhStopControl;';
  LStr := LStr + 'TpjhDelay;TpjhSetTimer;TpjhIFTimer;';
  Result.Add(LStr);
end;

exports
  GetPaletteList;

initialization
//bpl�� �������� �ε��� RegisterClass�ص� GetClass�ÿ� nil�� return �Ǵ� ���� �߻�
//�ذ�: exe�� bpl project option���� vcl.dcp�� rtl.dcp�� ��������(release version)
  RegisterClasses([TpjhIfControl,TpjhGotoControl,TpjhStartControl,TpjhStopControl,TpjhDelay,TpjhSetTimer,TpjhIFTimer]);
  RegisterClasses([TpjhStartButton]);

finalization
  UnRegisterClasses([TpjhStartButton]);
  UnRegisterClasses([TpjhIfControl,TpjhGotoControl,TpjhStartControl,TpjhStopControl,TpjhDelay,TpjhSetTimer,TpjhIFTimer]);

end.
