{
  i code this small application for my own needs
 so feel free to use
}

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Tlhelp32, sSkinManager, ExtCtrls, sButton, Buttons, sBitBtn,
  ImgList, sSpeedButton, ThdTimer, sLabel, acPNG, acImage, CoolTrayIcon,
  Menus;

type
  TMain = class(TForm)
    sSkinManager1: TsSkinManager;
    ImageList1: TImageList;
    StartStop: TsSpeedButton;
    Logs: TsSpeedButton;
    thrdtmr1: TThreadedTimer;
    Detail_lbl1: TsLabel;
    Detail_lbl2: TsLabel;
    About: TsSpeedButton;
    img1: TImage;
    cltrycn1: TCoolTrayIcon;
    ImageList2: TImageList;
    pm1: TPopupMenu;
    S1: TMenuItem;
    N1: TMenuItem;
    procedure StartStopClick(Sender: TObject);
    procedure thrdtmr1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LogsClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure cltrycn1DblClick(Sender: TObject);
    procedure cltrycn1MinimizeToTray(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Main: TMain;
  SkipWindow, SoundMuted: Boolean;

  // cette fonction sera appelée pour chaque lorsque l'on appelera l'API EnumWindows
function EnumWindowsCallback(hWnd: HWND; lParam: LPARAM): BOOL; stdcall;
function EnumChildProc(WndCtrl: HWND; lParam: Longint): Boolean; stdcall;

implementation

{$R *.DFM}
{$R skin.RES}

function GetProcessNameFromHandle(Handle: HWND): string;
var
  Pid: DWord;
  SnapShot: HWND;
  Module: TModuleEntry32;
begin
  Result := '';
  if not IsWindow(Handle) then
    exit;
  GetWindowThreadProcessId(Handle, @Pid);
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, Pid);
  // creer un snapshot sur le pid
  try
    if Snapshot <> -1 then
    begin
      Module.dwSize := SizeOf(TModuleEntry32);
      if Module32First(Snapshot, Module) then
        result := Module.szExePath;
    end;
  finally
    CloseHandle(Snapshot);
  end;
end;

function EnumWindowsCallback(hWnd: HWND; lParam: LPARAM): BOOL;
var
  Texte: array[0..255] of Char;
  Classe: array[0..255] of Char;
  HM: HMENU;
begin
  //GetWindowText(hWnd, Texte, SizeOf(Texte));
  // récupération du texte de la fenêtre
  GetClassName(hWnd, Classe, SizeOf(Classe)); // récupération de la classe
  if (LowerCase(ExtractFileName(GetProcessNameFromHandle(hWnd))) =
    LowerCase('paltalk.exe')) then
  begin
    { Main.Detailmmo.lines.add('classe :' + Classe + '      Texte: ' + Texte +
      '    Handle: ' + IntToStr(hWnd)
      + ' Exécutable : ' + GetProcessNameFromHandle(hWnd)); }
           // skip main window
    if (Classe <> 'SEINFELD_SUPERMAN') then
    begin
      // enable close button if it's disabled
      HM := GetSystemMenu(hwnd, False);
      EnableMenuItem(HM, SC_CLOSE, MFS_ENABLED);
      //detect big ad windows who stop sound in room
      if ({(Classe = 'ATL:00AE9210') or}(Classe = 'CwndGroupLoadingHeader'))
        then
      begin
        SoundMuted := True;
        Main.Caption := 'muted sound' + ' ' + Classe;
      end;
      // close big ad windows who stop sound in room
      if ((Classe = 'ATL:00AE9210') or (Classe = 'ATL:00AE26C0') or (Classe =
        'CwndGroupLoadingHeader') or (Classe =
        'ATL:00B3F028')
        or (Classe = 'ATL:00AE26B8')) or (Classe = 'ATL:00AE6358') or (Classe =
        'ATL:00AE7358') then
      begin
        // close big windows ad
        SendMessage(hWnd, WM_CLOSE, 0, 0);
        Main.Detail_lbl2.Caption := IntToStr(StrToInt(Main.Detail_lbl2.Caption)
          + 1);
      end;
      // to Skip window (View All) and Paltak today window
      if ((Classe = 'ATL:00ADB810') or (Classe = 'ATL:00ADA770')) then
        SkipWindow := True
      else
        SkipWindow := False;
      EnumChildWindows(hWnd, @EnumChildProc, 0);
    end;
  end;
  Result := True;
end;

//-----------------------------------------------------------------------------

function EnumChildProc(WndCtrl: HWND; lParam: Longint): Boolean; stdcall;
var
  szClass: array[0..255] of Char;
  CHwnd, PHwnd {, HCAM, ADSCAM}: HWND;
  WinRect, SoundRec: TRect;
  Pt: TPoint;
begin
  Result := True;
  GetClassName(WndCtrl, szClass, SizeOf(szClass));
  { if (GetWindowLong(WndCtrl, GWL_STYLE) = WS_POPUP) and (Copy(szClass, 1, 4) =
     'ATL:') then
     SendMessage(WndCtrl, WM_CLOSE, 0, 0); }
   //GetWindow(0, GW_OWNER)

   //remove ads from CAM
   //------------------------------------------
//  if (szClass = 'PalXVideo') then
//  begin
//    GetClassName(GetParent(WndCtrl), szClass, SizeOf(szClass));
//    if szClass = 'AtlAxWin90' then
//    begin
//      HCAM := GetParent(WndCtrl);
//      ADSCAM := HCAM;
//      HCAM := GetParent(HCAM);
//      HCAM := GetParent(HCAM);
//      HCAM := GetParent(HCAM);
//      SetParent(WndCtrl, HCAM);
//      SetForegroundWindow(HCAM);
//      //SendMessage(ADSCAM, WM_CLOSE, 0, 0);
//     //ShowWindow(ADSCAM, SW_HIDE);
//    end;
//  end;
  //-------------------------------------------
  if ((SoundMuted) and {(szClass = 'AvmUI_CUIBitmapButton') and  }
    (GetDlgCtrlID(WndCtrl) = $000001C2)) then
  begin
    SetForegroundWindow(GetWindow(WndCtrl, GW_OWNER));
    Main.Caption := Main.Caption + ' 66 ' + BoolToStr(SoundMuted);
    //Sleep(500);

    GetCursorPos(Pt);
    GetWindowRect(WndCtrl, SoundRec);
    SetCursorPos(SoundRec.Left + 1, SoundRec.top + 1);
    // First Click to mute Sound

    Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    // Second Click to Active Sound
    Mouse_Event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    Mouse_Event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    // Restore Mouse position
    //SetCursorPos(Pt.X, Pt.Y);
    SoundMuted := False;
  end;

  if szClass = 'Internet Explorer_Server' then
  begin
    //if (GetParent(WndCtrl) <> INVALID_HANDLE_VALUE) then
    //begin
    CHwnd := GetParent(WndCtrl);
    CHwnd := GetParent(CHwnd);
    CHwnd := GetParent(CHwnd);
    // Get Parent window
    PHwnd := GetParent(CHwnd);
    //Now we can Close ads windows   AtlAxWin90
    SendMessage(CHwnd, WM_CLOSE, 0, 0);
    Main.Detail_lbl2.Caption := IntToStr(StrToInt(Main.Detail_lbl2.Caption) +
      1);
    // here you can resize parent window and close it if you like
    //GetClassName(GetWindow(PHwnd, GW_OWNER), szClass, SizeOf(szClass));
    if (not SkipWindow and (szClass <> 'WTL_SplitterWindow')) then
    begin
      GetWindowRect(PHwnd, WinRect);
      MoveWindow(PHwnd, WinRect.Left, WinRect.Top, 0, 0, True);
      SendMessage(PHwnd, WM_CLOSE, 0, 0);

      //----------- don't want use it now
      //----ShowWindow(PHwnd, SW_HIDE);
    end;
    //end;
  end;
end;

procedure TMain.StartStopClick(Sender: TObject);
begin
  if (StartStop.Caption = '&Stop ADS') then
  begin
    StartStop.Caption := '&Active ADS';
    StartStop.ImageIndex := 1;
    thrdtmr1.Enabled := True;
  end
  else if (StartStop.Caption = '&Active ADS') then
  begin
    thrdtmr1.Enabled := False;
    StartStop.Caption := '&Stop ADS';
    StartStop.ImageIndex := 2;
  end;

end;

procedure TMain.thrdtmr1Timer(Sender: TObject);
begin
  // EnumWindows va appeler EnumWindowsCallback pour chaque fenetre présente
  EnumWindows(@EnumWindowsCallback, 0);
end;

procedure ApplySkin();
var
  ResStream: TResourceStream;
const
  SkinName = 'DarkGlass';
begin
  ResStream := TResourceStream.Create(HInstance, 'SkinsDark', RT_RCDATA);
  try
    Main.sSkinManager1.InternalSkins.Add;
    Main.sSkinManager1.InternalSkins[Main.sSkinManager1.InternalSkins.Count -
      1].Name := SkinName;
    // Main.sSkinManager1.InternalSkins.Items[0].PackedData.LoadFromStream(ResStream);
    Main.sSkinManager1.InternalSkins[Main.sSkinManager1.InternalSkins.Count -
      1].PackedData.LoadFromStream(ResStream);
    Main.sSkinManager1.SkinName := SkinName;
    Main.sSkinManager1.Active := True;
  finally
    ResStream.Free;
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  ApplySkin();
  Detail_lbl1.Caption := 'Killed ADS :';
  Detail_lbl2.Caption := '0';
  cltrycn1.IconVisible := True;
end;

procedure TMain.LogsClick(Sender: TObject);
begin
  Detail_lbl2.Caption := '0';
end;

procedure TMain.AboutClick(Sender: TObject);
var
  s: string;
begin
  s := '                            PalTalk Anti AD 1.0' + #10#13 +
    '                     Programmed by JamalC0der' + #10#13 +
    'Logo(PalTalk Anti AD) designed by moustapha mouzaki' + #10#13 +
    '            Special thank to our bro AlphaHDCode55' + #10#13 +
    '                        jamalcoder@hotmail.com';
  MessageBox(Self.Handle, PChar(s), PChar('PalTalk Anti AD'), MB_OK);
end;

procedure TMain.N1Click(Sender: TObject);
begin
  Main.thrdtmr1.Enabled := False;
  Application.Terminate;
end;

procedure TMain.S1Click(Sender: TObject);
begin
  cltrycn1DblClick(nil);
  cltrycn1.IconVisible := False;
end;

procedure TMain.cltrycn1DblClick(Sender: TObject);
begin
  cltrycn1.ShowMainForm;
end;

procedure TMain.cltrycn1MinimizeToTray(Sender: TObject);
begin

  //cltrycn1.h
  if (thrdtmr1.Enabled) then
    cltrycn1.ShowBalloonHint('PalTalk Anti-AD', 'PalTalk Anti-AD is activated',
      bitInfo, 10)
  else
    cltrycn1.ShowBalloonHint('PalTalk Anti-AD',
      'PalTalk Anti-AD is deactivated',
      bitInfo, 10);
end;

end.

