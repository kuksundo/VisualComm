{***************************************************************************}
{ Delphi IDE�� ����ϱ� ����                                         }
{***************************************************************************}

unit pjhTMSCompReg;

interface

uses
  pjhAdvCircularProgress, Classes;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('pjhTMS',[TpjhAdvCircularProgress]);
end;

end.
