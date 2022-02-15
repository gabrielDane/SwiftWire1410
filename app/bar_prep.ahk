/* 
    SwiftWire - Desktop Automation Software
    Copyright 2018, Fluent Systems, Inc. 
 */

; preliminaries
SetTitleMatchMode, 2
DetectHiddenWindows, On ; use with caution
#SingleInstance, force


;Create dependent files if not exist
IfNotExist, %A_ScriptDir%\user\CustomCommands.dat
	FileAppend, , %A_ScriptDir%\user\CustomCommands.dat
IfNotExist, %A_ScriptDir%\user\Plugins.dat
	FileAppend, , %A_ScriptDir%\user\Plugins.dat


; close alternate AutoHotkey instance if running
#IfWinExist, SwiftWire.app
	WinClose, SwiftWire.app

; get working directory -- the folder that contains users
D = %A_ScriptDir%\user

; Update the commands.dat file
prepare_commands_dat()

; If no categories exist, make sure app doesn't crash
IfNotExist,%A_ScriptDir%\resources\commandfile\commands.dat
	FileAppend,,%A_ScriptDir%\resources\commandfile\commands.dat

; Launch toolbar & exit bar_prep
Run, Booster.exe SwiftWire.app
return
ExitApp



/*
	Function to prepare the commands.dat file everytime the command is saved
*/

;creates a string to a string of its ascii characters
asciistr(str){
	str_out := ""
	loop, parse, str
		str_out .= asc(a_loopfield)
	return str_out
}

prepare_commands_dat(){
	global D	
	;fetch the command categories
	cmd_categories := Object()
	loop, %D%\*.*, 2, 0
	{
		cmd_category := A_LoopFileFullPath
		SplitPath, cmd_category, cmd_category_name
		cmd_category_commands := Object()
		loop, %cmd_category%\*.od1, 0, 0
		{
			cmd_file := A_LoopFileFullPath
			SplitPath, cmd_file,,,,cmd_file_name
			FileRead, cmd_contents, % cmd_file
			cmd_object := Object()
			cmd_object.command_name := cmd_file_name
			cmd_object.command_contents := cmd_contents
			cmd_object.command_category := cmd_category_name
			cmd_subroutine := "_" asciistr(cmd_category_name "." cmd_file_name)			
			cmd_category_commands[cmd_subroutine] := cmd_object  ;this approach will help prevent duplicates
		}
		cmd_category_subroutine := "_" asciistr(cmd_category_name)
		cmd_categories[cmd_category_subroutine] := cmd_category_commands ;this approach will help prevent duplicates
	}
	
	;create the command.dat contents
	command_dat_contents := ""
	for category_subroutine, category_commands in cmd_categories
	{
		for command_subroutine, command_object in category_commands
		{
			;command data
			command_dat_contents .=	command_dat_contents = "" ? command_subroutine . ":" : "`r`n`r`n" . command_subroutine . ":"
			command_dat_contents .= "`r`nsend, !{esc}`r`nsleep, 200`r`n`r`n;##### COMMAND GOES HERE #####`r`n"
			command_contents := command_object.command_contents
			command_dat_contents .= command_contents . "`r`nreturn`r`n" ;. "`r`nreturn`r`n" added 112317 -gdc
		}
		
		;;DPI scaling dependent custom display element - 20180117-gdc
		if (A_ScreenDPI == 96) {
		  	;add category context menu sub routine
			command_dat_contents .= "`r`n" category_subroutine ":"
			. "`r`nMouseGetPos,mx,my,mw,mcontrol"
			. "`r`nControlGetPos, X, Y, Width, Height,`%mcontrol`%,A"
			. "`r`nY := Y + 20"
			. "`r`nMenu," category_subroutine ",show, `%X`%,`%Y`%"
			. "`r`nreturn"
		} else {
		  	;add category context menu sub routine
			command_dat_contents .= "`r`n" category_subroutine ":"
			. "`r`nMouseGetPos,mx,my,mw,mcontrol"
			. "`r`nControlGetPos, X, Y, Width, Height,`%mcontrol`%,A"
			. "`r`nY := Y + 22"
			. "`r`nMenu," category_subroutine ",show, `%X`%,`%Y`%"
			. "`r`nreturn"
		}
		
	}
	
	;create the command.dat file
	IfExist, %A_ScriptDir%\resources\commandfile\commands.dat
		FileDelete, %A_ScriptDir%\resources\commandfile\commands.dat
	FileAppend, %command_dat_contents%, %A_ScriptDir%\resources\commandfile\commands.dat
}

/* 
	JSON handling code
*/
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

