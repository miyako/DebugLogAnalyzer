property fullCalcOnLoad : Boolean

Class constructor
	
	This:C1470.fullCalcOnLoad:=True:C214
	
Function _createWorkFolder() : 4D:C1709.Folder
	
	$path:=Temporary folder:C486+Generate UUID:C1066
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567($path; fk platform path:K87:2)
	$folder.create()
	
	return ($folder.exists) ? $folder : Null:C1517
	
Function read($file : 4D:C1709.File) : Object
	
	//%W-550.26
	This:C1470._workFolder:=Null:C1517
	
	If (OB Instance of:C1731($file; 4D:C1709.File)) && ($file.exists) && (($file.extension=".xlsx") || ($file.extension=".xlsm"))
		
		$folder:=This:C1470._createWorkFolder()
		
		If ($folder#Null:C1517)
			var $zipArchive : 4D:C1709.ZipArchive
			$zipArchive:=ZIP Read archive:C1637($file)
			If ($zipArchive#Null:C1517)
				This:C1470._workFolder:=$zipArchive.root.copyTo($folder)
			End if 
		End if 
		
	End if 
	
	return New object:C1471("success"; (This:C1470._workFolder#Null:C1517))
	//%W+550.26
	
Function write($file : 4D:C1709.File) : Object
	
	//%W-550.26
	If (OB Instance of:C1731($file; 4D:C1709.File)) && (($file.extension=".xlsx") || ($file.extension=".xlsm")) && (This:C1470._workFolder#Null:C1517) && (This:C1470._workFolder.exists)
		
		var $source : Object
		$source:=New object:C1471("files"; This:C1470._workFolder.files().combine(This:C1470._workFolder.folders()))
		
		$file.parent.create()
		
		return ZIP Create archive:C1640($source; $file)
		
	End if 
	//%W+550.26
	
	return New object:C1471("success"; False:C215)
	
Function convertToMicrosoftTime($time : Time) : Real
	
	return $time/86400
	
Function convertToMicrosoftDate($date : Date) : Integer
	
	Case of 
		: ($date<!1900-01-01!)
			
		: (!1900-01-01!<$date) & ($date<!1900-03-01!)
			
			return $date-!1899-12-31!
			
		: ($date>!1900-02-28!)
			
			return $date-!1899-12-30!
			
		Else 
/*
			
Microsoft date 60 (29th February 1900) does not exist!
			
https://en.wikipedia.org/wiki/Year_1900_problem
			
*/
	End case 
	
	return 
	
Function setValues($values : Object; $sheetIndex : Integer) : Object
	
	$success:=False:C215
	
	//%W-550.26
	If (This:C1470._workFolder#Null:C1517) && (This:C1470._workFolder.exists)
		
		$sheetIndex:=$sheetIndex>0 ? $sheetIndex : 1
		
		$sharedStrings:=This:C1470._workFolder\
			.folder("xl")\
			.file("sharedStrings.xml")
		
		var $sharedStringsCollection : Collection
		var $count; $uniqueCount : Integer
		var $length : Integer
		
		ARRAY LONGINT:C221($pos; 0)
		ARRAY LONGINT:C221($len; 0)
		
		$length:=This:C1470._getDataLength($values)
		$width:=This:C1470._getDataWidth($values)
		
		If ($sharedStrings.exists)
			$sharedStringsCollection:=New collection:C1472
			$xml:=$sharedStrings.getText("utf-8"; Document with LF:K24:22)
			$domSharedStrings:=DOM Parse XML variable:C720($xml)
			If (OK=1)
				$isSharedStringsOpen:=True:C214
				$sst:=DOM Find XML element:C864($domSharedStrings; "/sst")
				DOM GET XML ATTRIBUTE BY NAME:C728($sst; "count"; $count)
				DOM GET XML ATTRIBUTE BY NAME:C728($sst; "uniqueCount"; $uniqueCount)
				ARRAY TEXT:C222($sis; 0)
				$si:=DOM Find XML element:C864($sst; "si"; $sis)
				If (OK=1)
					For ($i; 1; Size of array:C274($sis))
						$si:=$sis{$i}
						ARRAY TEXT:C222($ts; 0)
						$t:=DOM Find XML element:C864($si; "t"; $ts)
						If (OK=1)
							DOM GET XML ELEMENT VALUE:C731($t; $stringValue)
							$hash:=Generate digest:C1147($stringValue; MD5 digest:K66:1)
							$index:=$sharedStringsCollection.length  //0-based
							$sharedStringsCollection.push(New object:C1471(\
								"hash"; $hash; \
								"value"; $stringValue; \
								"index"; $index))
						Else 
							$sharedStringsCollection.push(Null:C1517)
						End if 
					End for 
				End if 
			End if 
		End if 
		
		$sheet:=This:C1470._workFolder\
			.folder("xl")\
			.folder("worksheets")\
			.file(New collection:C1472("sheet"; $sheetIndex; ".xml").join(""))
		
		If ($sheet.exists)
			$xml:=$sheet.getText("utf-8"; Document with LF:K24:22)
			$dom:=DOM Parse XML variable:C720($xml)
			If (OK=1)
				
				$dimension:=DOM Find XML element:C864($dom; "/worksheet/dimension")
				If (OK=1)
					$ref:=""
					DOM GET XML ATTRIBUTE BY NAME:C728($dimension; "ref"; $ref)
					If (Match regex:C1019("([A-Z]+)(\\d+):([A-Z]+)(\\d+)"; $ref; 1; $pos; $len))
						$firstCell:=Substring:C12($ref; $pos{1}; $len{1})
						$firstRow:=Num:C11(Substring:C12($ref; $pos{2}; $len{2}))
						$lastCell:=Substring:C12($ref; $pos{3}; $len{3})
						$lastRow:=Num:C11(Substring:C12($ref; $pos{4}; $len{4}))
						$rowsToAppend:=$length-$lastRow
						$o:=New object:C1471
						$o[$lastCell+"1"]:=Null:C1517
						$lastCol:=This:C1470._getDataWidth($o)
						$colsToAppend:=$width-$lastCol
						$ref:=New collection:C1472($firstCell; $firstRow; ":"; $lastCell; $length).join("")
						DOM SET XML ATTRIBUTE:C866($dimension; "ref"; $ref)
						$sheetData:=DOM Find XML element:C864($dom; "/worksheet/sheetData")
						If (OK=1)
							ARRAY TEXT:C222($rows; 0)
							$row:=DOM Find XML element:C864($sheetData; "row"; $rows)
							If (OK=1)
								$row:=$rows{Size of array:C274($rows)}  //use last row as style template
								For ($ii; 1; DOM Count XML attributes:C727($row))
									DOM GET XML ATTRIBUTE BY INDEX:C729($row; $ii; $name; $stringValue)
									Case of 
										: ($name="r")
											
											$rowStyle:=New object:C1471
											
											For ($iii; 1; DOM Count XML attributes:C727($row))
												DOM GET XML ATTRIBUTE BY INDEX:C729($row; $iii; $name; $stringValue)
												If ($name#"r")
													$rowStyle[$name]:=$stringValue
												End if 
											End for 
											
											ARRAY TEXT:C222($cols; 0)
											$col:=DOM Find XML element:C864($row; "c"; $cols)
											
											$styles:=New object:C1471
											
											For ($iii; 1; Size of array:C274($cols))
												$col:=$cols{$iii}
												$style:=New object:C1471
												For ($ii; 1; DOM Count XML attributes:C727($col))
													DOM GET XML ATTRIBUTE BY INDEX:C729($col; $ii; $name; $stringValue)
													If ($name="r")
														If (Match regex:C1019("([A-Z]+)(\\d+)"; $stringValue; 1; $pos; $len))
															$cell:=Substring:C12($stringValue; $pos{1}; $len{1})
															$styles[$cell]:=$style
														End if 
													Else 
														$style[$name]:=$stringValue
													End if 
												End for 
											End for 
											
											$r:=String:C10($lastRow)
											
											For ($i; $lastCol+1; $lastCol+$colsToAppend)  //add cols to template row
												$node:=DOM Create XML element:C865($row; "c")
												$name:=This:C1470._getColName($i)
												DOM SET XML ATTRIBUTE:C866($node; "r"; $name+$r)
											End for 
											
											For ($iii; $lastRow+1; $lastRow+$rowsToAppend)  //append rows
												
												$r:=String:C10($iii)
												$row:=DOM Create XML element:C865($sheetData; "row")
												
												For each ($name; $rowStyle)  //except r
													DOM SET XML ATTRIBUTE:C866($row; $name; $rowStyle[$name])
												End for each 
												DOM SET XML ATTRIBUTE:C866($row; "r"; $r)
												
												For each ($name; $styles)  //copy from style template
													$node:=DOM Create XML element:C865($row; "c")
													DOM SET XML ATTRIBUTE:C866($node; "r"; $name+$r)
													$style:=$styles[$name]
													For each ($attribute; $style)
														DOM SET XML ATTRIBUTE:C866($node; $attribute; $style[$attribute])
													End for each 
												End for each 
												
												For ($i; $lastCol+1; $lastCol+$colsToAppend)  //add cols
													$node:=DOM Create XML element:C865($row; "c")
													$name:=This:C1470._getColName($i)
													DOM SET XML ATTRIBUTE:C866($node; "r"; $name+$r)
												End for 
												
											End for 
											
											break
									End case 
								End for 
							End if 
						End if 
					End if 
				End if 
				
				//get cells
				$sheetData:=DOM Find XML element:C864($dom; "/worksheet/sheetData")
				If (OK=1)
					ARRAY TEXT:C222($rows; 0)
					$row:=DOM Find XML element:C864($sheetData; "row"; $rows)
					If (OK=1)
						For ($i; 1; Size of array:C274($rows))
							$row:=$rows{$i}
							ARRAY TEXT:C222($cs; 0)
							$c:=DOM Find XML element:C864($row; "c"; $cs)
							If (OK=1)
								
								For ($ii; 1; Size of array:C274($cs))
									$c:=$cs{$ii}
									
									$cellRef:=This:C1470._getCellRef($c; "r")
									
									If (OB Is defined:C1231($values; $cellRef))
										$valueType:=Value type:C1509($values[$cellRef])
										
										Case of 
											: ($valueType=Is object:K8:27)
												
												If ($values[$cellRef].ca#Null:C1517)
													//undocumented microsoft excel dirty attribute
													DOM SET XML ATTRIBUTE:C866($c; "ca"; Num:C11($values[$cellRef].ca))
												End if 
												
												If ($values[$cellRef].f#Null:C1517) && ($values[$cellRef].v#Null:C1517)
													
													//f must come first
													$f:=This:C1470._removeElement($c; "f")._getElement($c; "f")
													
													DOM SET XML ELEMENT VALUE:C868($f; $values[$cellRef].f)
													
													$v:=This:C1470._removeElement($c; "v")._getElement($c; "v")
													
													$valueValueType:=Value type:C1509($values[$cellRef].v)
													
													Case of 
														: (($valueValueType=Is text:K8:3) || ($valueValueType=Is null:K8:31)) & ($isSharedStringsOpen)
															
															DOM SET XML ATTRIBUTE:C866($c; "t"; "str")  //static text
															If ($valueValueType=Is text:K8:3)
																DOM SET XML ELEMENT VALUE:C868($v; $values[$cellRef].v)
															Else 
																DOM SET XML ELEMENT VALUE:C868($v; "")
															End if 
															
														: ($valueValueType=Is real:K8:4)
															
															This:C1470._removeAttribute($c; "t")
															DOM SET XML ELEMENT VALUE:C868($v; Num:C11($values[$cellRef].v))
															
														: ($valueValueType=Is boolean:K8:9)
															
															DOM SET XML ATTRIBUTE:C866($c; "t"; "b")
															DOM SET XML ELEMENT VALUE:C868($v; Num:C11($values[$cellRef].v ? 1 : 0))
															
														: ($valueValueType=Is date:K8:7)
															
															This:C1470._removeAttribute($c; "t")
															DOM SET XML ELEMENT VALUE:C868($v; This:C1470.convertToMicrosoftDate($values[$cellRef].v))
															
														Else 
															TRACE:C157  //invalid value type!
													End case 
													
												End if 
												
											: (($valueType=Is text:K8:3) || ($valueType=Is null:K8:31)) & ($isSharedStringsOpen)
												
												$v:=This:C1470._removeElement($c; "f")._getElement($c; "v")
												
												If ($valueType=Is text:K8:3)
													$stringValue:=String:C10($values[$cellRef])
												Else 
													$stringValue:=""
												End if 
												
												For each ($ASCII; New collection:C1472(0x0010))
													$stringValue:=Replace string:C233($stringValue; Char:C90($ASCII); ""; *)
												End for each 
												
												$hash:=Generate digest:C1147($stringValue; MD5 digest:K66:1)
												$find:=$sharedStringsCollection.query("hash === :1"; $hash)
												If ($find.length=0)
													$count:=$count+1
													$uniqueCount:=$uniqueCount+1
													$index:=$sharedStringsCollection.length
													$sharedStringsCollection.push(New object:C1471(\
														"hash"; $hash; \
														"value"; $stringValue; \
														"index"; $index))
													$si:=DOM Create XML element:C865($sst; "si")
													$t:=DOM Create XML element:C865($si; "t")
													DOM SET XML ELEMENT VALUE:C868($t; $stringValue)
													$phoneticPr:=DOM Create XML element:C865($si; "phoneticPr")
													DOM SET XML ATTRIBUTE:C866($phoneticPr; "fontId"; 1)
												Else 
													$index:=$sharedStringsCollection[($find[0].index)].index
												End if 
												
												DOM SET XML ATTRIBUTE:C866($c; "t"; "s")  //shared string
												DOM SET XML ELEMENT VALUE:C868($v; $index)
												
												If (True:C214)
													OK:=1
													DOM SET XML ATTRIBUTE:C866($sst; "count"; $count; "uniqueCount"; $uniqueCount)
													$path:=$sharedStrings.platformPath
													DOM EXPORT TO FILE:C862($domSharedStrings; $path)
													If (OK=0)
														TRACE:C157
													End if 
												End if 
												
											: ($valueType=Is real:K8:4)
												
												$v:=This:C1470._removeElement($c; "f")._getElement($c; "v")
												
												This:C1470._removeAttribute($c; "t")
												DOM SET XML ELEMENT VALUE:C868($v; Num:C11($values[$cellRef]))
												
											: ($valueType=Is boolean:K8:9)
												
												//f must come first
												$f:=This:C1470._removeElement($c; "f")._getElement($c; "f")
												
												DOM SET XML ELEMENT VALUE:C868($f; $values[$cellRef] ? "TRUE()" : "FALSE()")
												
												$v:=This:C1470._removeElement($c; "v")._getElement($c; "v")
												
												DOM SET XML ATTRIBUTE:C866($c; "t"; "b")
												DOM SET XML ELEMENT VALUE:C868($v; $values[$cellRef] ? 1 : 0)
												
											: ($valueType=Is date:K8:7)
												
												$v:=This:C1470._removeElement($c; "f")._getElement($c; "v")
												
												This:C1470._removeAttribute($c; "t")
												DOM SET XML ELEMENT VALUE:C868($v; This:C1470.convertToMicrosoftDate($values[$cellRef]))
												
											Else 
												TRACE:C157  //invalid value type!
										End case 
									End if 
									
								End for 
							End if 
						End for 
						$success:=True:C214
					End if 
				End if 
				
				$path:=$sheet.platformPath
				DOM EXPORT TO FILE:C862($dom; $path)
				DOM CLOSE XML:C722($dom)
			End if 
		End if 
		
		If ($isSharedStringsOpen)
			DOM SET XML ATTRIBUTE:C866($sst; "count"; $count; "uniqueCount"; $uniqueCount)
			$path:=$sharedStrings.platformPath
			DOM EXPORT TO FILE:C862($domSharedStrings; $path)
			DOM CLOSE XML:C722($domSharedStrings)
		End if 
		
		If (This:C1470.fullCalcOnLoad)
			This:C1470._setFullCalcOnLoad()
		End if 
		
		This:C1470._deleteCalcChain()
		
	End if 
	//%W+550.26
	
	return New object:C1471("success"; $success)
	
Function _getColName($col : Integer) : Text
	
	$alphabet:="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	If ($col>Length:C16($alphabet))
		return This:C1470._getColName(($col-($col%Length:C16($alphabet)))\Length:C16($alphabet))+Substring:C12($alphabet; $col%Length:C16($alphabet); 1)
	Else 
		return Substring:C12($alphabet; $col; 1)
	End if 
	
Function _getDataWidth($values : Object) : Integer
	
	var $width; $colNumber : Integer
	var $cellRef : Text
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	$alphabet:="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	For each ($cellRef; $values)
		If (Match regex:C1019("(\\D+)\\d+"; $cellRef; 1; $pos; $len))
			$colNumber:=0
			$digit:=0
			For each ($letter; Split string:C1554(Substring:C12($cellRef; $pos{1}; $len{1}); "").reverse())
				$colNumber+=(Position:C15($letter; $alphabet; *)*(Length:C16($alphabet)^$digit))
				$digit+=1
			End for each 
			If ($colNumber>$width)
				$width:=$colNumber
			End if 
		End if 
	End for each 
	
	return $width
	
Function _getDataLength($values : Object) : Integer
	
	var $length; $rowNumber : Integer
	var $cellRef : Text
	
	ARRAY LONGINT:C221($pos; 0)
	ARRAY LONGINT:C221($len; 0)
	
	For each ($cellRef; $values)
		If (Match regex:C1019("\\D+(\\d+)"; $cellRef; 1; $pos; $len))
			$rowNumber:=Num:C11(Substring:C12($cellRef; $pos{1}; $len{1}))
			If ($rowNumber>$length)
				$length:=$rowNumber
			End if 
		End if 
	End for each 
	
	return $length
	
Function _getCellRef($dom : Text; $attributeName : Text) : Text
	
	var $attribute; $stringValue : Text
	For ($i; 1; DOM Count XML attributes:C727($dom))
		DOM GET XML ATTRIBUTE BY INDEX:C729($dom; $i; $attribute; $stringValue)
		If ($attribute=$attributeName)
			return $stringValue
		End if 
	End for 
	
Function _getElement($dom : Text; $elementName : Text)
	
	$element:=DOM Find XML element:C864($dom; $elementName)
	If (OK=0)
		$element:=DOM Create XML element:C865($dom; $elementName)
	End if 
	
	return $element
	
Function _removeElement($dom : Text; $elementName : Text) : Object
	
	$element:=DOM Find XML element:C864($dom; $elementName)
	If (OK=1)
		DOM REMOVE XML ELEMENT:C869($element)
	End if 
	
	return This:C1470
	
Function _removeAttribute($dom : Text; $attributeName : Text)
	
	var $attribute; $stringValue : Text
	For ($i; 1; DOM Count XML attributes:C727($dom))
		DOM GET XML ATTRIBUTE BY INDEX:C729($dom; $i; $attribute; $stringValue)
		If ($attribute=$attributeName)
			DOM REMOVE XML ATTRIBUTE:C1084($dom; $attributeName)
			break
		End if 
	End for 
	
Function _deleteCalcChain()
	
	//%W-550.26
	$calcChain:=This:C1470._workFolder\
		.folder("xl")\
		.file("calcChain.xml")
	
	If ($calcChain.exists)
		$calcChain.delete()
	End if 
	//%W+550.26
	
Function _setFullCalcOnLoad()
	
	//%W-550.26
	$workbook:=This:C1470._workFolder\
		.folder("xl")\
		.file("workbook.xml")
	If ($workbook.exists)
		$xml:=$workbook.getText("utf-8"; Document with LF:K24:22)
		$dom:=DOM Parse XML variable:C720($xml)
		If (OK=1)
			$calcPr:=DOM Find XML element:C864($dom; "/workbook/calcPr")
			If (OK=1)
				DOM SET XML ATTRIBUTE:C866($calcPr; "fullCalcOnLoad"; 1)
				DOM SET XML ATTRIBUTE:C866($calcPr; "calcMode"; "auto")
				This:C1470._removeAttribute($calcPr; "calcId")
			End if 
			$workbookPr:=DOM Find XML element:C864($dom; "/workbook/workbookPr")
			If (OK=1)
				DOM SET XML ATTRIBUTE:C866($workbookPr; "updateLinks"; "always")
				DOM SET XML ATTRIBUTE:C866($workbookPr; "saveExternalLinkValues"; 0)
			End if 
			$path:=$workbook.platformPath
			DOM EXPORT TO FILE:C862($dom; $path)
			DOM CLOSE XML:C722($dom)
		End if 
	End if 
	//%W+550.26