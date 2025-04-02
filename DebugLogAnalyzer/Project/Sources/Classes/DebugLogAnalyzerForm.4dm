property logFile : Object
property updateInterval : Real
property startTime : Integer
property duration : Text

Class extends _Form

Class constructor
	
	Super:C1705()
	
	This:C1470.logFile:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	//MARK:-Form Object States
	
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
	
	//MARK:-
	
Function start() : cs:C1710.DebugLogAnalyzerForm
	
	This:C1470.startTime:=Milliseconds:C459
	
	This:C1470.isRunning:=True:C214
	This:C1470.toggleSelectDataFile()
	
	return This:C1470
	
Function stop() : cs:C1710.DebugLogAnalyzerForm
	
	This:C1470.isRunning:=False:C215
	This:C1470.toggleSelectDataFile()
	
	return This:C1470
	
Function _getWorkerName($i : Integer) : Text
	
	If ($i=0)
		return "DataLogAnalyzer"
	Else 
		return ["DataLogAnalyzer"; " "; "("; $i; ")"].join("")
	End if 
	
Function open($paths : Collection)
	
	This:C1470.logFile:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	This:C1470.logFile.col:=$paths.map(This:C1470._mapPathsToFiles).orderByMethod(This:C1470._sortBySuffix)
	
	If (This:C1470.useMultipleCores)
		This:C1470.updateInterval:=This:C1470.countCores*This:C1470.updateIntervalUnit
	Else 
		This:C1470.updateInterval:=This:C1470.updateIntervalUnit
	End if 
	
	$ctx:={files: This:C1470.logFile.col; window: Current form window:C827}
	
	//$ctx.onFileInfo:=This._onFileInfo
	//$ctx.onTableInfo:=This._onTableInfo
	//$ctx.onTableStats:=This._onTableStats
	$ctx.onFinish:=This:C1470._onFinish
	$ctx.countCores:=This:C1470.countCores
	$ctx.useMultipleCores:=This:C1470.useMultipleCores
	//$ctx.workerFunction:=This._processTable
	$ctx.updateInterval:=This:C1470.updateInterval
	$ctx.dispatchInterval:=This:C1470.dispatchInterval
	
	This:C1470.start()
	
	var $workerNames : Collection
	var $workerName : Text
	
	$workerNames:=[]
	
	$workerName:=This:C1470._getWorkerName(0)
	$workerNames.push($workerName)
	
	$ctx.workerNames:=$workerNames
	
	For each ($workerName; $workerNames)
		CALL WORKER:C1389($workerName; Formula:C1597(preemptiveWorker); $ctx)
	End for each 
	
	CALL WORKER:C1389($workerNames[0]; This:C1470._open; $ctx)
	
Function _open($ctx : Object)
	
	$debugLogInfo:={}
	
	var $file : 4D:C1709.File
	$file:=$ctx.files.first()
	
	If ($file#Null:C1517)
		var $first; $parser : cs:C1710._ClassicDebugLogParser
		$first:=cs:C1710._ClassicDebugLogParser.new($file)
		$option:=$first.start()  //use same option for circular logs
		$first.continue()
		For each ($file; $ctx.files.slice(1))
			$parser:=cs:C1710._ClassicDebugLogParser.new($file; $first)
			$parser.continue()
		End for each 
	End if 
	
	CALL FORM:C1391($ctx.window; $ctx.onFinish; $debugLogInfo; $ctx)
	
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
	
Function _onFinish($debugLogInfo : Object; $ctx : Object)
	
	$this:=Form:C1466
	
	$this.stop()
	
	For each ($workerName; $ctx.workerNames)
		KILL WORKER:C1390($workerName)
	End for each 