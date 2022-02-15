/*
	SWIFTWIRE - Desktop Automation Reimagined
    Copyright 2018, Fluent Systems, Inc. 
*/

;preliminaries
#SingleInstance, Force
#Persistent
#NoTrayIcon ; to remove the icon from the tray
#NoEnv
;DllCall( "GDI32.DLL\AddFontResourceEx", Str,"%A_ScriptDir%\resources\fonts\Tahoma.TTF",UInt,(FR_PRIVATE:=0x10), Int,0) ;add custom font (disabled, not working 20180115-gdc)
SetTitleMatchMode, 2

;code to get coordinates of GUI window 
;for secondary GUI popup X/Y - gdc 20171212
;WinGetPos, Xpos, Ypos,,, Edit SwiftWire Toolbar ;disabled 20180115-gdc
;popupX := Xpos - 5
;popupY := Ypos 
;InputBox coordinates
popupX := 259
popupY := 150

;Martin Fix: 20160822 - this variable stores if the treeview selection was usergenerated or system generated
IsTVUserGerenerated := true

;window variables and sets
window_name := "Edit SwiftWire Toolbar ..."
FileRead, APP_ExpireDate, %A_ScriptDir%\resources\scripts\expire.dat
;item := ""
;command := ""
FormatTime, APP_Now, %A_Now%, yyyyMMdd
Menu, Tray, Icon, %A_ScriptDir%\resources\images\sw_logo_new.ico ;CHANGES TRAY ICON
D := A_ScriptDir . "\user" ;folder containing user files


;Creating the imagelist for treeview icons
TVImageList := IL_Create(10)
Loop 10
    IL_Add(TVImageList, "shell32.dll", A_Index)
IL_Add(TVImageList, "shell32.dll", A_Index)

;Custom coordinates for Msgboxes in Command_builder (associated function in functions section)
OnMessage(0x44, "WM_COMMNOTIFY")

;tree view right click menu
Menu, _cmd_builder_treeview_rightclickmenu, Add, Rename, _cmd_builder_treeview_rename
Menu, _cmd_builder_treeview_rightclickmenu, Add, Delete, _cmd_builder_treeview_delete

;drawing the user interface for the command builder
if (A_ScreenDPI == 96) {
  Gui, _guiCMDBuilder: Destroy
  Gui, _guiCMDBuilder: -DPIScale -Caption
  Gui, _guiCMDBuilder: Color, FFFFFF
  Gui, _guiCMDBuilder: Add, Picture, x721 y0 ,%A_ScriptDir%\resources\images\4D394B-300-500-2.png
  Gui, _guiCMDBuilder: Add, Picture, x10 y353 gSupport,%A_ScriptDir%\resources\images\help-circle2.png
  Gui, _guiCMDBuilder: Add, Picture, x695 y9 g_guiCMDBuilderGuiClose,%A_ScriptDir%\resources\images\close-x3.png
  Gui, _guiCMDBuilder: Add, Picture, x0 y399 g_guiCMDBuilderGuiClose,%A_ScriptDir%\resources\images\bottom-line.png
    Gui, _guiCMDBuilder: Add, Picture, x0 y400 g_guiCMDBuilderGuiClose,%A_ScriptDir%\resources\images\bottom-line.png
  Gui, _guiCMDBuilder: Font, S9 Bold CDefault, Tahoma
  Gui, _guiCMDBuilder: Add, Button, x8 y10 w130 h30 v_cmd_builder_new_category g_cmd_builder_new_category, New Category
  Gui, _guiCMDBuilder: Add, Button, x145 y10 w130 h30 v_cmd_builder_new_command g_cmd_builder_new_command, New Command
  Gui, _guiCMDBuilder: Font, S12 Bold C000000, Tahoma
  Gui, _guiCMDBuilder: Add, Text, x425 y15 h20 , Automation Steps
  ;Tree View
  Gui, _guiCMDBuilder: Font, S8 Normal C333333, Verdana
  Gui, _guiCMDBuilder: Add, TreeView, x0 y55 w282 h285 v_cmd_builder_treeview g_cmd_builder_treeview +AltSubmit imageList%TVImageList%,
  ;Command Edit Area
  OnMessage(0x204, "WM_RBUTTONDOWN")	;custom R click functionality
  OnMessage(0x205, "WM_RBUTTONUP")	;custom R click functionality
  Gui, _guiCMDBuilder: Font, S11 C38978d Normal, Consolas
  Gui, _guiCMDBuilder: Add, Edit, x281 y55 w440 h285 v_cmd_builder_edit g_cmd_builder_edit hwnd_cmd_builder_edit_hwnd WantTab Disabled,
;340, 390 -> 500, 300 new
  Gui, _guiCMDBuilder: Font, S9 Bold CDefault, Tahoma
  Gui, _guiCMDBuilder: Add, Button, x607 y355 w100 h30 v_cmd_builder_save g_cmd_builder_save Disabled, Save
  Gui, _guiCMDBuilder: Add, Button, x500 y355 w100 h30 v_cmd_builder_cancel g_cmd_builder_cancel Disabled, Cancel
  ;Show the GUI
  Gui, _guiCMDBuilder: Show, x0 y25 w723 h400, %window_name% ;was w1024
  } else {
  Gui, _guiCMDBuilder: Destroy
  Gui, _guiCMDBuilder: -DPIScale -Caption
  Gui, _guiCMDBuilder: Color, FFFFFF
  Gui, _guiCMDBuilder: Add, Picture, x771 y0 ,%A_ScriptDir%\resources\images\4D394B-300-500-2.png
  Gui, _guiCMDBuilder: Add, Picture, x10 y403 gSupport,%A_ScriptDir%\resources\images\help-circle2.png
  Gui, _guiCMDBuilder: Add, Picture, x745 y9 g_guiCMDBuilderGuiClose,%A_ScriptDir%\resources\images\close-x3.png
  Gui, _guiCMDBuilder: Add, Picture, x0 y449 g_guiCMDBuilderGuiClose,%A_ScriptDir%\resources\images\bottom-line.png
  Gui, _guiCMDBuilder: Font, S9 Bold CDefault, Tahoma
  Gui, _guiCMDBuilder: Add, Button, x8 y10 w130 h30 v_cmd_builder_new_category g_cmd_builder_new_category, New Category
  Gui, _guiCMDBuilder: Add, Button, x145 y10 w130 h30 v_cmd_builder_new_command g_cmd_builder_new_command, New Command
  Gui, _guiCMDBuilder: Font, S12 Bold C000000, Tahoma
  Gui, _guiCMDBuilder: Add, Text, x425 y12 h20 , Automation Steps
  ;Tree View
  Gui, _guiCMDBuilder: Font, S8 Normal C333333, Verdana
  Gui, _guiCMDBuilder: Add, TreeView, x0 y55 w282 h335 v_cmd_builder_treeview g_cmd_builder_treeview +AltSubmit imageList%TVImageList%,
  ;Command Edit Area
  OnMessage(0x204, "WM_RBUTTONDOWN")	;custom R click functionality
  OnMessage(0x205, "WM_RBUTTONUP")	;custom R click functionality
  Gui, _guiCMDBuilder: Font, S10 C38978d Bold, Consolas
  Gui, _guiCMDBuilder: Add, Edit, x281 y55 w490 h335 v_cmd_builder_edit g_cmd_builder_edit hwnd_cmd_builder_edit_hwnd WantTab Disabled,
;340, 390 -> 500, 300 new
  Gui, _guiCMDBuilder: Font, S9 Bold CDefault, Tahoma
  Gui, _guiCMDBuilder: Add, Button, x657 y405 w100 h30 v_cmd_builder_save g_cmd_builder_save Disabled, Save
  Gui, _guiCMDBuilder: Add, Button, x550 y405 w100 h30 v_cmd_builder_cancel g_cmd_builder_cancel Disabled, Cancel
  ;Show the GUI
  Gui, _guiCMDBuilder: Show, x0 y25 w773 h450, %window_name% ;was w1024
}




;Shortcuts for easier command building
Menu, CMenu, Add, Type Text, _cmd_builder_quicktools_sendtext
Menu, CMenu, Add, Click Mouse, _cmd_builder_quicktools_click640_480
Menu, CMenu, Add, Press Keys, _cmd_builder_quicktools_sendenter
Menu, CMenu, Add, Wait Time, _cmd_builder_quicktools_sendsleep1000



gosub, _cmd_builder_update_listview
return

Support:
Run, http://fluent.systems/support-go.html
Return

Handler:
Return

;updating treeview data
_cmd_builder_update_listview:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
TV_Delete()
_cmd_builder_add_treeview_folders(D, _param_treeview_root_node := 0)
Loop
{
	ItemID := TV_GetNext(ItemID, "Full")
	if Not ItemID
		break
	TV_GetText(ItemText, ItemID)
	GuiControl, -Redraw, _cmd_builder_treeview
	TempID := ItemID
	loop, Files, %D%\%ItemText%\*.*, FR
	{
		SplitPath,A_LoopFileFullPath,,,,fname
		TempID := TV_Add(fname,ItemID,Sort)
	}
	ItemID := TempID
	GuiControl, +Redraw, _cmd_builder_treeview
}
return

;closing the main application
_guiCMDBuilderGuiClose:
ExitApp
;Gui, _guiCMDBuilder: Show, Hide
return

_guiCMDBuilderGuiEscape:
ExitApp

;treeview events handling
_cmd_builder_treeview:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: +OwnDialogs
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
if A_GuiEvent = RightClick
{
	GuiControlGet, _cmd_builder_save, Enabled
	if !_cmd_builder_save  ;GABE - blocking right click while in current editing session
	{
		TV_Modify(A_EventInfo, "Select")
		Menu, _cmd_builder_treeview_rightclickmenu, Show
	} 
	else {
		MsgBox, 48, Navigation Error, You must Save or Cancel the Command You are Currently Editing Before you can Delete or Rename Commands.
		return	
	}
}
if A_GuiEvent = S
{
	Gui, _guiCMDBuilder: submit, nohide
	if (IsTVUserGerenerated AND save_edited_command(item, itemID, _cmd_builder_edit)) ;GABE - also checking for save when we nav from active command input
	{
		;Martin Fix: 20160822 - Introduced a new variable that checks when we automatically restore selection "IsTVUserGerenerated" by default, the variable is set to true
		;Martin Fix: 20160822 - Changed command to _cmd_builder_edit, this is the variable name for the command edit area containing the current values
		;Martin Fix: 20160822 - We return the selection to the previous file to prevent new selection
		parentID := TV_GetParent(itemID)
		IsTVUserGerenerated := false ;prevent save_edited_command check when we restore previous selection
		TV_Modify(parentID, "Expand")
		TV_Modify(itemID, "Select")
		return
	}
	TV_Modify(a_eventinfo, "Select")
	itemID := TV_GetSelection()
	parentID := TV_GetParent(itemID)
	TV_GetText(item, itemID)
	TV_GetText(itemParent, parentID)
	if parentID != 0
		item := D "\" itemParent "\" item ".od1"
	else
		item := D . "\" . item . ".od1"
	if (parentID != 0){
		if IsTVUserGerenerated ;Martin Fix: 20160822 prevent alteration of current edit content when selection is restored
		{
			FileRead, _cmd_readfile_commands, %item%
			GuiControl,, _cmd_builder_edit, %_cmd_readfile_commands%
		}
		GuiControl, Enable, _cmd_builder_edit
	}
	else {
		GuiControl,, _cmd_builder_edit,
		GuiControl, Disable, _cmd_builder_edit
		GuiControl, Disable, _cmd_builder_save
		GuiControl, Disable, _cmd_builder_cancel
	}
	IsTVUserGerenerated := true
}
return

;treeview right click menu event
_cmd_builder_treeview_rename:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: +OwnDialogs
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
path := get_selected_item(itemid, type)

InputBox,newname,Rename %type%,Type the new name,,238,125, %popupX%, %popupY%
if errorlevel
	return
if (!is_valid_filename(newname)) {
	MsgBox,0,Rename Failed,Sorry you have typed an invalid %type% name
	return
}
SplitPath,path,,location,extension
if (type = "file") {
	newpath := location . "\" . newname . "." . extension
} else {
	newpath := location . "\" . newname
}
if FileExist(newpath) {
	MsgBox,0,Rename Failed,Sorry a %type% exists with the same name.
	return
}
MsgBox,4,Rename file,Are you sure you want to rename this %type%?
IfMsgBox,No
	return
TV_Modify(itemid,,newname)
if (type = "file") {
	FileMove,%path%,%newpath%,1
} else {
	FileMoveDir,%path%,%newpath%,R
}
if (errorlevel > 0) {
	MsgBox,0,Rename Failed,There was an error renaming the %type%.
	return
}
Run, Booster.exe bar_prep.ahk
return

;treeview right click menu event
_cmd_builder_treeview_delete:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: +OwnDialogs
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
itemID := TV_GetSelection()
parentID := TV_GetParent(itemID)
TV_GetText(item,itemID)
TV_GetText(itemParent,parentID)
if parentID != 0
{
	item = %D%\%itemParent%\%item%
	MsgBox, 52, Delete file, Are you sure you want to delete this file?
	IfMsgBox, No
		return
	FileRecycle,%item%.od1
	TV_Delete(itemID)
	TV_Modify(parentID,"Select")
	GuiControl,,_cmd_builder_edit,
	GuiControl, Disable, _cmd_builder_edit
	Gui, -OwnDialogs
	Run, Booster.exe bar_prep.ahk
}
else {
	item := D . "\" . item
	MsgBox, 52, Delete folder, Are you sure you want to delete this folder and all its files?
	IfMsgBox, No
		return
	FileRecycle,%item%
	TV_Delete(itemID)
	GuiControl,,_cmd_builder_edit,
	Run, Booster.exe bar_prep.ahk
}
return

;when you click the black command builder ribbon
_cmd_builder_black_ribbon:
Run, Booster.exe Command_Builder.ahk
return

;new category button on click
_cmd_builder_new_category:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: +OwnDialogs
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
GuiControlGet, _cmd_builder_save, Enabled
if _cmd_builder_save  ;GABE - blocking new catagory while in current editing session
{
	MsgBox, 48, Navigation Error, You must Save or Cancel the Command You are Currently Editing Before you can Create a New Category.
	return
}

InputBox,category,New Category,Name the new Category,,238, 125, %popupX%,%popupY%
;InputBox,category,New category,Type the new category name,,200,125
;InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Font, Timeout
if errorlevel
	return
if (!is_valid_filename(category)) {
	MsgBox,0,New category,Sorry you have typed an invalid category name
	return
}
cat := D . "\" . category
IfExist,%cat%
{
	MsgBox,0,New category,Sorry the category already exists.
	return
}
FileCreateDir,%cat%
TV_Add(category,0,"Icon4")
TV_Modify(0,"Sort")
Run, Booster.exe bar_prep.ahk
return

;new command button on click
_cmd_builder_new_command:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: +OwnDialogs
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
GuiControlGet, _cmd_builder_save, Enabled
if _cmd_builder_save  ;GABE - blocking New Command while in current editing session
{
	MsgBox, 48, Navigation Error, You must Save or Cancel the Command you are currently editing before you can create a New Command.
	return
}
Gui, +OwnDialogs
;Martin's Edit 20160825 - moved the commands that were here down

InputBox, command, New Command,Name the new Command,,238,125, %popupX%, %popupY%

if errorlevel
	return
if (!is_valid_filename(command)){
	MsgBox,0,New command,Sorry you have typed an invalid command name
	return
}
;Martin's Edit 20160825 - this fix autoselects the first category when creating a command with no category selected
itemID := TV_GetSelection()
if itemID = 0
	itemID := TV_GetNext()
parentID := TV_GetParent(itemID)
TV_GetText(item,itemID)
TV_GetText(itemParent,parentID)
;--- end of fix --
if parentID = 0
	com := D . "\" . item . "\" . command . ".od1"
else
	com := D . "\" . itemParent . "\" . command . ".od1"
IfExist, %com%
{
	MsgBox,0,New command,Sorry a file with the same command name exists!
	return
}
FileAppend,,%com%
if parentID=0
{
	newCommand := TV_Add(command,itemID) ;Martin's Edit 20160825
	TV_Modify(itemID,"Expand")
	TV_Modify(itemID,"Sort")
	TV_Modify(newCommand,"Select") ;Martin's Edit 20160825
}
else
{
	newCommand := TV_Add(command,parentID) ;Martin's Edit 20160825
	TV_Modify(parentID,"Expand")
	TV_Modify(parentID,"Sort")
	TV_Modify(newCommand,"Select") ;Martin's Edit 20160825
}
return

;Edit area callbacks
_cmd_builder_edit:
GuiControlGet, _cmd_builder_save, Enabled
if !_cmd_builder_save
{ ;GABE - now we have changes to save so enable the buttons
	GuiControl, Enable,_cmd_builder_save 
	GuiControl, Enable,_cmd_builder_cancel
} 
return

;save button on click
_cmd_builder_save:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: +OwnDialogs
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
Gui, _guiCMDBuilder: submit, nohide
if !_validate(_cmd_builder_edit)
{
	MsgBox, 8240, Command Builder, The command could not be saved.  Please make sure each line starts with either: Send`, Sleep`, or Click`, and try saving again.
	return
}
itemID := TV_GetSelection()
parentID := TV_GetParent(itemID)
TV_GetText(item, itemID)
TV_GetText(itemParent, parentID)
if parentID != 0
{
	item = %D%\%itemParent%\%item%.od1
	FileDelete,%item%
	FileAppend,%_cmd_builder_edit%,%item%
	GuiControl, Disable, _cmd_builder_save ;GABE - grey the save/cancel if we just saved
	GuiControl, Disable, _cmd_builder_cancel
	Run, Booster.exe bar_prep.ahk
	MsgBox,0,SwiftWire,Command Updated Successfully
}
else {
	MsgBox,0,SwiftWire,There was a problem saving the command. Please select it from the tree on the left and try again.
}
return

;cancel button on click
_cmd_builder_cancel:
Gui, _guiCMDBuilder: Default
Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
itemID := TV_GetSelection()
parentID := TV_GetParent(itemID)
TV_Modify(parentID, "Select")
GuiControl, Disable, _cmd_builder_save ;GABE - grey the save/cancel if we just saved
GuiControl, Disable, _cmd_builder_cancel
return

;Quick tools actions
_cmd_builder_quicktools_sendtext:
edit_send_text("Send`, Text^{Left}+{Right 4}")
return

_cmd_builder_quicktools_sendenter:
edit_send_text("Send`, {{}Enter{}}^{Left}{Right}+{Right 5}")
return

_cmd_builder_quicktools_sendsleep1000:
edit_send_text("Sleep`, 1000^{Left}+{Right 4}")
return

_cmd_builder_quicktools_click640_480:
edit_send_text("Click`, 640`, 480^{Left 2}+{Right 8}")
return

_cmd_builder_quicktools_ctrlkey:
edit_send_text("Send`, {^}")
return

_cmd_builder_quicktools_shiftkey:
edit_send_text("Send`, {+}")
return

_cmd_builder_quicktools_altkey:
edit_send_text("Send`, {!}")
return

_cmd_builder_quicktools_sleep0_5_sec:
edit_send_text("Sleep`, 500")
return

_cmd_builder_quicktools_sleep1_0_sec:
edit_send_text("Sleep`, 1000")
return

_cmd_builder_quicktools_sleep2_0_sec:
edit_send_text("Sleep`, 2000")
return

_cmd_builder_quicktools_progressnotes:
edit_send_text("Send`, {^}{+}n {;} (Press CTRL{+}SHIFT{+}n)")
return

_cmd_builder_quicktools_orderentry:
edit_send_text("Send`, {^}o {;} (Press CTRL{+}o)")
return

_cmd_builder_quicktools_LOS:
edit_send_text("Send`, {!}v {;} (Press ALT{+}v)")
return

_cmd_builder_quicktools_Diagnosis:
edit_send_text("Send`, {^}g {;} (Press CTRL{+}g)")
return





;############################################################################
;COMMAND BUILDER SPECIFIC FUNCTIONS

;Msgbox custom X/Y location on screen
;use "OnMessage(0x44, "WM_COMMNOTIFY")" before "Msgbox" to execute
WM_COMMNOTIFY(wParam) {
    if (wParam = 1027) { ; AHK_DIALOG
        Process, Exist
        DetectHiddenWindows, On
        if WinExist("ahk_class #32770 ahk_pid " . ErrorLevel) {
            WinGetPos,,, w
            WinMove, 259, 136
        }
    }
}

;urlencode function
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

;function to validate commands before save - modified
_validate(com){ 
	;we get the commands typed by the user
	;we remove the tabs and spaces before we check if each line starts with send, sleep, or click
	;StringReplace,com,com,%a_space%,,all
	global
	Gui, _guiCMDBuilder: Default
	Gui, _guiCMDBuilder: +OwnDialogs
	StringReplace,com,com,%a_tab%,,all
	StringReplace,com,com,`,,%A_Space%,all
	comment_block := 0
	loop,parse,com,`n ;we go through the lines testing if they are send, , sleep, or click,
	{
		string = %A_LoopField%
		if string !=
		{
			stringArr := StrSplit(string,a_space,",")
			first_word := stringArr[1]
			first_word = %first_word%
			StringMid,test_comment,string,1,1
			if (comment_block == 0) AND (string == "/*")
				comment_block = 1
			if (string == "*/")
				comment_block --
			
			if (comment_block = 0) AND (string != "*/")
			{
				if test_comment != `;
				{
					if first_word not in sleep,click,send,run,winactivate,var,mousemove,coordmode,msgbox
					{
						MsgBox,1,Error!,Error at line %a_index% - %first_word%
						return false
					}
				}
			}
			if comment_block < 0
			{
				MsgBox,1,Error!,Error at line %a_index%
				return false
			}
		}
	}
	if comment_block = 1
	{
		MsgBox,1,Error!,Unexpected end of comment block
		return false
	}
	return true
}

_cmd_builder_add_treeview_folders(_param_root_folder, _param_treeview_root_node := "0")
{
	global
	Gui, _guiCMDBuilder: Default
	Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
	GuiControl, -Redraw, _cmd_builder_treeview
	Loop, Files, %_param_root_folder%\*.*, D ;ignore specific files/folders AND hidden/readonly/system files
		if (cat != "_gsdata_") ; ignore _gsdata_ folder from Sync
			if A_LoopFileAttrib not contains H,R,S ; Skip any file that is either H (Hidden), R (Read-only), or S (System). Note: No spaces in "H,R,S".
				_cmd_builder_add_treeview_folders(A_LoopFileFullPath, TV_Add(A_LoopFileName, _param_treeview_root_node, "Icon4" Sort))
	GuiControl, +Redraw, _cmd_builder_treeview
}

save_edited_command(saveItem, saveItemID, saveCommand){
	;GABE - This is the function call to prompt and do the save if modified
	global
	Gui, _guiCMDBuilder: Default
	Gui, _guiCMDBuilder: +OwnDialogs
	Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
	GuiControlGet, _cmd_builder_save, Enabled
	if _cmd_builder_save
	{
		TV_GetText(itemName, saveItemID)
		MsgBox, 51, Save Command?, You have not saved changes to %itemName%!`n`nWould you like to save these changes?
		IfMsgBox, YES
		{
			;Martin Fix: 20160823 - We just add this validate check to prevent saving incorrect code
			if !_validate(saveCommand)
			{
				MsgBox, 8240, Command Builder, The command could not be saved.  Please make sure each line starts with either: Send`, Sleep`, or Click`, and try saving again.
				return true ;return true so we dont move from the command being edited
			}
			FileDelete, %saveItem%
			FileAppend, %saveCommand%, %saveItem%
			Run, Booster.exe bar_prep.ahk
			MsgBox,0,SwiftWire,Command Updated Successfully
			GuiControl, Disable, _cmd_builder_save
			GuiControl, Disable, _cmd_builder_cancel
		}
		else
		IfMsgBox, Cancel
			return true
		else
		{
			GuiControl, Disable, _cmd_builder_save
			GuiControl, Disable, _cmd_builder_cancel
		}
	}
	Gui, -OwnDialogs
	return false
}

get_selected_item(byref itemid, byref type){
	global
	Gui, _guiCMDBuilder: Default
	Gui, _guiCMDBuilder: TreeView, _cmd_builder_treeview
	itemid := TV_GetSelection()
	TV_GetText(item,itemid)
	parentid := TV_GetParent(itemid)
	if (parentid != 0){
		TV_GetText(parent, parentid)
		type := "file"
		return D . "\" . parent . "\" . item . ".od1"
	} else {
		type := "folder"
		return D . "\" . item
	}
}

is_valid_filename(filename){
	if (filename = "")
		return false
	if filename contains `\,`/,`:,`*,`?,`",`<,`>,`|,`%
		return false
	return true
}

;custom R click menu for Edit Commands 
WM_RBUTTONDOWN(){
    if (A_GuiControl = "_cmd_builder_edit")
       Return 0
}
WM_RBUTTONUP(){
    if (A_GuiControl = "_cmd_builder_edit")
        Menu, cMenu, Show
}

edit_send_text(keys){
	global
	Gui, _guiCMDBuilder: Default
	Gui, _guiCMDBuilder: +OwnDialogs
	Gui, _guiCMDBuilder: Submit, Nohide
	_cmd_builder_edit_contents := _cmd_builder_edit
	GuiControlGet, _cmd_builder_edit, Enabled ;check to prevent editing a disabled control
	if !_cmd_builder_edit
	{
		MsgBox,64,Swiftwire,You are not editing any command at the moment. Use this quick tool when you are editing commands
		return
	}
	_cmd_builder_edit_contents = %_cmd_builder_edit_contents% ;trim
	if (_cmd_builder_edit_contents != "") ;prevent whitespace starting lines
		keys := "{end}{enter}" keys
	else
		keys := "{end}" keys
	ControlSend,,%keys%, ahk_id %_cmd_builder_edit_hwnd%
	ControlFocus,,ahk_id %_cmd_builder_edit_hwnd%
}

;JSON Class
class JSON
{
	/* Method: Load
	 *     Deserialize a string containing a JSON document to an AHK object.
	 * Syntax:
	 *     json_obj := JSON.Load( ByRef src [ , jsonize := false ] )
	 * Parameter(s):
	 *     src  [in, ByRef] - String containing a JSON document
	 *     jsonize     [in] - If true, objects {} and arrays [] are wrapped as
	 *                        JSON.Object and JSON.Array instances respectively.
	 */
	Load(ByRef src, jsonize:=false)
	{
		static q := Chr(34)

		args := jsonize ? [ JSON.Object, JSON.Array ] : []
		key := "", is_key := false
		stack := [ tree := [] ]
		is_arr := { (tree): 1 }
		next := q . "{[01234567890-tfn"
		pos := 0
		while ( (ch := SubStr(src, ++pos, 1)) != "" )
		{
			if InStr(" `t`n`r", ch)
				continue
			if !InStr(next, ch)
			{
				ln  := ObjLength(StrSplit(SubStr(src, 1, pos), "`n"))
				col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

				msg := Format("{}: line {} col {} (char {})"
				,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
				  : (next == "'")     ? "Unterminated string starting at"
				  : (next == "\")     ? "Invalid \escape"
				  : (next == ":")     ? "Expecting ':' delimiter"
				  : (next == q)       ? "Expecting object key enclosed in double quotes"
				  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
				  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
				  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
				  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
				    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
				, ln, col, pos)

				throw Exception(msg, -1, ch)
			}
			
			is_array := is_arr[obj := stack[1]]
			
			if i := InStr("{[", ch)
			{
				val := (proto := args[i]) ? new proto : {}
				is_array? ObjPush(obj, val) : obj[key] := val
				ObjInsertAt(stack, 1, val)
				
				is_arr[val] := !(is_key := ch == "{")
				next := q . (is_key ? "}" : "{[]0123456789-tfn")
			}

			else if InStr("}]", ch)
			{
				ObjRemoveAt(stack, 1)
				next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
			}

			else if InStr(",:", ch)
			{
				is_key := (!is_array && ch == ",")
				next := is_key ? q : q . "{[0123456789-tfn"
			}

			else
			{
				if (ch == q)
				{
					i := pos
					while i := InStr(src, q,, i+1)
					{
						val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
						static end := A_AhkVersion<"2" ? 0 : -1
						if (SubStr(val, end) != "\")
							break
					}
					if !i ? (pos--, next := "'") : 0
						continue
					
					pos := i ; update pos

					  val := StrReplace(val,    "\/",  "/")
					, val := StrReplace(val, "\" . q,    q)
					, val := StrReplace(val,    "\b", "`b")
					, val := StrReplace(val,    "\f", "`f")
					, val := StrReplace(val,    "\n", "`n")
					, val := StrReplace(val,    "\r", "`r")
					, val := StrReplace(val,    "\t", "`t")

					i := 0
					while (i := InStr(val, "\",, i+1))
					{
						if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
							continue 2

						; \uXXXX - JSON unicode escape sequence
						xxxx := Abs("0x" . SubStr(val, i+2, 4))
						if (A_IsUnicode || xxxx < 0x100)
							val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
					}

					if is_key
					{
						key := val, next := ":"
						continue
					}
				}
				
				else
				{
					val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
					
					static null := "" ; for #Warn
					if InStr(",true,false,null,", "," . val . ",", true) ; if var in
						val := %val%
					else if (Abs(val) == "") ? (pos--, next := "#") : 0
						continue
					
					val := val + 0, pos += i-1
				}
				
				is_array? ObjPush(obj, val) : obj[key] := val
				next := obj==tree ? "" : is_array ? ",]" : ",}"
			}
		}
		
		return tree[1]
	}
	/* Method: Dump
	 *     Serialize an object to a JSON formatted string.
	 * Syntax:
	 *     json_str := JSON.Dump( obj [ , indent := "" ] )
	 * Parameter(s):
	 *     obj      [in] - The object to stringify.
	 *     indent   [in] - Specify string(s) to use as indentation per level.
 	 */
	Dump(obj:="", indent:="", lvl:=1)
	{
		static q := Chr(34)

		if IsObject(obj)
		{
			static Type := Func("Type")
			if Type ? (Type.Call(obj) != "Object") : (ObjGetCapacity(obj) == "") ; COM,Func,RegExMatch,File,Property object
				throw Exception("Object type not supported.", -1, Format("<Object at 0x{:p}>", &obj))
			
			is_array := 0
			for k in obj
				is_array := (k == A_Index)
			until !is_array

			static integer := "integer"
			if indent is %integer%
			{
				if (indent < 0)
					throw Exception("Indent parameter must be a postive integer.", -1, indent)
				spaces := indent, indent := ""
				Loop % spaces
					indent .= " "
			}
			indt := ""
			Loop, % indent ? lvl : 0
				indt .= indent

			lvl += 1, out := "" ; make #Warn happy
			for k, v in obj
			{
				if IsObject(k) || (k == "")
					throw Exception("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", &obj) : "<blank>")
				
				if !is_array
					out .= ( ObjGetCapacity([k], 1) ? JSON.Dump(k) : q . k . q ) ; key
					    .  ( indent ? ": " : ":" ) ; token + padding
				out .= JSON.Dump(v, indent, lvl) ; value
				    .  ( indent ? ",`n" . indt : "," ) ; token + indent
			}
			
			if (out != "")
			{
				out := Trim(out, ",`n" indent)
				if (indent != "")
					out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
			}
			
			return is_array ? "[" . out . "]" : "{" . out . "}"
		}
		
		; Number
		if (ObjGetCapacity([obj], 1) == "") ; returns an integer if 'obj' is string
			return obj
		
		; String (null -> not supported by AHK)
		if (obj != "")
		{
			  obj := StrReplace(obj,  "\",    "\\")
			, obj := StrReplace(obj,  "/",    "\/")
			, obj := StrReplace(obj,    q, "\" . q)
			, obj := StrReplace(obj, "`b",    "\b")
			, obj := StrReplace(obj, "`f",    "\f")
			, obj := StrReplace(obj, "`n",    "\n")
			, obj := StrReplace(obj, "`r",    "\r")
			, obj := StrReplace(obj, "`t",    "\t")

			static needle := (A_AhkVersion<"2" ? "O)" : "") . "[^\x20-\x7e]"
			while RegExMatch(obj, needle, m)
				obj := StrReplace(obj, m[0], Format("\u{:04X}", Ord(m[0])))
		}
		
		return q . obj . q
	}
	
	class Object
	{
		
		__New(args*)
		{
			if ((len := ObjLength(args)) & 1)
				throw Exception("Too few parameters passed to function.", -1, len)

			ObjRawSet(this, "_", []) ; bypass __Set
			Loop % len//2
				this[args[A_Index*2-1]] := args[A_Index*2] ; invoke __Set
		}

		__Set(key, args*)
		{
			ObjPush(this._, key) ; add key to key list and allow __Set to continue normally
		}

		Delete(FirstKey, LastKey*)
		{
			IsRange := ObjLength(LastKey)
			i := 0
			for index, key in ObjClone(this._)
				if IsRange ? (key >= FirstKey && key <= LastKey[1]) : (key = FirstKey)
				{
					ObjRemoveAt(this._, index - (i++))
					if !IsRange ; single key only
						break
				}
			
			return ObjDelete(this, FirstKey, LastKey*)
		}

		Dump(indent:="")
		{
			return JSON.Dump(this, indent)
		}
		static Stringify := JSON.Object.Dump

		_NewEnum()
		{
			static enum := { "Next": JSON.Object._EnumNext }
			return { base: enum, enum: ObjNewEnum(this._), obj: this }
		}

		_EnumNext(ByRef key, ByRef val:="")
		{
			if r := this.enum.Next(, key)
				val := this.obj[key]
			return r
		}
		; Do not implement array methods??
		static InsertAt := "", RemoveAt := "", Push := "", Pop := ""
	}
		
	class Array
	{
			
		__New(args*)
		{
			args.base := this.base
			return args
		}

		Dump(indent:="")
		{
			return JSON.Dump(this, indent)
		}
		static Stringify := JSON.Array.Dump
	}
	; Deprecated but maintained for existing scripts using the lib
	static Parse := JSON.Load ; cast to .Load
	static Stringify := JSON.Dump ; cast to .Dump
}