# Astroneer Server Deployment Tools

![Astroneer Logo](https://astroneer.space/presskit/astroneer/images/header.png)


[![Build Status](https://travis-ci.com/alex4108/AstroInstaller.svg?branch=master)](https://travis-ci.com/alex4108/AstroInstaller)
![Supports Windows Server 2019](https://img.shields.io/badge/Windows-Server%202019-brightgreen)
![Supports Windows 10](https://img.shields.io/badge/Windows-10-brightgreen)
![Requires Powershell 5](https://img.shields.io/badge/Powershell-5+-green)
[![GitHub issues](https://img.shields.io/github/issues/alex4108/AstroInstaller)](https://github.com/alex4108/AstroInstaller/issues)
[![GitHub forks](https://img.shields.io/github/forks/alex4108/AstroInstaller)](https://github.com/alex4108/AstroInstaller/network)
[![GitHub stars](https://img.shields.io/github/stars/alex4108/AstroInstaller)](https://github.com/alex4108/AstroInstaller/stargazers)
[![GitHub license](https://img.shields.io/github/license/alex4108/AstroInstaller)](https://github.com/alex4108/AstroInstaller/blob/master/LICENSE)
![GitHub All Releases](https://img.shields.io/github/downloads/alex4108/AstroInstaller/total)
![GitHub contributors](https://img.shields.io/github/contributors/alex4108/AstroInstaller)

This module lets you quickly deploy an [Astroneer Dedicated Server](https://blog.astroneer.space/p/astroneer-dedicated-server-details/)

Did I save you some time?  [Buy me a :coffee::smile:](https://venmo.com/alex-schittko)

# How to use

## Easy Method (5 minutes)

[Watch the Video](https://screencast-o-matic.com/embed?sc=cYjnQCENUS&v=6&ff=1&title=0&controls=1)

1. Download the `AstroInstaller.zip` file from the [latest release](https://github.com/alex4108/AstroInstaller/releases) 
1. Extract the ZIP
1. Run the `AstroInstaller.exe` file as administrator
1. Answer the prompts followed by ENTER

* `Owner Steam Name`: This is how your steam name is publicly visible to the world.
* `Server Name`: This will be the name of your server
* `Server Password`: A server password if you wish, or just hit enter for no password.

## Advanced Method

1. Download or Clone the repository
1. Execute the powershell script: `powershell.exe -executionpolicy bypass -file "install-astroneer-server.ps1"`

#### Supported command line switches and examples

* `-ownerName "Astroneer server owner steam name"`
* `-serverName "Astroneer server name"`
* `-serverPassword "A Super Secure Password"` Server password. If ownerName, or serverName or serverPasswords are not provided on the command line, the script will ask for them interactively
* `-noServerPassword` _Optional._ Suppress password prompt if no server password was provided. Use it to run in non-interactive mode.
* `-erverPort 8777` _Optional_ _Default: 8777_ Astroneer server UDP port
* `-maxFPS 30` _Optional_ _Default: 30_ Maximum server FPS
* `-noAstroLauncher` _Optional._ Disables use of [AstroLauncher](https://www.github.com/ricky-davis/AstroLauncher)
* `-autoReboot` _Optional._  If specified, the server will be rebooted automatically after installation if needed.  Otherwise, if a reboot is needed, the script will exit and the server will not be able to start until the reboot is complete.
* `-installPath "C:\SteamServers"` _Optional_ _Default: C:\SteamServers_ The path to install to **without trailing slash**
* `-noWait` _Optional._ Suppress 2 minutes wait after script finishes. Use it to run in non-interactive mode.

#### Unattended installation

By specifiying `ownerName`, `serverName` and either `serverPassword` or `noServerPassword` parameters you will be able to run the installation completely unattended.

* `powershell.exe -executionpolicy bypass -file "install-astroneer-server.ps1" -ownerName "Guy" -serverName "Guys Lair" -serverPassword "Guy123" -autoReboot`

# Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

# Requirements

This script has been tested on Windows Server 2019 and Windows 10 1909 and Windows 10 2004 using Powershell 5 & Powershell 7.

# Credits

[MScholtes](https://github.com/MScholtes/PS2EXE) - PS2EXE allows me to build this in a way that's easy to use by masses

[hjorslev](https://github.com/hjorslev/SteamPS) - Wrapper that helped in speeding up usage of SteamCMD

[ricky-davis](https://www.github.com/ricky-davis/AstroLauncher) - Web based server management utility for Astroneer
