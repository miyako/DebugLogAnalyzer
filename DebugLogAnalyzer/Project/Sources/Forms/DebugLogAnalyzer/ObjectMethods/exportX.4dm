var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Clicked:K2:4)
		
		var $file : 4D:C1709.File
		$file:=Form:C1466.toXlsx()
		
		If (Macintosh option down:C545)
			Form:C1466.launch($file)
		Else 
			Form:C1466.show($file)
		End if 
		
End case 