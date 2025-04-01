property logFile : Object

Class extends _Form

Class constructor
	
	Super:C1705()
	
	This:C1470.logFile:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
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
	
Function open($paths : Collection)
	
	This:C1470.logFile:={col: []; sel: Null:C1517; pos: Null:C1517; item: Null:C1517}
	
	This:C1470.logFile.col:=$paths.map(This:C1470._mapPathsToFiles).orderByMethod(This:C1470._sortBySuffix)
	
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