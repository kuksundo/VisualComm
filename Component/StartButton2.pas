unit StartButton2;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, Menus, SerialCommLogic2;

type
  TpjhStartButton = class(TButton)
  private
    FStateMachine: TpjhLogicPanel;
    FSingleStep: Boolean;
    FAutoReset: Boolean;//���� ������ �Ϸ� ���� �ڵ����� �ʱ� ���·� ��
  protected

    procedure Click; override;
    procedure SetSingleStep(Value: Boolean);

    property LogicControl: TpjhLogicPanel read FStateMachine write FStateMachine;
  public
    constructor create(AOwner: TComponent); override;
  published

    property SingleStep: Boolean read FSingleStep write SetSingleStep;
    property AutoReset: Boolean read FAutoReset write FAutoReset;
  end;

implementation

uses CommLogic2;

{ TpjhStartButton }

procedure TpjhStartButton.Click;
begin
  if AutoReset then
  begin
    if SingleStep then
    begin
      if TComponent(LogicControl.State).ClassType = TpjhStopControl then
        LogicControl.Reset := AutoReset;
    end
    else
      LogicControl.Reset := AutoReset;
  end;

  if Assigned(LogicControl) then
    LogicControl.Execute;

  inherited;
end;

constructor TpjhStartButton.create(AOwner: TComponent);
var i: integer;
begin
  inherited;

  LogicControl := TpjhLogicPanel(AOwner);
{
  LogicControl := nil;

  for i := 0 to AOwner.ComponentCount - 1 do
  begin
    if AOwner.Components[i].ClassType = TpjhLogicPanel then
    begin
      LogicControl := TpjhLogicPanel(AOwner.Components[i]);
      break;
    end;
  end;
}
end;

procedure TpjhStartButton.SetSingleStep(Value: Boolean);
begin
  if FSingleStep <> Value then
  begin
    FSingleStep := Value;

    if Assigned(LogicControl) then
      if Value then
        LogicControl.Options := LogicControl.Options + [soSingleStep]
      else
        LogicControl.Options := LogicControl.Options - [soSingleStep];
  end;
end;

end.
