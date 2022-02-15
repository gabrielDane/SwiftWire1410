/*
	The routine "routine_init_winsparkle" initializes the WinSparkle.dll
	for application updates fetching bases on user preferences. WinSparkle
	creates values on the registry (HKCU) to track first usage and when to
	update based on preferences.
	
	The WinSparkleAHK class helps with calling functions from the DLL.
	The routine "routine_winsparkle_config" opens a GUI for winsparkle updates configuration.
	
	IMPORTANT NOTICE:
	Ensure both routine_winsparkle_init are in the same script.
	Call "routine_winsparkle_init" before calling "routine_winsparkle_config"
*/

;initializes winsparkle.dll library for updates management
routine_winsparkle_init:

;Reading SwiftWire Application Version
swiftwire_settings := A_ScriptDir "\resources\scripts\SwiftWireSettings.ini"
IniRead, app_version, %swiftwire_settings%, Version, appVersion ;read saved application version
if app_version = Error
{
	MsgBox, 16, SwiftWire Updates Error, Unable to read Swiftwire version from the settings
	return
}

;WinSparkleAHK setup
wsparkle_dll := A_ScriptDir "\resources\installer\WinSparkle.dll"
wsparkle_appcast := "http://fluent.systems/winsparkle/SwiftwireAppcast.xml"
wsparkle_company := "Fluent Systems"
wsparkle_app_name := "SwiftWire"
wsparkle_app_version := app_version

;WinSparkleAHK Initialization
if !WinSparkleAHK.load(wsparkle_dll)
{
	MsgBox, 16, SwiftWire Updates Error, % "Failed to load Updater!`n" WinSparkleAHK.error
	return
}
if !WinSparkleAHK.setAppDetails(wsparkle_company, wsparkle_app_name, wsparkle_app_version)
{
	MsgBox, 16, SwiftWire Updates Error, % "Unable to setup application details!`n" WinSparkleAHK.error
	return
}
if !WinSparkleAHK.setAppcastUrl(wsparkle_appcast)
{
	MsgBox, 16, SwiftWire Updates Error, % "Unable to setup appcast link!`n" WinSparkleAHK.error
	return
}
if !WinSparkleAHK.init()
{
	MsgBox, 16, SwiftWire Updates Error, % "Failed to initialize!`n" WinSparkleAHK.error
	return
}
return

;show/configure winsparkle.dll basic options
routine_winsparkle_config:
_wsparkle_auto := WinSparkleAHK.getAutomaticCheckForUpdates()
_wsparkle_interval := WinSparkleAHK.getUpdateCheckInterval()
_wsparkle_check := WinSparkleAHK.getLastCheckTime()
Gui, _wsparkle_: Destroy
Gui, _wsparkle_: +AlwaysOnTop
Gui, _wsparkle_: Add, CheckBox, x16 y17 w270 h20 v_wsparkle_auto Checked%_wsparkle_auto%, Automatically check for updates
Gui, _wsparkle_: Add, Text, x16 y47 w130 h20 , Updates check interval
Gui, _wsparkle_: Add, Edit, x146 y47 w140 h20 v_wsparkle_interval,% _wsparkle_interval
Gui, _wsparkle_: Add, Text, x16 y67 w270 h20 , Check interval is in seconds with a minimum of 3600s.
Gui, _wsparkle_: Add, Text, x16 y87 w130 h20 , Updates last check
Gui, _wsparkle_: Add, Edit, x146 y87 w140 h20 ReadOnly, % _wsparkle_check
Gui, _wsparkle_: Add, Button, x16 y117 w110 h30 g_wsparkle_save, Save Changes
Gui, _wsparkle_: Add, Button, x176 y117 w110 h30 g_wsparkle_update, Check Updates
Gui, _wsparkle_: Show, w303 h162, SwiftWire Updates
return

_wsparkle_GuiEscape:
_wsparkle_GuiClose:
Gui, _wsparkle_: Destroy
return

;save new config changes
_wsparkle_save:
Gui, _wsparkle_: Default
Gui, _wsparkle_: +OwnDialogs
Gui, _wsparkle_: Submit, NoHide
;correct input before save
if (_wsparkle_auto != 0 && _wsparkle_auto != 1)
	_wsparkle_auto := 1
if _wsparkle_interval is not number
	_wsparkle_interval := 86400 ;1 day
if _wsparkle_interval < 3600
	_wsparkle_interval := 3600 ;min
if !WinSparkleAHK.setAutomaticCheckForUpdates(_wsparkle_auto)
{
	MsgBox, 48, SwiftWire Updates, % "Failed to save automatic updates check state`n" WinSparkleAHK.error
	return
}
if !WinSparkleAHK.setUpdateCheckInterval(_wsparkle_interval)
{
	MsgBox, 48, SwiftWire Updates, % "Failed to save automatic updates check interval`n" WinSparkleAHK.error
	return
}
goto, routine_winsparkle_config

;manually check for updates with UI
_wsparkle_update:
Gui, _wsparkle_: Default
Gui, _wsparkle_: +OwnDialogs
if !WinSparkleAHK.checkUpdateWithUi()
{
	MsgBox, 48, SwiftWire Updates, % "Unable to check for updates`n" WinSparkleAHK.error
	return
}
goto, _wsparkle_GuiClose ;close config when checking for updates

/*
	WinSparkle.dll Wrapper for AutoHotkey
	For documentation and example usage: https://github.com/xthukuh/WinSparkleAHK
*/
class WinSparkleAHK {
	static dll := A_ScriptDir "\WinSparkle.dll"
	static success := false
	static module := ""
	static error := ""
	load(dll := ""){
		if (dll && FileExist(dll))
			WinSparkleAHK.dll := dll
		if FileExist(WinSparkleAHK.dll)
		{
			if WinSparkleAHK.module
				return true
			WinSparkleAHK.module := WinSparkleAHKDllCall("LoadLibrary", "Str", WinSparkleAHK.dll, "Ptr")
			if WinSparkleAHK.module
			{
				OnExit("WinSparkleAHKOnExit", -1)
				return true
			}
			else {
				WinSparkleAHK.error := WinSparkleAHKDllCall_Error
				WinSparkleAHK.module := ""
			}
		}
		else WinSparkleAHK.error := "Missing WinSparkle.dll file in path: " WinSparkleAHK.dll
		return false
	}
	unload(){
		if WinSparkleAHK.module
		{
			if WinSparkleAHK.cleanup()
			{
				if WinSparkleAHKDllCall("FreeLibrary", "Ptr", WinSparkleAHK.module)
				{
					OnExit("WinSparkleAHKOnExit", 0)
					WinSparkleAHK.module := ""
					return true
				}
				else WinSparkleAHK.error := WinSparkleAHKDllCall_Error
			}
		}
		else WinSparkleAHK.error := "DLL module had not been loaded!"
		return false
	}
	call(method, args*){
		global WinSparkleAHKDllCall_Error
		args.InsertAt(1, WinSparkleAHK.dll "\" method)
		args.Insert("Cdecl")
		result := WinSparkleAHKDllCall(args*)
		if (ErrorLevel != 0)
		{
			WinSparkleAHK.error := WinSparkleAHKDllCall_Error
			WinSparkleAHK.success := false
		}
		else WinSparkleAHK.success := true
		return result
	}
	;WinSparkle Calls Helpers
	checkUpdateWithUi(){
		result := WinSparkleAHK.call("win_sparkle_check_update_with_ui")
		return WinSparkleAHK.success ;return true/false
	}
	checkUpdateWithoutUi(){
		result := WinSparkleAHK.call("win_sparkle_check_update_without_ui")
		return WinSparkleAHK.success ;return true/false
	}
	cleanup(){
		result := WinSparkleAHK.call("win_sparkle_cleanup")
		return WinSparkleAHK.success ;return true/false
	}
	getAutomaticCheckForUpdates(){
		result := WinSparkleAHK.call("win_sparkle_get_automatic_check_for_updates")
		return WinSparkleAHK.success ? result : ""
	}
	getLastCheckTime(){
		result := WinSparkleAHK.call("win_sparkle_get_last_check_time")
		return WinSparkleAHK.success ? result : ""
	}
	getUpdateCheckInterval(){
		result := WinSparkleAHK.call("win_sparkle_get_update_check_interval")
		return WinSparkleAHK.success ? result : ""
	}
	init(){
		result := WinSparkleAHK.call("win_sparkle_init")
		return WinSparkleAHK.success ;return true/false
	}
	setAppBuildVersion(build){
		result := WinSparkleAHK.call("win_sparkle_set_app_build_version", "WStr", build)
		return WinSparkleAHK.success ;return true/false
	}
	setAppDetails(company_name, app_name, app_version){
		result := WinSparkleAHK.call("win_sparkle_set_app_details", "WStr", company_name, "WStr", app_name, "WStr", app_version)
		return WinSparkleAHK.success ;return true/false
	}
	setAppcastUrl(url){
		result := WinSparkleAHK.call("win_sparkle_set_appcast_url", "AStr", url)
		return WinSparkleAHK.success ;return true/false
	}
	setAutomaticCheckForUpdates(state){
		result := WinSparkleAHK.call("win_sparkle_set_automatic_check_for_updates", "Int", state)
		return WinSparkleAHK.success ;return true/false
	}
	setCanShutdownCallback(callback){
		result := WinSparkleAHK.call("win_sparkle_set_can_shutdown_callback", "Uint", callback)
		return WinSparkleAHK.success ;return true/false
	}
	setLang(lang){
		result := WinSparkleAHK.call("win_sparkle_set_lang", "AStr", lang)
		return WinSparkleAHK.success ;return true/false
	}
	setLangid(lang){
		result := WinSparkleAHK.call("win_sparkle_set_langid", "Short", lang)
		return WinSparkleAHK.success ;return true/false
	}
	setRegistryPath(path){
		result := WinSparkleAHK.call("win_sparkle_set_registry_path", "AStr", path)
		return WinSparkleAHK.success ;return true/false
	}
	setShutdownRequest_callback(callback){
		result := WinSparkleAHK.call("win_sparkle_set_shutdown_request_callback", "Uint", callback)
		return WinSparkleAHK.success ;return true/false
	}
	setUpdateCheckInterval(interval := 86400){
		result := WinSparkleAHK.call("win_sparkle_set_update_check_interval", "Int", interval)
		return WinSparkleAHK.success ;return true/false
	}
}
;Onexit WinSparkleAHK unload
WinSparkleAHKOnExit(){
	if !WinSparkleAHK.unload()
	{
		MsgBox, 4373, WinSparkle - Unload Error!, % "Error unloading WinSparkle updater library: " WinSparkleAHK.error, 8
		IfMsgBox, Retry
			return WinSparkleAHKOnExit()
	}
	return 0
}
/*
StrPutVar(string, ByRef var, encoding) ;from the help file
{
    VarSetCapacity(var, StrPut(string, encoding) * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1))
    return StrPut(string, &var, encoding)
}
*/
;Helper for dynamic DLLCall
WinSparkleAHKDllCall(args*){
	global WinSparkleAHKDllCall_Error
	for k, v in args
		str .= str = "" ? v : "," v
	result := Func("DllCall").Call(args*)
	if (ErrorLevel != 0){
		if (ErrorLevel = -1)
			WinSparkleAHKDllCall_Error := "The [DllFile\]Function parameter is a floating point number. A string or positive integer is required."
		else if (ErrorLevel = -2)
			WinSparkleAHKDllCall_Error := "The return type or one of the specified arg types is invalid."
		else if (ErrorLevel = -3)
			WinSparkleAHKDllCall_Error := "The specified DllFile could not be accessed or loaded."
		else if (ErrorLevel = -4)
			WinSparkleAHKDllCall_Error := "The specified function could not be found inside the DLL."
		else {
			if (SubStr(ErrorLevel, 1, 1) = "A")
				WinSparkleAHKDllCall_Error := "The function was called but was passed too many or too few arguments: " SubStr(ErrorLevel, 2)
			else WinSparkleAHKDllCall_Error := "Unspecified Errorlevel: " ErrorLevel ". LastError: " A_LastError
		}
	}
	else return result
}
