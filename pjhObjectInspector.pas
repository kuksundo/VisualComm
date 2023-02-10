{*******************************************************}
{                                                       }
{       Report Designer                                 }
{       Extension Library example of                    }
{       TELDesigner, TELDesignPanel                     }
{                                                       }
{       (c) 2001, Balabuyev Yevgeny                     }
{       E-mail: stalcer@rambler.ru                      }
{                                                       }
{*******************************************************}

unit pjhObjectInspector;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls,// QRPrntr,
  Grids, TypInfo, ELD5_Adds, pjhPropInsp, pjhClasses, pjhOIInterface;

type
  //THack = class(TPanel); //protected �Ӽ��� canvas�� ����ϱ� ���� ����� ��.
  TfrmProps = class(TForm)
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    ComponentList: TComboBox;
    PropInsp: TpjhPropertyInspector;
    procedure PropInspModified(Sender: TObject);
    procedure PropInspFilterProp(Sender: TObject; AInstance: TPersistent;
      APropInfo: PPropInfo; var AIncludeProp: Boolean);
    procedure PropInspGetComponentNames(Sender: TObject;
      AClass: TComponentClass; AResult: TStrings);
    procedure PropInspGetComponent(Sender: TObject;
      const AComponentName: String; var AComponent: TComponent);
    procedure ComponentListChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PropInspUpdateParam(Sender: TObject;
      AELPropertyInspectorItem: TELPropertyInspectorItem;
      AELPropEditor: TELPropEditor; var ADisplay: Boolean; var AUseDisplay: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    function PropInspEditorEdit(Sender: TObject; ATagList,
      ADescList: TStrings): Integer;
  private
    FDoc: TForm;
    FDisplayPropList,//Property Item�߿� Display�� Item list
    FDisplayCompList: TStringList; ////FDisplayPropList�� ������ ������Ʈ �̸� list

    //IbplOIInterface
    function GetDoc: TForm;
    procedure SetDoc(const Value: TForm);
    function GetOIVisible: Boolean;
    procedure SetOIVisible(const Value: Boolean);
    function GetDeleteControlName: string;
    procedure SetDeleteControlName(const Value: string);
    function GetIsOnDelete: Boolean;
    procedure SetIsOnDelete(const Value: Boolean);
    //function GetPropInspComp: TpjhPropertyInspector;
    //IbplOIInterface

    function AdjustTextWidth(AName, AClassName: string): string;
    function GetPropInspComp: TpjhPropertyInspector;
    { Private declarations }
  public
    FIsOnDelete: Boolean; //��Ʈ���� �����Ǵ� ���� True
    FDeleteControlName: String;//�����Ǵ� ��Ʈ�� �̸�

    //IbplOIInterface
    procedure ClearObjOfCombo;
    procedure FillObjList2Combo;
		procedure RefreshObjListOfCombo(SelectedObj: TControl = nil);
    procedure FillDisplayPropName(DisplayCompList, DisplayPropList: TStrings);
    procedure OI_AssignObjects(AObjects: TList);
    procedure OI_Modified;
    procedure SetDesigner4PropInsp(ADesigner: Pointer);

    property Doc: TForm read GetDoc write SetDoc;
    property OIVisible: Boolean read GetOIVisible write SetOIVisible;
    property DeleteControlName: string read GetDeleteControlName write SetDeleteControlName;
    property IsOnDelete: Boolean read GetIsOnDelete write SetIsOnDelete;
    //property PropInspComp: TpjhPropertyInspector read GetPropInspComp;
    //IbplOIInterface

    procedure CreateParams(var Params: TCreateParams); override;
    function  IsNonVisualComponent(Component: TComponent): Boolean;
  end;

var
  frmProps: TfrmProps;

implementation

uses frmDocUnit, frmMainUnit, ActnList, pjhFormDesigner;

{$R *.dfm}

type
  TRGB = record
      R: Integer;
      G: Integer;
      B: Integer;
  end;

  THLS = record
      H: Integer;
      L: Integer;
      S: Integer;
  end;

function Color2RGB(PColor: TColor): TRGB;
var
  i: Integer;
begin
  i := PColor;
  Result.R := 0;
  Result.G := 0;
  Result.B := 0;

  while i - 65536 >= 0 do
  begin
    i := i - 65536;
    Result.B := Result.B + 1;
  end;

  while i - 256 >= 0 do
  begin
    i := i - 256;
    Result.G := Result.G + 1;
  end;

  Result.R := i;
end;

function CalcComplementalColor(AColor: TColor): TColor;
var
  LRGB: TRGB;
  LHLS: THLS;
begin
  LRGB := Color2RGB(AColor);
{  LHLS := RGBToHLS(LRGB);

  LHLS.H := LHLS.H + $200;  //Hue, Add 180 deg (0x200 = 0x400 / 2)
  LHLS.H := LHLS.H and $7ff;//Hue, Mod 360 deg to Hue
  LRGB := HLSToRGB(LHLS);
  Result := RGBTOCol(LRGB);
}
  if AColor >= 0 then
    Result := RGB((255-LRGB.R),(255-LRGB.G),(255-LRGB.B))
  else
    Result := $00ffffff;
end;

{ TfrmProps }

procedure TfrmProps.SetDeleteControlName(const Value: string);
begin
  FDeleteControlName := Value;
end;

procedure TfrmProps.SetDesigner4PropInsp(ADesigner: Pointer);
begin
  PropInsp.Designer := ADesigner;
end;

procedure TfrmProps.SetDoc(const Value: TForm);
begin
  FDoc := Value;
end;

procedure TfrmProps.SetIsOnDelete(const Value: Boolean);
begin
  FIsOnDelete := Value;
end;

procedure TfrmProps.SetOIVisible(const Value: Boolean);
begin
  Visible := Value;
end;

procedure TfrmProps.PropInspModified(Sender: TObject);
begin
  if FDoc <> nil then
    TfrmDoc(FDoc).Modify;

  if PropInsp.Designer <> nil then
    TELDesigner(PropInsp.Designer).Grid.Color := CalcComplementalColor(TELDesigner(PropInsp.Designer).DesignPanel.GetPanelColor);
end;

function TfrmProps.PropInspEditorEdit
(Sender: TObject; ATagList,
  ADescList: TStrings): Integer;
begin
  ATagList.Add('TestTagname');
  ADescList.Add('TestDescription');
  ATagList.Add('TestTagname2');
  ADescList.Add('TestDescription2');
end;

procedure TfrmProps.PropInspFilterProp(Sender: TObject;
  AInstance: TPersistent; APropInfo: PPropInfo; var AIncludeProp: Boolean);
begin
{
  if (APropInfo.PropType^.Kind = tkClass) and
    (GetTypeData(APropInfo.PropType^).ClassType.InheritsFrom(TDataSet) or
    GetTypeData(APropInfo.PropType^).ClassType.InheritsFrom(TQuickRepBands)) then
    AIncludeProp := False;
}
end;

//Property Inspector���� Control �Ӽ��� Combo�� Drop down�Ҷ� ����Ǵ� �Լ�
//������ control ��ü���� ����Ʈ�� �Ѵ�.
procedure TfrmProps.PropInspGetComponentNames(Sender: TObject;
  AClass: TComponentClass; AResult: TStrings);
var i: integer;
begin
  if FDoc <> nil then
  begin
    with FDoc do
    begin
      for i := 0 to ComponentCount - 1 do
      begin
        if Components[i].InheritsFrom(AClass) then
        begin
          //�ڱ� �ڽ��� ����Ʈ���� ����
          if Components[i].Name <>
                    frmMain.MyDesigner.SelectedControls.DefaultControl.Name then
            AResult.Add(Components[i].Name);
        end
        else
        begin
          if Components[i].ClassType = TWrapperControl then
          begin
            if TWrapperControl(Components[i]).Component.InheritsFrom(AClass) then
              //�ڱ� �ڽ��� ����Ʈ���� ����
              if Components[i].Name <>
                      frmMain.MyDesigner.SelectedControls.DefaultControl.Name then
                AResult.Add(TWrapperControl(Components[i]).Component.Name);
          end;
        end;
      end;//for
    end;//with
  end;//if

end;

//ObjectInspector���� �Ӽ������� Component�� ������ �� ���� �Ǵ� �Լ�
procedure TfrmProps.PropInspGetComponent(Sender: TObject;
  const AComponentName: String; var AComponent: TComponent);
var i: integer;
begin
  AComponent := FDoc.FindComponent(AComponentName);

  if not Assigned(AComponent) then
  begin
    with FDoc do
    begin
      for i := 0 to ComponentCount - 1 do
      begin
        if Components[i].ClassType = TWrapperControl then
        begin
          if TWrapperControl(Components[i]).Component.Name = AComponentName then
            AComponent := TWrapperControl(Components[i]).Component;
        end;
      end;//for
    end;//with
  end;//if
end;

procedure TfrmProps.FillObjList2Combo;
var i: integer;
    tmpForm: TForm;
    LString: String;
begin
  if frmMain.MyDesigner.DesignControl = nil then
    exit;

  tmpForm := TForm(frmMain.MyDesigner.DesignControl);
	ComponentList.Clear;
  //Main Form ���� �߰�
  LString := AdjustTextWidth(tmpForm.Name,tmpForm.ClassName);
	ComponentList.Items.AddObject(LString, tmpForm);
	//ComponentList.Items.AddObject (Format ('%s: %s', [tmpForm.Name,tmpForm.ClassName]),
  //                            tmpForm);
  //������ Component �߰�
	for i := 0 to tmpForm.ComponentCount - 1 do
  begin
    if tmpForm.Components[i].ClassType = TWrapperControl then
    begin
      if Assigned(TWrapperControl(tmpForm.Components[i]).Component) then
        LString := AdjustTextWidth(TWrapperControl(tmpForm.Components[i]).Component.Name,
                          TWrapperControl(tmpForm.Components[i]).Component.ClassName)
      else
        Continue;
    end
    else
      LString := AdjustTextWidth(tmpForm.Components[i].Name, tmpForm.Components[i].ClassName);
    //Case Senstive �� �����Ұ�, Parent�� nil�� �����ν� �� ���� ���ʿ���
    //if tmpForm.Components[i].ClassName <> 'TPJHTimerPool' then
  		ComponentList.Items.AddObject(LString, tmpForm.Components[i]);
    //if tmpForm.Components[i].Owner.ClassType = TWrapperControl then
    //  ShowMessage('aaa');
  end;//for
end;

procedure TfrmProps.RefreshObjListOfCombo(SelectedObj: TControl);
begin
	if SelectedObj = nil then
		ComponentList.ItemIndex := -1
	else
  begin
    //if SelectedObj.ClassType = TWrapperControl then
    //  ComponentList.ItemIndex := ComponentList.Items.IndexOfObject(TWrapperControl(SelectedObj).Component)
    //else
      ComponentList.ItemIndex := ComponentList.Items.IndexOfObject(SelectedObj);
  end;
end;

procedure TfrmProps.ComponentListChange(Sender: TObject);
var
	ctrl : TControl;
  Comp : TComponent;
begin
	if TComboBox(Sender).ItemIndex = -1 then
    Exit;
	ctrl := TControl(TComboBox(Sender).Items.Objects[TComboBox(Sender).ItemIndex]);
	//Comp := TComponent(TComboBox(Sender).Items.Objects[TComboBox(Sender).ItemIndex]);

  //if Comp.Owner is TWrapperControl then
  //  ctrl := TControl(Comp.Owner)
  //else
  //  ctrl := TControl(Comp);
  //Object Inspector combobox���� component ���ýÿ� ���� ������ ������
  //��Ŀ���� �Ű����� �ϴ� ���
  if frmMain.MyDesigner.Active then
  begin
  	frmMain.MyDesigner.SelectedControls.Clear;
	  frmMain.MyDesigner.SelectedControls.Add(ctrl);
  end;
end;

procedure TfrmProps.FormShow(Sender: TObject);
begin
  FillObjList2Combo();
end;

function TfrmProps.GetDeleteControlName: string;
begin
  Result := FDeleteControlName;
end;

function TfrmProps.GetDoc: TForm;
begin
  Result := TForm(FDoc);
end;

function TfrmProps.GetIsOnDelete: Boolean;
begin
  Result := FIsOnDelete;
end;

function TfrmProps.GetOIVisible: Boolean;
begin
  Result := Visible;
end;

function TfrmProps.GetPropInspComp: TpjhPropertyInspector;
begin
  Result := PropInsp;
end;

procedure TfrmProps.FormCreate(Sender: TObject);
begin
  ComponentList.Align := alTop;
  FDisplayPropList := TStringList.Create;
  FDisplayCompList := TStringList.Create;
  //FillDisplayPropName(FDisplayCompList, FDisplayCompList);
  frmMain.RegisterDefaultComponent;
end;

procedure TfrmProps.FormDestroy(Sender: TObject);
begin
	ComponentList.Clear;
  FDisplayPropList.Free;
  FDisplayPropList := nil;

  FDisplayCompList.Free;
  FDisplayCompList := nil;
end;

procedure TfrmProps.ClearObjOfCombo;
begin
  ComponentList.Clear;
end;

function TfrmProps.AdjustTextWidth(AName, AClassName: string): string;
var
  LS: String;
  i,w: integer;
begin
  LS := AName;
  i := ComponentList.Canvas.TextWidth(LS);
  //���� �κ��� ������ ComboBox�� 2����� ��
  w := (ComponentList.Width Div 2) - GetSystemMetrics(SM_CXHTHUMB) - 1;
  while i < w do
  begin
    LS := LS + ' ';
    i := ComponentList.Canvas.TextWidth(LS);
  end;//while

  Result := LS + AClassName;
end;

procedure TfrmProps.FillDisplayPropName(DisplayCompList, DisplayPropList: TStrings);
var i: integer;
begin
  if Assigned(DisplayCompList) then
    for i := 0 to DisplayCompList.Count - 1 do
      FDisplayCompList.AddStrings(DisplayCompList);

  if Assigned(DisplayPropList) then
    for i := 0 to DisplayPropList.Count - 1 do
      FDisplayPropList.Add(DisplayPropList.Strings[i]);

  FDisplayCompList.Add('TfrmDoc');
  FDisplayCompList.Add('TpjhLogicPanel');
  FDisplayCompList.Add('TpjhProcess');
  FDisplayCompList.Add('TpjhProcess2');
  FDisplayCompList.Add('TpjhIfControl');
  FDisplayCompList.Add('TpjhGotoControl');
  FDisplayCompList.Add('TpjhStartControl');
  FDisplayCompList.Add('TpjhStopControl');
  FDisplayCompList.Add('TpjhStartButton');
  FDisplayCompList.Add('TPjhComLed');
  FDisplayCompList.Add('TpjhWriteComport');
  FDisplayCompList.Add('TpjhReadComport');
  FDisplayCompList.Add('TpjhDelay');
  FDisplayCompList.Add('TpjhWriteFile');
  FDisplayCompList.Add('TpjhWriteFAMem');
  FDisplayCompList.Add('TpjhSetTimer');
  FDisplayCompList.Add('TpjhIFTimer');

  FDisplayPropList.Add('Active');
  FDisplayPropList.Add('Align');
  FDisplayPropList.Add('Caption');
  FDisplayPropList.Add('Color');
  FDisplayPropList.Add('Font');
  FDisplayPropList.Add('Comport');
  FDisplayPropList.Add('NextStep');
  FDisplayPropList.Add('FromStep');
  FDisplayPropList.Add('ToStep');
  FDisplayPropList.Add('TrueStep');
  FDisplayPropList.Add('FalseStep');
  FDisplayPropList.Add('VarControl');
  FDisplayPropList.Add('Expression');
  FDisplayPropList.Add('StartIndex');
  FDisplayPropList.Add('Count');
  FDisplayPropList.Add('CompareData');
  FDisplayPropList.Add('Direction');
  FDisplayPropList.Add('Delimiter');
  FDisplayPropList.Add('WriteDataType');
  FDisplayPropList.Add('WriteData');
  FDisplayPropList.Add('BufClearB4Enter');
  FDisplayPropList.Add('DataCondition');
  FDisplayPropList.Add('DisplayFormName');
  FDisplayPropList.Add('ReadDataType');
  FDisplayPropList.Add('ReadDataBuf');
  FDisplayPropList.Add('ReadDataCount');
  FDisplayPropList.Add('Name');
  FDisplayPropList.Add('Path');
  FDisplayPropList.Add('Offset');
  FDisplayPropList.Add('Connectors');
  FDisplayPropList.Add('StartPoint');
  FDisplayPropList.Add('LogicControl');
  FDisplayPropList.Add('SingleStep');
  FDisplayPropList.Add('AutoReset');
  FDisplayPropList.Add('BeforeDelay');
  FDisplayPropList.Add('AfterDelay');
  FDisplayPropList.Add('DataFile');
  FDisplayPropList.Add('Text');
  //FDisplayPropList.Add('Start');
  FDisplayPropList.Add('Timeout');
  FDisplayPropList.Add('TimeLimit');
  FDisplayPropList.Add('DataCount');
  FDisplayPropList.Add('DataIndex');
end;

procedure TfrmProps.PropInspUpdateParam(Sender: TObject;
  AELPropertyInspectorItem: TELPropertyInspectorItem;
  AELPropEditor: TELPropEditor; var ADisplay: Boolean; var AUseDisplay: Boolean);
var LStr: String;
begin
  ADisplay := True;
  AUseDisplay := False;

  if FDisplayCompList.Count <= 0 then
    exit;

  if FDisplayCompList.IndexOf(frmMain.MyDesigner.SelectedControls.DefaultControl.ClassName) > -1 then
    AUseDisplay := True;

  if FDisplayPropList.Count <= 0 then
    exit;

  ADisplay := False;

  if FDisplayPropList.IndexOf(AELPropEditor.PropName) > -1 then
  begin
    if (FIsOnDelete) and (FDeleteControlName <> '') then
    begin
      //������Ʈ�� ������ ��� ������ ������Ʈ�� �ٸ� ������Ʈ�� �Ķ���Ͱ�����
      //���� �Ǿ� ������, �ش� ������Ʈ�� �����ϸ� Access Violation �߻��ϴ� ���� �ذ�
      //Designer�� OnControlDeleting���� ȣ���
      LStr := AELPropEditor.Value;
      if AELPropEditor.PropTypeInfo.Kind = tkClass then
        //����ü �������� ������ '(' �� ������
        if (LStr <> '') and (Pos('(', LStr) = 0) and (FDeleteControlName = LStr) then
          //if Doc.FindComponent(LStr) = nil then
            AELPropEditor.Value := '';
    end;
    ADisplay := True;
  end;
end;

procedure TfrmProps.FormActivate(Sender: TObject);
begin
  frmMain.ActionList1.State := asSuspended;
end;

procedure TfrmProps.FormDeactivate(Sender: TObject);
begin
  frmMain.ActionList1.State := asNormal;
end;

function TfrmProps.IsNonVisualComponent(Component: TComponent): Boolean;
begin
  Result:= False;
  if (Component is TWrapperControl) then
    Result:= True;
end;

procedure TfrmProps.OI_AssignObjects(AObjects: TList);
begin
  PropInsp.AssignObjects(AObjects);
end;

procedure TfrmProps.OI_Modified;
begin
  PropInsp.Modified;
end;

procedure TfrmProps.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := frmMain.Handle;
end;

end.


