unit pjhCyCompList;

interface

uses Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
    pjhCyCompConst, pjhTCyBevel;//

  function GetPaletteList: TStringList;
  function GetBplFileName: string;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents ('pjhCyComp', [TpjhTCyBevel]); //
end;

function GetPaletteList: TStringList;
var
  LStr: string;
begin
  Result := TStringList.Create;
  LStr := 'CyComponent =';
  LStr := LStr + 'TpjhTCyBevel;';
  Result.Add(LStr);
end;

function GetBplFileName: string;
begin
  Result := pjhCyCompBplFileName;
end;

exports
  GetPaletteList,
  GetBplFileName;

initialization
//bpl�� �������� �ε��� RegisterClass�ص� GetClass�ÿ� nil�� return �Ǵ� ���� �߻�
//�ذ�: exe�� bpl project option���� vcl.dcp�� rtl.dcp�� ��������(release version)
  RegisterClasses([TpjhTCyBevel]); //

finalization
  UnRegisterClasses([TpjhTCyBevel]);//

end.
