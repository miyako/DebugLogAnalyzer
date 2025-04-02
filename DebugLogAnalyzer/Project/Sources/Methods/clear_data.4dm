//%attributes = {"invisible":true}
//TRUNCATE TABLE([Debug_Logs])
//TRUNCATE TABLE([Log_Lines])

//SET DATABASE PARAMETER([Debug_Logs]; Table sequence number; 0)
//SET DATABASE PARAMETER([Log_Lines]; Table sequence number; 0)

cs:C1710._ClassicDebugLogParser.new()
