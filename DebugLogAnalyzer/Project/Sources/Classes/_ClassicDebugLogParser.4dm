property file : 4D:C1709.File
property fileHandle : 4D:C1709.FileHandle
property line1 : Text
property isValid : Boolean
property version : Integer
property EOL : Text

Class constructor($file : 4D:C1709.File)
	
	This:C1470.file:=$file
	This:C1470.fileHandle:=$file.open("read")
	This:C1470.line1:=This:C1470.fileHandle.readLine()
	
Function parse()
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	$line:=This:C1470.line1
	
	Case of 
		: (Match regex:C1019("-- Startup on: (\\S+), (\\S+) (\\d+), (\\d+) (\\d+):(\\d+):(\\d+) (A|PM) --"; $line; 1; $pos; $len))
			
			$dayofweek:=Substring:C12($line; $pos{1}; $len{1})
			$month:=Substring:C12($line; $pos{2}; $len{2})
			$m:=["January"; "February"; "March"; "April"; "May"; "June"; "July"; "August"; "September"; "October"; "November"; "December"].indexOf($month)+1
			$dd:=Num:C11(Substring:C12($line; $pos{3}; $len{3}))
			$year:=Num:C11(Substring:C12($line; $pos{4}; $len{4}))
			$hh:=Num:C11(Substring:C12($line; $pos{5}; $len{5}))
			$mm:=Num:C11(Substring:C12($line; $pos{6}; $len{6}))
			$ss:=Num:C11(Substring:C12($line; $pos{7}; $len{7}))
			$ampm:=Substring:C12($line; $pos{8}; $len{8})
			If ($ampm="PM") && ($hh<12)
				$hh+=12
			End if 
			$time:=Time:C179([$hh; $mm; $ss].join(":"))
			$date:=Add to date:C393(!00-00-00!; $year; $m; $dd)
			
			This:C1470.version:=2
			This:C1470.isValid:=True:C214
			
/*
-- Startup on: Tuesday, April 01, 2025 06:27:12 PM --
*/
			
			This:C1470._getEOL()
			
		: (Match regex:C1019("-- Startup on (\\S+), (\\S+) (\\d+), (\\d+) (\\d+):(\\d+):(\\d+) (A|PM) \\((\\d+)\\) --"; $line; 1; $pos; $len))
			
			$dayofweek:=Substring:C12($line; $pos{1}; $len{1})
			$month:=Substring:C12($line; $pos{2}; $len{2})
			$m:=["January"; "February"; "March"; "April"; "May"; "June"; "July"; "August"; "September"; "October"; "November"; "December"].indexOf($month)+1
			$dd:=Num:C11(Substring:C12($line; $pos{3}; $len{3}))
			$year:=Num:C11(Substring:C12($line; $pos{4}; $len{4}))
			$hh:=Num:C11(Substring:C12($line; $pos{5}; $len{5}))
			$mm:=Num:C11(Substring:C12($line; $pos{6}; $len{6}))
			$ss:=Num:C11(Substring:C12($line; $pos{7}; $len{7}))
			$ampm:=Substring:C12($line; $pos{8}; $len{8})
			If ($ampm="PM") && ($hh<12)
				$hh+=12
			End if 
			$time:=Time:C179([$hh; $mm; $ss].join(":"))
			$date:=Add to date:C393(!00-00-00!; $year; $m; $dd)
			$ms:=Num:C11(Substring:C12($line; $pos{9}; $len{9}))
			
			This:C1470.version:=1
			This:C1470.isValid:=True:C214
			
/*
-- Startup on Tuesday, October 06, 2009 07:07:24 PM (50712416) --
*/
			
			This:C1470._getEOL()
			
	End case 
	
	If (This:C1470.isValid)
		$line:=This:C1470.fileHandle.readLine()
	End if 
	
Function _getEOL() : cs:C1710._ClassicDebugLogParser
	
	$offset:=This:C1470.fileHandle.offset
	
	This:C1470.fileHandle.offset-=1  //because blob offset is 0 based
	var $bytes : 4D:C1709.Blob
	$bytes:=This:C1470.fileHandle.readBlob(2)
	
	Case of 
		: ($bytes[0]=Carriage return:K15:38) && ($bytes[1]=Line feed:K15:40)
			This:C1470.EOL:="crlf"
			$offset+=2
		: ($bytes[0]=Line feed:K15:40)
			This:C1470.EOL:="lf"
			$offset+=1
		Else 
			This:C1470.EOL:="cr"
			$offset+=1
	End case 
	
	This:C1470.fileHandle:=Null:C1517
	
	$option:={mode: "read"; breakModeRead: This:C1470.EOL}
	
	Case of 
		: (This:C1470.version=2)
			$option.charset:="utf-8"
		: (This:C1470.version=1)
			If (Get database localization:C1009(Internal 4D localization:K5:24)="ja")
				$option.charset:="windows-31j"
			Else 
				$option.charset:="macroman"
			End if 
	End case 
	
	This:C1470.fileHandle:=This:C1470.file.open($option)
	This:C1470.fileHandle.offset:=$offset
	
	return This:C1470