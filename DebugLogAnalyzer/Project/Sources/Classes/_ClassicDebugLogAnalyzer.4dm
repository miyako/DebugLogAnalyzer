property length : Integer
property functions : cs:C1710.Log_LinesSelection
property commands : cs:C1710.Log_LinesSelection
property methods : cs:C1710.Log_LinesSelection
property logs : cs:C1710.Log_LinesSelection
property averages : Object
property counts : Object
property times : Object
property ms : Integer

Class constructor($length : Integer)
	
	This:C1470.length:=$length
	This:C1470.averages:={functions: Null:C1517; commands: Null:C1517; methods: Null:C1517}
	This:C1470.counts:={functions: Null:C1517; commands: Null:C1517; methods: Null:C1517}
	This:C1470.times:={functions: Null:C1517; commands: Null:C1517; methods: Null:C1517}
	This:C1470.ms:=Milliseconds:C459
	
Function accumulate($logs : cs:C1710.Log_LinesSelection) : cs:C1710.Log_LinesSelection
	
	If (This:C1470.logs=Null:C1517)
		This:C1470.logs:=$logs
		If (This:C1470.functions=Null:C1517)
			This:C1470.functions:=$logs.query("Cmd_Type in :1"; ["project method"; "member function"])
		End if 
		If (This:C1470.commands=Null:C1517)
			This:C1470.commands:=$logs.query("Cmd_Type in :1"; ["native command"; "plugin call"])
		End if 
		If (This:C1470.methods=Null:C1517)
			This:C1470.methods:=$logs.query("Cmd_Type in :1"; ["form method"; "object method"])
		End if 
	End if 
	
	return This:C1470
	
Function analytics() : Object
	
	return {\
		averages: This:C1470.averages; \
		counts: This:C1470.counts; \
		times: This:C1470.times\
		}
	
Function _time($selection : Text; $ctx : Object) : Collection
	
	var $set : cs:C1710.Log_LinesSelection
	$set:=This:C1470[$selection]
	
	var $times : Collection
	$times:=[]
	
	var $e : cs:C1710.Log_LinesEntity
	
	var $i : Integer
	$i:=0
	For each ($e; $set.orderBy("Execution_Time desc").slice(0; This:C1470.length))
		$i+=1
		$times.push({\
			ranking: $i; \
			Execution_Time: $e.Execution_Time; \
			Command: [$e.Command; $e.Cmd_Event].join(" "; ck ignore null or empty:K85:5)\
			})
	End for each 
	
	return $times
	
Function _count($selection : Text; $ctx : Object) : Collection
	
	var $interval : Real
	var $isGUI : Boolean
	
	If ($ctx#Null:C1517)
		$isGUI:=True:C214
		$interval:=$ctx.updateInterval
	End if 
	
	var $counts : Collection
	$counts:=[]
	
	var $set; $logs : cs:C1710.Log_LinesSelection
	$set:=This:C1470[$selection]
	
	If ($set=Null:C1517)
		return 
	End if 
	
	$logs:=This:C1470.logs
	
	If ($logs=Null:C1517)
		return 
	End if 
	
	var $hashes : Collection
	$hashes:=$set.distinct("Hash")
	
	var $hash : Text
	$length:=This:C1470.length
	
	For each ($hash; $hashes)
		$count:=$logs.query("Hash == :1"; $hash).length
		If ($counts.length<$length)
			$counts.push({hash: $hash; Execution_Time: $count})
		Else 
			$counts:=$counts.orderBy("Execution_Time desc")
			$top:=$counts.first()
			If ($count>$top.Execution_Time)
				$counts.pop()
				$counts.unshift({hash: $hash; Execution_Time: $count})
			End if 
		End if 
		$milliseconds:=Milliseconds:C459
		If (Abs:C99($milliseconds-This:C1470.ms)>$interval)
			This:C1470.ms:=$milliseconds
			If ($isGUI)
				CALL FORM:C1391($ctx.window; $ctx.onYield)
			End if 
		End if 
	End for each 
	
	If ($counts.length<=$length)
		$counts:=$counts.orderBy("Execution_Time desc")
	End if 
	
	var $e : cs:C1710.Log_LinesEntity
	var $i : Integer
	$i:=0
	For each ($count; $counts)
		$i+=1
		$e:=ds:C1482.Log_Lines.query("Hash == :1"; $count.hash).first()
		OB REMOVE:C1226($count; "Hash")
		$count.ranking:=$i
		$count.Command:=[$e.Command; $e.Cmd_Event].join(" "; ck ignore null or empty:K85:5)
	End for each 
	
	return $counts
	
Function _average($selection : Text; $ctx : Object) : Collection
	
	var $interval : Real
	var $isGUI : Boolean
	
	If ($ctx#Null:C1517)
		$isGUI:=True:C214
		$interval:=$ctx.updateInterval
	End if 
	
	var $averages : Collection
	$averages:=[]
	
	var $set; $logs : cs:C1710.Log_LinesSelection
	$set:=This:C1470[$selection]
	
	If ($set=Null:C1517)
		return 
	End if 
	
	$logs:=This:C1470.logs
	
	If ($logs=Null:C1517)
		return 
	End if 
	
	var $hashes : Collection
	$hashes:=$set.distinct("Hash")
	
	var $hash : Text
	$length:=This:C1470.length
	
	For each ($hash; $hashes)
		$average:=$logs.query("Hash == :1"; $hash).average("Execution_Time")
		If ($averages.length<$length)
			$averages.push({hash: $hash; Execution_Time: $average})
		Else 
			$averages:=$averages.orderBy("Execution_Time desc")
			$top:=$averages.first()
			If ($average>$top.Execution_Time)
				$averages.pop()
				$averages.unshift({hash: $hash; Execution_Time: $average})
			End if 
		End if 
		$milliseconds:=Milliseconds:C459
		If (Abs:C99($milliseconds-This:C1470.ms)>$interval)
			This:C1470.ms:=$milliseconds
			If ($isGUI)
				CALL FORM:C1391($ctx.window; $ctx.onYield)
			End if 
		End if 
	End for each 
	
	If ($averages.length<=$length)
		$averages:=$averages.orderBy("Execution_Time desc")
	End if 
	
	var $e : cs:C1710.Log_LinesEntity
	var $i : Integer
	$i:=0
	For each ($average; $averages)
		$i+=1
		$e:=ds:C1482.Log_Lines.query("Hash == :1"; $average.hash).first()
		OB REMOVE:C1226($average; "Hash")
		$average.ranking:=$i
		$average.Command:=[$e.Command; $e.Cmd_Event].join(" "; ck ignore null or empty:K85:5)
	End for each 
	
	return $averages
	
Function average($ctx : Object) : cs:C1710.Log_LinesSelection
	
	If (This:C1470.averages.functions=Null:C1517)
		This:C1470.averages.functions:=This:C1470._average("functions"; $ctx)
	End if 
	
	If (This:C1470.averages.commands=Null:C1517)
		This:C1470.averages.commands:=This:C1470._average("commands"; $ctx)
	End if 
	
	If (This:C1470.averages.methods=Null:C1517)
		This:C1470.averages.methods:=This:C1470._average("methods"; $ctx)
	End if 
	
	return This:C1470
	
Function count($ctx : Object) : cs:C1710.Log_LinesSelection
	
	If (This:C1470.counts.functions=Null:C1517)
		This:C1470.counts.functions:=This:C1470._count("functions"; $ctx)
	End if 
	
	If (This:C1470.counts.commands=Null:C1517)
		This:C1470.counts.commands:=This:C1470._count("commands"; $ctx)
	End if 
	
	If (This:C1470.counts.methods=Null:C1517)
		This:C1470.counts.methods:=This:C1470._count("methods"; $ctx)
	End if 
	
	return This:C1470
	
Function time($ctx : Object) : cs:C1710.Log_LinesSelection
	
	If (This:C1470.times.functions=Null:C1517)
		This:C1470.times.functions:=This:C1470._time("functions"; $ctx)
	End if 
	
	If (This:C1470.times.commands=Null:C1517)
		This:C1470.times.commands:=This:C1470._time("commands"; $ctx)
	End if 
	
	If (This:C1470.times.methods=Null:C1517)
		This:C1470.times.methods:=This:C1470._time("methods"; $ctx)
	End if 
	
	return This:C1470