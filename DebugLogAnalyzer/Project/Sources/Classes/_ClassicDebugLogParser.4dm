property file : 4D:C1709.File
property fileHandle : 4D:C1709.FileHandle
property line1 : Text
property isValid : Boolean
property breakModeRead : Text
property Log_Date : Date
property Log_Time : Time
property Log_MS : Integer
property Log_Version : Integer
property charset : Text
property option : Object
property Id : Integer

Class constructor($file : 4D:C1709.File; $option : Object)
	
	This:C1470.file:=$file
	If ($option=Null:C1517)
		This:C1470.fileHandle:=$file.open("read")
	Else 
		This:C1470.fileHandle:=$file.open($option)
	End if 
	
	This:C1470.line1:=This:C1470.fileHandle.readLine()
	
Function start() : Object
	
	This:C1470.isValid:=False:C215
	
	If (This:C1470.fileHandle.eof)
		return 
	End if 
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	$line:=This:C1470.line1
	
	Case of 
		: (Length:C16($line)=0)
			//not first file
		: (Match regex:C1019("-- Startup on: (\\S+), (\\S+) (\\d+), (\\d+) (\\d+):(\\d+):(\\d+) (AM|PM) --"; $line; 1; $pos; $len))
			
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
			
			This:C1470.Log_Date:=$date
			This:C1470.Log_Time:=$time
			This:C1470.Log_MS:=0
			This:C1470.Log_Version:=2
			This:C1470.isValid:=True:C214
			This:C1470._getEOL()
			
		: (Match regex:C1019("-- Startup on (\\S+), (\\S+) (\\d+), (\\d+) (\\d+):(\\d+):(\\d+) (AM|PM) \\((\\d+)\\) --"; $line; 1; $pos; $len))
			
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
			
			This:C1470.Log_Date:=$date
			This:C1470.Log_Time:=$time
			This:C1470.Log_MS:=$ms
			This:C1470.Log_Version:=1
			This:C1470.isValid:=True:C214
			This:C1470._getEOL()
			
	End case 
	
	If (This:C1470.isValid)
		var $Debug_Logs : cs:C1710.Debug_LogsEntity
		$Debug_Logs:=ds:C1482.Debug_Logs.new()
		$Debug_Logs.Log_Date:=This:C1470.Log_Date
		$Debug_Logs.Log_Time:=This:C1470.Log_Time
		$Debug_Logs.Log_MS:=This:C1470.Log_MS
		$Debug_Logs.Log_Version:=This:C1470.Log_Version
		$Debug_Logs.save()
		This:C1470.Id:=$Debug_Logs.Id
	End if 
	
	return This:C1470.option
	
Function continue()
	
	If (This:C1470.isValid)
		Case of 
			: (This:C1470.Log_Version=2)
				This:C1470._v2()
			: (This:C1470.Log_Version=1)
				This:C1470._v1()
		End case 
	End if 
	
Function _v($flag : Integer)
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	var $MS_Stamp_cmd; $MS_Stamp_form; $MS_Stamp_meth : Collection
	
	If ($flag=1)
		$MS_Stamp_cmd:=[]
		$MS_Stamp_form:=[]
		$MS_Stamp_meth:=[]
	End if 
	
	var $o : Object
	
	Repeat 
		
		$line:=This:C1470.fileHandle.readLine()
		
		If (This:C1470.fileHandle.eof)
			break
		End if 
		
		var $MS_Stamp : Integer
		
		$values:=Split string:C1554($line; "\t")
		
		If ($values.length>0)
			Case of 
				: ($flag=2)
					$MS_Stamp:=Num:C11($values[0])  //actually the sequential operation number
				: ($flag=1)
					$line:=$values[0]
					If (Match regex:C1019("(\\d+) p=(\\d+) puid=(\\d+)(.*)"; $line; 1; $pos; $len))
						$MS_Stamp:=Num:C11(Substring:C12($line; $pos{1}; $len{1}))
						$PID:=Num:C11(Substring:C12($line; $pos{2}; $len{2}))
						$UPID:=Num:C11(Substring:C12($line; $pos{3}; $len{3}))
						$line:=Substring:C12($line; $pos{4}; $len{4})
						Case of 
							: (Match regex:C1019("\\s+([^:]+): (.+)"; $line; 1; $pos; $len))  //2 spaces in case of start token
								$Stack_Level:=0
								$token:=Substring:C12($line; $pos{1}; $len{1})
								$info:=Substring:C12($line; $pos{2}; $len{2})
							: (Match regex:C1019("\\s+(.+)"; $line; 1; $pos; $len))
								$token:=Substring:C12($line; $pos{1}; $len{1})
								$info:=""
								//end_form, end_obj has no info
							Else 
								If ($values.length>1)
									$line:=$values[1]
									If (Match regex:C1019("\\((\\d+)\\)\\s+([^:]+): (.+)"; $line; 1; $pos; $len))  //2 spaces in case of start token
										$Stack_Level:=Num:C11(Substring:C12($line; $pos{1}; $len{1}))
										$token:=Substring:C12($line; $pos{2}; $len{2})
										$info:=Substring:C12($line; $pos{3}; $len{3})
									End if 
								End if 
						End case 
					End if 
					Case of 
						: ($token="Log level")
							continue
						: ($token="end_form") || ($token="end_obj")
							$Command:=$info
							$Execution_Time:=0
/*
no information in end tag;
use p, pid only
*/
							If ($MS_Stamp_form.length#0)
								$o:=$MS_Stamp_form.query("PID === :1 and UPID == :2 and Cmd_Event != :3"; \
									$PID; $UPID; "").orderBy("MS_Stamp desc").first()
							End if 
							If ($o#Null:C1517)
								$Execution_Time:=$MS_Stamp-$o.MS_Stamp
								$MS_Stamp_form.remove($MS_Stamp_form.indexOf($o))
							Else 
								//no start record in stack
							End if 
						: ($token="end_meth")
							$Command:=$info
							$Execution_Time:=0
							$Cmd_Event:=""
							If ($MS_Stamp_meth.length#0)
								$o:=$MS_Stamp_meth.query("Command === :1 and Stack_Level === :2 and PID === :3 and UPID == :4 and Cmd_Event == :5"; \
									$Command; $Stack_Level; $PID; $UPID; $Cmd_Event).orderBy("MS_Stamp desc").first()
								If ($o#Null:C1517)
									$Execution_Time:=$MS_Stamp-$o.MS_Stamp
									$MS_Stamp_meth.remove($MS_Stamp_meth.indexOf($o))
								Else 
									//no start record in stack
								End if 
							End if 
						: ($token="meth")
							$Cmd_Event:=""
							$MS_Stamp_meth.push({\
								MS_Stamp: $MS_Stamp; \
								Command: $info; \
								Cmd_Event: $Cmd_Event; \
								Stack_Level: $Stack_Level; \
								PID: $PID; \
								UPID: $UPID})  //start
							continue
						: ($token="plugInName")
							If (Match regex:C1019("(.+); [^:]+: ([^\\.]+)\\.([^\\.]+)"; $info; 1; $pos; $len))
								$token:="plugin"
								$Cmd_Event:=Substring:C12($info; $pos{3}; $len{3})
								$Command:=Substring:C12($info; $pos{1}; $len{1})+" ("+Substring:C12($info; $pos{2}; $len{2})+")"
								$Execution_Time:=0
							End if 
						: ($token="form") || ($token="obj")
							If (Match regex:C1019("(.+); event: (\\.+)"; $info; 1; $pos; $len))
								$Cmd_Event:=Substring:C12($info; $pos{2}; $len{2})
								$Command:=Substring:C12($info; $pos{1}; $len{1})
								$MS_Stamp_form.push({\
									MS_Stamp: $MS_Stamp; \
									Command: $info; \
									Cmd_Event: $Cmd_Event; \
									Stack_Level: $Stack_Level; \
									PID: $PID; \
									UPID: $UPID})  //start
								continue
							End if 
						: ($token="cmd")
							If (Match regex:C1019("(.+)\\.$"; $info; 1; $pos; $len))
								$Command:=Substring:C12($info; $pos{1}; $len{1})
								$Execution_Time:=0
								$Cmd_Event:=""
								If ($MS_Stamp_cmd.length#0)
/*
can't use pop() because the debug log 
is not synchronous at the ms/process level
*/
									$o:=$MS_Stamp_cmd.query("Command === :1 and Stack_Level === :2 and PID === :3 and UPID == :4 and Cmd_Event == :5"; \
										$Command; $Stack_Level; $PID; $UPID; $Cmd_Event).orderBy("MS_Stamp desc").first()
									If ($o#Null:C1517)
										$Execution_Time:=$MS_Stamp-$o.MS_Stamp
										$MS_Stamp_cmd.remove($MS_Stamp_cmd.indexOf($o))
									Else 
										//no start record in stack
									End if 
								End if 
							Else 
								$MS_Stamp_cmd.push({\
									MS_Stamp: $MS_Stamp; \
									Command: $info; \
									Cmd_Event: $Cmd_Event; \
									Stack_Level: $Stack_Level; \
									PID: $PID; \
									UPID: $UPID})  //start
								continue
							End if 
						Else 
							TRACE:C157
					End case 
					This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; $Cmd_Event)
					continue
			End case 
		End if 
		
		If ($flag=2)
			If ($values.length>1)
				$line:=$values[1]
				If (Match regex:C1019("(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d{3}) p=(\\d+) puid=(\\d+)"; $line; 1; $pos; $len))
					$year:=Num:C11(Substring:C12($line; $pos{1}; $len{1}))
					$month:=Num:C11(Substring:C12($line; $pos{2}; $len{2}))
					$day:=Num:C11(Substring:C12($line; $pos{3}; $len{3}))
					$hh:=Num:C11(Substring:C12($line; $pos{4}; $len{4}))
					$mm:=Num:C11(Substring:C12($line; $pos{5}; $len{5}))
					$ss:=Num:C11(Substring:C12($line; $pos{6}; $len{6}))
					$ms:=Num:C11(Substring:C12($line; $pos{7}; $len{7}))
					$PID:=Num:C11(Substring:C12($line; $pos{8}; $len{8}))
					$UPID:=Num:C11(Substring:C12($line; $pos{9}; $len{9}))
				End if 
				If ($values.length>2)
					$line:=$values[2]
					If (Match regex:C1019("\\((\\d+)\\)\\s+([^:]+): (.+)"; $line; 1; $pos; $len))  //2 spaces in case of start token
						$Stack_Level:=Num:C11(Substring:C12($line; $pos{1}; $len{1}))
						$token:=Substring:C12($line; $pos{2}; $len{2})
						$info:=Substring:C12($line; $pos{3}; $len{3})
						Case of 
							: ($token="task start")
								continue
						End case 
						$Execution_Time:=0
						If (Match regex:C1019("(.+)\\s+([0-9<]+)\\s+ms$"; $info; 1; $pos; $len))
							$ms:=Substring:C12($info; $pos{2}; $len{2})
							$info:=Substring:C12($info; $pos{1}; $len{1})
							If ($ms#"<")
								$Execution_Time:=Num:C11($ms)
							End if 
						End if 
						Case of 
							: ($token="form")  //start
								continue
							: ($token="obj")  //start
								continue
							: ($token="cmd")  //start
								continue
							: ($token="mbr")  //start
								continue
							: (Match regex:C1019("end_(.+)"; $token; 1; $pos; $len))  //end_form|obj has event information
								$token:=Substring:C12($token; $pos{1}; $len{1})
								If (Match regex:C1019("(.+)\\.\\s*"; $info; 1; $pos; $len))
									$Command:=Substring:C12($info; $pos{1}; $len{1})
									Case of 
										: ($token="form") || ($token="obj")
											If (Match regex:C1019("(.+) during (\\.+)"; $info; 1; $pos; $len))
												$Cmd_Event:=Substring:C12($info; $pos{2}; $len{2})
												$Command:=Substring:C12($info; $pos{1}; $len{1})
												This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; $Cmd_Event)
											End if 
											continue
										: ($token="cmd") || ($token="meth") || ($token="mbr")
											$Cmd_Event:=""
									End case 
									This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; "")
									continue
								End if 
							: ($token="plugInName")  //end_externCall has entry point number
								$token:="plugin"
								If (Match regex:C1019("(.+)\\.\\s*"; $info; 1; $pos; $len))
									$info:=Substring:C12($info; $pos{1}; $len{1})
									If (Match regex:C1019("(.+) end_externCall: (\\d+)"; $info; 1; $pos; $len))
										$Cmd_Event:=Substring:C12($info; $pos{2}; $len{2})
										$Command:=Substring:C12($info; $pos{1}; $len{1})
										This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; $Cmd_Event)
										continue
									End if 
								Else 
									continue  //start
								End if 
						End case 
					End if 
				End if 
			End if 
		End if 
	Until (False:C215)
	
Function _v1()
	
	This:C1470._v(1)
	
Function _v2()
	
	This:C1470._v(2)
	
Function _add($DL_ID : Integer; $MS_Stamp : Integer; $PID : Integer; $UPID : Integer; $Stack_Level : Integer; $Execution_Time : Integer; $Command : Text; $Cmd_Type : Text; $Cmd_Event : Text)
	
	var $Log_Lines : cs:C1710.Log_LinesEntity
	$Log_Lines:=ds:C1482.Log_Lines.new()
	$Log_Lines.DL_ID:=$DL_ID
	$Log_Lines.MS_Stamp:=$MS_Stamp
	$Log_Lines.PID:=$PID
	$Log_Lines.UPID:=$UPID
	$Log_Lines.Stack_Level:=$Stack_Level
	$Log_Lines.Command:=$Command
	$Log_Lines.Execution_Time:=$Execution_Time
	$Log_Lines.Cmd_Type:=$Cmd_Type
	$Log_Lines.Cmd_Event:=$Cmd_Event
	$Log_Lines.Hash:=Generate digest:C1147([$Cmd_Type; $Command; $Cmd_Event].join(":"); SHA1 digest:K66:2)
	$Log_Lines.save()
	
Function _getEOL() : cs:C1710._ClassicDebugLogParser
	
	$offset:=This:C1470.fileHandle.offset
	
	This:C1470.fileHandle.offset-=1  //because blob offset is 0 based
	var $bytes : 4D:C1709.Blob
	$bytes:=This:C1470.fileHandle.readBlob(2)
	
	Case of 
		: ($bytes[0]=Carriage return:K15:38) && ($bytes[1]=Line feed:K15:40)
			This:C1470.breakModeRead:="crlf"
			$offset+=1
		: ($bytes[0]=Line feed:K15:40)
			This:C1470.breakModeRead:="lf"
		Else 
			This:C1470.breakModeRead:="cr"
	End case 
	
	This:C1470.fileHandle:=Null:C1517
	
	Case of 
		: (This:C1470.Log_Version=2)
			This:C1470.charset:="utf-8"
		: (This:C1470.Log_Version=1)
			If (Get database localization:C1009(Internal 4D localization:K5:24)="ja")
				This:C1470.charset:="windows-31j"
			Else 
				This:C1470.charset:="macroman"
			End if 
	End case 
	
	This:C1470.option:={mode: "read"; breakModeRead: This:C1470.breakModeRead; charset: This:C1470.charset}
	
	This:C1470.fileHandle:=This:C1470.file.open(This:C1470.option)
	This:C1470.fileHandle.offset:=$offset
	
	return This:C1470