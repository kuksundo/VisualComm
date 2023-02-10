unit pjhiSevenSegmentHexaDecimal;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Menus,
  iSevenSegmentHexaDecimal, pjhclasses, pjhDesignCompIntf, pjhIOCompStdConst;

type
  TpjhiSevenSegmentHexaDecimal = class(TiSevenSegmentHexaDecimal, IpjhDesignCompInterface)
  protected
    //For IpjhDesignCompInterface
    FpjhTagInfo: TpjhTagInfo;
    FpjhValue: string;
    FpjhBplFileName: string;

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

{ TpjhiSevenSegmentHexaDecimal }

constructor TpjhiSevenSegmentHexaDecimal.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FpjhTagInfo := TpjhTagInfo.Create;
  FpjhBplFileName := pjhIOCompStdBplFileName;
end;

destructor TpjhiSevenSegmentHexaDecimal.Destroy;
begin
  FpjhTagInfo.Free;
  inherited;
end;

function TpjhiSevenSegmentHexaDecimal.GetBplFileName: string;
begin
  Result := FpjhBplFileName;
end;

function TpjhiSevenSegmentHexaDecimal.GetpjhTagInfo: TpjhTagInfo;
begin
  Result := FpjhTagInfo;
end;

function TpjhiSevenSegmentHexaDecimal.GetpjhValue: string;
begin
  Result := FpjhValue;
end;

procedure TpjhiSevenSegmentHexaDecimal.SetBplFileName(AValue: string);
begin
  FpjhBplFileName := AValue;
end;

procedure TpjhiSevenSegmentHexaDecimal.SetpjhTagInfo(AValue: TpjhTagInfo);
begin
  FpjhTagInfo.Assign(AValue);
end;

procedure TpjhiSevenSegmentHexaDecimal.SetpjhValue(AValue: string);
begin
  if FpjhValue <> AValue then
  begin
    FpjhValue := AValue;
    Value := AValue;
  end;
end;

end.

