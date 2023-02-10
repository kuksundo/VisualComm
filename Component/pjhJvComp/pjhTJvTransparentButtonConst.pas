unit pjhTJvTransparentButtonConst;

interface

uses Messages;

Type
  TJvTransBtnActionKind = (tbakChangePage, tbakSendText, tbakLoadDFMFromFile);

  TbtnActionMsgRec = packed record
    FTargetCompName,
    FTextValue: string;
    FIntValue: integer;
    FFloatValue: Double;
  end;
Const
  WM_BUTTON_CLICK_NOTIFY = WM_USER + 200;

implementation

end.
