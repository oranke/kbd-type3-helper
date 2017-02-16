{-----------------------------------------------------------------------------
 Unit Name: MainUnit
 Author:    oranke
 Date:      2012-09-10
 Purpose:
 History:
-----------------------------------------------------------------------------}


unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IMM;

type
  TMainForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

function ClosePrevInstance(): Boolean;
  
implementation

{$R *.dfm}

const
  FORM_CAPTION = 'Keyboard Type 3 Helper';
  

function ClosePrevInstance(): Boolean;
var
  PrevWnd: THandle;
begin
  PrevWnd := FindWindow('TMainForm', FORM_CAPTION);
  //PrevWnd := FindWindow(nil, FORM_CAPTION);
  if IsWindow(PrevWnd) then
  begin
    SendMessage(PrevWnd, WM_CLOSE, 0, 0);
    //ShowMessage('종료');

    if ParamCount = 0 then
      MessageBox(0, '키보드 타입 3 도우미를 종료합니다.', '키보드 타입 3 도우미', MB_OK+MB_ICONASTERISK+MB_DEFBUTTON1+MB_APPLMODAL);

    Result := true;
  end else
    Result := false;
end;

{ TMainForm }

const
  WH_KEYBOARD_LL = 13;

type
  PKbdLLHookStruct = ^TKbdLLHookStruct; 
  TKbdLLHookStruct = record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: Pointer;
  end;

var
  ugHKbdLLHook: HHook = 0;
  
function GetSysIME(Wnd: HWnd): Integer;
begin
  Result := SendMessage(ImmGetDefaultIMEWnd(Wnd), WM_IME_CONTROL, $5, 0);
end;

procedure SimulateKeyDown(VirtualKey : Byte; Ext: Boolean = false); // 키의 down
begin
  if Ext then
    keybd_event(
      VirtualKey,
      MapVirtualkey(VirtualKey, 0),
      KEYEVENTF_EXTENDEDKEY, 0
    )
  else
    keybd_event(
      VirtualKey,
      MapVirtualkey(VirtualKey, 0),
      0, 0
    );
end;

procedure SimulateKeyUp(VirtualKey : Byte; Ext: Boolean = false); // 키의 up
begin
  if Ext then
    keybd_event(
      VirtualKey,
      MapVirtualkey(VirtualKey, 0),
      KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP,
      0
    )
  else
    keybd_event(
      VirtualKey,
      MapVirtualkey(VirtualKey, 0),
      KEYEVENTF_KEYUP, 0
    );
end;

function LowLevelKeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): Integer; stdcall;
//var
  //ImeMode: Integer;
begin
  Result := -1;

  if nCode >= 0 then
  with PKbdLLHookStruct(lParam)^ do
  begin
    if (vkCode = VK_HANJA) and
     (GetSysIme(GetForegroundWindow()) = IME_CMODE_ALPHANUMERIC) then
    begin
      //WriteLn('영문에서 한자변환키. 먹자! ', GetSysFocus);

      case wParam of
        WM_KEYDOWN:
        begin
          SimulateKeyDown(VK_RCONTROL, true);
          SimulateKeyUp(VK_RCONTROL, true);
          SimulateKeyDown(VK_SPACE, true);
        end;
        WM_KEYUP  :
        begin
          SimulateKeyUp(VK_SPACE, true);
        end;
      end;

      Exit;
    end;

  end;

  Result := CallNextHookEx(ugHKbdLLHook, nCode, wParam, lParam);
end;

constructor TMainForm.Create(aOwner: TComponent);
begin
  inherited;
  //SetWindowText(Handle, FORM_CAPTION);
  Caption := FORM_CAPTION;

  ugHKbdLLHook := SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardProc, hInstance, 0);

  //ShowMessage('시작');
  //ShowMessage(Caption);
  if ParamCount = 0 then
    MessageBox(0, '키보드 타입 3 도우미를 시작합니다.', '키보드 타입 3 도우미', MB_OK+MB_ICONASTERISK+MB_DEFBUTTON1+MB_APPLMODAL);
end;

destructor TMainForm.Destroy;
begin

  UnhookWindowsHookEx(ugHKbdLLHook);
  ugHKbdLLHook := 0;
  inherited;
end;


end.
