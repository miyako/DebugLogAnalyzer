var $event : Object

$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		If (Not:C34(OB Instance of:C1731(Form:C1466; cs:C1710.DebugLogAnalyzerForm)))
			
			ARRAY LONGINT:C221($events; 1)
			$events{1}:=On Unload:K2:2
			OBJECT SET EVENTS:C1239(*; ""; $events; Disable events others unchanged:K42:39)
			OBJECT SET ENABLED:C1123(*; "@"; False:C215)
			
			return   //please use "DebugLogAnalyzer" method! 
			
		End if 
		
		Form:C1466.onLoad()
		
	: ($event.code=On Unload:K2:2)
		
		Form:C1466.onUnload()
		
	: ($event.code=On Page Change:K2:54)
		
		Form:C1466.onPageChange()
		
End case 