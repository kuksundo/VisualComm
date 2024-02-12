unit EasterEgg;

interface

uses classes, Forms;

type
  TOnEasterEgg = procedure(msg: string) of object;

  TEasternEgg = class(TObject)
  private
    FEgg: String; //���׹���
    FControlKey: TShiftState; //����Ű
    FCount: Integer;
    FOwner: TForm;

  public
    FOnEasterEgg: TOnEasterEgg;

    constructor create(ControlKey: TShiftState; Egg: string; Owner: TForm);
    Procedure CheckKeydown(var Key: Word; Shift: TShiftState);
    procedure ExecuteEasternEgg;
  end;

implementation

{ TEasternEgg }

//TForm�� OnKeyDown���� �� �Լ��� �����Ŵ
//ex) Egg.CheckKeydown(Key, Shift);
procedure TEasternEgg.CheckKeydown(var Key: Word; Shift: TShiftState);
begin
  //Are the correct control keys down?
  if Shift = FControlKey then
  begin
    //was the proper key pressed?
    if Key = Ord(FEgg[FCount]) then
    begin
      //was this the last keystroke in the sequence?
      if FCount = Length(FEgg) then
      begin
        //Code of the easter egg
        ExecuteEasternEgg;
        //failure - reset the count
        FCount := 1; {}
      end
      else
      begin
        //success - increment the count
        Inc(FCount);
      end;
    end
    else
    begin
      //failure - reset the count
      FCount := 1;
    end;
  end;
end;

//ControlKey�� Egg�� �����ϸ� ��Ȱ�� �ް��� ����
//Owner�� KeyPreview�� �ʿ��ϱ� ������
//ex)  Egg := TEasternEgg.Create([ssCtrl],'EGG',Self);
constructor TEasternEgg.create(ControlKey: TShiftState; Egg: string; Owner: TForm);
begin
  FCount := 1;
  FEgg := Egg;
  FOwner := Owner;
  FControlKey := ControlKey;
  FOwner.KeyPreview := True;
end;

//������ ����Ǵ� �Լ�
//ex)
//    public
//      procedure East(msg: string);
//           ...
//      Egg.FOnEasterEgg := East;
procedure TEasternEgg.ExecuteEasternEgg;
begin
  if Assigned(FOnEasterEgg) then
    FOnEasterEgg(FEgg);
end;

end.
