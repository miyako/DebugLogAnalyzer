If (FORM Event:C1606.code=On Clicked:K2:4)
	
	$directoryPath:=Folder:C1567(fk documents folder:K87:21).platformPath
	$title:=OBJECT Get title:C1068(*; OBJECT Get name:C1087)
	
	ARRAY TEXT:C222($paths; 0)
	$fileName:=Select document:C905($directoryPath; ".txt;.log"; $title; Multiple files:K24:7 | Package open:K24:8; $paths)
	
	If (OK=1)
		var $documents : Collection
		$documents:=[]
		ARRAY TO COLLECTION:C1563($documents; $paths)
		
		Form:C1466.open($documents)
		
	End if 
	
End if 