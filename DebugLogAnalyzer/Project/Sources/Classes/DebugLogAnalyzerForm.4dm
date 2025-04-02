property logFile : Object
property updateInterval : Real
property startTime : Integer
property duration : Text
property logLines : Object

Class extends _Form

Class constructor
	
	Super:C1705()
	
	This:C1470.logFile:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	//MARK:-Form Object States
	
Function toggleListSelection() : cs:C1710.DebugLogAnalyzerForm
	
	If (This:C1470.isRunning)
		LISTBOX SET PROPERTY:C1440(*; "logLines"; lk selection mode:K53:35; lk none:K53:57)
	Else 
		LISTBOX SET PROPERTY:C1440(*; "logLines"; lk selection mode:K53:35; lk multiple:K53:59)
	End if 
	
	return This:C1470
	
Function toggleSelectDataFile() : cs:C1710.DebugLogAnalyzerForm
	
	OBJECT SET ENABLED:C1123(*; "open"; Not:C34(This:C1470.isRunning))
	
	return This:C1470
	
	//MARK:-Form Events
	
Function onDragOver() : Integer
	
	If (This:C1470.isRunning)
		return -1
	End if 
	
	$extension:=[".txt"; ".log"]
	
	var $i : Integer
	$i:=0
	
	Repeat 
		$i+=1
		$path:=Get file from pasteboard:C976($i)
		If ($path="")
			break
		End if 
		$type:=Test path name:C476($path)
		Case of 
			: ($type=Is a document:K24:1)
				$file:=File:C1566($path; fk platform path:K87:2)
				If ($file.isAlias)
					Case of 
						: ($file.original.isFolder)
							return 0
						: ($file.original.isFile)
							$file:=$file.original
					End case 
				End if 
				If ($extension.includes($file.extension))
					return 0
				End if 
			: ($type=Is a folder:K24:2)
				return 0
		End case 
	Until (False:C215)
	
	return -1
	
Function onDrop()
	
	$extension:=[".txt"; ".log"]
	$paths:=[]
	
	var $i : Integer
	$i:=0
	
	Repeat 
		$i+=1
		$path:=Get file from pasteboard:C976($i)
		If ($path="")
			break
		End if 
		$type:=Test path name:C476($path)
		Case of 
			: ($type=Is a document:K24:1)
				$file:=File:C1566($path; fk platform path:K87:2)
				If ($file.isAlias)
					Case of 
						: ($file.original.isFolder)
							continue
						: ($file.original.isFile)
							$file:=$file.original
					End case 
				End if 
				If ($extension.includes($file.extension))
					$paths.push($file.platformPath)
				End if 
			: ($type=Is a folder:K24:2)
				$folder:=Folder:C1567($path; fk platform path:K87:2)
				For each ($file; $folder.files().query("extension in :1"; $extension))
					If ($file.isAlias)
						Case of 
							: ($file.original.isFolder)
								continue
							: ($file.original.isFile)
								$file:=$file.original
						End case 
					End if 
					$paths.push($file.platformPath)
				End for each 
		End case 
	Until (False:C215)
	
	This:C1470.open($paths)
	
Function onLoad()
	
Function onUnload()
	
	Form:C1466._killAll()
	
	//MARK:-
	
Function start() : cs:C1710.DebugLogAnalyzerForm
	
	This:C1470.startTime:=Milliseconds:C459
	
	This:C1470.isRunning:=True:C214
	This:C1470.toggleSelectDataFile()
	
	return This:C1470
	
Function updateDuration() : cs:C1710.DebugLogAnalyzerForm
	
	This:C1470.duration:=[String:C10(Abs:C99(Milliseconds:C459-This:C1470.startTime)/1000; "#,###,###,###,##0.0"); "s"].join(" ")
	
	return This:C1470
	
Function stop() : cs:C1710.DebugLogAnalyzerForm
	
	This:C1470.isRunning:=False:C215
	This:C1470.toggleSelectDataFile()
	
	return This:C1470
	
Function _getWorkerName($i : Integer) : Text
	
	If ($i=0)
		return "DebugLogAnalyzer"
	Else 
		return ["DebugLogAnalyzer"; " "; "("; $i; ")"].join("")
	End if 
	
Function _killAll()
	
	var $process : Object
	$processes:=Process activity:C1495(Processes only:K5:35).processes
	If (This:C1470.useMultipleCores)
		For each ($process; $processes)
			If (Match regex:C1019("DebugLogAnalyzer\\s\\(\\d\\)"; $process.name))
				ABORT PROCESS BY ID:C1634($process.ID)
			End if 
		End for each 
	Else 
		$process:=$processes.query("name == :1"; "DebugLogAnalyzer").first()
		If ($process#Null:C1517)
			ABORT PROCESS BY ID:C1634($process.ID)
		End if 
	End if 
	
Function open($paths : Collection)
	
	This:C1470.logFile:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	This:C1470.logFile.col:=$paths.map(This:C1470._mapPathsToFiles).orderByMethod(This:C1470._sortBySuffix)
	
	$countCores:=This:C1470.countCores>This:C1470.logFile.col.length ? This:C1470.countCores : This:C1470.logFile.col.length
	
	If (This:C1470.useMultipleCores)
		This:C1470.updateInterval:=$countCores*This:C1470.updateIntervalUnit
	Else 
		This:C1470.updateInterval:=This:C1470.updateIntervalUnit
	End if 
	
	$ctx:={files: This:C1470.logFile.col; window: Current form window:C827}
	
	$ctx.workerFunction:=This:C1470._processFile
	$ctx.onRefresh:=This:C1470._onRefresh
	$ctx.onStart:=This:C1470._onStart
	$ctx.onFinish:=This:C1470._onFinish
	$ctx.countCores:=$countCores
	$ctx.useMultipleCores:=This:C1470.useMultipleCores
	$ctx.updateInterval:=This:C1470.updateInterval
	
	This:C1470.start().toggleListSelection()
	
	var $workerNames : Collection
	var $workerName : Text
	
	$workerNames:=[]
	
	If (This:C1470.useMultipleCores)
		For ($i; 1; $countCores)
			$workerName:=This:C1470._getWorkerName($i)
			$workerNames.push($workerName)
		End for 
	Else 
		$workerName:=This:C1470._getWorkerName(0)
		$workerNames.push($workerName)
	End if 
	
	$ctx.workerNames:=$workerNames
	
	For each ($workerName; $workerNames)
		CALL WORKER:C1389($workerName; Formula:C1597(preemptiveWorker); $ctx)
	End for each 
	
	CALL WORKER:C1389($workerNames[0]; This:C1470._open; $ctx)
	
	//MARK:-
	
Function _open($ctx : Object)
	
	$debugLogInfo:={}
	
	var $file : 4D:C1709.File
	$file:=$ctx.files.first()
	
	If ($file#Null:C1517)
		var $first; $parser : cs:C1710._ClassicDebugLogParser
		$first:=cs:C1710._ClassicDebugLogParser.new($file)
		$option:=$first.start()  //use same option for circular logs
		For each ($attr; ["Id"; "Log_Version"; "Log_MS"; "Log_Time"; "Log_Date"])
			$debugLogInfo[$attr]:=$first[$attr]
		End for each 
		CALL FORM:C1391($ctx.window; $ctx.onStart; $debugLogInfo; $ctx)
		If ($ctx.useMultipleCores)
			$this:={}
			$first.toObject($this; $first)
			var $parsers : Collection
			$parsers:=[$this]
			For each ($file; $ctx.files.slice(1))
				$parser:=cs:C1710._ClassicDebugLogParser.new($file; $first)
				$this:={}
				$parser.toObject($this; $parser)
				$parsers.push($this)
			End for each 
			$ctx.parsers:=$parsers.copy(ck shared:K85:29)
			For each ($workerName; $ctx.workerNames)
				CALL WORKER:C1389($workerName; $ctx.workerFunction; $ctx)
			End for each 
		Else 
			$first.continue($ctx)
			CALL FORM:C1391($ctx.window; $ctx.onFinish; $file; $ctx)
			For each ($file; $ctx.files.slice(1))
				$parser:=cs:C1710._ClassicDebugLogParser.new($file; $first)
				$parser.continue($ctx)
				CALL FORM:C1391($ctx.window; $ctx.onFinish; $file; $ctx)
			End for each 
		End if 
	End if 
	
Function _processFile($ctx : Object)
	
	var $that : Object
	$that:=$ctx.parsers.shift()
	
	If ($that=Null:C1517)
		KILL WORKER:C1390
		return 
	Else 
		$parser:=cs:C1710._ClassicDebugLogParser.new()
		$parser.toObject($parser; $that).reopen()
		$parser.continue($ctx)
		CALL FORM:C1391($ctx.window; $ctx.onFinish; $parser.file; $ctx)
	End if 
	
	CALL WORKER:C1389(Current process name:C1392; $ctx.workerFunction; $ctx)
	
Function _sortBySuffix($event : Object)
	
	var $name : Text
	var $idx1; $idx2 : Integer
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	$name:=$event.value.name
	If (Match regex:C1019("(.+)\\D(\\d+)"; $name; 1; $pos; $len))
		$idx1:=Num:C11(Substring:C12($name; $pos{2}; $len{2}))
	End if 
	$name:=$event.value2.name
	If (Match regex:C1019("(.+)\\D(\\d+)"; $name; 1; $pos; $len))
		$idx2:=Num:C11(Substring:C12($name; $pos{2}; $len{2}))
	End if 
	
	$event.result:=$idx1<$idx2
	
Function _mapPathsToFiles($event : Object)
	
	var $value : Variant
	$value:=$event.value
	
	$file:=File:C1566($value; fk platform path:K87:2)
	If ($file.isAlias)
		$file:=$file.original
	End if 
	
	$event.result:=$file
	
Function _onRefresh()
	
	$this:=Form:C1466
	
	$this.updateDuration()
	
	$col:=ds:C1482.Log_Lines.query("DL_ID == :1 and Execution_Time != :2 order by Execution_Time desc"; $this.debugLogInfo.Id; 0)
	
	$this.logLines:={col: $col; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
Function _onStart($debugLogInfo : Object; $ctx : Object)
	
	$this:=Form:C1466
	
	$this.debugLogInfo:=$debugLogInfo
	
	$this.logLines:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
Function _onFinish($file : 4D:C1709.File; $ctx : Object)
	
	$this:=Form:C1466
	
	$this.updateDuration()
	
	$col:=$this.logFile.col.query("path != :1"; $file.path)
	
	$this.logFile:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	$this.logFile.col:=$col.orderByMethod(This:C1470._sortBySuffix)
	
	If ($this.logFile.col.length=0)
		
		$this.stop().toggleListSelection()
		
		$col:=ds:C1482.Log_Lines.query("DL_ID == :1 order by Execution_Time desc"; $this.debugLogInfo.Id)
		
		$this.logLines:={col: $col; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
		
		For each ($workerName; $ctx.workerNames)
			KILL WORKER:C1390($workerName)
		End for each 
		
	End if 