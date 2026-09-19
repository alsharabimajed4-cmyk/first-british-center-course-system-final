#define AppName "First British Center Course System"
#define AppVersion "1.0.0"
#define SourceRoot GetEnv("BUILD_SOURCE_ROOT")

[Setup]
AppId={{7E3D4A0D-3B49-4F26-A2CA-7D3C4C2E2F31}
AppName={#AppName}
AppVersion={#AppVersion}
DefaultDirName={localappdata}\FirstBritishCenter
DefaultGroupName={#AppName}
PrivilegesRequired=lowest
OutputDir={#SourceRoot}\output
OutputBaseFilename=FirstBritishCenter-Setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
Uninstallable=yes

[Files]
Source: "{#SourceRoot}\app\*"; DestDir: "{app}\app"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#SourceRoot}\php\*"; DestDir: "{app}\php"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#SourceRoot}\mariadb\*"; DestDir: "{app}\mariadb"; Flags: recursesubdirs createallsubdirs ignoreversion
Source: "{#SourceRoot}\launch.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File \"{app}\launch.ps1\""; WorkingDir: "{app}"
Name: "{autodesktop}\{#AppName}"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File \"{app}\launch.ps1\""; WorkingDir: "{app}"

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File \"{app}\launch.ps1\""; WorkingDir: "{app}"; Description: "Start {#AppName}"; Flags: nowait postinstall skipifsilent