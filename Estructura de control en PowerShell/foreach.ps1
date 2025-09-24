$procesos = Get-Process | Select-Object -First 3
foreach($p in $procesos) {
	Write-Output $p.ProcessName
}