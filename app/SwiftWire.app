/* 
    SWIFTWIRE - Desktop Automation Reimagined
    Copyright 2018, Fluent Systems, Inc. 
    Encoding - UTF-8 with BOM
 */

appVersion := "1.4.1.0"
#SingleInstance,force
#Persistent
#NoEnv 
SetTitleMatchMode, 2
DetectHiddenWindows, On


gosub, routine_winsparkle_init ;Martin's edit_12012018 - initialize WinSparkle on main application load

/*
	Include Plugin launch code
*/
#Include %A_ScriptDir%\user\Plugins.dat

/*
	Load SW Settings variables
	Syntax: IniRead, OutputVar, Filename, Section, Key [, Default]
	Say if you want to get 'Orange' and store it to a variable called ABC, then use: 
	IniRead, ABC, C:\Folder\File.INI, Fruits, Name2
*/
IniRead, startWithWindows, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Settings, startWithWindows
;IniRead, appVersion, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Version, appVersion
IniWrite, %appVersion%, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Version, appVersion

; Include Lock/Unlock detect script
#Include %A_ScriptDir%\resources\modules\notifylockunlock.ahk
notify_lock_unlock()


; required wait time 
sleep, 1000


; APP-BAR CODE (comes before GUI code)
DetectHiddenWindows, On
DetectHiddenText, On
uEdge=1 ; left=0,top=1,right=2,bottom=3
uAppHeight=25 ; "ideal" height when horizonal
SysGet, Mon1, MonitorWorkArea
ScreenWidth := Mon1Right - Mon1Left
ScreenHeight := Mon1Bottom - Mon1Top
GX := 0
GY := 0
GW := ScreenWidth
GH := uAppHeight


; prepare global settings
app = Overdrive
;current_user := "user1"
current_user_files = %A_ScriptDir%\user\


SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
SetDefaultMouseSpeed, 0
CoordMode, Mouse, Screen


; create "user" menu
Gosub,USERMENU


; create the tray menu
Menu,TRAY,NoStandard
Menu,TRAY,Add,About SwiftWire,about_swiftwire
Menu,Tray,Add
Menu,TRAY,Add,Import `/ Export Commands,show_command_folder
Menu,Tray,Add
Menu,Tray,Add,Re-Play Tutorial,Tutorial ;Tutorial

;toggle auto-start
;menu,sub_settings,add
if (startWithWindows = 1)
{
Menu,sub_settings,Add,Start SwiftWire with Windows,uncheckAutoStart
Menu,sub_settings,Check,Start SwiftWire with Windows
}
else
{
Menu,sub_settings,Add,Start SwiftWire with Windows,checkAutoStart
}
Menu,sub_settings,Add,Automatic Updates,routine_winsparkle_config ;Martin's edit_12012018 - for opening Winsparkle basic config

;Menu, tray, add, Choice, :test
Menu,Tray,Add
Menu, Tray, Add, Settings, :sub_settings
menu,Tray,add
menu,Tray,add,Exit,Exit
Menu,Tray,Default,About SwiftWire
Menu,Tray,Tip,SwiftWire


;draw interface
Menu, Tray, Icon, %A_ScriptDir%\resources\images\sw_logo_new.ico
SysGet, work_area_1, MonitorWorkArea, 1
tool_bar_width := work_area_1Right
tool_bar_height = 25
min_close_position := tool_bar_width - 50 ;(96 with external shadow bar)(128 w/ min/close buttons) (72 w/o buttons) (76 in 1.3.0.7 with "X")
shadow_bar_width := tool_bar_width + 20

Gui, 1: +LastFound +AlwaysOnTop
;old code below for drop-shadow
;DllCall("SetClassLong", "uint", WinExist(), "int", -26
;    , "int", DllCall("GetClassLong", "uint", WinExist(), "int", -26) | 0x20000)

Gui, 1: -Caption -DPIScale
Gui, 1: +Toolwindow ;remove taskbar button
Gui, 1: Color, 333333 ;18282f
Gui, 1: Margin, X0, Y0
Gui, 1: Font, s9, Arial
Gui, 1: Font, cffffff bold ;italic
;Gui, _guiCMDBuilder: Add, Picture, x0 y0 v_cmd_builder_black_ribbon g_cmd_builder_black_ribbon,%A_ScriptDir%\resources\images\cb-logo-1.png
;Gui, 1: Add, Picture, x28 y4 -gUSERMENU_SHOW, %A_ScriptDir%\resources\images\sw-bar-1.png
Gui, 1: Add, Picture, x0 y0 -gUSERMENU_SHOW, %A_ScriptDir%\resources\images\sw-bar-3.png
;Gui, 1: Add,text,x28 y2 -gUSERMENU_SHOW,swiftwire
Gui, 1: Font, c38978d bold ;italic
;Gui, 1: Add,text, y2 -gUSERMENU_SHOW,WIRE
; Add Unicode down arrow to make clicking 'SWIFTWIRE' more intuitive
Gui, 1: Font, s7, norm
;Gui, 1: Add, text, x+7 y4 -gUSERMENU_SHOW,▼
Gui, 1: Font, cffffff norm ;was cd3d3d3 for grey categories

; LOAD THE COMMANDS AND PREPARE THE COMMANDS.DAT FILE
;start of -- martin fix 20160915 - in order to work with the new bar_prep.ahk
asciistr(str){
	str_out := ""
	loop, parse, str
		str_out .= asc(a_loopfield)
	return str_out
}

ignorepath(path){
	;ignore specific files/folders AND hidden/readonly/system files
	SplitPath, path,,,,path_file_name
	FileGetAttrib, path_file_attrib, % path
	if (category_name == "_gsdata_") ;ignore _gsdata_ folder from Sync
		return true
    if path_file_attrib contains H,R,S ;Skip any file that is either H (Hidden), R (Read-only), or S (System). Note: No spaces in "H,R,S".
		return true
	return false
}

Gui, 1: Font, s9 normal , Verdana
loop,%current_user_files%\*.*,2, 0
{
    category_path := A_LoopFileFullPath
    SplitPath, category_path,,,,category
	_category_sub := "_" asciistr(category)
	if (!ignorepath(category_path)){
		if (A_ScreenDPI == 96) {
		  Gui, 1: Add, Text, x+20 y5 g%_category_sub%,%category%
		} else {
		  Gui, 1: Add, Text, x+20 y2 g%_category_sub%,%category%
        }
		n := 0
		loop, %category_path%\*.od1, 0, 0
			n := A_Index
		if n = 0
			Menu,%_category_sub%,Add,No commands yet,MenuHandler
		else
		{
			loop, %category_path%\*.od1, 0, 0
			{
				command_path := A_LoopFileFullPath
				SplitPath, command_path,,,,command_name
				if (!ignorepath(command_path)){
					command_sub := "_" asciistr(category "." command_name)
					Menu,%_category_sub%,Add,%command_name%,%command_sub%
				}
			}
		}
	}
}
;end of -- martin fix 20160915 - in order to work with the new bar_prep.ahk

; add right bar content

; refresh unicode character & code
refresh_position := min_close_position - 18
Gui, 1: Font, s15
Gui, 1: Font, c837e7c
Gui, 1: Font, normal
;GUi, 1: Add, Text, x%refresh_position% y-4 -greload_toolbar, ⟳
;Gui, 1: Add, Picture, x%refresh_position% y0 -greload_toolbar, %A_ScriptDir%\resources\images\reload.png
;Gui, 1: Add, Picture, x%min_close_position% y1 , %A_ScriptDir%\resources\images\od_logo_mini_1b.bmp
Gui, 1: Font, s9
Gui, 1: Font, c837e7c ;c736f6e
Gui, 1: Font, bold
;Gui, 1: Add, Text, x+18 y2 -gCloseOverdrive , X ;old version with "X" to close the toolbar

; display the UI
Gui, 1: Show, x0 y0 w%shadow_bar_width% h%tool_bar_height%, SwiftWire


; APP-BAR CODE Part-2 (BELOW GUI)
ABM := DllCall( "RegisterWindowMessage", Str,"AppBarMsg" )
 
; APPBARDATA : http://msdn2.microsoft.com/en-us/library/ms538008.aspx
APPBARDATA := ""
Off := ""
VarSetCapacity(APPBARDATA,36,0)
Off := NumPut(36,APPBARDATA) ; cbSize
Off := NumPut(hAB, Off+0 ) ; hWnd
Off := NumPut(ABM, Off+0 ) ; uCallbackMessage
Off := NumPut(uEdge, Off+0 ) ; uEdge: left=0,top=1,right=2,bottom=3
Off := NumPut(GX, Off+0 ) ; rc.left
Off := NumPut(GY, Off+0 ) ; rc.top
Off := NumPut(GW, Off+0 ) ; rc.right
Off := NumPut(GH, Off+0 ) ; rc.bottom
Off := NumPut(1, Off+0 ) ; lParam
GoSub, RegisterAppBar
OnExit, QuitScript


; Reload app on resume from sleep state - required for AppBar to work after wakeup
OnMessage( (WM_POWERBROADCAST:=0x218), "OnPBMsg")
;SetTimer, uploadwork, 100 ;start the logs as soon -- Martin Edit - disabled 032716 gdc 
Return

OnPBMsg(wParam, lParam, msg, hwnd) {
	If (wParam = 18)	;PBT_APMRESUMEAUTOMATIC
		;MsgBox The computer is now automatically resuming from a suspended state.
		Sleep, 3000 ;pause before reload SwiftWire OnResume
		Run, Booster.exe bar_prep.ahk
	;Must return True after message is processed
	Return True
}



/*
    END the auto-run part of the script
*/    
return
;######################################################################################



; call Lock/Unlock & refresh app on Windows Unlock
on_lock()
{
	; do nothing
}
return
on_unlock()
{
    Sleep, 2000
	Run, Booster.exe bar_prep.ahk
}
return

; INCLUDE THE COMMANDS FILE
#Include %A_ScriptDir%\resources\commandfile\commands.dat

#+b::
COMMANDBUILDER:
Run, Booster.exe Command_Builder.ahk
return

EXIT:
WinClose, Edit SwiftWire Toolbar ...
Gui 1: Destroy 
ExitApp
return

/*
#+m::
*/
MOUSE_POSITION:
Run, Coordinates.exe
return

; SwiftWire Main Dropdown Menu
USERMENU:
IniRead, cloud_user, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Sync, cloudUser
menu,USERMENU,add,Edit SwiftWire Toolbar ...,COMMANDBUILDER ;Command Builder
menu,USERMENU,default,Edit SwiftWire Toolbar ...
menu,USERMENU,Icon, Edit SwiftWire Toolbar ..., %A_ScriptDir%\resources\images\38978d-dot-icon.ico, , 16 
;menu,USERMENU,add
menu,USERMENU,add,Mouse Position Finder,MOUSE_POSITION ;Mouse Locator=
menu,USERMENU,add
menu,USERMENU,add,Support,Slack_Community
menu,USERMENU,add
menu,USERMENU,add,Exit,Exit
return

Slack_Community:
IfExist C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
	Run, chrome.exe http://fluent.systems/support-go.html
IfNotExist C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
	Run, http://fluent.systems/support-go.html
return

Tutorial:
Run, Booster.exe Tutorial.ahk
return

;About SwiftWire
about_swiftwire:
MsgBox, 64, SwiftWire by Fluent, Version:  %appVersion%`n`nCopyright © 2019`nFluent Systems`, Inc.`nPatent Pending`n`nDesktop Automation Reimagined

return

;show "user" menu
USERMENU_SHOW:
menu,USERMENU,show,0,25
return

reload_toolbar:
Run, %A_ScriptDir%\Booster.exe bar_prep.ahk
return

show_command_folder:
Run, explore %A_ScriptDir%\user\
return

show_swiftwire_settings:
Run, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini
return

close_gui_2:
Gui 2: Destroy
return

; WikiPedia Search box
WikiPedia:
Gui, Submit, NoHide
Inputbox, Search, Search WikiPedia, , , 200, 100,,,,,Enter search terms...
if ErrorLevel ; no search if click "X" or "Cancel"
    return
else
    Search := RegExReplace(Search, "\s+", "`%20") ; replace spaces with %20
    IfExist C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
        Run, chrome.exe https://en.wikipedia.org/w/index.php?search=%Search%
    IfNotExist C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
        Run, https://en.wikipedia.org/w/index.php?search=%Search%
Return

; Google Search box
GoogleSearch:
Gui, Submit, NoHide
Inputbox, Search, Search Google, , , 200, 100,,,,,Enter search terms...
if ErrorLevel ; no search if click "X" or "Cancel"
    return
else
    Search := RegExReplace(Search, "\s+", "`%20") ; replace spaces with %20
    IfExist C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
        Run, chrome.exe https://www.google.com/search?q=%Search%
    IfNotExist C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
        Run, https://www.google.com/search?q=%Search%
Return



; include custom command scripts
#Include %a_scriptdir%\user\CustomCommands.dat

MenuHandler:
return


; APP-BAR HELPER CODE Part-3 (NEEDED) 
 
RegisterAppBar:
Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_NEW:=0x0),UInt,&APPBARDATA)
Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_QUERYPOS:=0x2),UInt,&APPBARDATA)
Result := DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_SETPOS:=0x3),UInt,&APPBARDATA)
Return
 
RemoveAppBar:
DllCall("Shell32.dll\SHAppBarMessage",UInt,(ABM_REMOVE := 0x1),UInt,&APPBARDATA)
return

; is this necessary?
Cerrar:
QuitScript:
Gui, 1: Destroy
GoSub, RemoveAppbar
ExitApp
Return

 
ABM_Callback( wParam, LParam, Msg, HWnd ) {
; When Taskbar settings are changed, wParam is 1, otherwise it's 2.
; I'll probably add code to handle this later.
}

/* END APP-BAR CODE 
*/


/*
	**********************************************************************************************************************************
	this is the MD5 generator by jNizM
	I will use this to give the categories unique sub names
	Please do not tamper with the code below.
	**********************************************************************************************************************************
*/
MD5(text){
StringLower,text,text

;edit to fix +/- bug in cmd names -gdc
;NewStr := RegExReplace("abc123123", "123$", "xyz")  ; Returns "abc123xyz" because the $ allows a match only at the end.
text := RegExReplace(text, "\+", "x")
text := RegExReplace(text, "-", "y")

;orignal 
text := RegExReplace(text, "i)[^a-zA-Z\d]","_")
text := RegExReplace(text, "i)[^a-zA-Z_\d]")
return text
}

/*
	New functions
*/

json_toobj( str ) {

	quot := """" ; firmcoded specifically for readability. Hardcode for (minor) performance gain
	ws := "`t`n`r " Chr(160) ; whitespace plus NBSP. This gets trimmed from the markup
	obj := {} ; dummy object
	objs := [] ; stack
	keys := [] ; stack
	isarrays := [] ; stack
	literals := [] ; queue
	y := nest := 0

; First pass swaps out literal strings so we can parse the markup easily
	StringGetPos, z, str, %quot% ; initial seek
	while !ErrorLevel
	{
		; Look for the non-literal quote that ends this string. Encode literal backslashes as '\u005C' because the
		; '\u..' entities are decoded last and that prevents literal backslashes from borking normal characters
		StringGetPos, x, str, %quot%,, % z + 1
		while !ErrorLevel
		{
			StringMid, key, str, z + 2, x - z - 1
			StringReplace, key, key, \\, \u005C, A
			If SubStr( key, 0 ) != "\"
				Break
			StringGetPos, x, str, %quot%,, % x + 1
		}
	;	StringReplace, str, str, %quot%%t%%quot%, %quot% ; this might corrupt the string
		str := ( z ? SubStr( str, 1, z ) : "" ) quot SubStr( str, x + 2 ) ; this won't

	; Decode entities
		StringReplace, key, key, \%quot%, %quot%, A
		StringReplace, key, key, \b, % Chr(08), A
		StringReplace, key, key, \t, % A_Tab, A
		StringReplace, key, key, \n, `n, A
		StringReplace, key, key, \f, % Chr(12), A
		StringReplace, key, key, \r, `r, A
		StringReplace, key, key, \/, /, A
		while y := InStr( key, "\u", 0, y + 1 )
			if ( A_IsUnicode || Abs( "0x" SubStr( key, y + 2, 4 ) ) < 0x100 )
				key := ( y = 1 ? "" : SubStr( key, 1, y - 1 ) ) Chr( "0x" SubStr( key, y + 2, 4 ) ) SubStr( key, y + 6 )

		literals.insert(key)

		StringGetPos, z, str, %quot%,, % z + 1 ; seek
	}

; Second pass parses the markup and builds the object iteratively, swapping placeholders as they are encountered
	key := isarray := 1

	; The outer loop splits the blob into paths at markers where nest level decreases
	Loop Parse, str, % "]}"
	{
		StringReplace, str, A_LoopField, [, [], A ; mark any array open-brackets

		; This inner loop splits the path into segments at markers that signal nest level increases
		Loop Parse, str, % "[{"
		{
			; The first segment might contain members that belong to the previous object
			; Otherwise, push the previous object and key to their stacks and start a new object
			if ( A_Index != 1 )
			{
				objs.insert( obj )
				isarrays.insert( isarray )
				keys.insert( key )
				obj := {}
				isarray := key := Asc( A_LoopField ) = 93
			}

			; arrrrays are made by pirates and they have index keys
			if ( isarray )
			{
				Loop Parse, A_LoopField, `,, % ws "]"
					if ( A_LoopField != "" )
						obj[key++] := A_LoopField = quot ? literals.remove(1) : A_LoopField
			}
			; otherwise, parse the segment as key/value pairs
			else
			{
				Loop Parse, A_LoopField, `,
					Loop Parse, A_LoopField, :, % ws
						if ( A_Index = 1 )
							key := A_LoopField = quot ? literals.remove(1) : A_LoopField
						else if ( A_Index = 2 && A_LoopField != "" )
							obj[key] := A_LoopField = quot ? literals.remove(1) : A_LoopField
			}
			nest += A_Index > 1
		} ; Loop Parse, str, % "[{"

		If !--nest
			Break

		; Insert the newly closed object into the one on top of the stack, then pop the stack
		pbj := obj
		obj := objs.remove()
		obj[key := keys.remove()] := pbj
		If ( isarray := isarrays.remove() )
			key++

	} ; Loop Parse, str, % "]}"

	Return obj
} ; json_toobj( str )

json_fromobj( obj ) {

	If IsObject( obj )
	{
		isarray := 0 ; an empty object could be an array... but it ain't, says I
		for key in obj
			if ( key != ++isarray )
			{
				isarray := 0
				Break
			}

		for key, val in obj
			str .= ( A_Index = 1 ? "" : "," ) ( isarray ? "" : json_fromObj( key ) ":" ) json_fromObj( val )

		return isarray ? "[" str "]" : "{" str "}"
	}
	else if obj IS NUMBER
		return obj
;	else if obj IN null,true,false ; AutoHotkey does not natively distinguish these
;		return obj

	; Encode control characters, starting with backslash.
	StringReplace, obj, obj, \, \\, A
	StringReplace, obj, obj, % Chr(08), \b, A
	StringReplace, obj, obj, % A_Tab, \t, A
	StringReplace, obj, obj, `n, \n, A
	StringReplace, obj, obj, % Chr(12), \f, A
	StringReplace, obj, obj, `r, \r, A
	StringReplace, obj, obj, ", \", A
	StringReplace, obj, obj, /, \/, A
	While RegexMatch( obj, "[^\x20-\x7e]", key )
	{
		str := Asc( key )
		val := "\u" . Chr( ( ( str >> 12 ) & 15 ) + ( ( ( str >> 12 ) & 15 ) < 10 ? 48 : 55 ) )
				. Chr( ( ( str >> 8 ) & 15 ) + ( ( ( str >> 8 ) & 15 ) < 10 ? 48 : 55 ) )
				. Chr( ( ( str >> 4 ) & 15 ) + ( ( ( str >> 4 ) & 15 ) < 10 ? 48 : 55 ) )
				. Chr( ( str & 15 ) + ( ( str & 15 ) < 10 ? 48 : 55 ) )
		StringReplace, obj, obj, % key, % val, A
	}
	return """" obj """"
}

/*
	vigenere
*/
_encipher(text, key)
 {
   offset := asc(a_space)
   key := key = "" ? a_space : key
   loop parse, text
    {
      a := asc(a_loopfield) - offset
      b := asc(substr(key, 1 + mod(a_index - 1, strlen(key)), 1)) - offset
      out .= chr(mod(a + b, 95) + offset)
    }
   return out
 }
 
_decipher(text, key)
 {
   offset := asc(a_space)
   loop parse, key
    {
      decoderkey .= chr(95 - (asc(a_loopfield) - offset) + offset)
    }
   return _encipher(text, decoderkey)
 }

 
/*
	urlencode
*/
urlencode(str){
	oldformat := A_FormatInteger
	setformat, integer, H
	loop, parse, str
	{
		if A_LoopField is alnum
		{
			out .= A_LoopField
			continue
		}
		hex := substr(asc(A_LoopField),3)
		out .= "%" . (strlen(hex) = 1 ? "0" . hex : hex)
	}
	setformat, integer, %oldformat%
	return out
}

/*
	URL Download to Var function
*/
UrlDownloadToVar(URL) {
ComObjError(false)
WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
WebRequest.Open("GET", URL)
WebRequest.Send()
Return WebRequest.ResponseText
}

/*
	Toggle Auto-Start
*/
uncheckAutoStart:
IniWrite, 0, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Settings, startWithWindows
startWithWindows := 0
Menu,sub_settings,Add,Start SwiftWire with Windows,checkAutoStart
Menu,sub_settings,Uncheck,Start SwiftWire with Windows
;delete shortcut to start with windows
FileDelete, %A_Startup%\SwiftWire.lnk
return

checkAutoStart:
IniWrite, 1, %A_ScriptDir%\resources\scripts\SwiftWireSettings.ini, Settings, startWithWindows
startWithWindows := 1
Menu,sub_settings,Add,Start SwiftWire with Windows,uncheckAutoStart
Menu,sub_settings,Check,Start SwiftWire with Windows
;add shortcut to start with windows A_Startup
FileCreateShortcut, %A_ScriptDir%\SwiftWire_Sync.exe, %A_Startup%\SwiftWire.lnk, %A_ScriptDir%
msgbox, ,SwiftWire, SwiftWire will now start automatically with Windows
return

;Include WinSparkle - Martin's edit_12012018
#Include, %A_ScriptDir%\winsparkle.ahk