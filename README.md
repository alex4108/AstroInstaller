# Astroneer Server Deployment Tools

![Astroneer Logo](https://astroneer.space/presskit/astroneer/images/header.png)

[![Build Status](https://travis-ci.com/alex4108/astroneer-server-deployment.svg?branch=master)](https://travis-ci.com/alex4108/astroneer-server-deployment)

This module lets you quickly deploy an [Astroneer Dedicated Server](https://blog.astroneer.space/p/astroneer-dedicated-server-details/)

Did I save you some time?  [Buy me a :coffee::smile:](https://venmo.com/alex-schittko)

# How to use

## Easy Method

**The Easy Method does not yet exist!**  

1. Download the latest Release zip
1. Extract the zip and run the EXE file on the system you want to install Astroneer on.
1. Fill in the parameters as requested

* Owner Steam Name: This is how your steam name is publicly visible to the world.
* Max FPS: Set to 30 if you're unsure.  
* 

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

# TODO

1. Travis-CI to publish the powershell module using PS2EXE and GitHub Releases.  This will release the EASY method


