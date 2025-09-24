$proceso ="Notepad"
if (Get-Process -Name $proceso -ErrorAction SilentlyContinue) {Write-Output "$proceso esta en ejecución"}

