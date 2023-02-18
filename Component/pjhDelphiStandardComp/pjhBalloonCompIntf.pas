unit pjhBalloonCompIntf;

interface

type
  //Balloon Component를 Design Screen에서 Find하기 위해 본 Interface를 추가함
  //본 Interface가 없을 경우 Watch2.pas에서 pjhTPanel을 Use절에 포함 시켜야 하며
  //이는 추가적인 작업이 필요하기 떄문에 피함
  IpjhBalloonCompInterface = interface ['{B0AC0E9D-9D35-457F-8951-2AA5CE5C34D9}']
    function GetBalloonRecordFromPropertyToJson(): string;
  end;

implementation

end.
