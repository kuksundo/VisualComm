unit pjhBalloonCompIntf;

interface

type
  //Balloon Component�� Design Screen���� Find�ϱ� ���� �� Interface�� �߰���
  //�� Interface�� ���� ��� Watch2.pas���� pjhTPanel�� Use���� ���� ���Ѿ� �ϸ�
  //�̴� �߰����� �۾��� �ʿ��ϱ� ������ ����
  IpjhBalloonCompInterface = interface ['{B0AC0E9D-9D35-457F-8951-2AA5CE5C34D9}']
    function GetBalloonRecordFromPropertyToJson(): string;
  end;

implementation

end.
