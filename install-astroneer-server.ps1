<#
.Synopsis
Deploys an application from current folder to kubernetes cluster.
.Description
https://github.com/alex4108/AstroInstaller
.Parameter ownerName
Astroneer server owner steam name
.Parameter serverName
Astroneer server name
.Parameter serverPort
Astroneer server UDP port. Default is 8777
.Parameter maxFPS
Maximum server FPS. Default is 30
.Parameter serverPassword
Server password. If ownerName, or sereverName or serverPasswords are not provided
on the command line, the script will ask for them interactively
.Parameter noServerPassword
Suppress password prompt if no server password was provided. Use it to run in 
non-interactive mode.
.Parameter noAstroLauncher
Disables use of AstroLauncher (not recommened)
.Parameter autoReboot
If depency installation requires a reboot, the script will automaticaly reboot the machine
.Parameter installPath
Path where to install steam applications. Defaults to "C:\SteamServers"
.Parameter noWait
Suppress 2 minutes wait after script finishes. Use it to run in non-interactive mode.
.Link
https://github.com/alex4108/AstroInstaller
#>
param(
  [string]$ownerName,
  [string]$serverName,
  [int]$serverPort = 8777,
  [string]$serverPassword,
  [switch]$noServerPassword,
  [string]$installPath = "C:\SteamServers",
  [int]$maxFPS = 30,
  [switch]$noAstroLauncher,
  [switch]$noService,
  [switch]$autoReboot,
  [switch]$noWait
)
#Requires -RunAsAdministrator

$installService = !$noService

if ($installService -eq $true) { 
    $nssm_build = "nssm-2.24-101-g897c7ad"
    $nssmUrl = "https://nssm.cc/ci/$nssm_build.zip"
}

$ErrorActionPreference = "Stop"
Start-Transcript -Path "$PSScriptRoot\AstroInstaller.log" -Append

$version = "2.1.5"
Write-Host "AstroInstaller $version"

# This is to workaround an issue with older .NET Framework where powershell cannot download Nuget provider because of the newer TLS cipher suits
if ($PSVersionTable.PSVersion.Major -lt 6) {

    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
}

# Detect Windows Server or Windows 10 
$edition = (Get-WindowsEdition -Online).Edition
if ($edition -like "*Server*") { 
    $windowsServer = $true;
} else {
    $windowsServer = $false;
}
Write-Host "OS: [$edition]"
Write-Host "IsWindowsServer: [$windowsServer]"


while ( !$ownerName ) { 
    $ownerName = Read-Host -Prompt "Enter Owner's Steam Name"
    if ($null -eq $ownerName -or $ownerName -eq "") { 
        Write-Warning -Message "No Steam Name Given.  Try again."
    }
}

while ( !$serverName ) { 
    $serverName = Read-Host -Prompt "Enter Server Name"
    if (!$serverName) { 
        Write-Warning -Message "No Server Name Given.  Try again."
        $serverName = $null
    }
}

if ( !$noServerPassword -and !$serverPassword ) { 
    $serverPasswordSecure = Read-Host -Prompt "Enter Server Password or leave blank" -AsSecureString
    $serverPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($serverPasswordSecure))
}

if (!$serverPassword) { 
    Write-Warning -Message "Your server is starting without a password.  BEWARE."
}

$useGUI = !$noAstroLauncher
    
Write-Host "ASTRO CONFIG"
Write-Host "Owner Name: [$ownerName]"
Write-Host "Server Name: [$serverName]"
Write-Host "Server Port: [$serverPort]"
Write-Host "Max FPS: [$maxFPS]"
Write-Host "AstroLauncher GUI: [$useGUI]"
Write-Host "Install Path: [$installPath]"
Write-Host "Install NSSM Service Manager: [$installService]"

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
netsh advfirewall firewall add rule name="AstroServer" dir=in action=allow program="$installPath\SteamCMD\steamcmd.exe" | Out-Null
# Invoking in a separate process so that .NET configuration changes at the top could be picked up
$nuGetResult = powershell -command "Install-PackageProvider NuGet -Force"
Set-PSRepository PSGallery -InstallationPolicy Trusted
$steamPSResult = Install-Module -Name SteamPS
$steamCMDResult = Install-SteamCMD -InstallPath $installPath -Force

Write-Host "Installing ASTRONEER Dedicated Server"
mkdir $installPath -Force | Out-Null
Start-Process -FilePath "$installPath\steamcmd\steamcmd.exe" -NoNewWindow -ArgumentList "+login anonymous +force_install_dir $installPath\Astroneer\ +app_update 728470 +quit" -Wait -PassThru


$configFile = "$installPath\Astroneer\Astro\Saved\Config\WindowsServer\AstroServerSettings.ini"
$engineFile = "$installPath\Astroneer\Astro\Saved\Config\WindowsServer\Engine.ini"

Write-Host "Running Unreal Engine 4 Prerequisite Setup"
# So even though we instal the prereq's, AstroServer is totally unaware.
$proc = Start-Process -FilePath "$installPath\Astroneer\Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe" -ArgumentList "/uninstall /passive" -WorkingDirectory $installPath -PassThru
$proc | Wait-Process
$proc = Start-Process -FilePath "$installPath\Astroneer\Engine\Extras\Redist\en-us\UE4PrereqSetup_x64.exe"  -ArgumentList "/install /passive" -WorkingDirectory $installPath -PassThru
$proc | Wait-Process

# So now we need to start AstroServer.  It won't generate config files, it will ask to install dependencies that are ALREADY PRESENT.
Write-Warning "Getting AstroServer ready..."
netsh advfirewall firewall add rule name="AstroServer" dir=in action=allow program="$installPath\Astroneer\AstroServer.exe" | Out-Null
netsh advfirewall firewall add rule name="AstroServer" dir=in action=allow program="$installPath\Astroneer\astro\binaries\win64\astroserver-win64-shipping.exe" | Out-Null
# This one silences a popup for dependncies that are already installed
Write-Host "Start Astroneer..."
$proc = Start-Process -filePath "$installPath\Astroneer\AstroServer.exe" -WorkingDirectory "$installPath\Astroneer\" -PassThru
Write-Host "Waiting for config file to populate"
$slept = $false
$start = Get-Date
while (($start.AddMinutes(2) -gt (Get-Date)) -and (!(Test-Path $configFile) -or (get-childitem $configFile).length -le 10)) {
    Start-Sleep 10
    Write-Host "." -NoNewLine
    $slept = $true
}
# Kill AstroServer.exe if it's not dead yet
if ($slept) { Write-Host }
if (!(Test-Path $configFile) -or (get-childitem $configFile).length -le 10) {
    Write-Error "Timed out waiting for config file to be populated"
    exit 1
}
Write-Host "Preparing to modify Astroneer config, killing the process..."
Stop-Process $proc

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

Write-Host "Setting Port: $serverPort"
Set-Content -Path $engineFile -Value (get-content -Path $engineFile | Select-String -Pattern "[URL]" -NotMatch)
Set-Content -Path $engineFile -Value (get-content -Path $engineFile | Select-String -Pattern "Port=*" -NotMatch)
Add-Content $engineFile "`r`n`r`n[URL]`r`nPort=$serverPort"


if ( $serverPassword) {
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
    Invoke-WebRequest -Uri $downloadUri -OutFile "$installPath\Astroneer\AstroLauncher.exe" -UseBasicParsing
}

Write-Host "Adding Firewall Exceptions for port $serverPort UDP"
netsh advfirewall firewall add rule name="AstroServer" dir=in action=allow protocol=UDP localport=$serverPort  | Out-Null

if ($useGUI -eq $true) {
    Write-Host "Adding Firewall Exception for AstroLauncher TCP 5000"
    Write-Warning "AstroLauncher will listen on 0.0.0.0:5000 by default.  Check your firewall rules to limit access if needed!"
    netsh advfirewall firewall add rule name="AstroLauncher" dir=in action=allow program="$installPath\Astroneer\AstroLauncher.exe"  | Out-Null
    netsh advfirewall firewall add rule name="AstroLauncher" dir=in action=allow protocol=TCP localport=5000  | Out-Null
}

if ($installService -eq $true) { 
    if ($useGui -eq $true) { 
        $astroServiceName = "AstroLauncher"
        $pathToAstro = "$installPath\Astroneer\AstroLauncher.exe"
    } else { 
        $astroServiceName = "AstroServer"
        $pathToAstro = "$installPath\Astroneer\AstroServer.exe"
    }

    Invoke-WebRequest -Uri $nssmUrl -OutFile "$installPath\nssm.zip"
    Expand-Archive -Path "$installPath\nssm.zip" -DestinationPath "$installPath"
    Start-Process -FilePath "$installPath\$nssm_build\nssm.exe" -NoNewWindow -ArgumentList "install $astroServiceName $pathToAstro" -Wait -PassThru
}

if ($reboot -eq $true) {
    if ($useGUi -eq $true) { 
        if ($installService -eq $true) { 
            Write-Host "The system will now reboot.  Upon boot the AstroLauncher service should be running, and you should have an astroneer server!"
        } else { 
            Write-Warning "When you come back, go to $installPath\Astroneer\ and run AstroLauncher.exe"
        }
    } else {
        if ($installService -eq $true) { 
            Write-Host "The system will now reboot.  Upon boot the AstroServer service should be running, and you should have an astroneer server!"
        } else { 
            Write-Warning "When you come back, go to $installPath\Astroneer\ and run AstroServer.exe"
        }
    }
    if ($autoReboot -eq $true) { 
        Write-Warning "System reboot scheduled for 60 seconds from now."
        Restart-Computer -Delay 60
    } else {
        $data = Read-Host -Prompt "Press ENTER to reboot."
        Restart-Computer -Delay 60
    }
} else {
    Write-Host "Installation Completed. Starting Astroneer Dedicated Server.  Have fun!"
    if ($installService -eq $false) { 
        if ($useGUI -eq $true) {
            Start-Process -FilePath "$installPath\Astroneer\AstroLauncher.exe" -WorkingDirectory $installPath\Astroneer\
            Write-Host "AstroLauncher should be available at http://localhost:5000"
        } else {
            Write-Host "If you need to make changes to the config file, ensure you kill the server first!"
            Start-Process -FilePath "$installPath\Astroneer\AstroServer.exe" -WorkingDirectory $installPath\Astroneer\
        }
    }
    else {
        Start-Process -FilePath "$installPath\$nssm_build\nssm.exe" -NoNewWindow -ArgumentList "start $astroServiceName" -Wait -PassThru
    }
}

Write-Host "Did you know you can offload your backups to a cloud storage with a simple script?"
Write-Host "Check out https://github.com/alex4108/astroneer-offsite-backups"

if ($noWait) {
    Write-Host "Installation is completed!"
} else {
    Write-Host "Installation is completed!  This script will exit in 2 minutes"
    Start-Sleep 120
}

Stop-Transcript
