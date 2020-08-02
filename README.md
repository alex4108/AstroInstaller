# Astroneer Server Deployment Tools

![Astroneer Logo](https://astroneer.space/presskit/astroneer/images/header.png)

[![Build Status](https://travis-ci.com/alex4108/astroneer-server-deployment.svg?branch=master)](https://travis-ci.com/alex4108/astroneer-server-deployment)
[![GitHub issues](https://img.shields.io/github/issues/alex4108/astroneer-server-deployment)](https://github.com/alex4108/astroneer-server-deployment/issues)
[![GitHub forks](https://img.shields.io/github/forks/alex4108/astroneer-server-deployment)](https://github.com/alex4108/astroneer-server-deployment/network)
[![GitHub stars](https://img.shields.io/github/stars/alex4108/astroneer-server-deployment)](https://github.com/alex4108/astroneer-server-deployment/stargazers)
[![GitHub license](https://img.shields.io/github/license/alex4108/astroneer-server-deployment)](https://github.com/alex4108/astroneer-server-deployment/blob/master/LICENSE)
![GitHub All Releases](https://img.shields.io/github/downloads/alex4108/astroneer-server-deployment/total)
![GitHub contributors](https://img.shields.io/github/contributors/alex4108/astroneer-server-deployment)

This module lets you quickly deploy an [Astroneer Dedicated Server](https://blog.astroneer.space/p/astroneer-dedicated-server-details/)

Did I save you some time?  [Buy me a :coffee::smile:](https://venmo.com/alex-schittko)

# How to use

## Easy Method
  
1. Download the `install-astroneer-server.zip` file from the [latest release](https://github.com/alex4108/astroneer-server-deployment/releases) 
1. Extract the ZIP
1. Run the `install-astroneer-server.exe` file as administrator
1. Answer the prompts followed by ENTER

* `Owner Steam Name`: This is how your steam name is publicly visible to the world.
* `Server Name`: This will be the name of your server
* `Max FPS`: Set to 30 if you're unsure.  
* `Server Password`: A server password if you wish, or just hit enter for no password.
* `Use AstroLauncher as GUI [y/n]`: _Recommended_ If you'd like to install [AstroLauncher](https://www.github.com/ricky-davis/AstroLauncher) to manage the server.

## Advanced Method

1. Download or Clone the repository
1. Execute the powershell script: `powershell.exe -executionpolicy bypass -file "install-astroneer-server.ps1"`

#### Supported command line switches and examples

* `-ownerName "The owner steam name"`
* `-serverName "The server name"`
* `-serverPassword "A Super Secure Password"`
* `-maxFPS 60`
* `-useGUI y` or `-useGUI n` to install [AstroLauncher](https://www.github.com/ricky-davis/AstroLauncher)
* `-autoReboot y` _Optional_ If set to y, the server will be rebooted automatically after installation if needed.  Otherwise, if a reboot is needed, the script will exit and the server will not be able to start until the reboot is complete.

#### Unattended installation

* `powershell.exe -executionpolicy bypass -file "install-astroneer-server.ps1" -ownerName "Guy" -serverName "Guys Lair" -serverPassword "Guy123" -maxFPS 60 -useGUI y`

# Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

# Credits

[MScholtes](https://github.com/MScholtes/PS2EXE) - PS2EXE allows me to build this in a way that's easy to use by masses

[hjorslev](https://github.com/hjorslev/SteamPS) - Wrapper that helped in speeding up usage of SteamCMD

[ricky-davis](https://www.github.com/ricky-davis/AstroLauncher) - Web based server management utility for Astroneer