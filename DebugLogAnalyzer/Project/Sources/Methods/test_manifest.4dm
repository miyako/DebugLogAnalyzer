//%attributes = {}
$manifests:=[]
$manifests.push(File:C1566("Macintosh HD:Users:miyako:Desktop:test:Data:Logs:manifest.json"; fk platform path:K87:2))
$c:=cs:C1710._PluginCommandResolver.new($manifests)
$t:=$c.getInfo("1;613")