program DesignManager_Debug2;

uses
  Vcl.Forms,
  HiMECSFormCollect in '..\..\HiMECS\Application\Source\Common\HiMECSFormCollect.pas',
  HiMECSComponentCollect in '..\..\HiMECS\Application\Source\Common\HiMECSComponentCollect.pas',
  WatchConst2 in '..\..\HiMECS\Application\Utility\Watch2\WatchConst2.pas',
  pjhPanel in '..\..\HiMECS\Application\Utility\Watch2\pjhPanel.pas',
  Watch2Interface in '..\..\HiMECS\Application\Utility\Watch2\common\Watch2Interface.pas',
  frmDesignManagerDockUnit in '..\frmDesignManagerDockUnit.pas' {frmDesignManagerDock};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDesignManagerDock, frmDesignManagerDock);
  Application.Run;
end.
