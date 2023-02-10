unit ConsoleDebug;

//�����Ŀ� ConsoleWriteLn(Str); �ϸ� ��

interface

uses Windows;

Type
  TConsoleDebug = class
  private
    FConHwnd: THANDLE;
  public
    constructor Create;
    destructor Destroy;
    procedure ConsoleLoad();
    procedure ConsoleWriteLn(Str: string);
    procedure ChgColor(const color: word);
    procedure MouseGotoxy(const x, y: integer);
    procedure ClrScr(Char_Fill: Char = #32);
  end;

implementation

{ TConsoleDebug }

constructor TConsoleDebug.Create;
begin
  AllocConsole();
  ConsoleLoad();
end;

destructor TConsoleDebug.Destroy;
begin
  FreeConsole();
end;

procedure TConsoleDebug.ConsoleLoad;
var
  Chars  : DWORD;
  SBSize : _COORD;
begin
  FConHwnd := CreateConsoleScreenBuffer(GENERIC_WRITE,
                                       FILE_SHARE_WRITE,
                                       nil,
                                       CONSOLE_TEXTMODE_BUFFER,
                                       nil );

  SBSize.X := 80;
  SBSize.Y := 1000;
  SetConsoleScreenBufferSize(FConHwnd, SBSize);

  SetConsoleActiveScreenBuffer(FConHwnd);
end;

procedure TConsoleDebug.ConsoleWriteLn(Str: string);
var
  Chars  : DWORD;
begin
  SetConsoleTextAttribute(FConHwnd , 10);

  Str := Str + #13#10;
  WriteConsole(FConHwnd, @Str[1], Length(Str), Chars, nil);
end;

{ex
  Closcr();
  MyColor(10);
  MyGotoxy(2,1);
  WriteLn( IntToStr(I) );
}
//============================================================================
// �ܼ� ȭ�� �����
//============================================================================
procedure TConsoleDebug.ClrScr(Char_Fill: Char = #32);
var
  hConsoleOutput: THandle;
  coordTopLeft: COORD;
  csbInfo: CONSOLE_SCREEN_BUFFER_INFO;
  tmp: Cardinal;
begin
  // �ܼ� �ڵ� ���
  //hConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  hConsoleOutput := FConHwnd;

  coordTopLeft.X := 0;  coordTopLeft.Y := 0;

  GetConsoleScreenBufferInfo(hConsoleOutput, csbInfo);

  FillConsoleOutputCharacter(hConsoleOutput, Char_Fill,
                            csbInfo.dwSize.X * csbInfo.dwSize.Y,
                            coordTopLeft, tmp);

  SetConsoleCursorPosition(hConsoleOutput, coordTopLeft);
end;

//============================================================================
// �ܼ� ȭ���� ���� �����Ѵ�.
//FOREGROUND_BLUE, FOREGROUND_GREEN, FOREGROUND_RED, FOREGROUND_INTENSITY,
//BACKGROUND_BLUE, BACKGROUND_GREEN, BACKGROUND_RED, and BACKGROUND_INTENSITY
//============================================================================
procedure TConsoleDebug.ChgColor(const color: word);
begin
  //SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), color);
  SetConsoleTextAttribute(FConHwnd, color);
end;

//============================================================================
// �ܼ� ȭ���� ���콺 Ŀ�� ��ġ�� �Ȱ��ش�.
//============================================================================S
procedure TConsoleDebug.MouseGotoxy(const x, y: integer);
var
  co: COORD;
begin
  co.X := x;
  co.Y := y;

  //SetConsoleCursorPosition(GetStdHandle( STD_OUTPUT_HANDLE),co);
  SetConsoleCursorPosition(FConHwnd,co);
end;

end.
