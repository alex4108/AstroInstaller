# Astroneer Server Deployment Tools

![Astroneer Logo](https://astroneer.space/presskit/astroneer/images/header.png)

[![Build Status](https://travis-ci.com/alex4108/astroneer-server-deployment.svg?branch=master)](https://travis-ci.com/alex4108/astroneer-server-deployment)

This module lets you quickly deploy an [Astroneer Dedicated Server](https://blog.astroneer.space/p/astroneer-dedicated-server-details/)

Did I save you some time?  [Buy me a :coffee::smile:](https://venmo.com/alex-schittko)

# How to use

## Easy Method
  
1. Download the `install-astroneer-server.zip` file from the latest release to the right :arrow_right:
1. Extract the ZIP
1. Run the `install-astroneer-server.exe` file as administrator
1. Answer the prompts followed by ENTER

* `Owner Steam Name`: This is how your steam name is publicly visible to the world.
* `Server Name`: This will be the name of your server
* `Max FPS`: Set to 30 if you're unsure.  
* `Server Password`: A server password if you wish, or just hit enter for no password.

## Advanced Method

1. Download or Clone the repository
1. Execute the powershell script: `powershell.exe -executionpolicy bypass -file "install-astroneer-server.ps1"`

#### Supported command line switches and examples

* `-ownerName "The owner steam name"`
* `-serverName "The server password"`
* `-serverPassword "A Super Secure Password"`
* `-maxFPS 60`

#### Full example to bypass all prompts

* `powershell.exe -executionpolicy bypass -file "install-astroneer-server.ps1" -ownerName "Guy" -serverName "Guys Lair" -serverPassword "Guy123" -maxFPS 60`

# Credits

[MScholtes](https://github.com/MScholtes/PS2EXE)
[hjorslev](https://github.com/hjorslev/SteamPS)
