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
property properties : Collection
property path : Text
property resolver : cs:C1710._PluginCommandResolver

Class constructor($file : 4D:C1709.File; $parser : cs:C1710._ClassicDebugLogParser)
	
	This:C1470.file:=$file
	
	Case of 
		: ($parser=Null:C1517) && (OB Instance of:C1731($file; 4D:C1709.File))  //for first file
			This:C1470.fileHandle:=$file.open("read")
			This:C1470.line1:=This:C1470.fileHandle.readLine()
		: (OB Instance of:C1731($parser; cs:C1710._ClassicDebugLogParser)) && ($parser.option#Null:C1517)
			This:C1470.fileHandle:=$file.open($parser.option)
			This:C1470.toObject(This:C1470; $parser)
	End case 
	
	This:C1470.resolver:=cs:C1710._PluginCommandResolver.new()
	
Function toObject($this : Object; $that : Object) : cs:C1710._ClassicDebugLogParser
	
	$properties:=["option"; "Id"; "option"; "charset"; "Log_Version"; "Log_MS"; "Log_Time"; "Log_Date"; "breakModeRead"; "isValid"; "line1"]
	
	var $attr : Text
	For each ($attr; $properties)
		$this[$attr]:=$that[$attr]
	End for each 
	
	If ($this.file=Null:C1517) && ($that.file#Null:C1517)
		$this.file:=$that.file
	End if 
	
	return This:C1470
	
Function reopen() : cs:C1710._ClassicDebugLogParser
	
	If (This:C1470.fileHandle=Null:C1517)
		This:C1470.fileHandle:=This:C1470.file.open(This:C1470.option)
		This:C1470.fileHandle.readLine()
	End if 
	
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
			If (This:C1470._isTsv())
				This:C1470.Log_Version:=3
			Else 
				This:C1470.Log_Version:=2
			End if 
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
	
Function continue($ctx : Object) : Boolean
	
	If (This:C1470.isValid)
		Case of 
			: (This:C1470.Log_Version=3)
				This:C1470._v3($ctx)
				return True:C214
			: (This:C1470.Log_Version=2)
				This:C1470._v2($ctx)
				return True:C214
			: (This:C1470.Log_Version=1)
				This:C1470._v1($ctx)
				return True:C214
		End case 
	End if 
	
	return False:C215
	
	//MARK:-
	
Function _v($flag : Integer; $ctx : Object)
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	var $MS_Stamp_cmd; $MS_Stamp_task; $MS_Stamp_form; $MS_Stamp_meth : Collection
	
	$MS_Stamp_cmd:=[]
	$MS_Stamp_form:=[]
	$MS_Stamp_meth:=[]
	$MS_Stamp_task:=[]
	
	var $stacks : Object
	$stacks:={}
	
	var $o : Object
	var $ms : Text
	
	var $interval : Real
	var $isGUI : Boolean
	
	If ($ctx#Null:C1517)
		$isGUI:=True:C214
		$interval:=$ctx.updateInterval
		$time:=Milliseconds:C459
	End if 
	
	Repeat 
		
		Repeat 
		Until (This:C1470.fileHandle.eof) || ($line#"")
		
		If (This:C1470.fileHandle.eof)
			break
		End if 
		
		var $MS_Stamp : Integer
		
		$values:=Split string:C1554($line; "\t")
		
		If ($values.length>0)
			Case of 
				: ($flag=3)
					If ($values.length#11)
						break
					End if 
					$MS_Stamp:=Num:C11($values[0])  //actually the sequential operation number
					$iso8601:=$values[1]
					$PID:=Num:C11($values[2])
					$UPID:=Num:C11($values[3])
					$Stack_Level:=Num:C11($values[4])
					$Command:=$values[6]
					If ($values[8]="0")
						$Cmd_Event:=""
					Else 
						$Cmd_Event:=$values[8]
					End if 
					$operation_type:=Num:C11($values[5])
					Case of 
						: ($operation_type=1)
							$token:="cmd"
						: ($operation_type=2)
							If ($Cmd_Event="")
								$token:="meth"
							Else 
								$token:="end_form"
							End if 
						: ($operation_type=3)  //message
							continue
						: ($operation_type=4)  //message
							continue
						: ($operation_type=5)
							$token:="plugin event"
						: ($operation_type=6)  //not implemented
							$token:="plugin command"
							continue
						: ($operation_type=7)
							$token:="plugin callback"
						: ($operation_type=8)
							$token:="task"
						: ($operation_type=9)
							$token:="mbr"
					End case 
					//$stack_opening_sequence_number:=Num($values[9])
					
					//If ()
					
					//$stacks[$MS_Stamp]:={Command: $Command}
					
					//End if 
					
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
							$Cmd_Event:=""
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
								$Command:=$o.Command
								$Cmd_Event:=$o.Cmd_Event
								$MS_Stamp_form.remove($MS_Stamp_form.indexOf($o))
							Else 
								//no start record in stack
								continue
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
							If (Match regex:C1019("([^;]+); event: (.+)"; $info; 1; $pos; $len))
								$Cmd_Event:=Substring:C12($info; $pos{2}; $len{2})
								$Command:=Substring:C12($info; $pos{1}; $len{1})
								$MS_Stamp_form.push({\
									MS_Stamp: $MS_Stamp; \
									Command: $Command; \
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
					End case 
					This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; $Cmd_Event)
					$milliseconds:=Milliseconds:C459
					If (Abs:C99($milliseconds-$time)>$interval)
						$time:=$milliseconds
						If ($isGUI)
							CALL FORM:C1391($ctx.window; $ctx.onRefresh)
						End if 
					End if 
					continue
			End case 
		End if 
		
		If ($flag=3)
			Case of 
				: ($token="cmd")
					If ($values[9]="")  //opening stack level 
						continue
					End if 
					$Execution_Time:=Num:C11($values[10])
					$Command:=Parse formula:C1576(":C"+$Command)
					$operation_parameters:=$values[7]
					If ($operation_parameters#"")
						$Command+="("+$operation_parameters+")"
					End if 
				: ($token="meth") || ($token="end_form") || ($token="mbr")  //no diff between obj/form
					If ($values[9]="")  //opening stack level 
						continue
					End if 
					$Cmd_Event:=This:C1470.resolver.getFormEventInfo($Cmd_Event)
					$Execution_Time:=Num:C11($values[10])
					$operation_parameters:=$values[7]
					If ($operation_parameters#"")
						$Command+="("+$operation_parameters+")"
					End if 
				: ($token="plugin callback")
					If ($values[9]="")  //opening stack level 
						continue
					End if 
					$Cmd_Event:=$Command
					$Command:=This:C1470.resolver.getCallbackInfo($Cmd_Event)
					If ($Command="")
						continue
					End if 
					$token:="plugin"
				: ($token="plugin event")
					If ($values[9]="")  //opening stack level 
						continue
					End if 
					$Cmd_Event:=$Command
					$Command:=This:C1470.resolver.getEventInfo($Cmd_Event)
					If ($Command="")
						continue
					End if 
					$token:="plugin"
				: ($token="task")
					If ($values[9]="")  //opening stack level 
						continue
					End if 
					If ($Command="")  //no task information, ignore
						continue
					End if 
				Else 
					TRACE:C157
			End case 
			If ($Command="")
				TRACE:C157
			End if 
			This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; $Cmd_Event)
			$milliseconds:=Milliseconds:C459
			If (Abs:C99($milliseconds-$time)>$interval)
				$time:=$milliseconds
				If ($isGUI)
					CALL FORM:C1391($ctx.window; $ctx.onRefresh)
				End if 
			End if 
			continue
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
					$milliseconds:=Num:C11(Substring:C12($line; $pos{7}; $len{7}))
					$PID:=Num:C11(Substring:C12($line; $pos{8}; $len{8}))
					$UPID:=Num:C11(Substring:C12($line; $pos{9}; $len{9}))
				End if 
				If ($values.length>2)
					$line:=$values[2]
					Case of 
						: (Match regex:C1019("\\((\\d+)\\)\\s+(\\S+) stop\\. ([0-9<]+)\\s+ms$"; $line; 1; $pos; $len))
							$Stack_Level:=Num:C11(Substring:C12($line; $pos{1}; $len{1}))
							$token:=Substring:C12($line; $pos{2}; $len{2})
							If ($MS_Stamp_task.length#0)
								$Command:=$MS_Stamp_task.pop().Command
							Else 
								$Command:=""
							End if 
							$Cmd_Event:=""
							$ms:=Substring:C12($line; $pos{3}; $len{3})
							$Execution_Time:=0
							If ($ms#"<")
								$Execution_Time:=Num:C11($ms)
							End if 
							This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; $Cmd_Event)
							$milliseconds:=Milliseconds:C459
							If (Abs:C99($milliseconds-$time)>$interval)
								$time:=$milliseconds
								If ($isGUI)
									CALL FORM:C1391($ctx.window; $ctx.onRefresh)
								End if 
							End if 
							continue
					End case 
					If (Match regex:C1019("\\((\\d+)\\)\\s+([^:]+): (.+)"; $line; 1; $pos; $len))  //2 spaces in case of start token
						$Stack_Level:=Num:C11(Substring:C12($line; $pos{1}; $len{1}))
						$token:=Substring:C12($line; $pos{2}; $len{2})
						$info:=Substring:C12($line; $pos{3}; $len{3})
						Case of 
							: ($token="task start")
								$MS_Stamp_task.push({Command: $info})
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
								If (Match regex:C1019("(.+) during (.+)"; $info; 1; $pos; $len))
									$Cmd_Event:=Substring:C12($info; $pos{2}; $len{2})
									$Command:=Substring:C12($info; $pos{1}; $len{1})
									$MS_Stamp_form.push({Command: $Command; Cmd_Event: $Cmd_Event})
								End if 
								continue
							: ($token="obj")  //start
								If (Match regex:C1019("(.+) during (.+)"; $info; 1; $pos; $len))
									$Cmd_Event:=Substring:C12($info; $pos{2}; $len{2})
									$Command:=Substring:C12($info; $pos{1}; $len{1})
									$MS_Stamp_form.push({Command: $Command; Cmd_Event: $Cmd_Event})
								End if 
								continue
							: ($token="cmd")  //start
								continue
							: ($token="mbr")  //start
								continue
							: (Match regex:C1019("end_(.+)"; $token; 1; $pos; $len))  //end_form|obj has no event information
								$token:=Substring:C12($token; $pos{1}; $len{1})
								If (Match regex:C1019("(.+)\\.\\s*"; $info; 1; $pos; $len))
									$Command:=Substring:C12($info; $pos{1}; $len{1})
									Case of 
										: ($token="form") || ($token="obj")
											If (Match regex:C1019("(.+) during \\."; $info; 1; $pos; $len))
												If ($MS_Stamp_form.length#0)
													$Cmd_Event:=$MS_Stamp_form.pop().Cmd_Event
												Else 
													$Cmd_Event:=""  //event name is only present at start
												End if 
												$Command:=Substring:C12($info; $pos{1}; $len{1})
												This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; $Cmd_Event)
												$milliseconds:=Milliseconds:C459
												If (Abs:C99($milliseconds-$time)>$interval)
													$time:=$milliseconds
													If ($isGUI)
														CALL FORM:C1391($ctx.window; $ctx.onRefresh)
													End if 
												End if 
												continue
											End if 
										: ($token="cmd") || ($token="meth") || ($token="mbr")
											$Cmd_Event:=""
									End case 
									This:C1470._add(This:C1470.Id; $MS_Stamp; $PID; $UPID; $Stack_Level; $Execution_Time; $Command; $token; "")
									$milliseconds:=Milliseconds:C459
									If (Abs:C99($milliseconds-$time)>$interval)
										$time:=$milliseconds
										If ($isGUI)
											CALL FORM:C1391($ctx.window; $ctx.onRefresh)
										End if 
									End if 
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
										$milliseconds:=Milliseconds:C459
										If (Abs:C99($milliseconds-$time)>$interval)
											$time:=$milliseconds
											If ($isGUI)
												CALL FORM:C1391($ctx.window; $ctx.onRefresh)
											End if 
										End if 
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
	
Function _v1($ctx : Object)
	
	This:C1470._v(1; $ctx)
	
Function _v2($ctx : Object)
	
	This:C1470._v(2; $ctx)
	
Function _v3($ctx : Object)
	
	This:C1470._v(3; $ctx)
	
Function _add($DL_ID : Integer; $MS_Stamp : Integer; $PID : Integer; $UPID : Integer; $Stack_Level : Integer; $Execution_Time : Integer; $Command : Text; $Cmd_Type : Text; $Cmd_Event : Text)
	
	If ($Execution_Time=0) || ($Cmd_Type="")
		return 
	End if 
	var $Log_Lines : cs:C1710.Log_LinesEntity
	$Log_Lines:=ds:C1482.Log_Lines.new()
	$Log_Lines.DL_ID:=$DL_ID
	$Log_Lines.MS_Stamp:=$MS_Stamp
	$Log_Lines.PID:=$PID
	$Log_Lines.UPID:=$UPID
	$Log_Lines.Stack_Level:=$Stack_Level
	$Log_Lines.Command:=$Command
	$Log_Lines.Execution_Time:=$Execution_Time
	$Log_Lines.Cmd_Type:=This:C1470._tokenToCommandType($Cmd_Type)
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
			This:C1470.breakModeRead:="cr"  //v11 windows is crcr which is an invalid argument
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
	
Function _isTsv() : Boolean
	
	$offset:=This:C1470.fileHandle.offset
	
	var $line2 : Text
	var $isCRLF : Boolean
	
	Repeat 
		$line2:=This:C1470.fileHandle.readLine()
		If ($line2="")
			$isCRLF:=True:C214
		End if 
	Until (This:C1470.fileHandle.eof) || ($line2#"")
	
	If ($isCRLF)
		This:C1470.fileHandle.offset+=2
	End if 
	
	$headers:=["sequence_number"; "time"; "processID"; "unique_processID"; "stack_level"; "operation_type"; "operation"; "operation_parameters"; "form_event"; "stack_opening_sequence_number"; "stack_level_execution_time"]
	
	$values:=Split string:C1554($line2; "\t")
	
	If ($values.length=$headers.length)
		For ($i; 0; $values.length-1)
			If (0#Compare strings:C1756($values[$i]; $headers[$i]; sk char codes:K86:5))
				This:C1470.fileHandle.offset:=$offset  //rewind
				return False:C215
			End if 
		End for 
		return True:C214
	End if 
	
	This:C1470.fileHandle.offset:=$offset  //rewind
	return False:C215
	
Function _tokenToCommandType($token : Text) : Text
	
	Case of 
		: ($token="cmd")
			return "native command"
		: ($token="plugin")
			return "plugin call"
		: ($token="end_meth")
			return "project method"
		: ($token="end_form")
			return "form method"
		: ($token="end_obj")
			return "object method"
		: ($token="meth")
			return "project method"
		: ($token="mbr")
			return "member function"
		: ($token="form")
			return "form method"
		: ($token="task")
			return "task"
		: ($token="message")
			return ""
		Else 
			TRACE:C157
	End case 
	