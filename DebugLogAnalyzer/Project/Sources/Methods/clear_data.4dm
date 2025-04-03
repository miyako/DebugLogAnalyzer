//%attributes = {"invisible":true}
//TRUNCATE TABLE([Debug_Logs])
//TRUNCATE TABLE([Log_Lines])

//SET DATABASE PARAMETER([Debug_Logs]; Table sequence number; 0)
//SET DATABASE PARAMETER([Log_Lines]; Table sequence number; 0)

SET DATABASE PARAMETER:C642(Debug log recording:K37:34; 0)
//SET DATABASE PARAMETER(Debug log recording; 1 | 4)