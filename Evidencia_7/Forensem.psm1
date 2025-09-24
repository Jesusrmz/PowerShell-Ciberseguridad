Set-StrictMode -Version Latest

function Get-Forense {
    
    [CmdletBinding()]
    #Se define los parametros de la funcion.
    param (
	#parametro para el nombre del log, el [ValidateSet] se asegura que se acepten los valores de la lista.
        [Parameter(Mandatory=$true)]
        [ValidateSet('Security', 'System', 'Application')]
        [string]$LogName,
	
	#Parametro para la fecha de inicio
        [Parameter(Mandatory=$true)]
        [datetime]$StartDate,

	#Parametro para la fecha de fin
        [Parameter(Mandatory=$true)]
        [datetime]$EndDate,

	#Parametro para la ruta de del archivo de salida
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,

	#Parametro para el formato de salida
        [Parameter(Mandatory=$true)]
        [ValidateSet('CSV', 'XML', 'HTML')]
        [string]$Format
    )
    #Se realiza que la fecha de fin no sea 
    if ($StartDate -gt $EndDate) {
        throw "La fecha de inicio no puede ser posterior a la fecha de fin."
    }
    
    #Se le informa al usuario que el proceso de extraccion ha comenzado
    Write-Host "Extrayendo eventos de '$LogName' entre $StartDate y $EndDate..."

    # Definir filtro con IDs específicos para Security
    if ($LogName -eq 'Security') {
        $filter = @{
            LogName   = $LogName
            StartTime = $StartDate
            EndTime   = $EndDate
            Id        = 4624,4625,4634,4720,4776,1102
        }
    }
    else {
        $filter = @{
            LogName   = $LogName
            StartTime = $StartDate
            EndTime   = $EndDate
        }
    }

    try {
	# Ejecuta el comando 'Get-WinEvent' con el filtro. '-ErrorAction SilentlyContinue' evita que un solo evento erróneo detenga todo el proceso.
        $events = Get-WinEvent -FilterHashtable $filter -ErrorAction SilentlyContinue |
                  ForEach-Object {

			# Inicia un bloque 'try/catch' anidado para manejar eventos individuales que puedan estar corruptos o ser ilegibles.
                      try {
                          $_ | Select-Object TimeCreated, Id, LevelDisplayName, Message, ProviderName
                      } catch {
                          Write-Warning "Evento dañado (ID=$($_.Id)) no se pudo procesar."
                      }
                  }

	# Verifica si la búsqueda anterior encontró algún evento.
        if ($events) {

	    # Si se encontraron eventos, informa al usuario cuántos se van a exportar.
            Write-Host "Exportando $(@($events).Count) eventos en formato $Format..."

            switch ($Format) {
                'CSV'  { $events | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8 }
                'XML'  { $events | Export-Clixml -Path $OutputPath }
                'HTML' {
                    $title = "Informe de Eventos - $LogName"
                    $head = "<title>$title</title><style>
                    body{font-family: Arial;} 
                    table{border-collapse: collapse;width: 100%;} 
                    th,td{border:1px solid #ddd;padding:8px;}
                    th{background:#4CAF50;color:white;} 
                    tr:nth-child(even){background:#f2f2f2;}
                    </style>"
                    $events | ConvertTo-Html -Head $head -PreContent "<h1>$title</h1><h2>Generado el $(Get-Date)</h2>" |
                    Out-File -FilePath $OutputPath -Encoding UTF8
                }
            }

	    # Informa al usuario que el informe se ha creado con éxito y dónde se encuentra.
            Write-Host "Informe guardado en: $OutputPath" -ForegroundColor Green
        } else {
            Write-Warning "No se encontraron eventos en el rango especificado."
        }
    }
    catch {
	# Si ocurre un error grave en el bloque 'try' principal, se captura aquí y se muestra.
        Write-Error "Error al extraer eventos: $_"
    }
}

# Exportar la función después de declararla
Export-ModuleMember -Function Get-Forense
