program PAD;

uses
  Forms, Windows,
  uMain in 'uMain.pas' {Main};

{$R *.res}
var
  Mutex: THandle;
  //HMain: HWND;
begin
  Mutex := CreateMutex(nil, True, 'PalAntiAD-01001110');
  if (Mutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    //    HMain := FindWindow(PChar('TMain'), PChar('PaltTalk Anti-AD 1.0'));
    //    Main.cltrycn1.ShowMainForm;
    //    SetForegroundWindow(HMain);
//    MessageBox(Main.Handle, PChar('PaltTalk Anti-AD 1.0'),
//      PChar('an instance of PalTalk Anti-AD is already running'),
//      MB_OK + MB_ICONEXCLAMATION);
    Application.Terminate;

  end
  else
  begin

    Application.Initialize;
    Application.CreateForm(TMain, Main);
    Application.Run;
    if Mutex <> 0 then
      CloseHandle(Mutex);
  end;
end.

