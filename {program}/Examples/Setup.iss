; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

;指定是否要注册相关后缀名
;#define RegisteAssociations

;指定是否在安装时轮播图片
#define ShowSlidePictures

;指定是否为绿色版安装程序（仅释放文件，不写入注册表条目，也不生成卸载程序）
;#define PortableBuild

;指定是否只能安装新版本，而不能用旧版本覆盖新版本
; #define OnlyInstallNewVersion

;指定是否使用自定义卸载程序
;#define UseCustomUninstaller

#define EX_APP_ID_STR "{b9464f48-5337-57a6-aa1d-adc298f5233d}"
#define EX_APP_VERSION_STR GetVersionNumbersString(AddBackslash(SourcePath) + "{app}\MyProg.exe")
#define EX_APP_NAME_STR "boardmix"
#define EX_APP_DISPLAY_NAME_STR "boardmix"
#define EX_APP_BASE_DIR_STR ".\{app}"
#define EX_APP_DIR_STR AddBackslash(EX_APP_BASE_DIR_STR)
#define EX_APP_EXE_NAME_STR EX_APP_NAME_STR + ".exe"
#define EX_APP_SETUP_EXE_NAME_STR EX_APP_NAME_STR + "_win_" + EX_APP_VERSION_STR + "_x64"
#define EX_APP_OUTPUT_DIR_STR ".\{output}"
#define EX_APP_SETUP_ICON_FILE_STR ".\setup.ico"
#define EX_COMPANY_NAME_STR "boardmix"
#define EX_COMPANY_URL_STR "https://boardmix.cn/"
#define EX_SUPPORT_URL_STR "https://boardmix.cn/contact-us/"
#define EX_UPDATES_URL_STR "https://boardmix.cn/releases/"
#define EX_CONTACT_STR "support@boardmix.cn"
#define EX_SUPPORT_PHONE_STR "0755-86665000"
#define EX_README_URL_STR "https://boardmix.cn/about-us/"
#define EX_POLICY_URL_STR "https://boardmix.cn/private-policy/"
#define EX_LICENSE_URL_STR "https://boardmix.cn/term-services/"
#define EX_COMMENTS_STR "boardmix是国内前沿的在线协作白板工具，集成了ai、思维导图、流程图、ppt、文档笔记和看板等创作能力，打通成员之间进行灵感采集、思考、创作、管理、演示、协作的全链路，支持2000+人实时协同，500+人实时编辑，boardmix一次性创新集成了 ai生图、ai一键ppt、ai 生成思维导图等 ai创作能力。"
#define EX_COPYRIGHT_STR "Copyright © 2023 BOSYUN TECHNOLOGY LIMITED. All rights reserved."

[Setup]
; 启用日志记录
SetupLogging=yes

AppId                           = {{#EX_APP_ID_STR}
AppName                         = {#EX_APP_NAME_STR}
AppVersion                      = {#EX_APP_VERSION_STR}
AppVerName                      = {#EX_APP_NAME_STR} {#EX_APP_VERSION_STR}
AppPublisher                    = {#EX_COMPANY_NAME_STR}
AppPublisherURL                 = {#EX_COMPANY_URL_STR}
AppSupportURL                   = {#EX_SUPPORT_URL_STR}
AppUpdatesURL                   = {#EX_UPDATES_URL_STR}
AppContact                      = {#EX_CONTACT_STR}
AppComments                     = {#EX_COMMENTS_STR}
AppSupportPhone                 = {#EX_SUPPORT_PHONE_STR}
AppReadmeFile                   = {#EX_README_URL_STR}
AppCopyright                    = {#EX_COPYRIGHT_STR}
DefaultDirName                  = {autopf}\{#EX_COMPANY_NAME_STR}
DefaultGroupName                = {#EX_COMPANY_NAME_STR}
VersionInfoCompany              = {#EX_COMPANY_NAME_STR}
VersionInfoCopyright            = {#EX_COPYRIGHT_STR}
VersionInfoDescription          = {#EX_APP_NAME_STR} Setup
VersionInfoProductName          = {#EX_APP_NAME_STR}
VersionInfoProductVersion       = {#EX_APP_VERSION_STR}
VersionInfoProductTextVersion   = {#EX_APP_VERSION_STR}
VersionInfoTextVersion          = {#EX_APP_VERSION_STR}
VersionInfoVersion              = {#EX_APP_VERSION_STR}

OutputDir                       = {#EX_APP_OUTPUT_DIR_STR}
OutputBaseFilename              = {#EX_APP_SETUP_EXE_NAME_STR}
SetupIconFile                   = {#EX_APP_SETUP_ICON_FILE_STR}

Compression                     = lzma2/ultra64
InternalCompressLevel           = ultra64
SolidCompression                = yes
DisableProgramGroupPage         = yes
DisableDirPage                  = yes
DisableReadyMemo                = yes
DisableReadyPage                = yes
TimeStampsInUTC                 = yes

AppMutex                        = {{#EX_APP_ID_STR}
SetupMutex                      = {{#EX_APP_ID_STR}Setup,Global\{{#EX_APP_ID_STR}Setup

LanguageDetectionMethod         = uilanguage
ShowLanguageDialog              = no
AllowCancelDuringInstall        = no

ArchitecturesAllowed            = x64
ArchitecturesInstallIn64BitMode = x64
DefaultDirName                  = {autopf}\{#EX_COMPANY_NAME_STR}\{#EX_APP_NAME_STR}
MinVersion                      = 10.0

#ifdef RegisteAssociations
ChangesAssociations             = yes
#else
ChangesAssociations             = no
#endif

#ifdef PortableBuild
Uninstallable                   = no
PrivilegesRequired              = lowest
#else
Uninstallable                   = yes
PrivilegesRequired              = admin
UninstallDisplayName            = {#EX_APP_NAME_STR}
UninstallDisplayIcon            = {app}\{#EX_APP_EXE_NAME_STR},0
UninstallFilesDir               = {app}\Uninstaller
#endif

[Languages]
; 此段的第一个语言为默认语言，除此之外，语言的名称与顺序都无所谓
Name: zh; MessagesFile: "compiler:Default.isl"
Name: en; MessagesFile: "compiler:Languages\English.isl"
Name: ko; MessagesFile: "compiler:Languages\Korean.isl"
Name: es; MessagesFile: "compiler:Languages\Spanish.isl"
Name: ja; MessagesFile: "compiler:Languages\Japanese.isl"

[CustomMessages]
;此段条目在等号后面直接跟具体的值，不能加双引号
;简体中文（默认语言）
zh.messagebox_close_title              = {#EX_APP_NAME_STR} 安装
zh.messagebox_close_text               = 您确定要取消安装过程吗？
zh.messagebox_close_sub_text           = 如果是这样,安装将被阻止。
zh.init_setup_outdated_version_warning = 您已安装更新版本的“{#EX_APP_NAME_STR}”，不允许使用旧版本替换新版本，请单击“确定”按钮退出此安装程序。
zh.wizardform_title                    = {#EX_APP_NAME_STR} V{#EX_APP_VERSION_STR} 安装
zh.destdir_warning                     = 安装路径
zh.installing_label_text               = 正在安装,请稍后
zh.install_label_setting               = 安装设置
zh.install_label_agree_text            = 点击“安装”按钮代表你同意
zh.install_label_policy_text           = 隐私政策
zh.install_label_and_text              = 和
zh.install_license_and_text            = 使用条款
zh.install_success_text                = 安装成功,快开始使用吧！

;English
en.messagebox_close_title              = {#EX_APP_NAME_STR} Setup
en.messagebox_close_text               = Are you sure to abort {#EX_APP_NAME_STR} setup?
en.messagebox_close_sub_text           = If so, the installation will be blocked.
en.init_setup_outdated_version_warning = You have already installed a newer version of {#EX_APP_NAME_STR}, so you are not allowed to continue. Click <OK> to abort.
en.wizardform_title                    = {#EX_APP_NAME_STR} V{#EX_APP_VERSION_STR} Setup
en.destdir_warning                     = Install Path
en.installing_label_text               = Please wait...
en.install_label_setting               = Installing setting
en.install_label_agree_text            = Clicking the "Install" button means you agree
en.install_label_policy_text           = Privacy Policy
en.install_label_and_text              = and
en.install_license_and_text            = Terms for usage
en.install_success_text                = Install successfully, start using now！

;Spanish
es.messagebox_close_title              = {#EX_APP_NAME_STR} Setup
es.messagebox_close_text               = ¿Está seguro de que va a abortar la configuración {#EX_APP_NAME_STR}?
es.messagebox_close_sub_text           = Si es así, la instalación será bloqueada.
es.init_setup_outdated_version_warning = Ya ha instalado una nueva versión de {#EX_APP_NAME_STR}, por lo que no puede continuar. Haga clic en <OK> para abortar.
es.wizardform_title                    = {#EX_APP_NAME_STR} V{#EX_APP_VERSION_STR} Setup
es.destdir_warning                     = Ruta de instalación
es.installing_label_text               = Por favor espere...
es.install_label_setting               = Configuración de instalación
es.install_label_agree_text            = Al hacer clic en el botón "instalar" significa que está de acuerdo
es.install_label_policy_text           = Política de privacidad
es.install_label_and_text              = y
es.install_license_and_text            = Condiciones de uso
es.install_success_text                = Instalar correctamente, empezar a usar ahora！

;Japanese
ja.messagebox_close_title              = {#EX_APP_NAME_STR} 取り付けます
ja.messagebox_close_text               = インストールをキャンセルしますか？
ja.messagebox_close_sub_text           = その場合,インストールは阻止されます。
ja.init_setup_outdated_version_warning = 新しいバージョンの「{#EX_APP_NAME_STR}」をインストールしました。古いバージョンと新しいバージョンを交換することはできません。
ja.wizardform_title                    = {#EX_APP_NAME_STR} V{#EX_APP_VERSION_STR} 取り付けます
ja.destdir_warning                     = インストール経路です
ja.installing_label_text               = 設置中ですので、少々お待ちください
ja.install_label_setting               = インストール設定です
ja.install_label_agree_text            = 「インストール」ボタンをクリックすると同意します
ja.install_label_policy_text           = プライバシーポリシーです
ja.install_label_and_text              = 和
ja.install_license_and_text            = 利用規約です
ja.install_success_text                = インストールは成功しました、すぐに使用を開始しましょう!

;Korean
ko.messagebox_close_title              = {#EX_APP_NAME_STR} 설치
ko.messagebox_close_text               = 설치 프로세스를 취소하시겠습니까?
ko.messagebox_close_sub_text           = 이 경우 설치가 차단됩니다.
ko.init_setup_outdated_version_warning = 최신 버전의"{#EX_APP_NAME_STR}"를 설치했으며 이전 버전을 새 버전으로 바꿀 수 없습니다."확인"단추를 클릭하여 설치를 종료하십시오.
ko.wizardform_title                    = {#EX_APP_NAME_STR} V{#EX_APP_VERSION_STR} 설치
ko.destdir_warning                     = 설치 경로
ko.installing_label_text               = 설치하는 중입니다. 잠시 기다려 주십시오
ko.install_label_setting               = 설정 설치
ko.install_label_agree_text            = "설치"버튼을 누르면 동의한다는 뜻입니다
ko.install_label_policy_text           = 개인정보 보호정책
ko.install_label_and_text              = 와
ko.install_license_and_text            = 이용 약관
ko.install_success_text                = 성공적으로 설치했습니다. 빨리 사용하십시오!

[Files]
; 包含所有临时资源文件
Source: ".\{tmp}\*"; DestDir: "{tmp}"; Flags: dontcopy solidbreak; Attribs: hidden system
;包含待打包项目的所有文件及文件夹
Source: ".\{#EX_APP_BASE_DIR_STR}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
#ifndef PortableBuild
#ifdef UseCustomUninstaller
#if FileExists(".\{#EX_APP_BASE_DIR_STR}\Uninstall.exe")
Source: ".\{#EX_APP_BASE_DIR_STR}\Uninstall.exe"; DestDir: "{app}"; Flags: ignoreversion
#endif
#endif
#endif

#ifndef PortableBuild
[Dirs]
;创建一个隐藏的系统文件夹存放卸载程序
Name: "{app}\Uninstaller"; Attribs: hidden system
#endif

#ifndef PortableBuild
#ifdef UseCustomUninstaller
[INI]
Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Name";    String: "{#EX_APP_NAME_STR}"
Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Version"; String: "{#EX_APP_VERSION_STR}"
Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Mutex";   String: "{#EX_APP_ID_STR}"
Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Path";    String: "{uninstallexe}"
Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Params";  String: "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "Dir";     String: "{app}\Uninstaller"
Filename: "{app}\Uninstall.ini"; Section: "General"; Key: "File";    String: "Uninstaller.zip"
#endif
#endif

;若有写入注册表条目的需要，请取消此区段的注释并自行添加相关脚本
[Registry]
Root: HKCR; Subkey: "boardmix"; Flags: deletekey uninsdeletekey
Root: HKCR; Subkey: "boardmix"; ValueType: string; ValueName: ""; ValueData: "URL:boardmix"
Root: HKCR; Subkey: "boardmix"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCR; Subkey: "boardmix\shell"; ValueType: string; ValueName: ""; ValueData: ""
Root: HKCR; Subkey: "boardmix\shell\Open"; ValueType: string; ValueName: ""; ValueData: ""
Root: HKCR; Subkey: "boardmix\shell\Open\command"; ValueType: string; ValueName: ""; ValueData: "'{app}\{#EX_APP_EXE_NAME_STR}' '%1'"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone
Name: "quicklaunchicon"; Description: "quicklaunchicon"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Icons]
Name: "{group}\{cm:UninstallProgram,{#EX_APP_NAME_STR}"; Filename: "{uninstallexe}"
Name: "{group}\{#EX_APP_NAME_STR}"; Filename: "{app}\{#EX_APP_EXE_NAME_STR}"; AfterInstall: ShoutcutRunAsAdmin('{group}\{#EX_APP_NAME_STR}.lnk');
Name: "{commondesktop}\{#EX_APP_NAME_STR}"; Filename: "{app}\{#EX_APP_EXE_NAME_STR}"; Tasks: desktopicon ; AfterInstall: ShoutcutRunAsAdmin('{commondesktop}\{#EX_APP_NAME_STR}.lnk');
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#EX_APP_NAME_STR}"; Filename:"{app}\{#EX_APP_EXE_NAME_STR}"; Tasks: quicklaunchicon  ; AfterInstall: ShoutcutRunAsAdmin('{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#EX_APP_NAME_STR}.lnk');
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\{#EX_APP_NAME_STR}"; Filename:"{app}\{#EX_APP_EXE_NAME_STR}"; Tasks: quicklaunchicon ; AfterInstall: ShoutcutRunAsAdmin('{userappdata}\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\{#EX_APP_NAME_STR}.lnk');

[UninstallRun]
#ifdef RegisteAssociations
; 卸载时运行反注册程序
Filename: "{app}\{#EX_APP_EXE_NAME_STR}"; Parameters: "--uninstall"; WorkingDir: "{app}"; Flags: waituntilterminated skipifdoesntexist
#endif

[Run]
Filename: "{app}\{#EX_APP_EXE_NAME_STR}"; Description: "{cm:LaunchProgram,{#StringChange(EX_APP_NAME_STR, '&', '&&')}}"; Flags: runascurrentuser nowait postinstall skipifsilent

#ifndef PortableBuild
[UninstallDelete]
;卸载时删除安装目录下的所有文件及文件夹
Type: filesandordirs; Name: "{app}"
#endif