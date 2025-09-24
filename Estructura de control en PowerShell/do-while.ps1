$intento = 0
do {
	write-output "Revisando intento $intento"
	$intento++
} While($intento -lt 3)