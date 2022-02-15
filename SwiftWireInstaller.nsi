/* 
	SWIFTWIRE - Desktop Automation Reimagined
	Copyright 2019, Fluent Systems, Inc.
	NSIS Installer script for application compiler
*/

!include "MUI.nsh"
!include "LogicLib.nsh"
!include "nsProcess.nsh"

RequestExecutionLevel user

!define SWIFTWIRE "SwiftWire"
!define SWIFTWIRE_VERSION "1.4.1.0"

!define SWIFTWIRE_EXE "SwiftWire.exe"
!define SWIFTWIRE_BOOSTER_EXE "Booster.exe"
!define SWIFTWIRE_COORDINATES_EXE "Coordinates.exe"
!define SWIFTWIRE_README "ReadMe.txt"
!define SWIFTWIRE_INSTALLER "SwiftWireInstaller.exe"
!define SWIFTWIRE_UNINSTALLER "SwiftWireUninstaller.exe"
!define SWIFTWIRE_HOME "$DOCUMENTS\${SWIFTWIRE}"
!define SWIFTWIRE_BACKUP_USER "$DOCUMENTS\${SWIFTWIRE} - Backup"
!define SWIFTWIRE_DESKTOP_SHORTCUT "$DESKTOP\${SWIFTWIRE}.lnk"
!define SWIFTWIRE_START_FOLDER "$SMPROGRAMS\${SWIFTWIRE}"
!define SWIFTWIRE_START_SHORTCUT "${SWIFTWIRE_START_FOLDER}\${SWIFTWIRE}.lnk"
!define SWIFTWIRE_START_USHORTCUT "${SWIFTWIRE_START_FOLDER}\uninstall.lnk"
!define SWIFTWIRE_COMPANY "Fluent Systems"
!define SWIFTWIRE_COPYRIGHT "Fluent Systems, Inc. © 2019"
!define SWIFTWIRE_DESCRIPTION "Application"
!define SWIFTWIRE_WEBSITE "http://fluent.systems"
!define SWIFTWIRE_SETTINGS "SwiftWireSettings.ini"
!define SWIFTWIRE_APP "app"
!define SWIFTWIRE_APP_USER "${SWIFTWIRE_APP}\user"
!define SWIFTWIRE_APP_BAR_PREP "${SWIFTWIRE_APP}\bar_prep.ahk"
!define SWIFTWIRE_APP_BOOSTER "${SWIFTWIRE_APP}\${SWIFTWIRE_BOOSTER_EXE}"
!define SWIFTWIRE_APP_COMMAND_BUILDER "${SWIFTWIRE_APP}\Command_Builder.ahk"
!define SWIFTWIRE_APP_COORDINATES "${SWIFTWIRE_APP}\${SWIFTWIRE_COORDINATES_EXE}"
!define SWIFTWIRE_APP_SWIFTWIRE "${SWIFTWIRE_APP}\SwiftWire.app"
!define SWIFTWIRE_APP_TUTORIAL "${SWIFTWIRE_APP}\Tutorial.ahk"
!define SWIFTWIRE_APP_USAGE_SYNC "${SWIFTWIRE_APP}\usage_sync.ahk"
!define SWIFTWIRE_APP_WINSPARKLE "${SWIFTWIRE_APP}\winsparkle.ahk"
!define SWIFTWIRE_APP_RESOURCES_COMMANDFILE "${SWIFTWIRE_APP}\resources\commandfile"
!define SWIFTWIRE_APP_RESOURCES_EULA "${SWIFTWIRE_APP}\resources\EULA"
!define SWIFTWIRE_APP_RESOURCES_EULA_FILE "${SWIFTWIRE_APP_RESOURCES_EULA}\SWIFTWIRE_EULA.txt"
!define SWIFTWIRE_APP_RESOURCES_IMAGES "${SWIFTWIRE_APP}\resources\images"
!define SWIFTWIRE_APP_RESOURCES_IMAGES_INSTALLER_ICON "${SWIFTWIRE_APP_RESOURCES_IMAGES}\install.ico"
!define SWIFTWIRE_APP_RESOURCES_MODULES "${SWIFTWIRE_APP}\resources\modules"
!define SWIFTWIRE_APP_RESOURCES_INSTALLER "${SWIFTWIRE_APP}\resources\installer"
!define SWIFTWIRE_APP_RESOURCES_INSTALLER_USER "${SWIFTWIRE_APP_RESOURCES_INSTALLER}\user"
!define SWIFTWIRE_APP_RESOURCES_INSTALLER_WINSPARKLE "${SWIFTWIRE_APP_RESOURCES_INSTALLER}\WinSparkle.dll"
!define SWIFTWIRE_APP_RESOURCES_INSTALLER_SETTINGS_NEW "${SWIFTWIRE_APP_RESOURCES_INSTALLER}\SwiftWireSettings_new.ini"
!define SWIFTWIRE_APP_RESOURCES_INSTALLER_SETTINGS_UPDATE "${SWIFTWIRE_APP_RESOURCES_INSTALLER}\SwiftWireSettings_update.ini"
!define SWIFTWIRE_APP_RESOURCES_SCRIPTS "${SWIFTWIRE_APP}\resources\scripts"

################################################
Var NUM
Var BACKUP_DIR
Var INSTALL_DIR
!define INSTALL_TYPE "SetShellVarContext current"
!define REG_ROOT "HKCU"
!define REG_APP_PATH "Software\Microsoft\Windows\CurrentVersion\App Paths\${SWIFTWIRE_EXE}"
!define REG_UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SWIFTWIRE}"
!define REG_INSTALL_DIR "Software\${SWIFTWIRE_COMPANY}\${SWIFTWIRE}"
!define REG_INSTALL_KEY "INSTALL_DIR"

################################################
VIProductVersion  "${SWIFTWIRE_VERSION}"
VIAddVersionKey "ProductName"  "${SWIFTWIRE}"
VIAddVersionKey "CompanyName"  "${SWIFTWIRE_COMPANY}"
VIAddVersionKey "LegalCopyright"  "${SWIFTWIRE_COPYRIGHT}"
VIAddVersionKey "FileDescription"  "${SWIFTWIRE_DESCRIPTION}"
VIAddVersionKey "FileVersion"  "${SWIFTWIRE_VERSION}"

################################################
XPStyle on
SetCompressor ZLIB
Name "${SWIFTWIRE}"
Caption "${SWIFTWIRE}"
OutFile "${SWIFTWIRE_INSTALLER}"
BrandingText "${SWIFTWIRE}"
InstallDirRegKey "${REG_ROOT}" "${REG_APP_PATH}" ""
InstallDir "$INSTALL_DIR"

################################################
!define MUI_ICON "${SWIFTWIRE_APP_RESOURCES_IMAGES_INSTALLER_ICON}"
!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SWIFTWIRE_APP_RESOURCES_EULA_FILE}"
!define MUI_PAGE_HEADER_SUBTEXT "Choose your preferred ${SWIFTWIRE} installation folder."
!define MUI_DIRECTORYPAGE_TEXT_TOP "Setup will install ${SWIFTWIRE} in the following folder. To install in a different folder, click Browse and select another folder. Click Install to start the installation. Note: Your scripts and settings will remain untouched during updates."
!define MUI_DIRECTORYPAGE_VARIABLE $INSTALL_DIR
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTALL_DIR\${SWIFTWIRE_EXE}"
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

################################################
Section -MainProgram
	${INSTALL_TYPE}
	SetOverwrite on
	SetOutPath "$INSTALL_DIR"
	File "${SWIFTWIRE_EXE}"
	File "${SWIFTWIRE_README}"
	SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP}"
	File "${SWIFTWIRE_APP_BAR_PREP}"
	File "${SWIFTWIRE_APP_BOOSTER}"
	File "${SWIFTWIRE_APP_COMMAND_BUILDER}"
	File "${SWIFTWIRE_APP_COORDINATES}"
	File "${SWIFTWIRE_APP_SWIFTWIRE}"
	File "${SWIFTWIRE_APP_TUTORIAL}"
	File "${SWIFTWIRE_APP_USAGE_SYNC}"
	File "${SWIFTWIRE_APP_WINSPARKLE}"
	CreateDirectory "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_COMMANDFILE}"
	SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_EULA}"
	File "${SWIFTWIRE_APP_RESOURCES_EULA_FILE}"
	SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_IMAGES}"
	File /r "${SWIFTWIRE_APP_RESOURCES_IMAGES}\*"
	SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_MODULES}"
	File /r "${SWIFTWIRE_APP_RESOURCES_MODULES}\*"
	SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_INSTALLER}"
	File "${SWIFTWIRE_APP_RESOURCES_INSTALLER_WINSPARKLE}"
	${If} ${FileExists} "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_SCRIPTS}\${SWIFTWIRE_SETTINGS}"
		SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_INSTALLER}"
		File "${SWIFTWIRE_APP_RESOURCES_INSTALLER_SETTINGS_UPDATE}"
		Push "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_INSTALLER_SETTINGS_UPDATE}"
		Push "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_SCRIPTS}\${SWIFTWIRE_SETTINGS}"
		Call ReadINIFileKeys
		Delete "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_INSTALLER_SETTINGS_UPDATE}"
	${Else}
		SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP_RESOURCES_SCRIPTS}"
		File "/oname=${SWIFTWIRE_SETTINGS}" "${SWIFTWIRE_APP_RESOURCES_INSTALLER_SETTINGS_NEW}"
	${EndIf}
	SetOverwrite off
	SetOutPath "$INSTALL_DIR\${SWIFTWIRE_APP_USER}"
	File /r "${SWIFTWIRE_APP_RESOURCES_INSTALLER_USER}\*"
SectionEnd

################################################
Section -Icons_Reg
	${INSTALL_TYPE}
	SetOutPath "$INSTALL_DIR"
	WriteUninstaller "$INSTALL_DIR\${SWIFTWIRE_UNINSTALLER}"
	CreateShortCut "${SWIFTWIRE_DESKTOP_SHORTCUT}" "$INSTALL_DIR\${SWIFTWIRE_EXE}"
	CreateDirectory "${SWIFTWIRE_START_FOLDER}"
	CreateShortCut "${SWIFTWIRE_START_SHORTCUT}" "$INSTALL_DIR\${SWIFTWIRE_EXE}"
	WriteRegStr ${REG_ROOT} "${REG_APP_PATH}" "" "$INSTALL_DIR\${SWIFTWIRE_EXE}"
	WriteRegStr ${REG_ROOT} "${REG_UNINSTALL_PATH}"  "DisplayName" "${SWIFTWIRE}"
	WriteRegStr ${REG_ROOT} "${REG_UNINSTALL_PATH}"  "UninstallString" "$INSTALL_DIR\${SWIFTWIRE_UNINSTALLER}"
	WriteRegStr ${REG_ROOT} "${REG_UNINSTALL_PATH}"  "DisplayIcon" "$INSTALL_DIR\${SWIFTWIRE_EXE}"
	WriteRegStr ${REG_ROOT} "${REG_UNINSTALL_PATH}"  "DisplayVersion" "${SWIFTWIRE_VERSION}"
	WriteRegStr ${REG_ROOT} "${REG_UNINSTALL_PATH}"  "Publisher" "${SWIFTWIRE_COMPANY}"
	WriteRegStr ${REG_ROOT} "${REG_UNINSTALL_PATH}"  "URLInfoAbout" "${SWIFTWIRE_WEBSITE}"
SectionEnd

################################################
Section Uninstall
	${INSTALL_TYPE}
	${If} ${FileExists} "$INSTALL_DIR\${SWIFTWIRE_APP_USER}"
		MessageBox MB_YESNO "Would you like to create a backup for your ${SWIFTWIRE} scripts folder: $INSTALL_DIR\${SWIFTWIRE_APP_USER}?" IDYES backup IDNO continue
	${EndIf}
	Goto continue
	backup:
		StrCpy $NUM 0
		StrCpy $BACKUP_DIR "${SWIFTWIRE_BACKUP_USER}"
	backup_loop:
		${If} ${FileExists} "$BACKUP_DIR"
			IntOp $NUM $NUM + 1
			StrCpy $BACKUP_DIR "${SWIFTWIRE_BACKUP_USER} $NUM"
			Goto backup_loop
		${EndIf}
		CreateDirectory "$BACKUP_DIR"
		CopyFiles "$INSTALL_DIR\${SWIFTWIRE_APP_USER}\*" "$BACKUP_DIR"
		MessageBox MB_OK "Your ${SWIFTWIRE} scripts folder has been backed up as: $BACKUP_DIR"
	continue:
		Delete "$INSTALL_DIR\${SWIFTWIRE_EXE}"
		Delete "$INSTALL_DIR\${SWIFTWIRE_README}"
		Delete "$INSTALL_DIR\${SWIFTWIRE_UNINSTALLER}"
		RMDir /r "$INSTALL_DIR\${SWIFTWIRE_APP}"
		SetOutPath "$TEMP"
		Push "$INSTALL_DIR"
		Call un.isEmptyDir
		Pop $0
		StrCmp $0 1 0 +2
			RMDir "$INSTALL_DIR"
		Delete "${SWIFTWIRE_DESKTOP_SHORTCUT}"
		RMDir /r "${SWIFTWIRE_START_FOLDER}"
		DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
		DeleteRegKey ${REG_ROOT} "${REG_UNINSTALL_PATH}"
		DeleteRegKey ${REG_ROOT} "${REG_INSTALL_DIR}"
SectionEnd

################################################
!macro SwiftWire_Init
	${nsProcess::CloseProcess} "${SWIFTWIRE_EXE}" $R0
	${nsProcess::CloseProcess} "${SWIFTWIRE_BOOSTER_EXE}" $R0
	${nsProcess::CloseProcess} "${SWIFTWIRE_COORDINATES_EXE}" $R0
	ReadRegStr $INSTALL_DIR HKCU "${REG_INSTALL_DIR}" "${REG_INSTALL_KEY}"
	${IF} $INSTALL_DIR == ""
		StrCpy $INSTALL_DIR "${SWIFTWIRE_HOME}"
	${EndIf}
	StrCpy $INSTDIR "$INSTALL_DIR"
!macroend

################################################
Function .onInit
	!insertmacro SwiftWire_Init
FunctionEnd
Function un.onInit
	MessageBox MB_YESNO "Are you sure you want to permanently remove ${SWIFTWIRE}?" IDYES next
	SetErrorLevel 1
	Quit
	next:
	!insertmacro SwiftWire_Init
FunctionEnd
Function un.isEmptyDir
	Exch $0
	Push $1
	FindFirst $0 $1 "$0\*.*"
	StrCmp $1 "." 0 _notempty
	FindNext $0 $1
	StrCmp $1 ".." 0 _notempty
	ClearErrors
	FindNext $0 $1
	IfErrors 0 _notempty
	FindClose $0
	Pop $1
	StrCpy $0 1
	Exch $0
	Goto _end
	_notempty:
		FindClose $0
		ClearErrors
		Pop $1
		StrCpy $0 0
		Exch $0
	_end:
FunctionEnd
Function ReadINIFileKeys
	Exch $R0
	Exch
	Exch $R1
	Push $R2
	Push $R3
	Push $R4
	Push $R5
	Push $R6
	FileOpen $R2 $R1 r
	Loop:
		FileRead $R2 $R3
		IfErrors Exit
		Push $R3
		Call StrTrimNewLines
		Pop $R3
		StrCmp $R3 "" Loop
		StrCpy $R4 $R3 1
		StrCmp $R4 ";" Loop
		StrCpy $R4 $R3 "" -1
		StrCmp $R4 "]" 0 +6
		StrCpy $R6 $R3 -1
		StrLen $R4 $R6
		IntOp $R4 $R4 - 1
		StrCpy $R6 $R6 "" -$R4
		Goto Loop
		Push "="
		Push $R3
		Call SplitFirstStrPart
		Pop $R4
		Pop $R5       
		WriteINIStr $R0 $R6 $R4 $R5      
		Goto Loop
	Exit:
		FileClose $R2
		Pop $R6
		Pop $R5
		Pop $R4
		Pop $R3
		Pop $R2
		Pop $R1
		Pop $R0
FunctionEnd
Function SplitFirstStrPart
	Exch $R0
	Exch
	Exch $R1
	Push $R2
	Push $R3
	StrCpy $R3 $R1
	StrLen $R1 $R0
	IntOp $R1 $R1 + 1
	loop:
		IntOp $R1 $R1 - 1
		StrCpy $R2 $R0 1 -$R1
		StrCmp $R1 0 exit0
		StrCmp $R2 $R3 exit1 loop
	exit0:
		StrCpy $R1 ""
		Goto exit2
	exit1:
		IntOp $R1 $R1 - 1
		StrCmp $R1 0 0 +3
		StrCpy $R2 ""
		Goto +2
		StrCpy $R2 $R0 "" -$R1
		IntOp $R1 $R1 + 1
		StrCpy $R0 $R0 -$R1
		StrCpy $R1 $R2
	exit2:
		Pop $R3
		Pop $R2
		Exch $R1
		Exch
		Exch $R0
FunctionEnd
Function StrTrimNewLines
	Exch $R0
	Push $R1
	Push $R2
	StrCpy $R1 0
	loop:
		IntOp $R1 $R1 - 1
		StrCpy $R2 $R0 1 $R1
		${If} $R2 == `$\r`
		${OrIf} $R2 == `$\n`
			Goto loop
		${EndIf}
		IntOp $R1 $R1 + 1
		${If} $R1 < 0
			StrCpy $R0 $R0 $R1
		${EndIf}
		Pop $R2
		Pop $R1
		Exch $R0
FunctionEnd
