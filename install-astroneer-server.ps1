Param($ownerName, $serverName, $maxFPS, $serverPassword)
#Param($ownerName, $serverName, $maxFPS, $serverPassword, [switch]$installAsService)

#https://stackoverflow.com/questions/150161/waiting-for-user-input-with-a-timeout
Function TimedPrompt($prompt,$secondsToWait){   
    Write-Host -NoNewline $prompt
    $secondsCounter = 0
    $subCounter = 0
    While ( (!$host.ui.rawui.KeyAvailable) -and ($count -lt $secondsToWait) ){
        start-sleep -m 10
        $subCounter = $subCounter + 10
        if($subCounter -eq 1000)
        {
            $secondsCounter++
            $subCounter = 0
            Write-Host -NoNewline "."
        }       
        If ($secondsCounter -eq $secondsToWait) { 
            Write-Host "`r`n"
            return $false;
        }
    }
    Write-Host "`r`n"
    return $true;
}


$version = "1.1.9"
Write-Host "install-astroneer-server $version"

while ( $ownerName -eq $null ) { 
    $ownerName = Read-Host -Prompt "Enter Owner's Steam Name "
    if (!$ownerName) { 
        Write-Warning -Message "No Steam Name Given.  Try again."
    }
}

while ( $serverName -eq $null ) { 
    $serverName = Read-Host -Prompt "Enter Server Name "
    if (!$serverName) { 
        Write-Warning -Message "No Server Name Given.  Try again."
    }
}

while ( $maxFPS -eq $null ) { 
    $maxFPS = Read-Host -Prompt "Enter Server Max FPS "
    if (!$maxFPS) { 
        Write-Warning -Message "No Max FPS Given Given.  Use 30 if you're unsure."
    }
}


if ( $serverPassword -eq $null ) { 
    $serverPassword = Read-Host -Prompt "Enter Server Password or leave blank"
    if (!$serverPassword) { 
        Write-Warning -Message "Your server is starting without a password.  BEWARE."
    }
}

#while ( $installAsService -eq $null ) {
#    $installAsService = $true
#    Write-Host 
#    $service = Read-Host -Prompt "Would you like to install Astroneer as an Always-On Service? [Y/n]"
#    if ($service -eq "Y" -or $service -eq "y" -or $service -eq "") { 
#        Write-Host "Okay, installing as a service"
#        http://nssm.cc/release/nssm-2.24.zip 
#}
    
Write-Host "ASTRO CONFIG"
Write-Host "Owner Name: [$ownerName]"
Write-Host "Server Name: [$serverName]"
Write-Host "Max FPS: [$maxFPS]"
Write-Host "Server Password: [$serverPassword]"

Write-Host "Installing DotNet Framework"
$dotNetResult = Install-WindowsFeature Net-Framework-Core
if (-not $dotNetResult.RestartNeeded -eq "No") {
  Write-Warning -Message "A reboot will be required after this installation is complete before Astroneer Dedicated Server will be functional."
  $reboot = $true
}
else {
  $reboot = $false
}

Write-Host "Installing SteamCMD"
$nuGetResult = Install-PackageProvider NuGet -Force
Set-PSRepository PSGallery -InstallationPolicy Trusted
$steamPSResult = Install-Module -Name SteamPS
$steamCMDResult = Install-SteamCMD -Force

Write-Host "Installing ASTRONEER Dedicated Server"
mkdir C:\SteamServers\
Update-SteamApp -AppID 728470 -Path "C:\SteamServers\Astrnoeer" -Force
#rm "C:\SteamServers\Astroneer\Astro\Saved\Config\Windows Server\AstroServerSettings.ini"
# Run Astro in background

$configFile = "C:\SteamServers\astrnoeer\Astro\Saved\Config\WindowsServer\AstroServerSettings.ini"
$engineFile = "C:\SteamServers\astrnoeer\Astro\Saved\Config\WindowsServer\Engine.ini"

Write-Host "Running UE4 Prerequisite Setup"
C:\SteamServers\astrnoeer\Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe /silent

Write-Host "Generating Astroneer Config Files"
C:\SteamServers\astrnoeer\AstroServer.exe /q

Write-Host "Sleeping until the config file shows up"
while (!(Test-Path $configFile)) { 
    Start-Sleep 10
    # if astro server isn't running, try starting it
    Wait-Process -Name "AstroServer.exe" -ErrorAction SilentlyContinue -TimeoutSec 30
    C:\SteamServers\astrnoeer\AstroServer.exe        
}

Write-Host "Waiting for config file to populate"
if ( (get-childitem $configFile).length -eq 0 ) {
    Start-Sleep 10
}

Write-Host "Waiting for Astro to die"
Wait-Process -Name "AstroServer.exe" -ErrorAction SilentlyContinue
Write-Host "Astro is dead!  Continuing..."
# Astro is dead by now

Write-Host "Modifying Config File"

# Two blank lines signifies the end of the config file.  So we need to remove them for now
(Get-Content $configFile) | ? {$_.trim() -ne "" } | Set-Content $configFile
(Get-Content $engineFile) | ? {$_.trim() -ne "" } | Set-Content $engineFile

$publicIP = Invoke-RestMethod -Uri 'http://ifconfig.me/ip'

Write-Host "Setting Public IP: $publicIP"
Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "PublicIP=" -NotMatch)
Add-Content $configFile "PublicIP=$publicIP"

Write-Host "Setting Max FPS: $maxFPS"
Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "MaxServerFramerate=*" -NotMatch)
Add-Content $configFile "MaxServerFramerate=$maxFPS.000000"

Write-Host "Setting Server Name: $serverName"
Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "ServerName=" -NotMatch)
Add-Content $configFile "ServerName=$serverName"

Write-Host "Setting Owner Name: $ownerName"
Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "OwnerName=" -NotMatch)
Add-Content $configFile "OwnerName=$ownerName"

Write-Host "Setting Port: 8777"
Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "[URL]" -NotMatch)
Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "Port=*" -NotMatch)
Add-Content $engineFile "`r`n`r`n[URL]`r`nPort=8777"

if ( $serverPassword -eq $null) {     
    
}
else {
    Write-Host "Setting Server Password"
    Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "ServerPassword=" -NotMatch)
    Add-Content $configFile "ServerPassword=$serverPassword"
}
# Put those two newlines back
Add-Content $configFile "`r`n`r`n"
Add-Content $engineFile "`r`n`r`n"

if ($reboot -eq $true) { 
    TimedPrompt "Press any key to abort reboot. Reboot will occur in 60 seconds." 60
    shutdown /r /t 01
}
else {
    Write-Host "Starting Astro Server.  Have fun!"
    Write-Host "If you need to make changes to the config file, ensure you kill the server first!"
    $WmiProcess = Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "C:\SteamServers\astrnoeer\AstroServer.exe"
}
