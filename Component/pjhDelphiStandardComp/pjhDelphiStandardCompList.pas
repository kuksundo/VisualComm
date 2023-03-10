unit pjhDelphiStandardCompList;

interface

uses Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
    pjhDelphiStandardCompConst, pjhTPanel, pjhTImage, pjhTBevel, pjhTGridPanel,
    pjhTLedPanel, pjhTShadowButton, pjhDateTimeLabel, pjhLabel4HiMECS;

  function GetPaletteList: TStringList;
  function GetBplFileName: string;
  procedure RegisterpjhClass;
  procedure UnRegisterpjhClass;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('pjhDelphiStandard', [TpjhTPanel,TpjhTImage,TpjhTBevel,
    TpjhTGridPanel,TpjhLedPanel, TpjhTShadowButton, TpjhTPanelWithBalloon,
    TpjhTransparentPanel, TpjhDateTimeLabel, TpjhLabel4HiMECSA2AABB,
    TpjhLabel4HiMECSA2CC]);
end;

function GetPaletteList: TStringList;
var
  LStr: string;
begin
  Result := TStringList.Create;
  LStr := 'Standard =';
  LStr := LStr + 'TpjhTPanel;TpjhTImage;TpjhTBevel;TpjhTGridPanel;TpjhLedPanel;';
  LStr := LStr + 'TpjhTShadowButton;TpjhTPanelWithBalloon;TpjhTransparentPanel;';
  LStr := LStr + 'TpjhDateTimeLabel;TpjhLabel4HiMECSA2AABB;TpjhLabel4HiMECSA2CC;'; //마지막 항목 뒤에 반드시 세미콜론 붙일 것
  Result.Add(LStr);
end;

function GetBplFileName: string;
begin
  Result := pjhDelphiStandardBplFileName;
end;

procedure RegisterpjhClass;
begin
  RegisterClasses([TpjhTPanel,TpjhTImage,TpjhTBevel,TpjhTGridPanel,TpjhLedPanel,
    TpjhTShadowButton, TpjhTPanelWithBalloon, TpjhTransparentPanel,
    TpjhDateTimeLabel, TpjhLabel4HiMECSA2AABB, TpjhLabel4HiMECSA2CC]);
end;

procedure UnRegisterpjhClass;
begin
  UnRegisterClasses([TpjhTPanel,TpjhTImage,TpjhTBevel,TpjhTGridPanel,TpjhLedPanel,
    TpjhTShadowButton, TpjhTPanelWithBalloon, TpjhTransparentPanel,
    TpjhDateTimeLabel, TpjhLabel4HiMECSA2AABB, TpjhLabel4HiMECSA2CC]);
end;

exports
  GetPaletteList,
  GetBplFileName,
  RegisterpjhClass,
  UnRegisterpjhClass;

initialization
//bpl을 동적으로 로딩시 RegisterClass해도 GetClass시에 nil이 return 되는 문제 발생
//해결: exe와 bpl project option에서 vcl.dcp와 rtl.dcp를 포함해줌(release version)
  //RegisterClasses([TpjhIfControl,TpjhGotoControl,TpjhStartControl,TpjhStopControl,TpjhDelay,TpjhSetTimer,TpjhIFTimer]);
//  RegisterClasses([TpjhTPanel,TpjhTImage,TpjhTBevel,TpjhTGridPanel,TpjhLedPanel, TpjhTShadowButton]);
  RegisterpjhClass;
finalization
  //UnRegisterClasses([TpjhIfControl,TpjhGotoControl,TpjhStartControl,TpjhStopControl,TpjhDelay,TpjhSetTimer,TpjhIFTimer]);
//  UnRegisterClasses([TpjhTPanel,TpjhTImage,TpjhTBevel,TpjhTGridPanel,TpjhLedPanel, TpjhTShadowButton]);
  UnRegisterpjhClass;
end.
