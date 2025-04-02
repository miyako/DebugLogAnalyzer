$p:=cs:C1710._ClassicDebugLogParser.new(Form:C1466.logFile.item)
$option:=$p.start()  //use same option for circular logs
$p.continue()