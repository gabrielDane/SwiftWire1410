;--------------------------------------------------------------- 
;Notify Lock\Unlock
;	This script monitors LockWorkstation calls
;
;	If a change is detected it 'notifies' the calling script
;		On Lock
;			This script will call function "on_lock()"
;		On Unlock
;			This script will call fucntion "on_unlock()"
;IMPORTANT: The functions "on_lock()" and "on_unlock()" DO NOT
;exist in this script, they are to be created in the script that
;calls notify_lock_unlock() (presumably your main script)
;---------------------------------------------------------------
;Re-purposed by WTO605
;Last edited 2009-08-18 16:34 UTC
;---------------------------------------------------------------
;Based on Winamp_Lock_Pause by MrInferno
;Posted: Fri Apr 21, 2006 4:49 am
;Source: http://www.autohotkey.com/forum/topic9384.html
;---------------------------------------------------------------
;Winamp_Lock_Pause was/is based on script codes from "shimanov"
;Posted: Thu Sep 15, 2005 12:26 am   
;Source: http://www.autohotkey.com/forum/viewtopic.php?t=5359
;Posted: Tue Dec 06, 2005 9:14 pm
;Source: http://www.autohotkey.com/forum/viewtopic.php?t=6755
;---------------------------------------------------------------

;Initialize global constants
WTS_SESSION_LOCK		:=	0x7
WTS_SESSION_UNLOCK		:=	0x8
NOTIFY_FOR_ALL_SESSIONS	:=	1
NOTIFY_FOR_THIS_SESSION	:=	0
WM_WTSSESSION_CHANGE	:=	0x02B1

notify_lock_unlock()
{
	Global WM_WTSSESSION_CHANGE
	Global NOTIFY_FOR_ALL_SESSION

	hw_ahk := FindWindowEx( 0, 0, "AutoHotkey", a_ScriptFullPath " - AutoHotkey v" a_AhkVersion ) 

	OnMessage( WM_WTSSESSION_CHANGE, "Handle_WTSSESSION_CHANGE" ) 

	success := DllCall( "wtsapi32.dll\WTSRegisterSessionNotification", "uint", hw_ahk, "uint", NOTIFY_FOR_ALL_SESSIONS )

	if( ErrorLevel OR ! success ) 
	{
		success := DllCall( "wtsapi32.dll\WTSUnRegisterSessionNotification", "uint", hw_ahk )
		;If DLL registration fails, wait 20 seconds and try again
		Sleep, 20000
		notify_lock_unlock()
		;MsgBox, [WTSRegisterSessionNotification] failed: EL = %ErrorLevel%
	}
	return
}

Handle_WTSSESSION_CHANGE( p_w, p_l, p_m, p_hw )
; p_w  = wParam   ;Session state change event
; p_l  = lParam   ;Session ID
; p_m  = Msg   ;WM_WTSSESSION_CHANGE
; p_hw = hWnd   ;Handle to Window
{
	Global WTS_SESSION_LOCK
	Global WTS_SESSION_UNLOCK

	If ( p_w = WTS_SESSION_LOCK ) 
	{
		on_lock()
	}
	Else If ( p_w = WTS_SESSION_UNLOCK ) 
	{
		on_unlock()
	}
}

FindWindowEx( p_hw_parent, p_hw_child, p_class, p_title ) 
{
	return, DllCall( "FindWindowEx", "uint", p_hw_parent, "uint", p_hw_child, "str", p_class, "str", p_title ) 
}