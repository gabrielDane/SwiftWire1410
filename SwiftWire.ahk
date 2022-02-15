/* 
  SWIFTWIRE - Desktop Automation Reimagined
  Copyright 2019, Fluent Systems, Inc. 
*/

;preliminaries
#SingleInstance, Force; set tray icon
Menu, Tray, Icon, %A_ScriptDir%\app\resources\images\sw_logo_new.ico
SetWorkingDir %A_ScriptDir%\app\

;Update registry fir INSTALL_DIR used by the installer on update
RegWrite, REG_SZ, HKCU, Software\Fluent Systems\SwiftWire, INSTALL_DIR, %A_ScriptDir%

;Launch tutorial on first run - done 20180203 gdc
IniRead, tutorialPlayed, %A_ScriptDir%\app\resources\scripts\SwiftWireSettings.ini, Settings, tutorialPlayed, 0

;Get user email & launch tutorial
if (tutorialPlayed == 0) {
  ;show purple background while get email
  Gui, _guiTutorial_background: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial_background: Color, 4d394b
  Gui, _guiTutorial_background: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, Purple Rain 
  InputBox, myEmail, Welcome, Please enter your email to start `r`nusing SwiftWire,,238, 145, , , , , me@example.com
  if ErrorLevel {
    MsgBox, ,Email, A valid email address is required to use SwiftWire
    Reload
  }
  else if (myEmail == "" OR InStr(myEmail, "@example.com", false)){ ;edited to filter all @example.com addresses
	MsgBox, ,Email, A valid email address is required to use SwiftWire
	Reload
  }
  else {
  	;CONSIDER:
    ;Messagebox: you entered "myEmail"
  	;is this correct "Yes / No"
  	;if "No", Reload script so can put in new email
  	IniWrite, %myEmail%, %A_ScriptDir%\app\resources\scripts\SwiftWireSettings.ini, RegisteredEmail, myEmail
  	Gui, _guiTutorial_background: Destroy ;kill purple background GUI
    Run %A_ScriptDir%\app\Booster.exe Tutorial.ahk
  }	
}
else
{
  ;if tutoralPlayed already, then launch main app 
  ;splash image code
  SplashImage, %A_ScriptDir%\app\resources\images\splash_logo.jpg, b fs10,
  Sleep, 3000
  SplashImage, Off

  Run %A_ScriptDir%\app\Booster.exe usage_sync.ahk ;call usage sync script (Martin's Edit 20171218)
  Run %A_ScriptDir%\app\Booster.exe bar_prep.ahk
}
ExitApp