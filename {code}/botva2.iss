[Code]
//模块，用于操作 botva2.dll 版本 0.9.9 的库  0.9.9
//Created by South.Tver 03.2015

const
  //事件标识符，用于按钮和复选框/单选按钮
  BtnClickEventID      = 1;
  BtnMouseEnterEventID = 2;
  BtnMouseLeaveEventID = 3;
  BtnMouseMoveEventID  = 4;
  BtnMouseDownEventID  = 5;
  BtnMouseUpEventID    = 6;

  //按钮上文本的对齐方式
  balLeft    = 0;  // 文本左对齐
  balCenter  = 1;  // 文本水平居中对齐
  balRight   = 2;  // 文本右对齐
  balVCenter = 4;  // 文本垂直居中对齐

function _ImgLoad(Wnd :HWND; FileName :PAnsiChar; Left, Top, Width, Height :integer; Stretch, IsBkg :boolean) :Longint; external 'ImgLoad@{tmp}\botva2.dll stdcall delayload';
//将图像加载至内存，并保留传入的参数
//Wnd          - 窗口的句柄，图像将显示在这个窗口中
//FileName     - 图像文件路径
//Left,Top     - 图像左上角的坐标（以Wnd窗口的区域坐标为参考）
//Width,Height - 图像的宽度和高度
//               如果 Stretch=True, 图像将会在指定区域内被拉伸或压缩以适应大小
//               Rect.Left:=Left;
//               Rect.Top:=Top;
//               Rect.Right:=Left+Width;
//               Rect.Bottom:=Top+Height;
//               如果 Stretch=False, 则 Width 和 Height 参数会被忽略，ImgLoad 会自行计算图像的实际宽度和高度，因此可以传入 0
//Stretch      - 指定是否应该拉伸或压缩图像尺寸
//IsBkg        - 如果 IsBkg=True, 图像会被作为背景绘制在窗口上,
//               图像的上层将绘制其他图形元素 (如TLabel, TBitmapImage等),
//               具有 IsBkg=False 属性的图像会被绘制在所有元素之上
//返回值 - 是一个转换为 Longint 类型的指针，它指向包含图像数据及其参数的结构体
//图像会按照调用 ImgLoad 函数的顺序依次显示

procedure ImgSetVisiblePart(img:Longint; NewLeft, NewTop, NewWidth, NewHeight : integer); external 'ImgSetVisiblePart@{tmp}\botva2.dll stdcall delayload';
//保存图像可见部分的新坐标、宽度和高度，坐标基于原始图像。
//img                - 调用 ImgLoad 函数时获取的返回值。
//NewLeft,NewTop     - 可视区域新的左上角坐标。
//NewWidth,NewHeight - 新的可见区域的宽度和高度。
//PS 在调用 ImgLoad 时，默认图像的可见性为完全可见。
//若需显示图像的部分区域，应调用此方法实现。

procedure ImgGetVisiblePart(img:Longint; var Left, Top, Width, Height : integer); external 'ImgGetVisiblePart@{tmp}\botva2.dll stdcall delayload';
//返回图像可视区域的位置及尺寸（宽高）
//img                - 调用 ImgLoad 函数时获取的返回值。
//NewLeft,NewTop     - 可视区域的左上角坐标。
//NewWidth,NewHeight - 可视区域宽高。

procedure ImgSetPosition(img :Longint; NewLeft, NewTop, NewWidth, NewHeight :integer); external 'ImgSetPosition@{tmp}\botva2.dll stdcall delayload';
//保存图像显示的新坐标、宽度和高度，坐标基于父窗口。
//img                - 调用 ImgLoad 函数时获取的返回值。
//NewLeft,NewTop     - 新的左上角坐标
//NewWidth,NewHeight - 指定新的宽度和高度。如果在调用 ImgLoad 时 Stretch 设置为 False，则这两个参数将不生效。

procedure ImgGetPosition(img:Longint; var Left, Top, Width, Height:integer); external 'ImgGetPosition@{tmp}\botva2.dll stdcall delayload';
//返回图像在屏幕上显示时的左上角坐标以及其宽度和高度
//img          - 调用 ImgLoad 函数时获取的返回值。
//Left,Top     - 左上角坐标
//Width,Height - 宽度和高度。

procedure ImgSetVisibility(img :Longint; Visible :boolean); external 'ImgSetVisibility@{tmp}\botva2.dll stdcall delayload';
//用于存储图像可见状态的参数
//img     - 调用 ImgLoad 函数时获取的返回值。
//Visible - 是否可见

function ImgGetVisibility(img:Longint):boolean; external 'ImgGetVisibility@{tmp}\botva2.dll stdcall delayload';
//img - 调用 ImgLoad 函数时获取的返回值。
//返回值 - 表示图像是否可见的状态

procedure ImgSetTransparent(img:Longint; Value:integer); external 'ImgSetTransparent@{tmp}\botva2.dll stdcall delayload';
//用于设置图像的透明度
//img   - 调用 ImgLoad 函数时获取的返回值。
//Value - 表示透明度的值 (0-255)

function ImgGetTransparent(img:Longint):integer; external 'ImgGetTransparent@{tmp}\botva2.dll stdcall delayload';
//用于获取图像透明度的值
//img   - 调用 ImgLoad 函数时获取的返回值。
//返回值 - 表示当前图像透明度的数值

procedure ImgRelease(img :Longint); external 'ImgRelease@{tmp}\botva2.dll stdcall delayload';
//用于从内存中释放图像资源
//img - 调用 ImgLoad 函数时获取的返回值。

procedure ImgApplyChanges(h:HWND); external 'ImgApplyChanges@{tmp}\botva2.dll stdcall delayload';
//用于生成最终的图像，以便在屏幕上进行显示
//提交之前通过 ImgLoad、ImgSetPosition、ImgSetVisibility、ImgRelease 等函数所做的所有修改，刷新窗口以显示最终图像
//h - 指定需要重新绘制图像的窗口的句柄



function _BtnCreate(hParent :HWND; Left, Top, Width, Height :integer; FileName :PAnsiChar; ShadowWidth :integer; IsCheckBtn :boolean) :HWND; external 'BtnCreate@{tmp}\botva2.dll stdcall delayload';
//hParent           - 表示要在这个窗口上创建按钮的父窗口句柄
//Left,Top,
//Width,Height      - 不需赘述。与普通按钮相同
//FileName          - 指定包含按钮不同状态图片资源的路径
//                    普通按钮通常包含4种状态（正常、鼠标悬停、按下、禁用），因此需要提供对应这4种状态的4张图片
//                    如果按钮的IsCheckBtn属性设置为True，那么它需要8张图像，就像一个复选框一样
//                    不同状态的图片资源应按照垂直方向依次排列
//ShadowWidth       - 表示从按钮图像外观边缘到其实际边界之间的像素宽度，即阴影区域的宽度。
//                    确保按钮在用户交互时能正确响应，即按钮状态和光标样式能按预期进行切换
//IsCheckBtn        - 若设为 True，则生成一个类似于复选框的按钮，具有选中和未选中两种状态；
//                    若设为 False，则生成一个标准按钮。
//返回值 - 表示新创建按钮的句柄。

procedure BtnSetText(h :HWND; Text :PAnsiChar); external 'BtnSetText@{tmp}\botva2.dll stdcall delayload';
//该函数用于设置按钮的文字标签 (比如 Button.Caption:='bla-bla-bla')
//h    - 按钮的句柄 (由 BtnCreate 函数返回)
//Text - 要在按钮上显示的具体文本内容。

procedure BtnGetText_(h: HWND; Text: PAnsiChar; var NewSize: integer); external 'BtnGetText@{tmp}\botva2.dll stdcall delayload';
//получает текст кнопки
//h    - 按钮的句柄 (由 BtnCreate 函数返回)
//Text - 作为输出参数的缓冲区，将填充为按钮上的文本内容。
//返回值 - 文本的长度

procedure BtnSetTextAlignment(h :HWND; HorIndent, VertIndent :integer; Alignment :DWORD); external 'BtnSetTextAlignment@{tmp}\botva2.dll stdcall delayload';
//设置按钮上文本的对齐方式
//h          - 按钮的句柄 (由 BtnCreate 函数返回)
//HorIndent  - 文本与按钮左右边缘之间的水平内边距。
//VertIndent - 文本与按钮上下边缘之间的垂直内边距。
//Alignment  - 文本对齐选项，可以通过指定以下常量来设置：balLeft（左对齐）、balCenter（水平居中对齐）、balRight（右对齐），以及 balVCenter（垂直居中对齐）；
//             还可以将 balVCenter 与其他对齐类型组合使用，如 balVCenter 和 balRight 组合表示垂直居中且右对齐。

procedure BtnSetFont(h :HWND; Font :Cardinal); external 'BtnSetFont@{tmp}\botva2.dll stdcall delayload';
//设置按钮上使用的字体样式。
//h    - 按钮的句柄 (由 BtnCreate 函数返回)
//Font - 要设置的字体描述符
//       为了简化操作，避免直接使用 WinAPI 函数，可以使用 Inno Setup 内置的方法创建字体，并将得到的字体句柄传递给函数。
//       例如：
//       var
//         Font:TFont;
//         . . .
//       begin
//         . . .
//         Font:=TFont.Create;
//         在创建字体时，并不需要显式地设置所有属性，因为它们会自动填充默认值。只需修改那些需要自定义的属性即可。
//         with Font do begin
//           Name:='Tahoma';
//           Size:=10;
//           . . .
//         end;
//         BtnSetFont(hBtn,Font.Handle);
//         . . .
//       end;
//       在程序结束或不再需要该字体时，请务必通过调用 `Font.Free` 来释放字体资源。

procedure BtnSetFontColor(h :HWND; NormalFontColor, FocusedFontColor, PressedFontColor, DisabledFontColor :Cardinal); external 'BtnSetFontColor@{tmp}\botva2.dll stdcall delayload';
//设置按钮在不同状态下字体的颜色
//h                 - 按钮的句柄 (由 BtnCreate 函数返回)
//NormalFontColor   - 按钮正常状态下的文本颜色
//FocusedFontColor  - 按钮获得焦点时（高亮）的文本颜色
//PressedFontColor  - 按钮按下时的文本颜色
//DisabledFontColor - 按钮禁用状态下的文本颜色

function BtnGetVisibility(h :HWND) :boolean; external 'BtnGetVisibility@{tmp}\botva2.dll stdcall delayload';
//获取按钮当前是否可见 (类似于 f:=Button.Visible)
//h - 按钮的句柄 (由 BtnCreate 函数返回)
//返回值 - 按钮的可见性状态

procedure BtnSetVisibility(h :HWND; Value :boolean); external 'BtnSetVisibility@{tmp}\botva2.dll stdcall delayload';
//设置按钮的可见性 (类似于 Button.Visible:=True / Button.Visible:=False)
//h     - 按钮的句柄 (由 BtnCreate 函数返回)
//Value - 表示按钮可见或不可见的状态值

function BtnGetEnabled(h :HWND) :boolean; external 'BtnGetEnabled@{tmp}\botva2.dll stdcall delayload';
//检索按钮当前是否可用 (类似于 f:=Button.Enabled)
//h - 按钮的句柄 (由 BtnCreate 函数返回)
//返回值 - 按钮的可用性状态

procedure BtnSetEnabled(h :HWND; Value :boolean); external 'BtnSetEnabled@{tmp}\botva2.dll stdcall delayload';
//设置按钮的可用性 (类似于 Button.Enabled:=True / Button.Enabled:=False)
//h - 按钮的句柄 (由 BtnCreate 函数返回)
//Value -  按钮可用性状态的值

function BtnGetChecked(h :HWND) :boolean; external 'BtnGetChecked@{tmp}\botva2.dll stdcall delayload';
//获取按钮的选中状态 (开启/关闭) (类似于 f:=Checkbox.Checked)
//h - 按钮的句柄 (由 BtnCreate 函数返回)

procedure BtnSetChecked(h :HWND; Value :boolean); external 'BtnSetChecked@{tmp}\botva2.dll stdcall delayload';
//设置按钮的状态 (开启/关闭) (类似于 Сheckbox.Checked:=True / Сheckbox.Checked:=False)
//h - 按钮的句柄 (由 BtnCreate 函数返回)
//Value - 表示按钮状态的值

procedure BtnSetEvent(h :HWND; EventID :integer; Event :Longword); external 'BtnSetEvent@{tmp}\botva2.dll stdcall delayload';
//给按钮绑定一个特定的事件处理程序
//h       - 按钮的句柄 (由 BtnCreate 函数返回)
//EventID - 事件标识符，由常量 BtnClickEventID、BtnMouseEnterEventID、BtnMouseLeaveEventID、BtnMouseMoveEventID 等指定
//Event   - 提供指向事件触发时应执行的回调函数的指针。
//Example - BtnSetEvent(hBtn, BtnClickEventID, WrapBtnCallback(@BtnClick,1));
//示例用法是将按钮点击事件与相应的回调函数 `BtnClick` 绑定，并可能传递额外参数

procedure BtnGetPosition(h:HWND; var Left, Top, Width, Height: integer);  external 'BtnGetPosition@{tmp}\botva2.dll stdcall delayload';
//获取按钮的位置和大小
//h             - 按钮的句柄 (由 BtnCreate 函数返回)
//Left, Top     - 按钮左上角的坐标 (以父窗口为坐标系)
//Width, Height - 按钮的宽度和高度

procedure BtnSetPosition(h:HWND; NewLeft, NewTop, NewWidth, NewHeight: integer);  external 'BtnSetPosition@{tmp}\botva2.dll stdcall delayload';
//设置按钮的左上角坐标及其大小
//h                   - 按钮的句柄 (由 BtnCreate 函数返回)
//NewLeft, NewTop     - 新的左上角坐标 (以父窗口坐标系为基准)
//NewWidth, NewHeight - 新的按钮宽度和高度

procedure BtnRefresh(h :HWND); external 'BtnRefresh@{tmp}\botva2.dll stdcall delayload';
//立即重绘按钮，绕过消息队列。当按钮未能及时重绘时调用。
//h - 按钮的句柄 (由 BtnCreate 函数返回)

procedure BtnSetCursor(h:HWND; hCur:Cardinal); external 'BtnSetCursor@{tmp}\botva2.dll stdcall delayload';
//设置按钮的鼠标光标
//h    - 按钮的句柄 (由 BtnCreate 函数返回)
//hCur - 要设置的光标描述符
//不需要手动调用 DestroyCursor，该光标将在 gdipShutDown 被调用时自动销毁。

function GetSysCursorHandle(id:integer):Cardinal; external 'GetSysCursorHandle@{tmp}\botva2.dll stdcall delayload';
//通过其标识符加载标准光标
//id - 标准光标的标识符。标准光标的标识符由 OCR_... 常量定义，这些常量的值可以在网上查找获得。
//返回值 - 加载成功后得到的光标描述符

procedure gdipShutdown; external 'gdipShutdown@{tmp}\botva2.dll stdcall delayload';
//在应用程序结束时必须调用此函数



procedure _CreateFormFromImage(h:HWND; FileName:PAnsiChar); external 'CreateFormFromImage@{tmp}\botva2.dll stdcall delayload';
//根据PNG图像创建窗体 (原则上可以使用其他图像格式)
//h        - 窗口句柄
//FileName - 图像文件路径
//在此窗体上将不可见任何控件 (按钮、复选框、编辑框等) !!!

function CreateBitmapRgn(DC: LongWord; Bitmap: HBITMAP; TransClr: DWORD; dX:integer; dY:integer): LongWord; external 'CreateBitmapRgn@{tmp}\botva2.dll stdcall delayload';
//根据位图创建一个区域（矩形）
//DC       - 表示窗体的设备上下文（Device Context）
//Bitmap   - 用于构建区域形状的位图图像
//TransClr - 不会被包含在区域内的像素颜色（透明色
//dX,dY    - 区域在窗体上的水平和垂直偏移量

procedure SetMinimizeAnimation(Value: Boolean); external 'SetMinimizeAnimation@{tmp}\botva2.dll stdcall delayload';
//开启/关闭窗口折叠时的动画效果

function GetMinimizeAnimation: Boolean; external 'GetMinimizeAnimation@{tmp}\botva2.dll stdcall delayload';
//获取当前窗口折叠动画的状态


function _CheckBoxCreate(hParent:HWND; Left,Top,Width,Height:integer; FileName:PAnsiChar; GroupID, TextIndent:integer) :HWND; external 'CheckBoxCreate@{tmp}\botva2.dll stdcall delayload';
//hParent,Left,Top,Width,Height,FileName 参数与按钮相同
//GroupID - 用于单选按钮。同一组内的单选按钮中只能选择一个。
//GroupID=0 - 表示无组，此时控件将表现为复选框。非零值表示单选按钮
//TextIndent - 复选框/单选按钮的文本与图片之间的间距（以像素为单位）

//所有其余针对复选框和单选按钮的操作和函数，其使用方式与按钮控件类似。
procedure CheckBoxSetText(h :HWND; Text :PAnsiChar); external 'CheckBoxSetText@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxGetText_(h: HWND; Text: PAnsiChar; var NewSize: integer); external 'CheckBoxGetText@{tmp}\botva2.dll stdcall delayload'; //скорее всего работает криво
procedure CheckBoxSetFont(h:HWND; Font:LongWord); external 'CheckBoxSetFont@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxSetEvent(h:HWND; EventID:integer; Event:Longword); external 'CheckBoxSetEvent@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxSetFontColor(h:HWND; NormalFontColor, FocusedFontColor, PressedFontColor, DisabledFontColor: Cardinal); external 'CheckBoxSetFontColor@{tmp}\botva2.dll stdcall delayload';
function CheckBoxGetEnabled(h:HWND):boolean; external 'CheckBoxGetEnabled@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxSetEnabled(h:HWND; Value:boolean); external 'CheckBoxSetEnabled@{tmp}\botva2.dll stdcall delayload';
function CheckBoxGetVisibility(h:HWND):boolean; external 'CheckBoxGetVisibility@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxSetVisibility(h:HWND; Value:boolean); external 'CheckBoxSetVisibility@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxSetCursor(h:HWND; hCur:LongWord); external 'CheckBoxSetCursor@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxSetChecked(h:HWND; Value:boolean); external 'CheckBoxSetChecked@{tmp}\botva2.dll stdcall delayload';
function CheckBoxGetChecked(h:HWND):boolean; external 'CheckBoxGetChecked@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxRefresh(h:HWND); external 'CheckBoxRefresh@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxSetPosition(h:HWND; NewLeft, NewTop, NewWidth, NewHeight: integer); external 'CheckBoxSetPosition@{tmp}\botva2.dll stdcall delayload';
procedure CheckBoxGetPosition(h:HWND; var Left, Top, Width, Height: integer); external 'CheckBoxGetPosition@{tmp}\botva2.dll stdcall delayload';

function BtnGetText(hBtn: HWND): string;
var
  buf: AnsiString;
  NewSize: integer;
begin
  buf:='';
  NewSize:=0;
  BtnGetText_(hBtn, PAnsiChar(buf), NewSize);
  if NewSize > 0 then begin
    SetLength(buf, NewSize);
    BtnGetText_(hBtn, PAnsiChar(buf), NewSize);
  end;
  Result := string(buf);
end;

function CheckBoxGetText(hBtn: HWND): string;
var
  buf: AnsiString;
  NewSize: integer;
begin
  buf:='';
  NewSize:=0;
  CheckBoxGetText_(hBtn, PAnsiChar(buf), NewSize);
  if NewSize > 0 then begin
    SetLength(buf, NewSize);
    CheckBoxGetText_(hBtn, PAnsiChar(buf), NewSize);
  end;
  Result := string(buf);
end;

function ImgLoad(Wnd :HWND; FileName :PAnsiChar; Left, Top, Width, Height :integer; Stretch, IsBkg :boolean) :Longint;
begin
  if not FileExists(FileName) then begin
    ExtractTemporaryFile(FileName);
    Result:=_ImgLoad(Wnd,ExpandConstant('{tmp}\')+FileName,Left,Top,Width,Height,Stretch,IsBkg);
    DeleteFile(ExpandConstant('{tmp}\')+FileName);
  end else Result:=_ImgLoad(Wnd,FileName,Left,Top,Width,Height,Stretch,IsBkg);
end;

function BtnCreate(hParent :HWND; Left, Top, Width, Height :integer; FileName :PAnsiChar; ShadowWidth :integer; IsCheckBtn :boolean) :HWND;
begin
  if not FileExists(FileName) then begin
    ExtractTemporaryFile(FileName);
    Result:=_BtnCreate(hParent,Left,Top,Width,Height,ExpandConstant('{tmp}\')+FileName,ShadowWidth,IsCheckBtn);
    DeleteFile(ExpandConstant('{tmp}\')+FileName);
  end else Result:=_BtnCreate(hParent,Left,Top,Width,Height,FileName,ShadowWidth,IsCheckBtn);
end;

function CheckBoxCreate(hParent:HWND; Left,Top,Width,Height:integer; FileName:PAnsiChar; GroupID, TextIndent:integer):HWND;
begin
  if not FileExists(FileName) then begin
    ExtractTemporaryFile(FileName);
    Result:=_CheckBoxCreate(hParent,Left,Top,Width,Height,ExpandConstant('{tmp}\')+FileName,GroupID,TextIndent);
    DeleteFile(ExpandConstant('{tmp}\')+FileName);
  end else Result:=_CheckBoxCreate(hParent,Left,Top,Width,Height,FileName,GroupID,TextIndent);
end;

procedure CreateFormFromImage(h:HWND; FileName:PAnsiChar);
begin
  if not FileExists(FileName) then begin
    ExtractTemporaryFile(FileName);
    _CreateFormFromImage(h, ExpandConstant('{tmp}\')+FileName);
    DeleteFile(ExpandConstant('{tmp}\')+FileName);
  end else _CreateFormFromImage(h, FileName);
end;
