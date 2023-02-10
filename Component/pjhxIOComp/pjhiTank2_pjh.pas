unit pjhiTank2_pjh;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  iTank_smh, pjhclasses, pjhDesignCompIntf, pjhPipeFlowInterface,
  pjhxIOCompConst, pjhiTank_pjh;

type
  TpjhiTank2_pjh = class(TpjhiTank_pjh)
  published
    property NextStep3;
  end;

implementation

end.
