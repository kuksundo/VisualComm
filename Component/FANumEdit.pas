unit FANumEdit;

{**************************OpenFAVCL PROJECT***********************************}
//  VCL NAME  : F.A NumberEdit(TFANumberEdit)
//  Copyright : Hwang Kwang IL(c) by 1998.2 ~ 2000.7
//  NOTE      :
//            - �� ���� �̿��Ͽ� ����� ����Ʈ��� �����ϰ� �Ǹ��ϴ� �������
//              ������ ȹ���ϴ� ������ ���ؼ��� ��ü ����.
//            - �� ���� �̿��Ͽ� ������Ʈ�� ����ϴ� ���� �㰡��.
//            - �� ���� �������� �ڵ带 �����ϴ� ���� �����ڿ��� �뺸���ִ�
//              ���� �Ͽ��� �㰡��(�ҽ������� ����)
//            - TNumberEdit ���� ������ ����(������ ������)
//  URL       : http://myhome.shinbiro.com/~opencomm
//  Email     : opencomm@shinbiro.com
//
{******************************************************************************}
//  B U G     F I X E D    &    M O D I F I E D      L I S T
//==============================================================================
//  1. 2000.7.10  by ����� (ksl@namyangmetals.co.kr)
//------------------------------------------------------------------------------
//     1) �ּҰ��� 0 �̻��� �� ������ FIXED.
//------------------------------------------------------------------------------
//        ������:   v := (FFAMemMan.GetR(FMemIndex) * abs(FAnalogMax-FAnalogMin) / FPlcMax) - (abs(0 - FAnalogMin))
//        ������:   v := (FFAMemMan.GetR(FMemIndex) * (FAnalogMax-FAnalogMin) / FPlcMax) + FAnalogMin
//------------------------------------------------------------------------------
//        ������:
//                  R_MEM : FFAMemMan.SetR(FDestMemIndex, (Trunc(v+abs(0.-FAnalogMin)) * FPlcMax) div Trunc((FAnalogMax - FAnalogMin)) );
//                  W_MEM : FFAMemMan.SetW(FDestMemIndex, (Trunc(v+abs(0.-FAnalogMin)) * FPlcMax) div Trunc((FAnalogMax - FAnalogMin)) );
//                  A_MEM : FFAMemMan.SetA(FDestMemIndex, (v * abs(FAnalogMax-FAnalogMin) / FPlcMax) - ( abs(0 - FAnalogMin)) );
//                  F_MEM : FFAMemMan.SetF(FDestMemIndex, (v * abs(FAnalogMax-FAnalogMin) / FPlcMax) - ( abs(0 - FAnalogMin)) );
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                  R_MEM : FFAMemMan.SetR(FDestMemIndex, (Trunc(v+abs(0.-FAnalogMin)) * FPlcMax) div Trunc((FAnalogMax - FAnalogMin)) );
//                                                                                                ~~~
//                                                                                                �̰� ������ ��Ȯ�� ���� ������ ����
//------------------------------------------------------------------------------
//        ������:
//                  R_MEM : FFAMemMan.SetR( FDestMemIndex, trunc(((v-FAnalogMin) * FPlcMax) / (FAnalogMax - FAnalogMin)) );
//                  W_MEM : FFAMemMan.SetW( FDestMemIndex, trunc(((v-FAnalogMin) * FPlcMax) / (FAnalogMax - FAnalogMin)) );
//                  A_MEM : FFAMemMan.SetA( FDestMemIndex, (v * (FAnalogMax-FAnalogMin) / FPlcMax) + FAnalogMin );
//                  F_MEM : FFAMemMan.SetF( FDestMemIndex, (v * (FAnalogMax-FAnalogMin) / FPlcMax) + FAnalogMin );
//==============================================================================
//  2. 2000.7.17  by ����� (ksl@namyangmetals.co.kr)
//------------------------------------------------------------------------------
//     1) ����Ÿ �̵�(FADestMemName) ��� ���� �����°��� Value���� �ƴ�, Memory���� ����ϵ��� ThisToMemManValue�Լ��� ����߰�
//        ���������� PLC�� ����Ÿ�� Convert�ؼ� ������ ��� �� ���� �ٸ� �޸𸮿� ������ �� Convert�ϸ� ������ ���̵ȴ�
//        Convert���� �ʰ� ������ ������ ������ PLC���� ������ ���� �ٸ� �޸𸮷� �ڵ� �̵� ��ų�� ����
//        Memory���� ����ϵ��� �����ϸ� �׳� ������ PLC���� ������ Convert�ϸ� Convert�� ���� ������ �ִ�
//     2) SetDestMemConvert�� Convert����(True,False) ������ ������ FDestMemName := NONE ���� ������� FDestMemName�� �״�� �ε��� ����
//     3) Memory Type�����Ҷ� �ùٸ��� ���� ������� ���� (SetDestMemConvert, SetMemName, SetDestMemName)
//     4) SetMemName - 3)���� ����� ���ؼ� �߰��� �Լ�
//     5) fmin, fmax���� �ּҰ� �� �ִ밪�� �������� ����
//        FAnalogMax,FAnalogMin�� ����� �� ���� FMax,FMin�� �ݿ����� �ʵ��� ����
//        ���������� ���ؼ� ������ FMax,FMin���� ���α׷� ���ට FAAnalogMax,FAAnalogMin������ �ٲ��� ������
//     6) �̸����� : SetDestMem -> SetDestMemName , SetMemMan -> SetFAMemMan
//                   ...SrcConvert -> ...Convert, ...Convert -> ...DestMemConvert
//     7) Convert�� ��Ȱ Ȯ��
//        R_MEM, W_MEM���� PLC�� ��(word)�� ����,  A_MEM, F_MEM���� �����Ͼ��(double)�� ����
//        ����, Convert�� Convert��� �޸𸮰� ����ΰ��� ���� PLC������ �Ǵ� �����Ͼ������ ��ȯ�ȴ�
{******************************************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FAMemMan_pjh, SyncObjs;

type
  TFANumberEdit = class(TEdit)
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

    Sect : TCriticalSection;

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
    procedure DoExit; override;
    procedure DoEnter; override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;

    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    procedure SetFAMemMan(mm:TpjhFAMemMan);
    procedure MemManValueToThis;
    procedure ThisToMemManValue;
  public
    { Public declarations }
    constructor Create (AOwner : TComponent);override;
    destructor Destroy; override;
    procedure Update; override;
    procedure ApplyUpdate;
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; override;
  published
    { Published declarations }
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


constructor TFANumberEdit.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Sect := TCriticalSection.Create;
  FFormatString := '%5.1n';
  fdec := decimalseparator;
  fdigits := 0;
  fmin := -999999999.0;
  fmax := 999999999.0;
  fertext := notext;
  FPlcMax := 2000;
  FAAnalogMax := 100;
  Tabstop := False;
  setvalue(0.0);
end;

destructor TFANumberEdit.Destroy;
begin
  if FFAMemMan <> nil then
    FFAMemMan.KickOutNewsMember(Self);
  Sect.Free;
  inherited Destroy;
end;

procedure TFANumberEdit.setvalue(Newvalue : extended);
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
  Text := floattostrf(newvalue,ffNumber,18,fdigits);
end;

procedure TFANumberEdit.SetFormat(const Value: string);
begin
  FFormatString := Value;
end;

function TFANumberEdit.GetFormat: string;
begin
  result := FFormatString;
end;

function TFANumberEdit.getvalue : extended;
var
  ts : string;
begin
  ts := text;
  if (ts = '-') or (ts = fdec) or (ts = '') then  ts := '0';
  try
    result := strtoNumber(ts);
  except
    result := fmin;
  end;

  if result < fmin then  result := fmin;
  if result > fmax then  result := fmax;
end;

procedure TFANumberEdit.setdigits;
begin
  if fdigits <> newValue then
  begin
    if newvalue > 18 then newvalue := 18;
    fdigits := newvalue;
    setvalue(getvalue);
  end;
end;

procedure TFANumberEdit.setmin;
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

procedure TFANumberEdit.setmax;
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

procedure TFANumberEdit.KeyPress;
var
  ts     : string;
  result : extended;
  ThisForm : TCustomForm;
begin
  if Key = #13 then                  // [Enter] Key ��� �����׸�����
  begin
    ThisForm := GetParentForm( Self );
    if not (ThisForm = nil ) then
       SendMessage(ThisForm.Handle, WM_NEXTDLGCTL, 0, 0);
    Key := #0;
  end;

  if key < #32 then
  begin
    inherited;
    exit;
  end;

  ts := copy(text,1,selstart)+copy(text,selstart+sellength+1,500);

  if (key <'0') or (key > '9') then
     if (key <> fdec) and (key <> '-') then
     begin
       inherited;
       key := #0;
       exit;
     end;
  if key = fdec then
     if pos(fdec,ts) <> 0 then
     begin
       inherited;
       key := #0;
       exit;
     end;
  if key = '-' then
     if pos('-',ts) <> 0 then
     begin
       inherited;
       key := #0;
       exit;
     end;
  if key = '-' then
     if fmin >= 0 then
     begin
       inherited;
       key := #0;
       exit;
     end;
  if key = fdec then
     if fdigits = 0 then
     begin
       inherited;
       key := #0;
       exit;
     end;

  ts := copy(text,1,selstart)+key+copy(text,selstart+sellength+1,500);

  if key > #32 then if pos(fdec,ts)<> 0 then
  begin
    if length(ts)-pos(fdec,ts) > fdigits then
    begin
      inherited;
      key := #0;
      exit;
    end;
  end;

  if key = '-' then
     if pos('-',ts) <> 1 then
     begin
       inherited;
       key := #0;
       exit;
     end;

  if ts ='' then
  begin
    inherited;key := #0;
    text := floattostrf(fmin,ffNumber,18,fdigits);selectall;
    // ���泻���� TLinkMem�� �ݿ�...
    ThisToMemManValue;
    exit;
  end;

  if ts = '-' then
  begin
    inherited;key:=#0;
    text := '-0';selstart := 1;sellength:=1;
    ThisToMemManValue;
    exit;
  end;

  if ts = fdec then
  begin
    inherited;key:=#0;
    text := '0'+fdec+'0';
    selstart :=2;
    sellength:=1;
    ThisToMemManValue;
    exit;
  end;

  try
     result := strtoNumber(ts);
  except
     if fertext <> notext then showmessage(fertext);
     inherited;
     key := #0;
     text := floattostrf(fmin,ffNumber,18,fdigits);
     selectall;
     ThisToMemManValue;
     exit;
  end;

  if result < fmin then
  begin
    inherited;
    key := #0;
    if fertext <> notext then showmessage(fertext);
    text := floattostrf(fmin,ffNumber,18,fdigits);
    selectall;
    ThisToMemManValue;
    exit;
  end;

  if result > fmax then
  begin
    inherited;key := #0;
    if fertext <> notext then showmessage(fertext);
    text := floattostrf(fmax,ffNumber,18,fdigits);
    selectall;
    ThisToMemManValue;
    exit;
  end;
  inherited;
end;

Function TFANumberEdit.StrToNumber(s:String) : Extended;
var
  r : Extended;
  i : integer;
  v : string;
Begin
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
End;

procedure TFANumberEdit.DoExit;
begin
  Text := floattostrf(value,ffNumber,18,fdigits);
  inherited;
  ThisToMemManValue;
end;

procedure TFANumberEdit.Change;
begin
  inherited;
  ThisToMemManValue;
end;

procedure TFANumberEdit.Update;
begin
  inherited;
  ThisToMemManValue;
end;

procedure TFANumberEdit.DoEnter;
begin
  Text := FloatToStrF(value,ffFixed,18,fdigits);
  SelStart  := 0;
  SelLength := Length(Text);
  inherited;
end;

procedure TFANumberEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or (ES_RIGHT or ES_MULTILINE);
end;

//****************************************************************************//

procedure TFANumberEdit.SetAnalogMax(A: Single);
begin
  if A <> FAnalogMax then
  begin
    FAnalogMax := A;
//    FMax := Trunc(A);
  end;
end;

procedure TFANumberEdit.SetAnalogMin(A: Single);
begin
  if A <> FAnalogMin then
  begin
    FAnalogMin := A;
//    FMin := Trunc(A);
  end;
end;

procedure TFANumberEdit.SetMemConvert(A: boolean);
begin
  if A <> FMemConvert then
  begin
    FMemConvert := A;
  end;
end;

procedure TFANumberEdit.SetMemName(A : TMemName);
begin
  if FMemName <> A then
  begin
    FMemName := A;
    SetDestMemName( FDestMemName );
  end;
end;

procedure TFANumberEdit.SetDestMemConvert(A: boolean);
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

procedure TFANumberEdit.SetDestMemName(A : TMemName);
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
procedure TFANumberEdit.SetFAMemMan(mm:TpjhFAMemMan);
begin
  FFAMemMan := mm;
end;

// The Notification method is called automatically when the component specified
// by AComponent is about to be inserted or removed. --> online help.
procedure TFANumberEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent,Operation);
  // ������ TFAMemMan�� ���� �Ǿ����� ���� �޾Ҵٸ�..
  if (Operation=opRemove) and (AComponent=FFAMemMan) then
    FFAMemMan := nil;
end;

procedure TFANumberEdit.Loaded;
begin
  inherited Loaded;
  // TFAMemMan�κ��� �޸� ����� �뺸�ޱ� ���Ͽ� �� ������Ʈ�� TFAMemMan�� ����Ѵ�.
  if FFAMemMan<>nil then
    FFAMemMan.RegisterNewsMember(Self, FAMemName, FAMemIndex);
end;

// TFAMemMan�� ���� �� ������Ʈ�� ����...
procedure TFANumberEdit.MemManValueToThis;
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

// �� ������Ʈ�� ���� TFAMemMan�� �ݿ���Ų��.
procedure TFANumberEdit.ThisToMemManValue;
var
  v : extended;
begin
  if (csDesigning in ComponentState) then
    Exit;

  // TFAMemMan�� �� ������Ʈ�� �����Ǿ��ٸ�..
  if FFAMemMan<>nil then
  begin
    // ����Ÿ �̵�(FADestMemName) ��� ���� �����°��� Value���� �ƴ�, Memory���� ���
    v := 0;
    Sect.Enter;
    case FMemName of
      R_MEM : v := FFAMemMan.GetR(FMemIndex);
      W_MEM : v := FFAMemMan.GetW(FMemIndex);
      A_MEM : v := FFAMemMan.GetA(FMemIndex);
      F_MEM : v := FFAMemMan.GetF(FMemIndex);
    end;
    if FDestMemConvert then
    begin
      case FDestMemName of
        {�����Ͼ��(double) --> PLC�� �Ƴ��αװ�(word)}
        R_MEM : FFAMemMan.SetR( FDestMemIndex, trunc(((v-FAnalogMin) * FPlcMax) / (FAnalogMax - FAnalogMin)) );
        W_MEM : FFAMemMan.SetW( FDestMemIndex, trunc(((v-FAnalogMin) * FPlcMax) / (FAnalogMax - FAnalogMin)) );
        {PLC�� �Ƴ��αװ�(word) --> �����Ͼ��(double)}
        A_MEM : FFAMemMan.SetA( FDestMemIndex, (v * (FAnalogMax-FAnalogMin) / FPlcMax) + FAnalogMin );
        F_MEM : FFAMemMan.SetF( FDestMemIndex, (v * (FAnalogMax-FAnalogMin) / FPlcMax) + FAnalogMin );
      end;
    end
    else
    begin
      case FDestMemName of
        R_MEM : FFAMemMan.SetR( FDestMemIndex, trunc(v) );
        W_MEM : FFAMemMan.SetW( FDestMemIndex, trunc(v) );
        A_MEM : FFAMemMan.SetA( FDestMemIndex, v );
        F_MEM : FFAMemMan.SetF( FDestMemIndex, v );
      end;
    end;
    Sect.Leave;
  end;
end;

// �� �Լ��� TFAMemMan���� ����� ���Ͽ� ���Ƿ� ���۵Ǿ���..
// ��뿡 �����ϱ� �ٶ�..
function TFANumberEdit.SafeCallException(ExceptObject: TObject;
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
procedure TFANumberEdit.ApplyUpdate;
begin
  // �޸� ���氪�� �ݿ�..
  Sect.Enter;
  MemManValueToThis;
  Sect.Leave;
end;

end.
