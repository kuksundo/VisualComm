unit UnitTransparentBtnInterface;

interface

uses
  Classes, pjhTJvTransparentButtonConst;

type
  IpjhTransparentBtnIntf = interface ['{3ADA31BE-2B22-47DC-93D9-10FDC930EB2F}']
    function ChangepjhBtnActionKind(AValue: TJvTransBtnActionKind): Boolean;
    function TogglepjhBtnActionKind: TJvTransBtnActionKind;
  end;

implementation

end.
