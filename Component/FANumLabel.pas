unit FANumLabel;

{**************************OpenFAVCL PROJECT***********************************}
//  VCL NAME  : F.A Number Label(TFANumLabel)
//  Copyright : Hwang Kwang IL(c) by 1998.2 ~ 2000.7
//  NOTE      :
//            - �� ���� �̿��Ͽ� ����� ����Ʈ��� �����ϰ� �Ǹ��ϴ� �������
//              ������ ȹ���ϴ� ������ ���ؼ��� ��ü ����.
//            - �� ���� �̿��Ͽ� ������Ʈ�� ����ϴ� ���� �㰡��.
//            - �� ���� �������� �ڵ带 �����ϴ� ���� �����ڿ��� �뺸���ִ�
//              ���� �Ͽ��� �㰡��(�ҽ������� ����)
//            - TLabel���� ���.
//  URL       : http://myhome.shinbiro.com/~opencomm
//  Email     : opencomm@shinbiro.com
//
{******************************************************************************}
//  B U G     F I X E D    &    M O D I F I E D      L I S T
//==============================================================================
//  1. 2000.7.17  by ����� (ksl@namyangmetals.co.kr)
//     1) FANumEdit.pas���� 2000.7.17������ ���� �ذ� �ݿ�
//------------------------------------------------------------------------------
//  2. 2000.7.23  by Ȳ���� (opencomm@shinbiro.com)
//     1) TFANumLabel�� Label�̹Ƿ� �Է���Ŀ���� �����Ƿ�...
//        ThisToMemMan ���ν����� �ǹ̰� ��� ����...
//     2) Alignment �Ӽ��� Create����  taRightJustify �� �����ʿ� ����
//        taLeft, taCenter �Ӽ��� ��Ÿ�ӿ��� ��ȿȭ ��. => ����.
{******************************************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FAMemMan_pjh;

type
  TFANumLabel = class(TLabel)
  private
    { Private declarations }
    FDigits   : byte;
    FFormatString : string;
    FMin,FMax : extended;
    fdec      : char;
    Fertext   : string;

    FFAMemMan : TpjhFAMemMan;
    FPlcMax   : SmallInt;
    FAnalogMin: Single;
    FAnalogMax: Single;
    FMemConvert : boolean;     // PLC���� �����ͼ� ������ �޸𸮿� ������ Convert���� ����
    FMemIndex : integer;       // PLC���� ������ ����Ÿ�� ������ �޸� ��ġ
    FMemName  : TMemName;      //                  "                    ����
    FDestMemConvert : boolean; // ������ �޸𸮿��ִ°��� �ٸ� �޸𸮿� ����� Convert���� ����
    FDestMemIndex: Integer;    // FMemName,FMemIndex�� ���簡 �Ǿ������� �޸� ��ġ
    FDestMemName : TMemName;   //                  "                            ����

    procedure SetAnalogMax(A: single);
    procedure SetAnalogMin(A: single);
    procedure SetMemConvert(A: boolean);
    procedure SetMemName(A: TMemName);
    procedure SetDestMemConvert(A: boolean);
    procedure SetDestMemName(A: TMemName);
  protected
    { Protected declarations }
    function GetFormat: string;
    procedure SetFormat(const Value: string);
    procedure setvalue(Newvalue : extended);
    procedure setmin(Newvalue : extended);
    procedure setmax(Newvalue : extended);
    procedure setdigits(Newvalue : byte);
    function getvalue : extended;
    Function StrToNumber(s:String) : Extended;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    procedure SetFAMemMan(mm:TpjhFAMemMan);
    procedure MemManValueToThis;
  public
    { Public declarations }
    constructor Create (AOwner : TComponent);override;
    destructor Destroy; override;
    procedure ApplyUpdate;
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; override;
  published
    { Published declarations }
    property Alignment;
    property Digits : byte read FDigits write setDigits;
    property Value : extended read getvalue write setValue;
    property Min : extended read Fmin write setMin;
    property Max : extended read Fmax write setmax;
    property ErrorMessage :string read fertext write fertext;
    property FormatStr : string read GetFormat write SetFormat;

    property FAMemoryManager: TpjhFAMemMan read FFAMemMan write SetFAMemMan;
    property FAMemName: TMemName read FMemName write SetMemName;
    property FAMemIndex: Integer read FMemIndex write FMemIndex;
    property FAMemConvert: boolean read FMemConvert write SetMemConvert;
    property FADestMemName: TMemName read FDestMemName write SetDestMemName;
    property FADestMemIndex: Integer read FDestMemIndex write FDestMemIndex;
    property FADestMemConvert: boolean read FDestMemConvert write SetDestMemConvert;
    property FAPLCAnalogRangeMax: smallint read FPlcMax write FPlcMax default 2000;
    property FAAnalogMax: single read FAnalogMax write SetAnalogMax;
    property FAAnalogMin: single read FAnalogMin write SetAnalogMin;
  end;

const
    notext       = '[No Text]';


implementation


constructor TFANumLabel.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FFormatString := '%5.1n';
  Font.Name := '����';
  Font.Size := 9;
  Font.Style := [fsBold];
  AutoSize := False;
  Width := 100;
  fdec := decimalseparator;
  FDigits := 1;
  fmin := -999999999.0;
  fmax :=  999999999.0;
  Fertext := notext;
  FPlcMax := 2000;
  FAAnalogMax := 100;
  setvalue(0.0);
end;

destructor TFANumLabel.Destroy;
begin
  if FFAMemMan <> nil then
    FFAMemMan.KickOutNewsMember(Self);
  inherited Destroy;
end;

procedure TFANumLabel.setvalue(Newvalue : extended);
begin
  if newvalue > fmax then
  begin
    if fertext <> notext then
      showmessage(fertext);
    newvalue := fmax;
  end;
  if newvalue < fmin then
  begin
    if fertext <> notext then
      showmessage(fertext);
    newvalue := fmin;
  end;
  Caption := floattostrf(newvalue,ffNumber,18,fdigits);

end;

procedure TFANumLabel.SetFormat(const Value: string);
begin
  FFormatString := Value;
end;

function TFANumLabel.GetFormat: string;
begin
  result := FFormatString;
end;

function TFANumLabel.getvalue : extended;
var
  ts : string;
begin
  ts := Caption;
  if (ts = '-') or (ts = fdec) or (ts = '') then  ts := '0';
  try
    result := strtoNumber(ts);
  except
    result := fmin;
  end;

  if result < fmin then  result := fmin;
  if result > fmax then  result := fmax;
end;

procedure TFANumLabel.setdigits;
begin
  if fdigits <> newValue then
  begin
    if newvalue > 18 then newvalue := 18;
    fdigits := newvalue;
    setvalue(getvalue);
  end;
end;

procedure TFANumLabel.setmin;
begin
  if fmin <> newValue then
  begin
    if fmin > fmax then
    begin
      showmessage('Min-Value has to be less than or equal to Max-Value !');
      newvalue := fmax;
    end;
    fmin := newvalue;
    setvalue(getvalue);
  end;
end;

procedure TFANumLabel.setmax;
begin
  if fmax <> newValue then
  begin
    if fmin > fmax then
    begin
      showmessage('Max-Value has to be greater than or equal to Min-Value !');
      newvalue := fmin;
    end;
    fmax := newvalue;
    setvalue(getvalue);
  end;
end;

Function TFANumLabel.StrToNumber(s:String) : Extended;
var
  r : Extended;
  i : integer;
  v : string;
begin
  v := '';
  for i := 1 to Length(s) do
  begin
    if s[i] in ['-','.','0'..'9'] then
       v := v + s[i]
    else if (s[i]<>',') and (s[i]<>' ') then
         begin
           StrToNumber := 0;
           exit;
         end;
  end;

  Val(v,r,i);

  if i = 0 then
    StrToNumber := r
  else
    StrToNumber := 0;
end;

//****************************************************************************//

procedure TFANumLabel.SetAnalogMax(A: Single);
begin
  if A <> FAnalogMax then
  begin
    FAnalogMax := A;
//    FMax := Trunc(A);
  end;
end;

procedure TFANumLabel.SetAnalogMin(A: Single);
begin
  if A <> FAnalogMin then
  begin
    FAnalogMin := A;
//    FMin := Trunc(A);
  end;
end;

procedure TFANumLabel.SetMemConvert(A: boolean);
begin
  if A <> FMemConvert then
  begin
    FMemConvert := A;
  end;
end;

procedure TFANumLabel.SetMemName(A : TMemName);
begin
  if FMemName <> A then
  begin
    FMemName := A;
    SetDestMemName( FDestMemName );
  end;
end;

procedure TFANumLabel.SetDestMemConvert(A: boolean);
begin
  if A <> FDestMemConvert then
  begin
    FDestMemConvert := A;
    if not FDestMemConvert then
      //FDestMemName := NONE
    else
      if FDestMemName <> NONE then
        SetDestMemName( FDestMemName );
  end;
end;

procedure TFANumLabel.SetDestMemName(A : TMemName);
begin
  FDestMemName := NONE;  // �ʱ�ȭ (SetDestMemConvert���� ȣ�⶧ ����)
  // DestMemConvert �� True�̸�
  if FDestMemConvert then
  begin
    if (FMemName = A_MEM) or (FMemName = F_MEM) then
      if (A = R_MEM) or (A = W_MEM) then
        FDestMemName := A
      else
        ShowMessage('DestMemConvert�� True�϶� FAMemName�� A,F_MEM�̸�'+chr(13)+chr(13)+'FADestMemName�� R,W_MEM���� �����Ǿ�� ��');
    if (FMemName = R_MEM) or (FMemName = W_MEM) then
      if (A = A_MEM) or (A = F_MEM) then
        FDestMemName := A
      else
        ShowMessage('DestMemConvert�� True�϶� FAMemName�� R,W_MEM�̸�'+chr(13)+chr(13)+'FADestMemName�� A,F_MEM���� �����Ǿ�� ��');
  end
  else
    FDestMemName := A;
end;

//------------------------------------------------------------------------------
// ���� TFAMemoryManager �� ����� ���� ���ν�����
//------------------------------------------------------------------------------

// TpjhFAMemMan VCL�� ����� �� ....
procedure TFANumLabel.SeTFAMemMan(mm:TpjhFAMemMan);
begin
  FFAMemMan := mm;
end;

// The Notification method is called automatically when the component specified
// by AComponent is about to be inserted or removed. --> online help.
procedure TFANumLabel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent,Operation);
  // ������ TFAMemMan�� ���� �Ǿ����� ���� �޾Ҵٸ�..
  if (Operation=opRemove) and (AComponent=FFAMemMan) then
    FFAMemMan := nil;
end;

procedure TFANumLabel.Loaded;
begin
  inherited Loaded;
  // TFAMemMan�κ��� �޸� ����� �뺸�ޱ� ���Ͽ� �� ������Ʈ�� TFAMemMan�� ����Ѵ�.
  if FFAMemMan<>nil then
    FFAMemMan.RegisterNewsMember(Self, FAMemName, FAMemIndex);
end;

// TFAMemMan�� ���� �� ������Ʈ�� ����...
procedure TFANumLabel.MemManValueToThis;
var
  v: extended;
begin
  if (csDesigning in ComponentState) then
    Exit;

  v := 0; //�ʱ�ȭ..
  // TFAMemMan�� �� ������Ʈ�� �����Ǿ��ٸ�..
  if FFAMemMan<>nil then
  begin
    // TFAMemMan�� ���� ������ Casting�Ѵ�..
    if FMemConvert then
    begin
      case FMemName of
        {PLC�� �Ƴ��αװ�(word) --> �����Ͼ��(double)}
        R_MEM : v := (FFAMemMan.GetR(FMemIndex) * (FAnalogMax-FAnalogMin) / FPlcMax) + FAnalogMin;
        W_MEM : v := (FFAMemMan.GetW(FMemIndex) * (FAnalogMax-FAnalogMin) / FPlcMax) + FAnalogMin;
        {�����Ͼ��(double) --> PLC�� �Ƴ��αװ�(word)}
        A_MEM : v := trunc(((FFAMemMan.GetA(FMemIndex)-FAnalogMin) * FPlcMax) / (FAnalogMax - FAnalogMin));
        F_MEM : v := trunc(((FFAMemMan.GetF(FMemIndex)-FAnalogMin) * FPlcMax) / (FAnalogMax - FAnalogMin));
      end;
    end
    else
    begin
      case FMemName of
        R_MEM : v := FFAMemMan.GetR(FMemIndex);
        W_MEM : v := FFAMemMan.GetW(FMemIndex);
        A_MEM : v := FFAMemMan.GetA(FMemIndex);
        F_MEM : v := FFAMemMan.GetF(FMemIndex);
      end;
    end;
    // ���� VCL�� �ݿ�.....
    Value := v;
  end;
end;


// �� �Լ��� TFAMemMan���� ����� ���Ͽ� ���Ƿ� ���۵Ǿ���..
// ��뿡 �����ϱ� �ٶ�..
function TFANumLabel.SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult;
var
  bFromMemMan: boolean;
begin
  // TpjhFAMemMan ���� ȣ��� �������� Ȯ���ϴ� ����..
  bFromMemMan := False;

  if FFAMemMan<>nil then
  begin
    if (FFAMemMan = ExceptObject) and (ExceptAddr=nil) then
      bFromMemMan := True;
  end;

  // TFAMemMan���� ȣ��� ���� Ȯ���ϴٸ�..
  if bFromMemMan then
  begin
    Result := 0;
    ApplyUpdate; // ���� ���� ����...
  end
  else
  begin
    // ������ �뵵�� ȣ��Ȱ��̶��... ���� �Լ��� Call..
    Result := inherited SafeCallException(ExceptObject,ExceptAddr);
  end;
end;

// ���α׷� �󿡼� Ȥ�� TpjhFAMemMan �� ���ؼ� ȣ��ȴ�..
procedure TFANumLabel.ApplyUpdate;
begin
  // �޸� ���氪�� �ݿ�..
  MemManValueToThis;
end;

end.
