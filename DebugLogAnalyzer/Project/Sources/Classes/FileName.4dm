property file : 4D:C1709.File

Class constructor($file : 4D:C1709.File)
	
	If (OB Instance of:C1731($file; 4D:C1709.File))
		$file:=File:C1566($file.platformPath; fk platform path:K87:2)
		//%W-550.26
		This:C1470._file:=$file
		If (This:C1470._file.exists)
			var $i : Integer
			$i:=0
			var $name; $extension : Text
			$name:=$file.name
			$extension:=$file.extension
			Repeat 
				$i+=1
				This:C1470._file:=$file.parent.file([$name; " "; $i; $extension].join(""))
			Until (Not:C34(This:C1470._file.exists))
			//%W+550.26
		End if 
	End if 
	
Function get file() : 4D:C1709.File
	
	//%W-550.26
	return This:C1470._file
	//%W+550.26