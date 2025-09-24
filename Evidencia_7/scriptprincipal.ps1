Import-Module .\ModuloIPremotas.psm1
Import-Module .\ModuloForense.psm1
Import-Module .\Forensem.psm1

    $menu= @(
        write-host "----------Menu----------"
        '1: Registro de eventos'
        '2: Conexiones de red'
        '3: Procesos sospechosos'
        '4: Direcciones IP remotas'
        '5: Exit'
        write-host "------------------------"
    )

    foreach ($opcion in $menu) {
        Write-Host $opcion
    }
    write-host "------------------------"
    write-host "------------------------"

    $op= Read-Host 'Porfavor elige una opcion del menu (1-5)'

    switch ($op) {
        '1' { Get-Forense }
        '2' { Get-ProcessConnections }
        '3' {Get-SuspiciousProcesses}
        '4' { Get-IPRemotas }
        '5' { Write-Host 'Adios!'; break }
        default { Write-Host 'Opcion invalida porfavor elige una opcion que exista en el menu (1-5)' }
    }