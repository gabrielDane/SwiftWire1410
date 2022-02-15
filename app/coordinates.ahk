/*
	The routine "show_coordinates" creates and displayes a gui
	to show current mouse position relative to active window.
	Mouse position is updated by listener "_coords_update"
	which is dismissed on gui close.
*/

show_coordinates:
SysGet, work_area_, MonitorWorkArea, 1
minclose_position := work_area_Right - 137
Gui, _coords_: Destroy
Gui, _coords_: -DPIScale
Gui, _coords_: +LastFound +AlwaysOnTop +ToolWindow
Gui, _coords_: Color, 272727
Gui, _coords_: Font, s9 Bold, Arial
Gui, _coords_: Add, Text, vMyText x24 y10 cWhite +BackgroundTrans, XXXXX YYYYY
Gui, _coords_: Show, x%minclose_position% y77 NoActivate w120 h35, fluent TECH
SetTimer, _coords_update, 50

;mouse position listener
_coords_update:
Gui, _coords_: Default				;default gui for this thread
CoordMode, Mouse, Relative			;set coordmode for mouse
MouseGetPos, MouseX, MouseY			;get mouse x, y coordinates
GuiControl,, MyText, X%MouseX%, Y%MouseY%	;set coordinates to default gui control "MyText"
return

;closing coordinates gui
_coords_GuiEscape:
_coords_GuiClose:
SetTimer, _coords_update, Off		;disable _coords_update listener
Gui, _coords_: Destroy				;destroy _coords_ gui
return