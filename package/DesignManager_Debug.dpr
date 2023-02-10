program DesignManager_Debug;

uses
  Vcl.Forms,
  frmDesignManagerDockUnit in '..\frmDesignManagerDockUnit.pas' {frmDesignManagerDock},
  WatchConst2 in '..\..\HiMECS\Application\Utility\Watch2\WatchConst2.pas',
  Watch2Interface in '..\..\HiMECS\Application\Utility\Watch2\common\Watch2Interface.pas',
  pjhPanel in '..\..\HiMECS\Application\Utility\Watch2\pjhPanel.pas',
  HiMECSComponentCollect in '..\..\HiMECS\Application\Source\Common\HiMECSComponentCollect.pas',
  HiMECSFormCollect in '..\..\HiMECS\Application\Source\Common\HiMECSFormCollect.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDesignManagerDock, frmDesignManagerDock);
  Application.Run;
end.
