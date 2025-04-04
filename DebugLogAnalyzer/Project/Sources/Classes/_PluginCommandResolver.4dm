property manifests : Collection
property callbacks : Object
property pluginAreaEvents : Object
property formEvents : Object

Class constructor($files : Collection)
	
	If ($files#Null:C1517)
		var $manifests : Collection
		$manifests:=[]
		var $file : 4D:C1709.File
		For each ($file; $files)
			$manifest:=JSON Parse:C1218($file.getText())
			$manifests.push($manifest)
		End for each 
		This:C1470.manifests:=$manifests  //not used
	End if 
	
	This:C1470.callbacks:=JSON Parse:C1218(File:C1566("/RESOURCES/PluginCallback.json").getText())
	This:C1470.pluginAreaEvents:=JSON Parse:C1218(File:C1566("/RESOURCES/PluginEvent.json").getText())
	This:C1470.formEvents:=JSON Parse:C1218(File:C1566("/RESOURCES/FormEvent.json").getText())
	
Function _get($operation : Text; $source : Text) : Text
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	var $kvp : Object
	$kvp:=This:C1470[$source]
	
	If (Match regex:C1019("(\\d+);(\\d+)"; $operation; 1; $pos; $len))
		$id:=Num:C11(Substring:C12($operation; $pos{1}; $len{1}))
		$ep:=Substring:C12($operation; $pos{2}; $len{2})
		If (OB Is defined:C1231($kvp; $ep))
			return $kvp[$ep]
		End if 
	End if 
	
	return 
	
Function getEventInfo($operation : Text) : Text
	
	return This:C1470._get($operation; "pluginAreaEvents")
	
Function getFormEventInfo($operation : Text) : Text
	
	var $kvp : Object
	$kvp:=This:C1470.formEvents
	
	If (OB Is defined:C1231($kvp; $operation))
		return $kvp[$operation]
	End if 
	
	return 
	
Function getCallbackInfo($operation : Text) : Text
	
	return This:C1470._get($operation; "callbacks")