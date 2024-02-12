unit pjhJvCompList;

interface

uses Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
    pjhJvCompConst, JvGIFCtrl, pjhTJvLabel, pjhTJvTransparentButton, pjhTJvGIFAnimator;//

  function GetPaletteList: TStringList;
  function GetBplFileName: string;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents ('pjhJvComp', [TpjhTJvGIFImage, TpjhTJvLabel, TpjhTJvTransparentButton, TpjhTJvTransparentButton2]); //
end;

function GetPaletteList: TStringList;
var
  LStr: string;
begin
  Result := TStringList.Create;
  LStr := 'JvComponent =';
  LStr := LStr + 'TpjhTJvGIFImage;TpjhTJvLabel;TpjhTJvTransparentButton;TpjhTJvTransparentButton2;';
  Result.Add(LStr);
end;

function GetBplFileName: string;
begin
  Result := pjhJvCompBplFileName;
end;

exports
  GetPaletteList,
  GetBplFileName;

initialization
//bpl을 동적으로 로딩시 RegisterClass해도 GetClass시에 nil이 return 되는 문제 발생
//해결: exe와 bpl project option에서 vcl.dcp와 rtl.dcp를 포함해줌(release version)
  RegisterClasses([TpjhTJvGIFImage,TpjhTJvLabel,TpjhTJvTransparentButton,
    TpjhTJvTransparentButton2]); //

finalization
  UnRegisterClasses([TpjhTJvGIFImage,TpjhTJvLabel,TpjhTJvTransparentButton,
    TpjhTJvTransparentButton2]);//

end.
