unit pjhLabel4HiMECS;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Extctrls,
  pjhclasses, pjhDesignCompIntf, pjhDelphiStandardCompConst;

type
  TpjhLabel4HiMECSA2AABB = class(TLabel, IpjhDesignCompInterface)
  protected
    //For IpjhDesignCompInterface
    FpjhTagInfo: TpjhTagInfo;
    FpjhValue: string;
    FpjhBplFileName: string;

    FMajorVer,
    FMinorVer: integer;

    function GetpjhValue: string;
    procedure SetpjhValue(AValue: string);
    function GetpjhTagInfo: TpjhTagInfo;
    procedure SetpjhTagInfo(AValue: TpjhTagInfo);
    function GetBplFileName: string;
    procedure SetBplFileName(AValue: string);
    //For IpjhDesignCompInterface
  public
    constructor Create(AOwner: TComponent);  override;
    destructor  Destroy;                     override;
  published
    //For IpjhDesignCompInterface
    property pjhTagInfo: TpjhTagInfo read GetpjhTagInfo write SetpjhTagInfo;
    property pjhValue: string read GetpjhValue write SetpjhValue;
    property pjhBplFileName: string read GetBplFileName write SetBplFileName;
    //For IpjhDesignCompInterface
  end;

  TpjhLabel4HiMECSA2CC = class(TLabel, IpjhDesignCompInterface)
  protected
    //For IpjhDesignCompInterface
    FpjhTagInfo: TpjhTagInfo;
    FpjhValue: string;
    FpjhBplFileName: string;

    FRevision: integer;

    function GetpjhValue: string;
    procedure SetpjhValue(AValue: string);
    function GetpjhTagInfo: TpjhTagInfo;
    procedure SetpjhTagInfo(AValue: TpjhTagInfo);
    function GetBplFileName: string;
    procedure SetBplFileName(AValue: string);
    //For IpjhDesignCompInterface
  public
    constructor Create(AOwner: TComponent);  override;
    destructor  Destroy;                     override;
  published
    //For IpjhDesignCompInterface
    property pjhTagInfo: TpjhTagInfo read GetpjhTagInfo write SetpjhTagInfo;
    property pjhValue: string read GetpjhValue write SetpjhValue;
    property pjhBplFileName: string read GetBplFileName write SetBplFileName;
    //For IpjhDesignCompInterface
  end;

implementation

uses JHP.Util.Bit;

{ TpjhDateTimeLabel }

constructor TpjhLabel4HiMECSA2AABB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhDelphiStandardBplFileName;
end;

destructor TpjhLabel4HiMECSA2AABB.Destroy;
begin
  FpjhTagInfo.Free;

  inherited;
end;

function TpjhLabel4HiMECSA2AABB.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhLabel4HiMECSA2AABB.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhLabel4HiMECSA2AABB.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

procedure TpjhLabel4HiMECSA2AABB.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

procedure TpjhLabel4HiMECSA2AABB.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhLabel4HiMECSA2AABB.SetpjhValue(AValue: string);
var
  iValue: integer;
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;

    iValue := StrToIntDef(FpjhValue, 0);
    FMajorVer := ExtractBitsLRFromInt(iValue, 1, 8);
    FMinorVer := ExtractBitsLRFromInt(iValue, 9, 8);

    Caption := IntToStr(FMajorVer) + '.' + IntToStr(FMinorVer);
  end;
end;

{ TpjhLabel4HiMECSA2CC }

constructor TpjhLabel4HiMECSA2CC.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhDelphiStandardBplFileName;
end;

destructor TpjhLabel4HiMECSA2CC.Destroy;
begin
  FpjhTagInfo.Free;

  inherited;
end;

function TpjhLabel4HiMECSA2CC.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhLabel4HiMECSA2CC.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhLabel4HiMECSA2CC.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

procedure TpjhLabel4HiMECSA2CC.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

procedure TpjhLabel4HiMECSA2CC.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhLabel4HiMECSA2CC.SetpjhValue(AValue: string);
var
  iValue: integer;
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;

    iValue := StrToIntDef(FpjhValue, 0);
    FRevision := ExtractBitsLRFromInt(iValue, 1, 8);

    Caption := '.' + IntToStr(FRevision);
  end;
end;

end.

