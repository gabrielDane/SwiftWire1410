/*
	The routine "routine_usage_sync" saves number of times app has been launched.
	It stores details in the config file and on the Firebase remote server.
	It creates a unique SYNC_ID from a MD5 hash of the computer username and serial no.
	Remote sync: https://swiftwiredb.firebaseio.com/usage/[SYNC_ID]
	Remote sync json: {
		"id" : [USER_ID],
		"start" : [YYYYMMDDHHMMSS],
		"count" : [NUMBER],
		"timestamp" : [YYYYMMDDHHMMSS]
	}
	More details on commented code.
*/

#SingleInstance, force ;run single instance
#Persistent	;keep script running
#NoEnv	;optimize - no env
;#NoTrayIcon ;uncomment to hide this script icon from taskbar tray
SetWorkingDir, % A_ScriptDir ;working dir is script dir
swiftwire_settings := "resources\scripts\SwiftWireSettings.ini" ;config ini file - path relative to working dir
gosub, routine_usage_sync ;run sync routine
ExitApp ;close script after usage sync

routine_usage_sync:
now_timestamp := A_Now ;get current timestamp
usage_id := sync_md5(A_UserName sync_xserialno()) ;create unique id using computer's username and serial no.
usage_config := swiftwire_settings ;get config ini file to save usage data
IniRead, app_email, %usage_config%, RegisteredEmail, myEmail ;read saved application email
IniRead, app_version, %usage_config%, Version, appVersion ;read saved application version
IniRead, usage_start, %usage_config%, Settings, usage_start	;read saved usage start timestamp (time app begun use)
IniRead, usage_count, %usage_config%, Settings, usage_count	;read saved usage count (count of instances app has been launched)
if (usage_start = "" || usage_start = "ERROR")	;set now as start timestamp if config value has not been set
	usage_start := now_timestamp
if (usage_count = "" || usage_count = "ERROR")	;reset usage count if config value has not been set
	usage_count := 0
usage_timestamp := now_timestamp	;set usage timestamp to current timestamp
usage_count += 1					;increment usage count
IniWrite, %usage_id%, %usage_config%, Settings, usage_id				;save unique usage id to config file
IniWrite, %usage_start%, %usage_config%, Settings, usage_start			;save usage start timestamp to config file
IniWrite, %usage_count%, %usage_config%, Settings, usage_count			;save incremented usage count to config file
IniWrite, %usage_timestamp%, %usage_config%, Settings, usage_timestamp	;save current usage timestamp to config file
usage_sync_url := "https://swiftwiredb.firebaseio.com/usage/" usage_id ".json"	;FIREBASE - remote usage store sync location url
usage_sync_json = {"email":"%app_email%","version":"%app_version%","id":"%usage_id%","start":"%usage_start%","count":"%usage_count%","timestamp":"%usage_timestamp%"}	;usage sync json

;UPLOADING SYNC - FIREBASE PUT REQUEST
;NOTE: We don't handle usage sync response/fail
try {
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("PUT", usage_sync_url, true) ;sync url
	whr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
	whr.Option(6) := false ;no redirects
	whr.Send(usage_sync_json) ;sync json data
	whr.WaitForResponse()
	;MsgBox, 0, Sync Response, % whr.ResponseText ;sync request response (if success should be same as sync json data) - TODO REMOVE
}
;MsgBox, 0, Sync Response, Usage sync complete ;sync complete - TODO REMOVE
return

;sync functions
;md5: Returns an MD5 hash for the input string
sync_md5(string, encoding := "UTF-8"){
	static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
	algid := 0x8003, hash := 0, hashlength := 0
	chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
    length := (StrPut(string, encoding) - 1) * chrlength
    VarSetCapacity(data, length, 0)
    StrPut(string, &data, floor(length / chrlength), encoding)
	addr := &data
	hProv := hHash := o := ""
    if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000)){
        if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash)){
            if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0)){
                if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0)){
                    VarSetCapacity(hash, hashlength, 0)
                    if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0)){
                        loop % hashlength
                        {
                            v := NumGet(hash, A_Index - 1, "UChar")
                            o .= h[(v >> 4) + b] h[(v & 0xf) + b]
                        }
                    }
                }
            }
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
        }
        DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    }
    return o
}

;xserialno: returns Win32_BaseBoard serial number for running computer - blank on error
;Win32_BaseBoard reference: https://msdn.microsoft.com/en-us/library/aa394072(v=vs.85).aspx
sync_xserialno(){
	try {
		for item in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_BaseBoard")
			return ltrim(rtrim(item.SerialNumber))
	}
}
