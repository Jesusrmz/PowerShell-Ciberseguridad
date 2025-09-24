function Get-IPRemotas {
    #verifica que el archivo csv con las IP's remotas existe
    if (-not (Test-Path -Path ".\ConnectionsReport.csv")) {
        Write-Host "No se encontraron los archivos .csv favor de verificar que se ejecuto la opcion 2 del menu correctamente"
        return 
    }

    $api = "3fedecd9ae5043dbc3f4cf2f1b62dc5c0c901a505df4148135eb209de4c6351fcc975d6a4532f1d5"

    $ips = Import-Csv .\ConnectionsReport.csv |
        Where-Object { $_.RemoteAddress -and $_.RemoteAddress -ne '::' -and $_.RemoteAddress -ne '127.0.0.1' } |
        Select-Object -ExpandProperty RemoteAddress -Unique

    $resultados = @()

    foreach ($ip in $ips) {
        try {
            #solicitud del API
            $response = Invoke-RestMethod -Uri "https://api.abuseipdb.com/api/v2/check?ipAddress=$ip&maxAgeInDays=90" `
                -Headers @{Key = $api; Accept = "application/json"} -Method GET

            # obtienes los datos de los resultados
            $data = $response.data

            # calcula los niveles de riesgo de las ip
            $nriesgo = switch ($data.abuseConfidenceScore) {
                { $_ -ge 71 } { "Alto"; break }
                { $_ -ge 21 } { "Medio"; break }
                default { "Bajo" }
            }

            # muestra los resultados
            $response.data | Format-List
            Write-Host "Nivel de Riesgo: $nriesgo"
            Write-Host "__________________________________________"

            # guardo los resultados en una lista
            $resultados += "" | Select-Object `
                @{Name = "IP"; Expression = { $data.ipAddress } },
                @{Name = "Score"; Expression = { $data.abuseConfidenceScore } },
                @{Name = "Riesgo"; Expression = { $nriesgo } }

        } catch {
            Write-Warning "Error al consultar $ip"
        }
    }

    #guardar los resultados en csv
    $resultados | Export-Csv -Path "Reporte_IPs.csv" -NoTypeInformation -Encoding UTF8
}
