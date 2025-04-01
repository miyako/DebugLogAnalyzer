var $event : Object
$event:=FORM Event:C1606

Case of 
	: ($event.code=On Drag Over:K2:13)
		
		return Form:C1466.onDragOver()
		
	: ($event.code=On Drop:K2:12)
		
		Form:C1466.onDrop()
		
End case 