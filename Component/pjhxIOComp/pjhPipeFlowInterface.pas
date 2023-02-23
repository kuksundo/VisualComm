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
    //NextStep에 할당 된 Component Name List를 반환함
    //Circulation Check를 위해 사용됨
    function GetNextStepListWithComma: string;
    //PrevStep에 할당 된 Component Name List를 반환함
    //Circulation Check를 위해 사용됨
    function GetPrevStepListWithComma: string;
  end;

  TPipeFlowTree = class;

  TPipeFlowTree = class
  public
    FName: string;
    FVisitedIndex: integer;//1 = NextStep 처리 완료, 2 = NextStep2 처리 완료
    FIsVisited: Boolean;//Free할때 Cycle 존재 시 overflow 방지를 위해 사용됨
    //DFS로 순회할 때 도착시 Arrival 저장, Neighbor Node를 모두 순회하고 복귀 시 Departure 저장
    //Back Edge는 Departure[PrevNode] < Departure[NextNode] 인 경우 뿐이다.
    //Back Edge가 존재하면 Cycle이 Graph내에 존재한다는 의미임
    FArrival, FDeparture: integer;

    FNextStep, FNextStep2, FNextStep3,
    FPrevStep, FPrevStep2, FPrevStep3: TPipeFlowTree;
  end;

implementation

end.
