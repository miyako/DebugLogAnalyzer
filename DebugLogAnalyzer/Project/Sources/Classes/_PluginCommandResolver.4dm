property manifests : Collection

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
	
Function getInfo($operation : Text) : Text
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	If (Match regex:C1019("(\\d+);(\\d+)"; $operation; 1; $pos; $len))
		
		$id:=Num:C11(Substring:C12($operation; $pos{1}; $len{1}))
		$ep:=Num:C11(Substring:C12($operation; $pos{2}; $len{2}))
		
		Case of 
			: ($ep=249)
				return "EX_ALERT"
			: ($ep=410)
				return "EX_CLEAR_VARIABLE"
			: ($ep=411)
				return "EX_GET_STRUCTURE_FULLPATH"
			: ($ep=424)
				return "EX_CONVERT_STRING"
			: ($ep=427)
				return "EX_GET_4D_FOLDER"
			: ($ep=434)
				return "EX_HANDLE_MANAGER"
			: ($ep=506)
				return "EX_GET_COMMAND_ID"
			: ($ep=507)
				return "EX_GET_COMMAND_NAME"
			: ($ep=508)
				return "EX_GET_METHOD_ID"
			: ($ep=611)
				return "EX_COMPARE_UNIBUFFERS"
			: ($ep=612)
				return "EX_CREATE_UNISTRING"
			: ($ep=613)
				return "EX_SET_UNISTRING"
			: ($ep=614)
				return "EX_DISPOSE_UNISTRING"
			: ($ep=615)
				return "EX_VARIABLE_TO_STRING"
			: ($ep=617)
				return "EX_CREATE_PICTURE"
			: ($ep=620)
				return "EX_DISPOSE_PICTURE"
			: ($ep=636)
				return "EX_EXECUTE_COMMAND_BY_ID"
			: ($ep=654)
				return "EX_DUPLICATE_PICTURE"
			: ($ep=671)
				return "EX_GET_PICTURE_DATA"
			: ($ep=675)
				return "EX_CONVERT_CHARSET_TO_CHARSET"
			: ($ep=701)
				return "EX_SET_OBJ_VALUE"
			: ($ep=702)
				return "EX_GET_OBJ_VALUE"
			: ($ep=703)
				return "EX_COPY_VARIABLE"
			: ($ep=720)
				return "EX_CALL_OBJ_FUNCTION"
			Else 
				return ["plugin"; $id; "command"; $ep].join(" ")
		End case 
		
	End if 