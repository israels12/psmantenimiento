# Script para PowerShell 5
# Autor: Israel Suárez
# Fecha: 23/04/2024

# Copiar las lineas de abajo comentadas e introducirlas manualmente en PowerShell 5
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Unblock-File -Path "C:\ruta_donde\se_guardo_el\scriptPS5.ps1"
# .\scriptPS5.ps1 -ExecutionPolicy Bypass


if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Host "Este Programa debe ejecutarse como administrador." -ForegroundColor Red
    Exit
}


# Importar el módulo Storage
Import-Module Storage
# Obtener el objeto de la unidad C:
$disk = Get-Volume -DriveLetter C
$carpetalog = "\Windows\Logs"



$limpieza = Read-Host '¿Desea realizar mantenimiento? [S/N]'
if($limpieza -eq 'S' -or $limpieza -eq 's'){
    Write-Host 'Presione 1 para Limpieza Standar 2 para Limpieza Profunda o 3 para Salir'
    $nivel = Read-Host "[1] Limpieza Standar `n[2] Limpieza a Fondo `n[3] Salir"
    if($nivel -eq 1){
        Set-Location \Windows\Temp
        Get-ChildItem | Remove-Item -Force -Recurse
        netsh winsock reset
        netsh int ip reset
        ipconfig /release
        ipconfig /renew Wi-Fi
        ipconfig /flushdns
        ipconfig /registerdns
        # Limpiar archivos temporales de Internet Explorer
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Force -Recurse
        # Vaciar la papelera de reciclaje
        Clear-RecycleBin -Force
        # Eliminar archivos temporales
        Remove-Item -Path "$env:TEMP\*" -Force -Recurse
        Stop-Process -Id $PID
    }
    elseif($nivel -eq 2){
        Set-Location $carpetalog
        Get-ChildItem -Path $carpetalog -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force
        Set-Location ..\Temp
        Get-ChildItem | Remove-Item -Force -Recurse
        netsh winsock reset
        netsh int ip reset
        ipconfig /release
        ipconfig /renew Wi-Fi
        ipconfig /flushdns
        ipconfig /registerdns
        # Limpiar archivos temporales de Internet Explorer
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Force -Recurse
        # Vaciar la papelera de reciclaje
        Clear-RecycleBin -Force
        # Eliminar archivos temporales
        Remove-Item -Path "$env:TEMP\*" -Force -Recurse
        # Analizar la unidad para determinar si necesita desfragmentación
        $analysis = Optimize-Volume -DriveLetter $disk.DriveLetter -Analyze
        if($analysis.DefragRecommended){
            Write-Host 'Se necesita Desfragmentar la unidad' -ForegroundColor Red
            Optimize-Volume -DriveLetter $disk.DriveLetter -Defrag -Verbose
        }
        else{
            Write-Host "No se necesita desfragmentación en la unidad." -ForegroundColor Green
        }
        $errores = Read-Host '¿Desea escanear el Disco Duro? [S/N]'
        if($errores -eq 'S' -or $errores -eq 's'){
            $issue = Get-Volume | Repair-Volume -Scan -ErrorAction SilentlyContinue | Where-Object { $_.OperationResult -ne "Succeeded" }
            if($issue -eq 'NoErrorsFound'){
                Write-Host "No se encontraron errores en el disco duro." -ForegroundColor Green
            }
            elseif($issue -eq 'ErrorsFound'){
                Write-Host "Se encontraron errores en el disco duro:" -ForegroundColor Red
                Write-Host "Se intentaron reparar:" -ForegroundColor Green
                $issue | Format-Table -AutoSize
                
            }
        }
        elseif($errores -eq 'N' -or $errores -eq 'n'){
           
        }
        else{
            Write-Host 'Operación Invalida'
        }
        chkdsk C: /F /R
        DISM /Online /Cleanup-Image /RestoreHealth
        sfc /scannow
        $reiniciar = Read-Host '¿Desea Reiniciar el equipo? [S/N]'
        if($reiniciar -eq 'S' -or $reiniciar -eq 's'){
            Write-Host "El equipo se REINICIARÁ. Por favor, GUARDA TÚ TRABAJO!!!.`nPresiona la Letra Y para confirmar" -ForegroundColor Red
            Restart-Computer -Force -Confirm
        }
        elseif($reiniciar -eq 'N' -or $reiniciar -eq 'n'){
            
        }
        else{
            Write-Host 'Operacion Invalida'
        }

        $apagarpc = Read-Host '¿Desea apagar el equipo? [S/N]'
        if($apagarpc -eq 'S' -or $apagarpc -eq 's'){
            Write-Host "El equipo se APAGARÁ!!!. Por favor, GUARDA TÚ TRABAJO!!!.`nPresiona la Letra Y para confirmar" -ForegroundColor Red
            Stop-Computer -Force -Confirm
        }
        elseif($apagarpc -eq 'N' -or $apagarpc -eq 'n'){
            
        }
        else{
            Write-Host 'Operacion Invalida'
        }
        Stop-Process -Id $PID
    }
    
    elseif($nivel -eq 3){
        break
    }

    else{
        Write-Host 'Operacion invalida'
    }
}

elseif($limpieza -eq 'N' -or $limpieza -eq 'n'){
    break
}
else{
    Write-Host 'Operacion Invalida'
}