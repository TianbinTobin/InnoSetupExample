[Code]
const
  PRODUCT_REGISTRY_KEY = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{{#EX_APP_ID_STR}_is1';
  PRODUCT_REGISTRY_OLD_KEY = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#EX_APP_ID_OLD_STR}';
  WM_SYSCOMMAND = $0112;
  CS_DROPSHADOW = 131072;
  GCL_STYLE = -26;
  ID_BUTTON_ON_CLICK_EVENT = 1;
  WIZARDFORM_WIDTH_NORMAL = 640;
  WIZARDFORM_HEIGHT_NORMAL = 400;
  WIZARDFORM_HEIGHT_MORE = 440;
  INSTALL_LABEL_HEIGHT = 270;
  INSTALL_LABEL_WIDTH = 200;
  INSTALL_LABEL_SETTING_TOP = 374;
  INSTALL_LABEL_SETTING_LEFT = 616;
  INSTALL_PROGRESSBAR_HEIGHT = 350;
  INSTALL_PROGRESSBAR_WIDTH = 520;
  INSTALL_PROGRESSBAR_PADDING = 60;
  INSTALL_BUTTON_PADDING = 224;
  INSTALL_LABEL_PATH_HEIGHT = 410;
  INSTALL_LABEL_PATH_WIDTH = 220;

  SUCCESS_IMAGE_LEFT = 237;
  SUCCESS_IMAGE_HEIGHT = 230;

  LABEL_TEXT_COLOR = $797C84;
  LABEL_TEXT_FONT = 9;

  SLIDES_PICTURE_WIDTH = WIZARDFORM_WIDTH_NORMAL;
  SLIDES_PICTURE_HEIGHT = 332;
  SLIDES_PAUSE_SECONDS = 2;

var
  label_wizardform_main, label_messagebox_main, label_wizardform_more_product_already_installed, label_messagebox_information, label_install_text, label_install_progress,label_install_success,label_wizardform_setting,label_agree,label_policy,label_and,label_license : TLabel;
  image_wizardform_background,image_success_background,image_messagebox_background, image_progressbar_background, image_progressbar_foreground, PBOldProc : longint;
  button_minimize, button_close, button_browse,button_input, button_setup_or_next, button_customize_setup, button_uncustomize_setup, button_messagebox_close, button_messagebox_ok, button_messagebox_cancel : hwnd;
  is_wizardform_show_normal, is_installer_initialized, is_wizardform_released, can_exit_setup : boolean;
  edit_target_path : TEdit;
  version_installed_before : String;
  messagebox_close : TSetupForm;
  taskbar_update_timer, wizardform_animation_timer, slide_picture_timer, slide_pause_timer : longword;
  fake_main_form : TMainForm;
  slide_1_b, slide_2_b, slide_3_b, slide_1_t, slide_2_t, slide_3_t : longint;
  cur_pic_no, cur_pic_pos : integer;
  time_counter : integer;

//Windows API
function CreateRoundRectRgn(p1, p2, p3, p4, p5, p6 : integer) : THandle; external 'CreateRoundRectRgn@gdi32.dll stdcall';
function SetWindowRgn(h : hwnd; hRgn : THandle; bRedraw : boolean) : integer; external 'SetWindowRgn@user32.dll stdcall';
function ReleaseCapture() : longint; external 'ReleaseCapture@user32.dll stdcall';
function CallWindowProc(lpPrevWndFunc : longint; h : hwnd; Msg : UINT; wParam, lParam : longint) : longint; external 'CallWindowProcW@user32.dll stdcall';
function SetWindowLong(h : hwnd; Index : integer; NewLong : longint) : longint; external 'SetWindowLongW@user32.dll stdcall';
function GetWindowLong(h : hwnd; Index : integer) : longint; external 'GetWindowLongW@user32.dll stdcall';
function GetDC(hWnd: HWND): longword; external 'GetDC@user32.dll stdcall';
function BitBlt(DestDC: longword; X, Y, Width, Height: integer; SrcDC: longword; XSrc, YSrc: integer; Rop: DWORD): BOOL; external 'BitBlt@gdi32.dll stdcall';
function ReleaseDC(hWnd: HWND; hDC: longword): integer; external 'ReleaseDC@user32.dll stdcall';
function SetTimer(hWnd, nIDEvent, uElapse, lpTimerFunc: longword): longword; external 'SetTimer@user32.dll stdcall';
function KillTimer(hWnd, nIDEvent: longword): longword; external 'KillTimer@user32.dll stdcall';
function SetClassLong(h : hwnd; nIndex : integer; dwNewLong : longint) : DWORD; external 'SetClassLongW@user32.dll stdcall';
function GetClassLong(h : hwnd; nIndex : integer) : DWORD; external 'GetClassLongW@user32.dll stdcall';

//停止轮播计时器
procedure stop_slide_timer;
begin
  if (slide_picture_timer <> 0) then
  begin
    KillTimer(0, slide_picture_timer);
    slide_picture_timer := 0;
  end;
end;

//停止暂停轮播用的计时器
procedure stop_slide_pause_timer;
begin
  if (slide_pause_timer <> 0) then
  begin
    KillTimer(0, slide_pause_timer);
    slide_pause_timer := 0;
    time_counter := 0;
  end;
end;

procedure pictures_slides_animation(HandleW, Msg, idEvent, TimeSys: longword); forward;

//暂停轮播
procedure slide_pause_for_a_while(HandleW, Msg, idEvent, TimeSys: longword);
begin
  stop_slide_timer;
  if (time_counter >= (SLIDES_PAUSE_SECONDS * 1000)) then
  begin
    stop_slide_pause_timer;
    time_counter := 0;
    slide_picture_timer := SetTimer(0, 0, 1 div 60, CreateCallBack(@pictures_slides_animation));
  end else
  begin
    time_counter := time_counter + 50;
  end;
end;

procedure pause_slides_for_a_while();
begin
  if (cur_pic_pos <= 0) then
  begin
    stop_slide_timer;
    if (slide_pause_timer = 0) then
    begin
      slide_pause_timer := SetTimer(0, 0, 10, CreateCallBack(@slide_pause_for_a_while));
    end;
  end;
end;

//安装时轮播图片
procedure pictures_slides_animation(HandleW, Msg, idEvent, TimeSys: longword);
begin
  cur_pic_pos := cur_pic_pos + 6;
  if (ScaleX(cur_pic_pos) > ScaleX(SLIDES_PICTURE_WIDTH)) then
  begin
    cur_pic_no := cur_pic_no + 1;
    cur_pic_pos := 0;
    pause_slides_for_a_while;
  end else
  begin
    if (cur_pic_no = 1) then
    begin
      ImgSetPosition(slide_1_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_1_t, True);
    end;
    if (cur_pic_no = 2) then
    begin
      ImgSetPosition(slide_2_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_1_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_2_t, True);
      ImgSetVisibility(slide_1_b, True);
      ImgSetVisibility(slide_3_b, False);
      ImgSetVisibility(slide_2_b, False);
    end;
    if (cur_pic_no = 3) then
    begin
      ImgSetPosition(slide_3_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_1_t, False);
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_3_t, True);
      ImgSetVisibility(slide_1_b, False);
      ImgSetVisibility(slide_3_b, False);
      ImgSetVisibility(slide_2_b, True);
    end;
    if (cur_pic_no > 3) then
    begin
      ImgSetPosition(slide_1_t, ScaleX(cur_pic_pos - SLIDES_PICTURE_WIDTH), 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT));
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_1_t, True);
      ImgSetVisibility(slide_1_b, False);
      ImgSetVisibility(slide_3_b, False);
      ImgSetVisibility(slide_2_b, False);
      cur_pic_no := 1;
    end;
  end;
  ImgApplyChanges(WizardForm.Handle);
end;

//轮播图片点击事件：打开特定网页
procedure slide_picture_on_click(Sender : TObject);
var
  URL : String;
  ErrorCode : Integer;
begin
  URL := '';
  case cur_pic_no of
    0: URL := 'http://www.example.com/';
    1: URL := 'http://www.example.com/';
    2: URL := 'http://www.example.com/';
    3: URL := 'http://www.example.com/';
  end;
  if URL <> '' then
  begin
    ShellExec('open', URL, '', '', SW_SHOW, ewNoWait,  ErrorCode);
  end;
end;

//停止动画计时器
procedure stop_animation_timer;
begin
  if (wizardform_animation_timer <> 0) then
  begin
    KillTimer(0, wizardform_animation_timer);
    wizardform_animation_timer := 0;
  end;
end;

//窗口变大动画
procedure show_full_wizardform_animation(HandleW, Msg, idEvent, TimeSys: longword);
begin
  if (WizardForm.ClientHeight < ScaleY(WIZARDFORM_HEIGHT_MORE)) then
  begin
    WizardForm.ClientHeight := WizardForm.ClientHeight + ScaleY(10);
  end else
  begin
    stop_animation_timer;
    WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_MORE);
  end;
end;

//窗口变小动画
procedure show_normal_wizardform_animation(HandleW, Msg, idEvent, TimeSys: longword);
begin
  if (WizardForm.ClientHeight > ScaleY(WIZARDFORM_HEIGHT_NORMAL)) then
  begin
    WizardForm.ClientHeight := WizardForm.ClientHeight - ScaleY(10);
  end else
  begin
    stop_animation_timer;
    WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_NORMAL);
  end;
end;

//将窗口画面画到准备的窗口上，用来实现Win7及更新的系统的任务栏缩略图的效果
procedure update_img(HandleW, Msg, idEvent, TimeSys: longword);
var
  FormDC, DC: longword;
begin
  fake_main_form.ClientWidth := WizardForm.ClientWidth;
  fake_main_form.ClientHeight := WizardForm.ClientHeight;
  DC := GetDC(fake_main_form.Handle);
  FormDC := GetDC(WizardForm.Handle);
  BitBlt(DC, 0, 0, fake_main_form.ClientWidth, fake_main_form.ClientHeight, FormDC, 0, 0, $00CC0020);
  ReleaseDC(fake_main_form.Handle, DC);
  ReleaseDC(WizardForm.Handle, FormDC);
end;

//初始化任务栏缩略图
procedure init_taskbar;
begin
  fake_main_form := TMainForm.Create(nil);
  fake_main_form.BorderStyle := bsNone;
  fake_main_form.ClientWidth := WizardForm.ClientWidth;
  fake_main_form.ClientHeight := WizardForm.ClientHeight;
  fake_main_form.Left := WizardForm.Left - ScaleX(999999);
  fake_main_form.Top := WizardForm.Top - ScaleY(999999);
  fake_main_form.Show;
  taskbar_update_timer := SetTimer(0, 0, 500, CreateCallBack(@update_img));
end;

//销毁任务栏缩略图定时器
procedure deinit_taskbar;
begin
  if (taskbar_update_timer <> 0) then
  begin
    KillTimer(0, taskbar_update_timer);
    taskbar_update_timer := 0;
  end;
end;

//调用这个函数可以使矩形窗口转变为圆角矩形窗口
procedure shape_form_round(aForm : TForm; edgeSize : integer);
var
  FormRegion : longword;
begin
  FormRegion := CreateRoundRectRgn(0, 0, aForm.ClientWidth, aForm.ClientHeight, edgeSize, edgeSize);
  SetWindowRgn(aForm.Handle, FormRegion, True);
end;

//这个函数的作用是判断是否已经安装了将要安装的产品，若已经安装，则返回TRUE，否则返回FALSE
function is_installed_before() : Boolean;
begin
  if RegKeyExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY) then
  begin
    RegQueryStringValue(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_KEY, 'DisplayVersion', version_installed_before);
    Result := True;
  end else
  begin
    version_installed_before := '0.0.0';
    Result := False;
  end;
end;

//这个函数的作用是判断是否正在安装旧版本（若系统中已经安装了将要安装的产品），是则返回TRUE，否则返回FALSE
function is_installing_older_version() : Boolean;
var
  installedVer : array[1..10] of longint;
  installingVer : array[1..10] of longint;
  oldVer, nowVer, version_installing_now : String;
  i, oldTotal, nowTotal, total : integer;
begin
  oldTotal := 1;
  while (Pos('.', version_installed_before) > 0) do
  begin
    oldVer := version_installed_before;
    Delete(oldVer, Pos('.', oldVer), ((Length(oldVer) - Pos('.', oldVer)) + 1));
    installedVer[oldTotal] := StrToIntDef(oldVer, 0);
    oldTotal := oldTotal + 1;
    version_installed_before := Copy(version_installed_before, (Pos('.', version_installed_before) + 1), (Length(version_installed_before) - Pos('.', version_installed_before)));
  end;
  if (version_installed_before <> '') then
  begin
    installedVer[oldTotal] := StrToIntDef(version_installed_before, 0);
  end else
  begin
    oldTotal := oldTotal - 1;
  end;
  version_installing_now := '{#EX_APP_VERSION_STR}';
  nowTotal := 1;
  while (Pos('.', version_installing_now) > 0) do
  begin
    nowVer := version_installing_now;
    Delete(nowVer, Pos('.', nowVer), ((Length(nowVer) - Pos('.', nowVer)) + 1));
    installingVer[nowTotal] := StrToIntDef(nowVer, 0);
    nowTotal := nowTotal + 1;
    version_installing_now := Copy(version_installing_now, (Pos('.', version_installing_now) + 1), (Length(version_installing_now) - Pos('.', version_installing_now)));
  end;
  if (version_installing_now <> '') then
  begin
    installingVer[nowTotal] := StrToIntDef(version_installing_now, 0);
  end else
  begin
    nowTotal := nowTotal - 1;
  end;
  if (oldTotal < nowTotal) then
  begin
    for i := (oldTotal + 1) to nowTotal do
    begin
      installedVer[i] := 0;
    end;
    total := nowTotal;
  end else if (oldTotal > nowTotal) then
  begin
    for i := (nowTotal + 1) to oldTotal do
    begin
      installingVer[i] := 0;
    end;
    total := oldTotal;
  end else
  begin
    total := nowTotal;
  end;
  for i := 1 to total do
  begin
    if (installedVer[i] > installingVer[i]) then
    begin
      Result := True;
      Exit;
    end else if (installedVer[i] < installingVer[i]) then
    begin
      Result := False;
      Exit;
    end else
    begin
      Continue;
    end;
  end;
  Result := False;
end;

//主界面关闭按钮按下时执行的脚本
procedure button_close_on_click(hBtn : hwnd);
begin
  WizardForm.CancelButton.OnClick(WizardForm);
end;

//主界面最小化按钮按下时执行的脚本
procedure button_minimize_on_click(hBtn : hwnd);
begin
  SendMessage(WizardForm.Handle, WM_SYSCOMMAND, 61472, 0);
end;

//主界面自定义安装按钮按下时执行的脚本
procedure button_customize_setup_on_click(hBtn : hwnd);
begin
  if is_wizardform_show_normal then
  begin
    stop_animation_timer;
    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_background_welcome_more.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_MORE), True, True);
    is_wizardform_show_normal := False;
    wizardform_animation_timer := SetTimer(0, 0, 1, CreateCallBack(@show_full_wizardform_animation));
    BtnSetVisibility(button_customize_setup, False);
    BtnSetVisibility(button_uncustomize_setup, True);
  end else
  begin
    stop_animation_timer;
    is_wizardform_show_normal := True;
    wizardform_animation_timer := SetTimer(0, 0, 1, CreateCallBack(@show_normal_wizardform_animation));
    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_background_welcome.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
    BtnSetVisibility(button_customize_setup, True);
    BtnSetVisibility(button_uncustomize_setup, False);
  end;
  ImgApplyChanges(WizardForm.Handle);
end;

//主界面浏览按钮按下时执行的脚本
procedure button_browse_on_click(hBtn : hwnd);
begin
  WizardForm.DirBrowseButton.OnClick(WizardForm);
  edit_target_path.Text := WizardForm.DirEdit.Text;
end;

//路径输入框文本变化时执行的脚本
procedure edit_target_path_on_change(Sender : TObject);
begin
  WizardForm.DirEdit.Text := edit_target_path.Text;
end;

//主界面安装按钮按下时执行的脚本
procedure button_setup_or_next_on_click(hBtn : hwnd);
begin
  WizardForm.NextButton.OnClick(WizardForm);
end;

//复制文件时执行的脚本，每复制1%都会被调用一次，若要调整进度条或进度提示请在此段修改
function PBProc(h : hWnd; Msg, wParam, lParam : longint) : longint;
var
  pr, i1, i2 : EXTENDED;
  w : integer;
begin
  Result := CallWindowProc(PBOldProc, h, Msg, wParam, lParam);
  if ((Msg = $402) and (WizardForm.ProgressGauge.Position > WizardForm.ProgressGauge.Min)) then
  begin
    i1 := WizardForm.ProgressGauge.Position - WizardForm.ProgressGauge.Min;
    i2 := WizardForm.ProgressGauge.Max - WizardForm.ProgressGauge.Min;
    pr := (i1 * 100) / i2;
    label_install_progress.Caption := Format('%d', [Round(pr)]) + '%';
    w := Round((ScaleX(INSTALL_PROGRESSBAR_WIDTH) * pr) / 100);
    ImgSetPosition(image_progressbar_foreground, ScaleX(INSTALL_PROGRESSBAR_PADDING), ScaleY(INSTALL_PROGRESSBAR_HEIGHT), w, ScaleY(6));
    ImgSetVisiblePart(image_progressbar_foreground, 0, 0, w, ScaleY(6));
    ImgApplyChanges(WizardForm.Handle);
  end;
end;

procedure lblPolicyClick(Sender : TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('', '{#EX_POLICY_URL_STR}', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

procedure lblLicenseClick(Sender : TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('', '{#EX_LICENSE_URL_STR}', '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

//取消安装弹框的确定按钮按下时执行的脚本
procedure button_messagebox_ok_on_click(hBtn : hwnd);
begin
  can_exit_setup := True;
  messagebox_close.Close();
end;

//取消安装弹框的取消按钮按下时执行的脚本
procedure button_messagebox_cancel_on_click(hBtn : hwnd);
begin
  can_exit_setup := False;
  messagebox_close.Close();
end;

//主界面被点住就随鼠标移动的脚本
procedure wizardform_on_mouse_down(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : integer);
begin
  ReleaseCapture();
  SendMessage(WizardForm.Handle, WM_SYSCOMMAND, $F012, 0);
end;

//取消弹框被点住就随鼠标移动的脚本
procedure messagebox_on_mouse_down(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : integer);
begin
  ReleaseCapture();
  SendMessage(messagebox_close.Handle, WM_SYSCOMMAND, $F012, 0);
end;

//创建取消弹框的脚本
procedure messagebox_close_create();
begin
  messagebox_close := CreateCustomForm();
  with messagebox_close do
  begin
    BorderStyle := bsNone;
    ClientWidth := ScaleX(248);
    ClientHeight := ScaleY(264);
    Color := clWhite;
  end;
  label_messagebox_information := TLabel.Create(messagebox_close);
  with label_messagebox_information do
  begin
    Parent := messagebox_close;
    AutoSize := False;
    Top := ScaleY(100);
    Left := (messagebox_close.Width - ScaleX(200)) div 2;
    Width := ScaleX(200);
    Height := ScaleX(48);
    WordWrap := True;
    Transparent := True;
    Alignment := taCenter
    Font.Size := 12;
    Font.Color := LABEL_TEXT_COLOR;
    Font.Height := 16;
    Caption := CustomMessage('messagebox_close_text');
    OnMouseDown := @messagebox_on_mouse_down;
  end;
  label_messagebox_main := TLabel.Create(messagebox_close);
  with label_messagebox_main do
  begin
    Parent := messagebox_close;
    AutoSize := False;
    Left := 0;
    Top := 0;
    ClientWidth := messagebox_close.ClientWidth;
    ClientHeight := messagebox_close.ClientHeight;
    Caption := '';
    Transparent := True;
    OnMouseDown := @messagebox_on_mouse_down;
  end;
  image_messagebox_background := ImgLoad(messagebox_close.Handle, ExpandConstant('{tmp}\pixso_background_messagebox.png'), 0, 0, ScaleX(248), ScaleY(264), True, True);
  button_messagebox_close := BtnCreate(messagebox_close.Handle, ScaleX(224), 0, ScaleX(24), ScaleY(24), ExpandConstant('{tmp}\pixso_button_close.png'), 0, False);
  BtnSetEvent(button_messagebox_close, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_messagebox_cancel_on_click));
  button_messagebox_ok := BtnCreate(messagebox_close.Handle, ScaleX(28), ScaleY(160), ScaleX(192), ScaleY(32), ExpandConstant('{tmp}\pixso_button_ok.png'), 0, False);
  BtnSetEvent(button_messagebox_ok, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_messagebox_ok_on_click));
  button_messagebox_cancel := BtnCreate(messagebox_close.Handle, ScaleX(28), ScaleY(205), ScaleX(192), ScaleY(32), ExpandConstant('{tmp}\pixso_button_cancel.png'), 0, False);
  BtnSetEvent(button_messagebox_cancel, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_messagebox_cancel_on_click));
  ImgApplyChanges(messagebox_close.Handle);
end;

//释放安装程序时调用的脚本
procedure release_installer();
begin
  deinit_taskbar;
  stop_slide_timer;
  stop_animation_timer;
  gdipShutdown();
  messagebox_close.Release();
  WizardForm.Release();
end;

//在初始化之后释放安装程序的脚本
procedure release_installer_after_init();
begin
  messagebox_close.Release();
  WizardForm.Release();
end;

//释放需要的临时资源文件
procedure extract_temp_files();
begin
  ExtractTemporaryFile('pixso_button_customize_setup.png');
  ExtractTemporaryFile('pixso_button_uncustomize_setup.png');
  ExtractTemporaryFile('pixso_button_finish.png');
  ExtractTemporaryFile('pixso_button_setup_or_next.png');
  ExtractTemporaryFile('pixso_background_welcome.png');
  ExtractTemporaryFile('pixso_background_welcome_more.png');
  ExtractTemporaryFile('pixso_button_browse.png');
  ExtractTemporaryFile('pixso_button_input.png');
  ExtractTemporaryFile('pixso_progressbar_background.png');
  ExtractTemporaryFile('pixso_progressbar_foreground.png');
  ExtractTemporaryFile('pixso.background_installing.png');
  ExtractTemporaryFile('pixso_background_finish.png');
  ExtractTemporaryFile('pixso_success.png');
  ExtractTemporaryFile('pixso_button_close.png');
  ExtractTemporaryFile('pixso_button_minimize.png');
  ExtractTemporaryFile('pixso_background_messagebox.png');
  ExtractTemporaryFile('pixso_button_cancel.png');
  ExtractTemporaryFile('pixso_button_ok.png');
  #ifdef ShowSlidePictures
    ExtractTemporaryFile('pixso_slides_picture_1.png');
    ExtractTemporaryFile('pixso_slides_picture_2.png');
    ExtractTemporaryFile('pixso_slides_picture_3.png');
  #endif
end;

//重载主界面取消按钮被按下后的处理过程
procedure CancelButtonClick(CurPageID : integer; var Cancel, Confirm: boolean);
begin
  Confirm := False;
  // messagebox_close.Center();
  messagebox_close.ShowModal();
  if can_exit_setup then
  begin
    release_installer();
    Cancel := True;
  end else
  begin
    Cancel := False;
  end;
end;

procedure CreateInstallSetting();
begin
  label_wizardform_setting := TLabel.Create(WizardForm);
  with label_wizardform_setting do
  begin
    Parent := WizardForm;
    AutoSize := True;
    Transparent := True;
    Font.Size := LABEL_TEXT_FONT;
    Font.Color := LABEL_TEXT_COLOR;
    Caption := CustomMessage('install_label_setting');
    OnMouseDown := @wizardform_on_mouse_down;
  end;
  label_wizardform_setting.Top := ScaleY(INSTALL_LABEL_SETTING_TOP) - ((label_wizardform_setting.Height - ScaleY(8)) div 2);
  label_wizardform_setting.Left := ScaleX(INSTALL_LABEL_SETTING_LEFT) - label_wizardform_setting.Width - ScaleX(3);
end;

procedure CreateInstallLabelText();
var
  left_pos,total_width: Integer;
begin
  label_agree := TLabel.Create(WizardForm);
  with label_agree do
  begin
    Parent := WizardForm;
    AutoSize := True;
    Transparent := True;
    Top := ScaleY(INSTALL_LABEL_HEIGHT);
    Font.Size := LABEL_TEXT_FONT;
    Font.Color := LABEL_TEXT_COLOR;
    Caption := CustomMessage('install_label_agree_text');
  end;
  label_and := TLabel.Create(WizardForm);
  with label_and do
  begin
    Parent := WizardForm;
    AutoSize := True;
    Transparent := True;
    Top := ScaleY(INSTALL_LABEL_HEIGHT);
    Font.Size := LABEL_TEXT_FONT;
    Font.Color := LABEL_TEXT_COLOR;
    Caption := CustomMessage('install_label_and_text');
  end;
  label_policy := TLabel.Create(WizardForm);
  with label_policy do
  begin
    Parent := WizardForm;
    AutoSize := True;
    Transparent := True;
    Top := ScaleY(INSTALL_LABEL_HEIGHT);
    Font.Size := LABEL_TEXT_FONT;
    Font.Color := LABEL_TEXT_COLOR;
    Font.Style:= [fsUnderline];
    Cursor:=crHand;
    OnClick:=@lblPolicyClick;
    Caption := CustomMessage('install_label_policy_text');
  end;
  label_license := TLabel.Create(WizardForm);
  with label_license do
  begin
    Parent := WizardForm;
    AutoSize := True;
    Transparent := True;
    Top := ScaleY(INSTALL_LABEL_HEIGHT);
    Font.Size := LABEL_TEXT_FONT;
    Font.Color := LABEL_TEXT_COLOR;
    Font.Style:= [fsUnderline];
    Cursor:=crHand;
    OnClick:=@lblLicenseClick;
    Caption := CustomMessage('install_label_license_text');
  end;
  total_width := label_agree.Width + label_policy.Width + label_and.Width + label_license.Width + 15;
  left_pos := (WizardForm.ClientWidth - total_width) div 2
  label_agree.Left := left_pos;
  label_policy.Left := left_pos + label_agree.Width + 5;
  label_and.Left := left_pos + label_agree.Width + label_policy.Width + 10;
  label_license.Left := left_pos + label_agree.Width + label_policy.Width + label_and.Width + 15;
end;

procedure TconSetVisible(lbl:TControl; bVis:boolean);
begin
  if bVis then begin
    lbl.Show;
  end else begin
    lbl.Hide;
	end;
end;

// 获取旧版应用卸载路径
function GetOlderUninstallString(SubKeyName: String): String;
var
  UninstallPath: String;
begin
  // 检索指定应用程序的卸载字符串）
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, SubKeyName, 'QuietUninstallString', UninstallPath) then
    Result := UninstallPath
  else if RegQueryStringValue(HKEY_LOCAL_MACHINE, SubKeyName, 'UninstallString', UninstallPath) then
    Result := UninstallPath
  else
    Result := '';
end;

procedure SplitCommandAndParams(const FullString: String; var Command, Parameters: String);
var
  QuotePos: Integer;
begin
  // 寻找第一个引号加空格后的位置
  QuotePos := Pos('" ', FullString);
  if QuotePos = 0 then
  begin
    QuotePos := Length(FullString) + 1;
  end;  
  // 提取文件名和参数
  Command := Copy(FullString, 1, QuotePos);
  Parameters := Trim(Copy(FullString, QuotePos + 2, MaxInt));
end;

//重载安装程序初始化函数，判断是否已经安装新版本，是则禁止安装
function InitializeSetup: Boolean;
var
  FullString, Command, Parameters: String;
  ResultCode: Integer;
begin
  if RegKeyExists(HKEY_LOCAL_MACHINE, PRODUCT_REGISTRY_OLD_KEY) then
  begin
    FullString := GetOlderUninstallString(PRODUCT_REGISTRY_OLD_KEY);
    SplitCommandAndParams(FullString, Command, Parameters);
    // 执行卸载命令
    if not Exec(RemoveQuotes(Command), Parameters, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      MsgBox('无法自动卸载旧版本，请手动卸载后再尝试安装新版本。', mbError, MB_OK);
      Log(Format('Operation result code: %d', [ResultCode]));
      Result := False;
    end;
  end;

  if is_installed_before() then
  begin
    if is_installing_older_version() then
    begin
      MsgBox(CustomMessage('init_setup_outdated_version_warning'), mbInformation, MB_OK);
      Result := False;
    end else
    begin
      Result := True;
    end;
  end else
  begin
    Result := True;
  end;
end;

//重载安装程序初始化函数（和上边那个不一样），进行初始化操作
procedure InitializeWizard;
begin
  Log('开始执行初始化向导...');
  is_installer_initialized := True;
  is_wizardform_show_normal := True;
  is_wizardform_released := False;
  extract_temp_files();
  WizardForm.InnerNotebook.Hide();
  WizardForm.OuterNotebook.Hide();
  WizardForm.Bevel.Hide();
  with WizardForm do
  begin
    BorderStyle := bsNone;
    Position := poScreenCenter;
    ClientWidth := ScaleX(WIZARDFORM_WIDTH_NORMAL);
    ClientHeight := ScaleY(WIZARDFORM_HEIGHT_MORE);
    Color := clWhite;
    NextButton.ClientHeight := 0;
    CancelButton.ClientHeight := 0;
    TconSetVisible(BackButton, False);
  end;
  // 安装设置
  Log(Format('WizardForm Width: %d, Height: %d', [WIZARDFORM_WIDTH_NORMAL, ScaleX(WIZARDFORM_WIDTH_NORMAL)]));
  Log(Format('WizardForm ClientWidth: %d, ClientHeight: %d', [WIZARDFORM_HEIGHT_MORE, ScaleX(WIZARDFORM_HEIGHT_MORE)]));
  CreateInstallSetting();
  label_wizardform_more_product_already_installed := TLabel.Create(WizardForm);
  with label_wizardform_more_product_already_installed do
  begin
    Parent := WizardForm;
    AutoSize := True;
    Top := ScaleY(INSTALL_LABEL_PATH_HEIGHT);
    Font.Size := LABEL_TEXT_FONT;
    Font.Color := clGray;
    Font.Height := 14;
    Caption := CustomMessage('destdir_warning');
    Transparent := True;
    OnMouseDown := @wizardform_on_mouse_down;
  end;
  label_wizardform_more_product_already_installed.Left := ScaleX(INSTALL_LABEL_PATH_WIDTH - label_wizardform_more_product_already_installed.Width - 10);
  label_wizardform_more_product_already_installed.Hide();
  label_wizardform_main := TLabel.Create(WizardForm);
  with label_wizardform_main do
  begin
    Parent := WizardForm;
    AutoSize := False;
    Left := 0;
    Top := 0;
    ClientWidth := WizardForm.ClientWidth;
    ClientHeight := WizardForm.ClientHeight;
    Caption := '';
    Transparent := True;
    OnMouseDown := @wizardform_on_mouse_down;
  end;
  edit_target_path := TEdit.Create(WizardForm);
  with edit_target_path do
  begin
    Parent := WizardForm;
    Text := WizardForm.DirEdit.Text;
    Font.Size := LABEL_TEXT_FONT;
    BorderStyle := bsNone;
    SetBounds(ScaleX(INSTALL_LABEL_PATH_WIDTH + 10), ScaleY(INSTALL_LABEL_PATH_HEIGHT), ScaleX(200), ScaleY(20));
    OnChange := @edit_target_path_on_change;
    Color := clWhite;
    TabStop := False;
  end;
  edit_target_path.Hide();
  button_close := BtnCreate(WizardForm.Handle, ScaleX(616), 0, ScaleX(24), ScaleY(24), ExpandConstant('{tmp}\pixso_button_close.png'), 0, False);
  BtnSetEvent(button_close, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_close_on_click));
  button_minimize := BtnCreate(WizardForm.Handle, ScaleX(592), 0, ScaleX(24), ScaleY(24), ExpandConstant('{tmp}\pixso_button_minimize.png'), 0, False);
  BtnSetEvent(button_minimize, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_minimize_on_click));
  button_setup_or_next := BtnCreate(WizardForm.Handle, ScaleX(INSTALL_BUTTON_PADDING), ScaleY(220), ScaleX(192), ScaleY(40), ExpandConstant('{tmp}\pixso_button_setup_or_next.png'), 0, False);
  BtnSetEvent(button_setup_or_next, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_setup_or_next_on_click));
  button_browse := BtnCreate(WizardForm.Handle, ScaleX(INSTALL_LABEL_PATH_WIDTH + 212), ScaleY(INSTALL_LABEL_PATH_HEIGHT - 5), ScaleX(24), ScaleY(24), ExpandConstant('{tmp}\pixso_button_browse.png'), 0, False);
  BtnSetEvent(button_browse, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_browse_on_click));
  BtnSetVisibility(button_browse, False);
  button_input := BtnCreate(WizardForm.Handle, ScaleX(INSTALL_LABEL_PATH_WIDTH), ScaleY(INSTALL_LABEL_PATH_HEIGHT - 10), ScaleX(240), ScaleY(32), ExpandConstant('{tmp}\pixso_button_input.png'), 0, False);
  BtnSetVisibility(button_input, False);
  button_customize_setup := BtnCreate(WizardForm.Handle, ScaleX(INSTALL_LABEL_SETTING_LEFT), ScaleY(INSTALL_LABEL_SETTING_TOP), ScaleX(8), ScaleY(8), ExpandConstant('{tmp}\pixso_button_customize_setup.png'), 0, False);
  BtnSetEvent(button_customize_setup, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_customize_setup_on_click));
  button_uncustomize_setup := BtnCreate(WizardForm.Handle, ScaleX(INSTALL_LABEL_SETTING_LEFT), ScaleY(INSTALL_LABEL_SETTING_TOP), ScaleX(8), ScaleY(8), ExpandConstant('{tmp}\pixso_button_uncustomize_setup.png'), 0, False);
  BtnSetEvent(button_uncustomize_setup, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_customize_setup_on_click));
  BtnSetVisibility(button_uncustomize_setup, False);
  PBOldProc := SetWindowLong(WizardForm.ProgressGauge.Handle, -4, CreateCallBack(@PBProc));
  ImgApplyChanges(WizardForm.Handle);
  messagebox_close_create();
  SetClassLong(WizardForm.Handle, GCL_STYLE, GetClassLong(WizardForm.Handle, GCL_STYLE) or CS_DROPSHADOW);
  SetClassLong(messagebox_close.Handle, GCL_STYLE, GetClassLong(messagebox_close.Handle, GCL_STYLE) or CS_DROPSHADOW);
  // init_taskbar;
  cur_pic_no := 0;
  cur_pic_pos := 0;
end;

//安装程序销毁时会调用这个函数
procedure DeinitializeSetup();
begin
  if ((is_wizardform_released = False) and (can_exit_setup = False)) then
  begin
    deinit_taskbar;
    stop_slide_timer;
    stop_animation_timer;
    gdipShutdown();
    if is_installer_initialized then
    begin
      release_installer_after_init();
    end;
  end;
end;

//安装页面改变时会调用这个函数
procedure CurPageChanged(CurPageID : integer);
begin
  if (CurPageID = wpWelcome) then begin
    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_background_welcome.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
    // 隐私政策
    CreateInstallLabelText();
    edit_target_path.Show();
    BtnSetVisibility(button_browse, True);
    BtnSetVisibility(button_input, True);
    BtnSetVisibility(button_customize_setup, True);
    BtnSetVisibility(button_uncustomize_setup, False);

    if is_installed_before() then begin
      edit_target_path.Enabled := False;
      BtnSetEnabled(button_browse, False);
      BtnSetEnabled(button_input, True);
      label_wizardform_more_product_already_installed.Show();
    end;

    WizardForm.ClientHeight := ScaleY(WIZARDFORM_HEIGHT_NORMAL);
    ImgApplyChanges(WizardForm.Handle);
  end;
  if (CurPageID = wpInstalling) then begin
    stop_animation_timer;
    is_wizardform_show_normal := True;
    wizardform_animation_timer := SetTimer(0, 0, 1, CreateCallBack(@show_normal_wizardform_animation));
    edit_target_path.Hide();
    label_wizardform_more_product_already_installed.Hide();
    BtnSetVisibility(button_browse, False);
    BtnSetVisibility(button_input, False);
    is_wizardform_show_normal := True;
    BtnSetVisibility(button_customize_setup, False);
    BtnSetVisibility(button_uncustomize_setup, False);
    BtnSetEnabled(button_close, False);
    TconSetVisible(label_agree, False);
    TconSetVisible(label_license, False);
    TconSetVisible(label_and, False);
    TconSetVisible(label_policy, False);
    TconSetVisible(label_wizardform_setting, False);
    label_install_text := TLabel.Create(WizardForm);
    with label_install_text do
    begin
      Parent := WizardForm;
      AutoSize := False;
      Left := ScaleX(INSTALL_PROGRESSBAR_PADDING);
      Top := ScaleY(INSTALL_PROGRESSBAR_HEIGHT + 10);
      ClientWidth := ScaleX(100);
      ClientHeight := ScaleY(16);
      Font.Size := LABEL_TEXT_FONT;
      Font.Color := LABEL_TEXT_COLOR;
      Caption := CustomMessage('installing_label_text');
      Transparent := True;
      OnMouseDown := @wizardform_on_mouse_down;
    end;
    label_install_progress := TLabel.Create(WizardForm);
    with label_install_progress do
    begin
      Parent := WizardForm;
      AutoSize := False;
      Left := ScaleX(547);
      Top := ScaleY(INSTALL_PROGRESSBAR_HEIGHT + 10);
      ClientWidth := ScaleX(35);
      ClientHeight := ScaleY(30);
      Font.Size := LABEL_TEXT_FONT;
      Font.Color := LABEL_TEXT_COLOR;
      Caption := '';
      Transparent := True;
      Alignment := taRightJustify;
      OnMouseDown := @wizardform_on_mouse_down;
    end;
    image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso.background_installing.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
    image_progressbar_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_progressbar_background.png'), ScaleX(INSTALL_PROGRESSBAR_PADDING), ScaleY(INSTALL_PROGRESSBAR_HEIGHT), ScaleX(INSTALL_PROGRESSBAR_WIDTH), ScaleY(6), True, True);
    image_progressbar_foreground := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_progressbar_foreground.png'), ScaleX(INSTALL_PROGRESSBAR_PADDING), ScaleY(INSTALL_PROGRESSBAR_HEIGHT - 1), 0, 0, True, True);
    BtnSetVisibility(button_setup_or_next, False);
    #ifdef ShowSlidePictures
      slide_1_b := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_slides_picture_1.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
      slide_2_b := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_slides_picture_2.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
      slide_3_b := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_slides_picture_3.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
      slide_1_t := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_slides_picture_1.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
      slide_2_t := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_slides_picture_2.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
      slide_3_t := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_slides_picture_3.png'), 0, 0, ScaleX(SLIDES_PICTURE_WIDTH), ScaleY(SLIDES_PICTURE_HEIGHT), True, True);
      ImgSetVisibility(slide_1_t, False);
      ImgSetVisibility(slide_2_t, False);
      ImgSetVisibility(slide_3_t, False);
      ImgSetVisibility(slide_1_b, False);
      ImgSetVisibility(slide_2_b, False);
      ImgSetVisibility(slide_3_b, False);
    #endif
      ImgApplyChanges(WizardForm.Handle);
    #ifdef ShowSlidePictures
      stop_slide_timer;
      stop_slide_pause_timer;
      time_counter := 0;
      slide_picture_timer := SetTimer(0, 0, 1 div 60, CreateCallBack(@pictures_slides_animation));
    #endif
  end;
  if (CurPageID = wpFinished) then begin
    #ifdef ShowSlidePictures
      stop_slide_timer;
      stop_slide_pause_timer;
      time_counter := 0;
    #endif
      TconSetVisible(label_install_text, False);
      TconSetVisible(label_install_progress, False);
      ImgSetVisibility(image_progressbar_background, False);
      ImgSetVisibility(image_progressbar_foreground, False);
      BtnSetEnabled(button_close, True);
      BtnSetVisibility(button_close, True);
      button_setup_or_next := BtnCreate(WizardForm.Handle, ScaleX(INSTALL_BUTTON_PADDING), ScaleY(275), ScaleX(192), ScaleY(40), ExpandConstant('{tmp}\pixso_button_finish.png'), 0, False);
      BtnSetEvent(button_setup_or_next, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_setup_or_next_on_click));
      BtnSetEvent(button_close, ID_BUTTON_ON_CLICK_EVENT, CreateCallBack(@button_setup_or_next_on_click));
      image_wizardform_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_background_finish.png'), 0, 0, ScaleX(WIZARDFORM_WIDTH_NORMAL), ScaleY(WIZARDFORM_HEIGHT_NORMAL), True, True);
      label_install_success := TLabel.Create(WizardForm);
      with label_install_success do
      begin
        Parent := WizardForm;
        AutoSize := True;
        Caption := CustomMessage('install_success_text');
        Transparent := true;
        Font.Size := LABEL_TEXT_FONT
        Font.Color := LABEL_TEXT_COLOR
        Font.Height := 16;
      end;
      label_install_success.Top := ScaleY(SUCCESS_IMAGE_HEIGHT) + (ScaleY(18) - label_install_success.Height) div 2;
      label_install_success.Left := (WizardForm.ClientWidth - (ScaleX(18 + 4) + label_install_success.Width)) div 2;
      image_success_background := ImgLoad(WizardForm.Handle, ExpandConstant('{tmp}\pixso_success.png'), label_install_success.Left - ScaleX(18 + 4), ScaleY(SUCCESS_IMAGE_HEIGHT), ScaleX(18), ScaleY(18), True, True);
      ImgApplyChanges(WizardForm.Handle);
  end;
end;

//安装步骤改变时会调用这个函数
procedure CurStepChanged(CurStep : TSetupStep);
begin
  if (CurStep = ssPostInstall) then
  begin
    //and do things you want
  end;
  if (CurStep = ssDone) then
  begin
    is_wizardform_released := True;
    release_installer();
  end;
end;

procedure ShoutcutRunAsAdmin(Filename: String);
var
  Buffer: String;
  Stream: TStream;
begin
  Filename := ExpandConstant(Filename);
  Stream:=TFileStream.Create(FileName,fmOpenReadWrite);
  try
    Stream.Seek(21, soFromBeginning);
    SetLength(Buffer, 1)
    Stream.ReadBuffer(Buffer, 1);
    Buffer[1] := Chr(Ord(Buffer[1]) or $20);
    Stream.Seek(-1, soFromCurrent);
    Stream.WriteBuffer(Buffer, 1);
  finally
    Stream.Free;
  end;
end;

//指定跳过哪些标准页面
function ShouldSkipPage(PageID : integer) : boolean;
begin
  if (PageID = wpLicense) then Result := True;
  if (PageID = wpPassword) then Result := True;
  if (PageID = wpInfoBefore) then Result := True;
  if (PageID = wpUserInfo) then Result := True;
  if (PageID = wpSelectDir) then Result := True;
  if (PageID = wpSelectComponents) then Result := True;
  if (PageID = wpSelectProgramGroup) then Result := True;
  if (PageID = wpSelectTasks) then Result := True;
  if (PageID = wpReady) then Result := True;
  if (PageID = wpPreparing) then Result := True;
  if (PageID = wpInfoAfter) then Result := True;
end;
