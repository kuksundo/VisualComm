unit pjhJvCompList;

interface

uses Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
    pjhJvCompConst, JvGIFCtrl, pjhTJvLabel, pjhTJvTransparentButton;//

  function GetPaletteList: TStringList;
  function GetBplFileName: string;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents ('pjhJvComp', [TJvGIFAnimator,TpjhTJvLabel, TpjhTJvTransparentButton, TpjhTJvTransparentButton2]); //
end;

function GetPaletteList: TStringList;
var
  LStr: string;
begin
  Result := TStringList.Create;
  LStr := 'JvComponent =';
  LStr := LStr + 'TJvGIFAnimator;TpjhTJvLabel;TpjhTJvTransparentButton;TpjhTJvTransparentButton2;';
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
//bpl�� �������� �ε��� RegisterClass�ص� GetClass�ÿ� nil�� return �Ǵ� ���� �߻�
//�ذ�: exe�� bpl project option���� vcl.dcp�� rtl.dcp�� ��������(release version)
  RegisterClasses([TJvGIFAnimator,TpjhTJvLabel,TpjhTJvTransparentButton,
    TpjhTJvTransparentButton2]); //

finalization
  UnRegisterClasses([TJvGIFAnimator,TpjhTJvLabel,TpjhTJvTransparentButton,
    TpjhTJvTransparentButton2]);//

end.
