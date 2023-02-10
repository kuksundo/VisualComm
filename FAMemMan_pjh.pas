unit FAMemMan_pjh;

{******************************************************************************}
//  VCL NAME  : F.A Memory Manager(TFAMemMan)
//  Copyright : Hwang Kwang IL(c) by 1998.2 ~ 2000.7
//  NOTE      :
//            - �� ���� �̿��Ͽ� ����� ����Ʈ��� �����ϰ� �Ǹ��ϴ� �������
//              ������ ȹ���ϴ� ������ ���ؼ��� ��ü ����.
//            - �� ���� �̿��Ͽ� ������Ʈ�� ����ϴ� ���� �㰡��.
//            - �� ���� �������� �ڵ带 �����ϴ� ���� �����ڿ��� �뺸���ִ�
//              ���� �Ͽ��� �㰡��(�ҽ������� ����)
//  URL       : http://myhome.shinbiro.com/~opencomm
//  Email     : opencomm@shinbiro.com
{******************************************************************************}
//  B U G     F I X E D    &    M O D I F I E D      L I S T
//==============================================================================
//  1. 2000.7.10  by ����� (ksl@namyangmetals.co.kr)
//------------------------------------------------------------------------------
//     1) �޸� �� ���� �̺�Ʈ �߰�.(OnRMemChange/OnWMemChange/OnAMemChange/OnFMemChange)
//     2) procedure TFAMemMan.ApplyUpdate �Լ� ����ȭ.
//==============================================================================
//  2. 2000.7.11  by ����� (ksl@namyangmetals.co.kr)
//------------------------------------------------------------------------------
//     1) A �� F �޸𸮿� ����Ÿ ������ ��Ȯ�� ���� ������� TYPE�� ����
//        ��) ������ : A : TSingleArray;   -->   A : TDoubleArray;
{******************************************************************************}
//==============================================================================
//  3. 2001.7.22  by Ȳ���� (opencomm@shinbiro.com)
//------------------------------------------------------------------------------
//     1) TDoubleArray�� TSmallIntArray�� MxArrays.dcu�� Ŭ������ �̿��� ���̾
//        Standard, Pro���������� ���Ұ��Ͽ���.
//     2) WindowsAPI Memory Mapped File�� ����ϴ� ������ ����.
//     3) TFAMemMan�� ����ϴ� ���α׷����� TFAMemMan�� name �� ���� �����ϸ�
//        �ܺ����α׷����� ������ �޸𸮿� ���� ���ų� �о�� �� �ְ� �Ǿ���
//        ���� �޸𸮸� �＼���� �� ���� �Ͼ�� VXD ���α׷� �浹�� ������ ��
//        �ְ� �Ǿ���.
//        ���� TSmallIntArray �� ���� Heap�� ����Ͽ� �޸𸮸� �Ҵ��Ͽ��� ����
//        TCriticalSection ó���� ���ؾ߸� ġ������ VXD ������ ����� �� �ִٴ�
//        ���� ����� ���� ������Ʈ���� �� �� �ְ� �Ǿ���.
//        �̴� ��Ƽ �����忡�� ���� ������ ���� ���� �ð��� �＼�� �� ���
//        �߻��� �� �ִ� ġ������ ��� ������ ���� �ٺ������� ��ó�ϰ��� ��.
{******************************************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Syncobjs, Buttons, pjhClasses;

type
  TMemName = (NONE, A_MEM, F_MEM, R_MEM, W_MEM);

  TAMemChangeEvent = procedure(Sender: TObject; Index: Smallint; preValue, Value: Double) of object;
  TFMemChangeEvent = procedure(Sender: TObject; Index: Smallint; preValue, Value: Double) of object;
  TRMemChangeEvent = procedure(Sender: TObject; Index, preValue, Value: Smallint) of object;
  TWMemChangeEvent = procedure(Sender: TObject; Index, preValue, Value: Smallint) of object;

  TpjhFAMemMan = class;
{  TMyWatchThread = class;
 }
  TNewsMember = class
    FComponent: TComponent;
    FMemName: TMemName;
    FMemIndex: Smallint;
    constructor Create;
    procedure ApplyUpdate(sm: TpjhFAMemMan);
  end;

  TpjhFAMemMan = class(TWrapperControl)//TSpeedButton)
  private
{    FWatchThread: TMyWatchThread;
    FServer: Boolean;
 }
    { Private declarations }
    FOnAMemChange: TAMemChangeEvent;
    FOnFMemChange: TFMemChangeEvent;
    FOnRMemChange: TRMemChangeEvent;
    FOnWMemChange: TWMemChangeEvent;

    FNewsMembers: TList;                //����� ������Ʈ ���...

    FAMemoryCount: SmallInt;
    FFMemoryCount: SmallInt;
    FRMemoryCount: SmallInt;
    FWMemoryCount: SmallInt;

    //���޸�...
    A: THandle;
    F: THandle;
    R: THandle;
    W: THandle;
    lpDataA: LPSTR;
    lpDataF: LPSTR;
    lpDataR: LPSTR;
    lpDataW: LPSTR;
    Sect: TCriticalSection;

{    procedure SetServer(Value: Boolean);}

    procedure SetAMemoryCount(Cnt: SmallInt);
    procedure SetFMemoryCount(Cnt: SmallInt);
    procedure SetRMemoryCount(Cnt: SmallInt);
    procedure SetWMemoryCount(Cnt: SmallInt);
  protected
    { Protected declarations }
    procedure loaded; override;
    procedure DestroyNewsMembers;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    //�ܺ� �޽��
    function GetA(Index: SmallInt): Double;
    function GetF(Index: SmallInt): Double;
    function GetR(Index: SmallInt): SmallInt;
    function GetW(Index: SmallInt): SmallInt;

    procedure SetA(Index: SmallInt; Value: Double);
    procedure SetF(Index: SmallInt; Value: Double);
    procedure SetR(Index: SmallInt; Value: SmallInt);
    procedure SetW(Index: SmallInt; Value: SmallInt);

    procedure RegisterNewsMember(AComponent: TComponent; AMemName: TMemName; AMemIndex: Smallint);
    procedure KickOutNewsMember(AComponent: TComponent);
    procedure ApplyUpdate(AMemName: TMemName; AMemIndex: Smallint);
  published
    { Published declarations }
{    property IsServer: Boolean read FServer write SetServer;}

    property FA_A_Count: SmallInt read FAMemoryCount write SetAMemoryCount default 100;
    property FA_F_Count: SmallInt read FFMemoryCount write SetFMemoryCount default 100;
    property FA_R_Count: SmallInt read FRMemoryCount write SetRMemoryCount default 100;
    property FA_W_Count: SmallInt read FWMemoryCount write SetWMemoryCount default 100;

    property OnAMemChange: TAMemChangeEvent read FOnAMemChange write FOnAMemChange;
    property OnFMemChange: TFMemChangeEvent read FOnFMemChange write FOnFMemChange;
    property OnRMemChange: TRMemChangeEvent read FOnRMemChange write FOnRMemChange;
    property OnWMemChange: TWMemChangeEvent read FOnWMemChange write FOnWMemChange;
  end;

{  TMyWatchThread = class(TThread)
  protected
    FWatchEvent: TEvent;
    FOwner: TpjhFAMemMan;

    procedure Execute; override;
  public
    FCurrentMemName: TMemName;
    FCurrentMemIndex: SmallInt;

    constructor Create(AOwner: TpjhFAMemMan);
    destructor Destroy; override;
  end;
}
implementation

constructor TpjhFAMemMan.Create(AOwner: TComponent);
begin
  inherited Create(AOWner);

  Visible := False;
  
  FNewsMembers := TList.Create;
  FAMemoryCount := 1000;
  FFMemoryCount := 1000;
  FRMemoryCount := 1000;
  FWMemoryCount := 1000;
  Sect := TCriticalSection.Create;
  //Self.Glyph.LoadFromResourceName(HInstance, PChar(String(ClassName)));
end;

destructor TpjhFAMemMan.Destroy;
begin
  Sect.Free;
  UnMapViewOfFile(lpDataA);
  UnMapViewOfFile(lpDataF);
  UnMapViewOfFile(lpDataR);
  UnMapViewOfFile(lpDataW);

  CloseHandle(A);
  CloseHandle(F);
  CloseHandle(R);
  CloseHandle(W);

  if Assigned(FNewsMembers) then
    DestroyNewsMembers;
  FNewsMembers.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TpjhFAMemMan.loaded;
begin
  try
    A :=
      CreateFileMapping(
      $FFFFFFFF,                        // ���� ���� ����.
      nil,                              // ���ȹ��� �Ű� �� ��.
      PAGE_READWRITE,                   // �а� �� ����.
      0,                                // ũ�� ���� DWORD
      (FA_A_Count - 1) * SizeOf(Double), // ũ�� ���� DWORD
      PChar(Name + '_A')                // �޸� ������ �̸�
      );

    if (A = 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
      A := OpenFileMapping(PAGE_READWRITE, True, PChar(Name + '_A'));

    F :=
      CreateFileMapping(
      $FFFFFFFF,                        // ���� ���� ����.
      nil,                              // ���ȹ��� �Ű� �� ��.
      PAGE_READWRITE,                   // �а� �� ����.
      0,                                // ũ�� ���� DWORD
      (FA_F_Count - 1) * SizeOf(Double), // ũ�� ���� DWORD
      PChar(Name + '_F')                // �޸� ������ �̸�
      );

    if (A = 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
      A := OpenFileMapping(PAGE_READWRITE, True, PChar(Name + '_F'));

    R :=
      CreateFileMapping(
      $FFFFFFFF,                        // ���� ���� ����.
      nil,                              // ���ȹ��� �Ű� �� ��.
      PAGE_READWRITE,                   // �а� �� ����.
      0,                                // ũ�� ���� DWORD
      (FA_R_Count - 1) * SizeOf(SmallInt), // ũ�� ���� DWORD
      PChar(Name + '_R')                // �޸� ������ �̸�
      );

    if (A = 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
      A := OpenFileMapping(PAGE_READWRITE, True, PChar(Name + '_R'));

    W :=
      CreateFileMapping(
      $FFFFFFFF,                        // ���� ���� ����.
      nil,                              // ���ȹ��� �Ű� �� ��.
      PAGE_READWRITE,                   // �а� �� ����.
      0,                                // ũ�� ���� DWORD
      (FA_R_Count - 1) * SizeOf(SmallInt), // ũ�� ���� DWORD
      PChar(Name + '_W')                // �޸� ������ �̸�
      );

    if (A = 0) and (GetLastError() = ERROR_ALREADY_EXISTS) then
      A := OpenFileMapping(PAGE_READWRITE, True, PChar(Name + '_W'));

    lpDataA := MapViewOfFile(A, FILE_MAP_WRITE, 0, 0, 0);
    lpDataF := MapViewOfFile(F, FILE_MAP_WRITE, 0, 0, 0);
    lpDataR := MapViewOfFile(R, FILE_MAP_WRITE, 0, 0, 0);
    lpDataW := MapViewOfFile(W, FILE_MAP_WRITE, 0, 0, 0);

  except
    ShowMessage('�޸� �Ҵ� ����');
  end;
end;


procedure TpjhFAMemMan.SetAMemoryCount(Cnt: SmallInt);
begin
  if FAMemoryCount <> Cnt then
    FAMemoryCount := Cnt;
end;

procedure TpjhFAMemMan.SetFMemoryCount(Cnt: SmallInt);
begin
  if FFMemoryCount <> Cnt then
    FFMemoryCount := Cnt;
end;

procedure TpjhFAMemMan.SetRMemoryCount(Cnt: SmallInt);
begin
  if FRMemoryCount <> Cnt then
    FRMemoryCount := Cnt;
end;

procedure TpjhFAMemMan.SetWMemoryCount(Cnt: SmallInt);
begin
  if FWMemoryCount <> Cnt then
    FWMemoryCount := Cnt;
end;

function TpjhFAMemMan.GetA(Index: SmallInt): Double;
var
  val               : Double;
begin
  if Index > FAMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Result := 0;
    Exit;
  end;
  //Sect.Enter;
  try
    val := 0;
    Move(lpDataA[Index * (SizeOf(Double))], val, SizeOf(Double));
    Result := val;
  finally
    //Sect.Leave;
  end;
end;

function TpjhFAMemMan.GetF(Index: SmallInt): Double;
var
  val               : Double;
begin
  if Index > FFMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Result := 0;
    Exit;
  end;
  //Sect.Enter;
  try
    val := 0;
    Move(lpDataF[Index * (SizeOf(Double))], val, SizeOf(Double));
    Result := val;
  finally
   // Sect.Leave;
  end;
end;

function TpjhFAMemMan.GetR(Index: SmallInt): smallint;
var
  val               : SmallInt;
begin
  if Index > FRMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Result := 0;
    Exit;
  end;
//  Sect.Enter;
  try
    val := 0;
    Move(lpDataR[Index * (SizeOf(SmallInt))], val, SizeOf(SmallInt));
    Result := val;
  finally
   // Sect.Leave;
  end;
end;

function TpjhFAMemMan.GetW(Index: SmallInt): smallint;
var
  val               : SmallInt;
begin
  if Index > FWMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Result := 0;
    Exit;
  end;
  //Sect.Enter;
  try
    val := 0;
    Move(lpDataW[Index * (SizeOf(SmallInt))], val, SizeOf(SmallInt));
    Result := val;
  finally
   // Sect.Leave;
  end;
end;

//------------------------------------------------------------------------------

procedure TpjhFAMemMan.SetA(Index: smallInt; Value: Double);
var
  pre_val           : Double;
begin
  if Index > FAMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Exit;
  end;
 // Sect.Enter;
  try
    pre_val := GetA(Index);             //--+
    Move(Value, lpDataA[Index * SizeOf(Double)], SizeOf(Value));

    if Assigned(FOnAMemChange) and (pre_val <> Value) then //--+ Change Event��
      FOnAMemChange(Self, Index, pre_val, Value); //--+
    ApplyUpdate(A_MEM, Index);          //��ϵ� �ܺ� ������Ʈ���� �����͸� ��������� �뺸...
  finally
   // Sect.Leave;
  end;
end;

procedure TpjhFAMemMan.SetF(Index: smallInt; Value: Double);
var
  pre_val           : Double;
begin
  if Index > FFMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Exit;
  end;
  //Sect.Enter;
  try
    pre_val := GetF(Index);             //--+
    Move(Value, lpDataF[Index * SizeOf(Double)], SizeOf(Value));

    if Assigned(FOnFMemChange) and (pre_val <> Value) then //--+ Change Event��
      FOnFMemChange(Self, Index, pre_val, Value); //--+
    ApplyUpdate(F_MEM, Index);          //��ϵ� �ܺ� ������Ʈ���� �����͸� ��������� �뺸...
  finally
    //Sect.Leave;
  end;
end;

procedure TpjhFAMemMan.SetR(Index: smallInt; Value: SmallInt);
var
  pre_val           : SmallInt;
begin
  if Index > FRMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Exit;
  end;
  //Sect.Enter;
  try
    pre_val := GetR(Index);             //--+
    Move(Value, lpDataR[Index * SizeOf(SmallInt)], SizeOf(Value));

    if Assigned(FOnRMemChange) and (pre_val <> Value) then //--+ Change Event��
      FOnRMemChange(Self, Index, pre_val, Value); //--+
    ApplyUpdate(R_MEM, Index);          //��ϵ� �ܺ� ������Ʈ���� �����͸� ��������� �뺸...
  finally
    //Sect.Leave;
  end;
end;

procedure TpjhFAMemMan.SetW(Index: smallInt; Value: SmallInt);
var
  pre_val           : SmallInt;
begin
  if Index > FWMemoryCount - 1 then
  begin
    raise Exception.Create('Allocation Count�� �ʰ��ϴ� Index�Դϴ�.');
    Exit;
  end;
  //Sect.Enter;
  try
    pre_val := GetW(Index);             //--+
    Move(Value, lpDataW[Index * SizeOf(SmallInt)], SizeOf(Value));

    if Assigned(FOnWMemChange) and (pre_val <> Value) then //--+ Change Event��
      FOnWMemChange(Self, Index, pre_val, Value); //--+
    ApplyUpdate(W_MEM, Index);          //��ϵ� �ܺ� ������Ʈ���� �����͸� ��������� �뺸...
  finally
    //Sect.Leave;
  end;
end;

//------------------------------------------------------------------------------
//  �޸� ������ ���� ���� ������Ʈ ��� ���� Class
//------------------------------------------------------------------------------

constructor TNewsMember.Create;
begin
  FComponent := nil;
end;

procedure TNewsMember.ApplyUpdate(sm: TpjhFAMemMan);
begin
  // ����� ȣ���� ���Ͽ� ä���� ����޽��.
  FComponent.SafeCallException(sm, nil);
end;

// ���������� ��� ��ü�� ����..

procedure TpjhFAMemMan.DestroyNewsMembers;
var
  item              : TNewsMember;
begin
  while FNewsMembers.Count > 0 do
  begin
    item := FNewsMembers.Last;
    FNewsMembers.Remove(item);
    item.Free;
  end;
end;

// �ܺο��� ȣ���Ͽ� TFAMemMan�� ���濩�θ� ���� ����
// �ܺ� VCL�� ������ ����ϵ��� �ϴ� �Լ�...

procedure TpjhFAMemMan.RegisterNewsMember(AComponent: TComponent; AMemName: TMemName; AMemIndex: Smallint);
var
  n, nCount         : integer;
  item              : TNewsMember;
begin
  nCount := FNewsMembers.Count;
  if nCount > 0 then
    for n := 0 to nCount - 1 do
    begin
      item := TNewsMember(FNewsMembers.Items[n]);
    // ���� ������Ʈ�� �̹� ��ϵǾ��ִٸ� ��� ������...
      if (item.FComponent = AComponent) then
      begin
        item.FMemName := AMemName;
        item.FMemIndex := AMemIndex;
        Exit;
      end;
    end;
  item := TNewsMember.Create;
  item.FComponent := AComponent;
  item.FMemName := AMemName;
  item.FMemIndex := AMemIndex;
  // �ڽ��� ���...
  FNewsMembers.Add(item);
end;

// �� �̻� TFAMemMan�� ������� ������Ʈ�� ����.
// �ܺο��� ȣ��- ���� ����~~~~~~~~~~

procedure TpjhFAMemMan.KickOutNewsMember(AComponent: TComponent);
var
  n, nCount         : integer;
  item              : TNewsMember;
begin
  nCount := FNewsMembers.Count;
  if nCount > 0 then
    for n := 0 to nCount - 1 do
    begin
      item := TNewsMember(FNewsMembers.Items[n]);
      if (item.FComponent = AComponent) then
      begin
        FNewsMembers.Remove(item);
        item.Free;
        Exit;
      end;
    end;
end;

// �ܺ� Ȥ�� ���ο��� ȣ��ȴ�.
// TFAMemMan�� ���� ������ �̿� ����� �ٸ� ������Ʈ��� �뺸.
// ��~~~~~~ �م���~~~~~~~~~~~

procedure TpjhFAMemMan.ApplyUpdate(AMemName: TMemName; AMemIndex: Smallint);
var
  n, nCount         : integer;
  item              : TNewsMember;
begin
  nCount := FNewsMembers.Count;
  if nCount > 0 then
    for n := 0 to nCount - 1 do
    begin
      item := TNewsMember(FNewsMembers.Items[n]);
      if (item.FMemName = AMemName) and (item.FMemIndex = AMemIndex) then
      begin
        Sect.Enter;
        item.ApplyUpdate(Self);
        Sect.Leave;
      // ���� ������ ������ �����Ҽ� �����Ƿ� ���⿡ Exit;�� ����ϸ� �ʵ�
      end;
    end;

{  if FServer then
    FWatchThread.FWatchEvent.SetEvent
  else
  begin
    FCurrentMemName := AMemName;
    FCurrentMemIndex:= AMemIndex;
  end
}
end;

{procedure TpjhFAMemMan.SetServer(Value: Boolean);
begin
  if FServer <> Value then
  begin
    if Value then
    begin
      if not Assigned(FWatchThread) then
        FWatchThread := TMyWatchThread.Create(Self);
    end//if
    else
    begin
      FWatchThread.Terminate;
      FWatchThread.FWatchEvent.SetEvent;
    end;
  end;
end;
}
{ TMyWatchThread }

{constructor TMyWatchThread.Create(AOwner: TpjhFAMemMan);
begin
  inherited Create(True);

  FOwner := AOwner;
  FWatchEvent := TEvent.Create(nil, False, True, FOwner.Name + '_Event');
  FreeOnTerminate := True;
end;

destructor TMyWatchThread.Destroy;
begin
  FreeAndNil(FWatchEvent);
  
  inherited;
end;

procedure TMyWatchThread.Execute;
begin
  while not Terminated do
  begin
    if WaitForSingleObject(FWatchEvent.Handle, INFINITE) <> WAIT_OBJECT_0 then
      Break;

    FOwner.ApplyUpdate(FOwner);
  end;//while

end;
}
end.

