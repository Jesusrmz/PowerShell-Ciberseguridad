
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Listar procesos activos con su ruta
Get-Process | Select-Object Name, Id, Path

#Filtrar procesos con ruta conocida
Get-Process | Where-Object {$_.Path} | Select-Object Name, Id, Path

# Obtener todas las conexiones TCP activas con PID
$connections = Get-NetTCPConnection | Where-Object {$_.OwningProcess} 

function Get-ProcessConnections {
<#
.SYNOPSIS
    Lista los procesos con sus conexiones de red.
.DESCRIPTION
    Correlaciona cada conexión TCP con el proceso que la generó,
    mostrando puertos abiertos y direcciones remotas.
.EXAMPLE
    Get-ProcessConnections
#>

    Get-NetTCPConnection | ForEach-Object {
        $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            ProcessName   = $proc.ProcessName
            ProcessId     = $_.OwningProcess
            LocalAddress  = $_.LocalAddress
            LocalPort     = $_.LocalPort
            RemoteAddress = $_.RemoteAddress
            RemotePort    = $_.RemotePort
            State         = $_.State
        }
    } | Sort-Object -Property ProcessName
}

function Get-SuspiciousProcesses {
<#
.SYNOPSIS
    Detecta procesos potencialmente sospechosos.
.DESCRIPTION
    Marca procesos que no tienen firma digital válida o
    que se ejecutan desde rutas inusuales.
.EXAMPLE
    Get-SuspiciousProcesses
#>

    Get-Process | ForEach-Object {
        $path = $_.Path
        if ($path) {
            $signature = Get-AuthenticodeSignature -FilePath $path
            $isSigned = ($signature.Status -eq "Valid")
            $isSuspiciousPath = ($path -like "*Temp*" -or $path -like "*Downloads*" -or $path -like "*Desktop*")

            if (-not $isSigned -or $isSuspiciousPath) {
                [PSCustomObject]@{
                    ProcessName = $_.ProcessName
                    Id          = $_.Id
                    Path        = $path
                    Signed      = $isSigned
                    SuspiciousPath = $isSuspiciousPath
                }
            }
        }
    }
}

Get-ProcessConnections | Export-Csv -Path "ConnectionsReport.csv" -NoTypeInformation
Get-SuspiciousProcesses | ConvertTo-Html | Out-File "SuspiciousProcesses.html"
Get-ProcessConnections | Export-Clixml "ConnectionsReport.xml"

