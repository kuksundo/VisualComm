unit Unit4;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, iComponent, iVCLComponent,
  UnitJHCustomComponent, iValve_smh, pjhiValve_pjh, iPipe_pjh, pjhiPipe_pjh,
  iLed_pjh, iLedArrow_pjh, pjhiLedArrow_pjh, UnitJHPositionComponent, iTank_smh,
  pjhiTank_pjh;

type
  TForm4 = class(TForm)
    pjhiTank_pjh1: TpjhiTank_pjh;
    pjhiLedArrow_pjh1: TpjhiLedArrow_pjh;
    pjhiPipe_pjh1: TpjhiPipe_pjh;
    procedure pjhiValve_pjh1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.pjhiValve_pjh1Click(Sender: TObject);
begin
//  if pjhiValve_pjh1.ValveKnobPosition = vdTop then
//    pjhiValve_pjh1.ValveKnobPosition := vdBottom
//  else
//    pjhiValve_pjh1.ValveKnobPosition := vdTop;
end;

end.
