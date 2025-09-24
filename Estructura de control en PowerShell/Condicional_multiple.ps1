$puerto = 80
if($puerto -eq 22){
	Write-output "Puerto SSH dectado"
} elseif($puerto -eq 80){
	Write-output "puerto HTTP dectado"
} else{
	Write-output "Otro puerto"
}