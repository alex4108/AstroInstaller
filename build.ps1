Param($version)
if ( $null -eq $version ) {
    Write-Host "Aborted Build - No Version Number"
    Exit
}

Install-Module ps2exe -Force
$file = "install-astroneer-server.ps1"
$regex = '\$version\s+\=\s+"(?:(?!\.)(?:.|\n))*\.(?:(?!\.)(?:.|\n))*\.(?:(?!")(?:.|\n))*"'
(Get-Content $PSScriptRoot\$file) -replace $regex, "`$version = `"$version`"" | Set-Content $PSScriptRoot\$file
ps2exe -inputFile "$PSScriptRoot\install-astroneer-server.ps1" -outputFile "$PSScriptRoot\install-astroneer-server.exe" -verbose -requireAdmin -title "Astroneer Server Installer"
Compress-Archive "$PSScriptRoot\install-astroneer-server.exe" "$PSScriptRoot\install-astroneer-server-$version.zip"