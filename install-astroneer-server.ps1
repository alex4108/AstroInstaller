Param($ownerName, $serverName, $maxFPS, $serverPassword, $useGUI, $autoReboot, $installPath)
Start-Transcript -Path "$PSScriptRoot\AstroInstaller.log" -Append
#Param($ownerName, $serverName, $maxFPS, $serverPassword, [switch]$installAsService)


$version = "2.1.2"
Write-Host "AstroInstaller $version"

# Detect Windows Server or Windows 10 
$edition = (Get-WindowsEdition -Online).Edition
if ($edition -like "*Server*") { 
    $windowsServer = $true;
} else {
    $windowsServer = $false;
}
Write-Host "OS: [$edition]"
Write-Host "IsWindowsServer: [$windowsServer]"


while ( $null -eq $ownerName -or $ownerName -eq "" ) { 
    $ownerName = Read-Host -Prompt "Enter Owner's Steam Name"
    if ($null -eq $ownerName -or $ownerName -eq "") { 
        Write-Warning -Message "No Steam Name Given.  Try again."
    }
}

while ( $null -eq $serverName ) { 
    $serverName = Read-Host -Prompt "Enter Server Name"
    if (!$serverName) { 
        Write-Warning -Message "No Server Name Given.  Try again."
        $serverName = $null
    }
}

while ( $null -eq $maxFPS ) { 
    $maxFPS = Read-Host -Prompt "Enter Server Max FPS"
    if (!$maxFPS) { 
        Write-Warning -Message "No Max FPS Given Given.  Use 30 if you're unsure."
        $maxFPS = $null
    }
}

if ( $null -eq $serverPassword ) { 
    $serverPassword = Read-Host -Prompt "Enter Server Password or leave blank"
    if (!$serverPassword) { 
        Write-Warning -Message "Your server is starting without a password.  BEWARE."
    }
}

while ( $useGUI -ne 'y' -and $useGUI -ne 'n' ) { 
    $useGUI = Read-Host -Prompt "Use AstroLauncher GUI for Management (RECOMMENDED) [y/n]"
    if ($useGUI -eq 'y') { 
        $useGUI = $true
        break
    }
    elseif ($useGUI -eq 'n') { 
        $useGUI = $false
        break
    }
    else {
        Write-Warning -Message "Enter y or n"
    }
}


if ($useGUI -eq 'y') { 
    $useGUI = $true
}

if ($autoReboot -eq 'y') { 
    $autoReboot = $true
}
else {
    $autoReboot = $false
}


if ($installPath -eq $null) { 
    $installPath = "C:\SteamServers"
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
Write-Host "AstroLauncher GUI: [$useGUI]"

Write-Host "Installing DotNet Framework"
if ( $windowsServer -eq $true ) { 
    $dotNetResult = Install-WindowsFeature Net-Framework-Core
    if ($dotNetResult.RestartNeeded -ne "No") {
        Write-Warning -Message "A reboot will be required before Astroneer Dedicated Server will be functional."
        $reboot = $true
    } else {
        $reboot = $false
    }
} else {
    
    $dotNetResult = Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"
    if ($dotNetResult.RestartNeeded -eq $true) {
        Write-Warning -Message "A reboot will be required before Astroneer Dedicated Server will be functional."
        $reboot = $true
    } else {
        $reboot = $false
    }
}

Write-Host "Installing SteamCMD"
$registerPSResult = Register-PSRepository -Default -ErrorAction SilentlyContinue
$nuGetResult = Install-PackageProvider NuGet -Force
Set-PSRepository PSGallery -InstallationPolicy Trusted
$steamPSResult = Install-Module -Name SteamPS
$steamCMDResult = Install-SteamCMD -Force

Write-Host "Installing ASTRONEER Dedicated Server"
mkdir $installPath
Update-SteamApp -AppID 728470 -Path "$installPath\Astroneer" -Force

$configFile = "$installPath\Astroneer\Astro\Saved\Config\WindowsServer\AstroServerSettings.ini"
$engineFile = "$installPath\Astroneer\Astro\Saved\Config\WindowsServer\Engine.ini"

Write-Host "Running Unreal Engine 4 Prerequisite Setup"
# So even though we instal the prereq's, AstroServer is totally unaware.
Start-Process -FilePath "$installPath\Astroneer\Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe" -ArgumentList "/uninstall /passive" -WorkingDirectory $installPath | Get-Process
Start-Process -FilePath "$installPath\Astroneer\Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe"  -ArgumentList "/install /passive" -WorkingDirectory $installPath | Get-Process

# So now we need to start AstroServer.  It won't generate config files, it will ask to install dependencies that are ALREADY PRESENT.
Write-Warning "Getting AstroServer ready..."
netsh advfirewall firewall add rule name="AstroServer" dir=in action=allow program="$installPath\Astroneer\AstroServer.exe"
netsh advfirewall firewall add rule name="AstroServer" dir=in action=allow program="$installPath\Astroneer\astro\binaries\win64\astroserver-win64-shipping.exe"
# This one silences a popup for dependncies that are already installed
Write-Host "Start Astroneer..."
$proc = Start-Process -filePath "$installPath\Astroneer\AstroServer.exe" -WorkingDirectory "$installPath\Astroneer\" -PassThru
$proc | Wait-Process -Timeout 30 -ErrorAction SilentlyContinue 
# Kill AstroServer.exe if it's not dead yet
Write-Host "Kill Astroneer..."
Stop-Process $proc

# This one lets astro generate the config files
Write-Host "Start Astroneer..."
$proc = Start-Process -filePath "$installPath\Astroneer\AstroServer.exe" -WorkingDirectory "$installPath\Astroneer\" -PassThru
$proc | Wait-Process -Timeout 30 -ErrorAction SilentlyContinue 
# Kill AstroServer.exe if it's not dead yet
Write-Host "Kill Astroneer..."
Stop-Process $proc

# Now we can continue
Write-Host "Sleeping until the config file shows up"
while (!(Test-Path $configFile)) { 
    Start-Sleep 10
    Write-Host "."
}
Write-Host "Config File Exists!"

Write-Host "Waiting for config file to populate"
while ( (get-childitem $configFile).length -eq 10 ) {
    Start-Sleep 10
    Write-Host "."
}
Write-Host "Config file has data!"
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
Set-Content -Path $engineFile -Value (get-content -Path $engineFile | Select-String -Pattern "[URL]" -NotMatch)
Set-Content -Path $engineFile -Value (get-content -Path $engineFile | Select-String -Pattern "Port=*" -NotMatch)
Add-Content $engineFile "`r`n`r`n[URL]`r`nPort=8777"


if ( $serverPassword -eq $null) {     
    
} else {
    Write-Host "Setting Server Password"
    Set-Content -Path $configFile -Value (get-content -Path $configFile | Select-String -Pattern "ServerPassword=" -NotMatch)
    Add-Content $configFile "ServerPassword=$serverPassword"
}
# Put those two newlines back
Add-Content $configFile "`r`n`r`n"
Add-Content $engineFile "`r`n`r`n"

# Install AstroLauncher
if ($useGUI -eq $true) {
    Write-Host "Downloading AstroLauncher"
    $repo = "ricky-davis/AstroLauncher"
    $filename = "AstroLauncher.exe"
    $releasesUri = "https://api.github.com/repos/$repo/releases/latest"
    $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $filename ).browser_download_url
    $iwrResponse = Invoke-WebRequest -Uri $downloadUri -OutFile "$installPath\Astroneer\AstroLauncher.exe" -PassThru -UseBasicParsing
}

Write-Host "Adding Firewall Exceptions for port 8777 UDP"
netsh advfirewall firewall add rule name="AstroServer" dir=in action=allow protocol=UDP localport=8777

if ($reboot -eq $true) {
    Write-Warning "Reboot scheduled for 60 seconds!"
    if ($useGUI -eq $true) {
        Write-Warning "When you come back, go to $installPath\Astroneer\ and run AstroLauncher.exe"
    } else {
        Write-Warning "When you come back, go to $installPath\Astroneer\ and run AstroServer.exe"
    }
    if ($autoReboot -eq $true) { 
        Write-Warning "System reboot scheduled for 60 seconds from now."
        shutdown /r /t 60
    } else {
        $data = Read-Host -Prompt "Press ENTER to reboot."
        shutdown /r /t 60
    }
    
} else {
    Write-Host "Starting AstroServer.  Have fun!"
    if ($useGUI -eq $true) {
        Write-Host "Adding Firewall Exception for AstroLauncher TCP 5000"
        netsh advfirewall firewall add rule name="AstroLauncher" dir=in action=allow program="$installPath\Astroneer\AstroLauncher.exe"
        netsh advfirewall firewall add rule name="AstroLauncher" dir=in action=allow protocol=TCP localport=5000
        $WmiProcess = Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "$installPath\Astroneer\AstroLauncher.exe -p $installPath\Astroneer\"
        Write-Host "AstroLauncher should be available at http://localhost:5000"
        Write-Warning "AstroLauncher is listening on 0.0.0.0:5000 by default.  Check your firewall rules to limit access if needed!"
    } else {
        Write-Host "If you need to make changes to the config file, ensure you kill the server first!"
        $WmiProcess = Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "$installPath\Astroneer\AstroServer.exe"
    }
}
Write-Host "Installation is completed!  This script will exit in 2 minutes"

Start-Sleep 120
Stop-Transcript
