#SingleInstance, force
#NoTrayIcon

window_name := "SwiftWire Tutorial"
tut_x := (A_ScreenWidth / 2) - 400
tut_y := (A_ScreenHeight / 2) - 229
tut_left := (tut_x - 192)
tut_right := (tut_x + 900)

;show purple background the whole Time
Gui, _guiTutorial_background: -DPIScale -Caption +ToolWindow
Gui, _guiTutorial_background: Color, 4d394b
Gui, _guiTutorial_background: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

;drawing the user interface for the tutorial
_guiTutorial0:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%tut_y% ,%A_ScriptDir%\resources\images\tut0.png
  ;Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% ,%A_ScriptDir%\resources\images\tut_left.png
  Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% -g_guiTutorial0a,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_guiTutorial0a:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%tut_y% ,%A_ScriptDir%\resources\images\tut0a.png
  Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% -g_guiTutorial0,%A_ScriptDir%\resources\images\tut_left.png
  Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% -g_guiTutorial1,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_guiTutorial1:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%tut_y% ,%A_ScriptDir%\resources\images\tut1.png
  Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% -g_guiTutorial0a,%A_ScriptDir%\resources\images\tut_left.png
  Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% -g_guiTutorial2,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_guiTutorial2:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%tut_y% ,%A_ScriptDir%\resources\images\tut2.png
  Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% -g_guiTutorial1,%A_ScriptDir%\resources\images\tut_left.png
  Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% -g_guiTutorial3,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_guiTutorial3:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%tut_y% ,%A_ScriptDir%\resources\images\tut3.png
  Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% -g_guiTutorial2,%A_ScriptDir%\resources\images\tut_left.png
  Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% -g_guiTutorial4,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_guiTutorial4:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%tut_y% ,%A_ScriptDir%\resources\images\tut4.png
  Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% -g_guiTutorial3,%A_ScriptDir%\resources\images\tut_left.png
  Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% -g_guiTutorial5,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_guiTutorial5:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%tut_y% ,%A_ScriptDir%\resources\images\tut5.png
  Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% -g_guiTutorial4,%A_ScriptDir%\resources\images\tut_left.png
  Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% -g_guiTutorial6,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_guiTutorial6:

  Gui, _guiTutorial1: Destroy
  Gui, _guiTutorial1: -DPIScale -Caption +ToolWindow
  Gui, _guiTutorial1: Color, 4d394b
  last_y := tut_y + 43
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y%last_y%,%A_ScriptDir%\resources\images\tut6-1.png
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y+83 -g_dontSkipTutorial,%A_ScriptDir%\resources\images\tut6-2.png
  Gui, _guiTutorial1: Add, Picture, x%tut_x% y+43 -g_skipTutorial,%A_ScriptDir%\resources\images\tut6-3.png
  Gui, _guiTutorial1: Add, Picture, x%tut_left% y%tut_y% -g_guiTutorial5,%A_ScriptDir%\resources\images\tut_left.png
  ;Gui, _guiTutorial1: Add, Picture, x%tut_right% y%tut_y% ,%A_ScriptDir%\resources\images\tut_right.png
  Gui, _guiTutorial1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%, %window_name%

return

_skipTutorial:
MsgBox,308,Skip Tutorial Video,Are you really sure you want to skip the tutorial video?  `r`n`r`n(To re-play the tutorial right click the SwiftWire app icon in the system tray)
IfMsgBox,No
	return
Gui, _guiTutorial_background: Destroy
SplashImage, %A_ScriptDir%\resources\images\splash_logo.jpg, b fs10,
Sleep, 3000
SplashImage, Off
Run %A_ScriptDir%\Booster.exe usage_sync.ahk
Run %A_ScriptDir%\Booster.exe bar_prep.ahk
IniWrite, 1, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Settings, tutorialPlayed
ExitApp
return

_dontSkipTutorial:
;msgbox with single "ok", You can re-play the tutorial at anytime by right clicking the SwiftWire app icon in the system tray
;find correct MsgBox code from AHK help
MsgBox,64,Tutorial,You can re-play the tutorial at anytime by right clicking the SwiftWire app icon in the system tray 
Run, http://fluent.systems/tutorial-go.html
Gui, _guiTutorial_background: Destroy
SplashImage, %A_ScriptDir%\resources\images\splash_logo.jpg, b fs10,
Sleep, 3000
SplashImage, Off
Run %A_ScriptDir%\Booster.exe usage_sync.ahk
Run %A_ScriptDir%\Booster.exe bar_prep.ahk
IniWrite, 1, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Settings, tutorialPlayed
ExitApp
return
