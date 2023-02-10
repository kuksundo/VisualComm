unit UnitRevFlowInterface;

interface

uses
  Classes, UnitPipeData;

type
  IpjhPipeRevFlowInterface = interface ['{F004FD2F-BF79-4E9A-BB85-DD16ED7747C8}']
    function SetRevNextStepAuto(ADestComponent: TComponent): Boolean; overload;
    function SetAutoRevPrevStep(AComponent: TComponent): Boolean;
    function SetNilRevPrevStep(AComponentName: string): Boolean;
    function GetRevPrevStepFromName(ATriggerName: string): TPrevStepVar;
    function SetRevPrevStep4Source(ADestComponent: TComponent): Boolean;
    function GetRevPrevStepStatus(out AOnStatus: Boolean; var APrevStatus: TPipeInternalStatus): TComponent;
  end;

implementation

end.
