unit pjhPipeFlowInterface;

interface

uses
  Classes;

type
  IpjhPipeFlowInterface = interface ['{6451F56D-4C01-4A17-96CC-E8DB82CC29AA}']
    function SetNextStepAuto(ADestComponent: TComponent): Boolean; overload;
    //이미 설정된 NextStep에 만약 AWillDeleteComponent가 있으면 삭제
    function DeleteNextStep(AWillDeleteComponent: TComponent): Boolean; overload;
    function ClearXStep: Boolean;
    //존재하는 NextStep Propperty Name List를 반환함 (ex: 'NextStep,NextStep2,PrevNextStep')
    //CommandJson에서 사용함
    function GetXStepNameListWithComma: string;
  end;

implementation

end.
