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
  end;

implementation

end.