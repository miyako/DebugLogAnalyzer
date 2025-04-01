//%attributes = {"shared":true}
#DECLARE($params : Object)

If ($params=Null:C1517)
	
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	$form:=cs:C1710.DebugLogAnalyzerForm.new()
	$window:=Open form window:C675("DebugLogAnalyzer")
	DIALOG:C40("DebugLogAnalyzer"; $form; *)
	
End if 