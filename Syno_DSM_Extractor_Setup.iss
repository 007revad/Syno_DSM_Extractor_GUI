[_TopOfScript]
; This Inno script is part of Syno DSM Extractor GUI - Copyright © 2025 007revad

[ISPP]
#define MyAppType ""
#define MyAppVersion GetFileVersion(AddBackslash(SourcePath) + "SDE-GUI.exe")
;#define MyAppVersion GetFileVersion(AddBackslash("build files\Syno DSM Extractor GUI") + "SDE-GUI.exe")
#define MyAppName "Syno DSM Extractor GUI"
#define MyAppExeName "SDE-GUI"
#define MyAppPublisher "007revad"
;#define MyAppVer "1.2.0"
; https://stackoverflow.com/questions/49388942/extracting-application-version-number-using-inno-setup-but-excluding-the-fourth
; https://groups.google.com/g/innosetup/c/9eEQkKaPFZs
#define AppVerText() \
   ParseVersion(SetupSetting(SourcePath) + "SDE-GUI.exe", \
     Local[0], Local[1], Local[2], Local[3]), \
   Str(Local[0]) + "." + Str(Local[1]) + "." + Str(Local[2])
;#define MyAppFolder "007revad\Syno DSM Extractor GUI"
#define MyAppFolder "Syno DSM Extractor GUI"
#define MyAppDescription "Extract Synology DSM 7 pat files and spk package files"
#define MyDateTimeString GetDateTimeString('yyyy', '', '')
;function CompareStr(const 2025, {#MyDateTimeString}: string): Integer;

[ISG-ScriptDefines]
; Folder of Inno Compiler for compiling
FolderOfInno=C:\Program Files\Inno Setup 6\
; Filename for own defined constants
ConstantFile=

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{BED91ACD-E13D-4E55-86A2-7BC011416AAC}
AppName={#MyAppName}
;AppVerName={#MyAppName} {#MyAppVersion} {#MyAppType}
AppVerName={#MyAppName} {#MyAppVersion}
VersionInfoVersion={#MyAppVersion}
;VersionInfoTextVersion={#MyAppVersion}
VersionInfoTextVersion={#AppVerText}
;VersionInfoTextVersion={#MyAppVer}

; https://jrsoftware.org/is6help/index.php?topic=setup_versioninfoproducttextversion
;VersionInfoProductVersion={#AppVerText}
; https://jrsoftware.org/is6help/index.php?topic=setup_versioninfoproducttextversion
;VersionInfoProductTextVersion={#AppVerText}

;VersionInfoCopyright=Copyright © 2025-{#MyDateTimeString} {#MyAppPublisher}
VersionInfoCopyright=Copyright © {#MyDateTimeString} {#MyAppPublisher}
AppPublisher={#MyAppPublisher}
DefaultDirName={commonpf}\{#MyAppFolder}
;DefaultGroupName={#MyAppPublisher}\{#MyAppFolder}
DefaultGroupName={#MyAppFolder}
LicenseFile=installer\texts\License.txt
InfoBeforeFile=installer\texts\Welcome.txt
InfoAfterFile=installer\texts\Getting Started.txt
;OutputDir=compiled
OutputDir=installer
;OutputBaseFilename={#MyAppName} setup
OutputBaseFilename={#MyAppName} {#MyAppVersion} setup
SetupIconFile=installer\icons\install-48.ico
WizardImageFile=installer\images\InstallImage-sde.bmp
WizardSmallImageFile=installer\images\InstallSmallImage-sde.bmp
UninstallDisplayIcon={app}\{#MyAppExeName}.exe
;UninstallFilesDir={userappdata}\{#MyAppPublisher}\{#MyAppName}\uninstall
UninstallFilesDir={app}\uninstall
AlwaysRestart=false
Compression=lzma
SolidCompression=true
MinVersion=10.0.19041
PrivilegesRequired=poweruser
AlwaysShowGroupOnReadyPage=true
OutputManifestFile=Setup-Manifest.txt
AlwaysUsePersonalGroup=false
;AllowUNCPath=false
UserInfoPage=false
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}
ChangesAssociations=true
TimeStampsInUTC=true
AppCopyright=Copyright © 2025-{#MyDateTimeString}
;AppVersion={#MyAppVersion} {#MyAppType}
AppVersion={#MyAppVersion}
AlwaysShowDirOnReadyPage=true
AllowNoIcons=true
AppPublisherURL="https://github.com/007revad/Syno_DSM_Extractor_GUI"
AppSupportURL="https://github.com/007revad/Syno_DSM_Extractor_GUI/issues"

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
;Name: installwsl; Description: {cm:InstallWSL}; GroupDescription: {cm:WSL}; Flags: unchecked

[Files]
Source: {#MyAppExeName}.exe; DestDir: {app}; Flags: restartreplace uninsrestartdelete promptifolder replacesameversion overwritereadonly uninsremovereadonly
Source: scripts\sae.py; DestDir: {app}\scripts; Flags: comparetimestamp confirmoverwrite promptifolder
Source: scripts\sae.ini; DestDir: {app}\scripts; Flags: comparetimestamp confirmoverwrite promptifolder
Source: scripts\syno_archive_extractor.sh; DestDir: {app}\scripts; Flags: comparetimestamp confirmoverwrite promptifolder
Source: scripts\syno_archive_extractor.ini; DestDir: {app}\scripts; Flags: comparetimestamp confirmoverwrite promptifolder
Source: scripts\syno_archive_extractor.txt; DestDir: {app}\scripts; Flags: comparetimestamp confirmoverwrite promptifolder
Source: SDE-GUI.ini; DestDir: {localappdata}\{#MyAppPublisher}\{#MyAppFolder}; Flags: comparetimestamp confirmoverwrite uninsneveruninstall 

Source: lib\lib*; DestDir: {app}\lib; Flags: restartreplace uninsrestartdelete promptifolder replacesameversion overwritereadonly uninsremovereadonly

; Settings and log files etc go in {userappdata}\{#MyAppPublisher}\{#MyAppName}
;Source: build files\{#MyAppName}\settings\*.ini; DestDir: {userappdata}\{#MyAppPublisher}\{#MyAppName}; Tasks: ; Languages: ; Flags: recursesubdirs createallsubdirs
; Settings files go in {userappdata}\{#MyAppPublisher}\{#MyAppName}
; Temporary files go in {userappdata}\{#MyAppPublisher}\{#MyAppName}
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

Source: *.dll; DestDir: {sys}; Flags: sharedfile replacesameversion 32bit restartreplace overwritereadonly uninsrestartdelete promptifolder; Permissions: authusers-modify

[Icons]
Name: {group}\{#MyAppName}; Filename: {app}\{#MyAppExeName}.exe; Comment: {#MyAppDescription}
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe}; Comment: Uninstall {#MyAppName}
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppFolder}; Filename: {app}\{#MyAppExeName}.exe; Tasks: quicklaunchicon; Comment: {#MyAppDescription}
Name: {commondesktop}\{#MyAppFolder}; Filename: {app}\{#MyAppExeName}.exe; Tasks: desktopicon; Comment: {#MyAppDescription}
Name: {group}\{#MyAppName} Webpage; Filename: "https://github.com/007revad/Syno_DSM_Extractor_GUI"
Name: {group}\{#MyAppName} Support; Filename: "https://github.com/007revad/Syno_DSM_Extractor_GUI/issues"

[Run]
Filename: {app}\{#MyAppExeName}.exe; Description: {cm:LaunchProgram,{#MyAppName}}; Flags: nowait postinstall skipifsilent unchecked

[CustomMessages]
AdditionalIcons=Additional shortcuts:
CreateStartMenuIcon=Create &Start Menu shortcut
CreateDesktopIcon=Create a &Desktop shortcut
CreateQuickLaunchIcon=Create a &Quick Launch shortcut
;WSL=Install WSL Ubuntu:
;InstallWSL=&Install Windows System for Linux with Ubuntu

[UninstallDelete]
Name: {tmp}\{#MyAppName}; Type: filesandordirs
Name: {tmp}\{#MyAppPublisher}\{#MyAppName}; Type: filesandordirs
Name: {tmp}\{#MyAppPublisher}; Type: dirifempty
Name: {group}; Type: filesandordirs
Name: {commonprograms}\{#MyAppPublisher}; Type: dirifempty
Name: {userprograms}\{#MyAppPublisher}; Type: dirifempty

[Registry]
Root: HKA; Subkey: "Software\Classes\.pat\OpenWithProgids"; ValueType: string; ValueName: "SDE-GUI.pat"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\.spk\OpenWithProgids"; ValueType: string; ValueName: "SDE-GUI.spk"; ValueData: ""; Flags: uninsdeletevalue

Root: HKA; Subkey: "Software\Classes\SDE-GUI.pat"; ValueType: string; ValueName: ""; ValueData: "Syno DSM update"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\SDE-GUI.spk"; ValueType: string; ValueName: ""; ValueData: "Syno Package update"; Flags: uninsdeletekey

Root: HKA; Subkey: "Software\Classes\SDE-GUI.pat\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}.exe,1"
Root: HKA; Subkey: "Software\Classes\SDE-GUI.spk\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}.exe,2"

Root: HKA; Subkey: "Software\Classes\SDE-GUI.pat\shell\Extract\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}.exe"" ""%1"""
Root: HKA; Subkey: "Software\Classes\SDE-GUI.spk\shell\Extract\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}.exe"" ""%1"""

Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}.exe\SupportedTypes"; ValueType: string; ValueName: ".pat"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}.exe\SupportedTypes"; ValueType: string; ValueName: ".spk"; ValueData: ""; Flags: uninsdeletekey


