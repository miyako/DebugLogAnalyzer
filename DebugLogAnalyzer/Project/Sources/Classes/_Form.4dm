property countCores : Integer
property isInterpretedMode : Boolean
property isRunning : Boolean
property updateIntervalUnit : Integer
property useMultipleCores : Boolean

Class constructor
	
	This:C1470.countCores:=System info:C1571.cores
	If (This:C1470.countCores>3)
		This:C1470.countCores-=2  //save for UI and system
	Else 
		This:C1470.countCores:=1
	End if 
	
	This:C1470.isInterpretedMode:=Not:C34(Is compiled mode:C492)
	This:C1470.isRunning:=False:C215
	This:C1470.updateIntervalUnit:=This:C1470.isInterpretedMode ? 200 : 100  //every 0.1 seconds
	This:C1470.useMultipleCores:=False:C215
	
Function launch($file : 4D:C1709.File) : cs:C1710._Form
	
	OPEN URL:C673($file.platformPath)
	
	return This:C1470
	
Function show($file : 4D:C1709.File) : cs:C1710._Form
	
	SHOW ON DISK:C922($file.platformPath)
	
	return This:C1470