unit pjhPipeFlowInterface;

interface

uses
  Classes;

type
  IpjhPipeFlowInterface = interface ['{6451F56D-4C01-4A17-96CC-E8DB82CC29AA}']
    function SetNextStepAuto(ADestComponent: TComponent): Boolean; overload;
    //�̹� ������ NextStep�� ���� AWillDeleteComponent�� ������ ����
    function DeleteNextStep(AWillDeleteComponent: TComponent): Boolean; overload;
    function ClearXStep: Boolean;
    //�����ϴ� NextStep Propperty Name List�� ��ȯ�� (ex: 'NextStep,NextStep2,PrevNextStep')
    //CommandJson���� �����
    function GetXStepNameListWithComma: string;
    //NextStep�� �Ҵ� �� Component Name List�� ��ȯ��
    //Circulation Check�� ���� ����
    function GetNextStepListWithComma: string;
    //PrevStep�� �Ҵ� �� Component Name List�� ��ȯ��
    //Circulation Check�� ���� ����
    function GetPrevStepListWithComma: string;
  end;

  TPipeFlowTree = class;

  TPipeFlowTree = class
  public
    FName: string;
    FVisitedIndex: integer;//1 = NextStep ó�� �Ϸ�, 2 = NextStep2 ó�� �Ϸ�
    FIsVisited: Boolean;//Free�Ҷ� Cycle ���� �� overflow ������ ���� ����
    //DFS�� ��ȸ�� �� ������ Arrival ����, Neighbor Node�� ��� ��ȸ�ϰ� ���� �� Departure ����
    //Back Edge�� Departure[PrevNode] < Departure[NextNode] �� ��� ���̴�.
    //Back Edge�� �����ϸ� Cycle�� Graph���� �����Ѵٴ� �ǹ���
    FArrival, FDeparture: integer;

    FNextStep, FNextStep2, FNextStep3,
    FPrevStep, FPrevStep2, FPrevStep3: TPipeFlowTree;
  end;

implementation

end.
