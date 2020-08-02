<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    AstroServer Installer GUI
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(400,400)
$Form.text                       = "Form"
$Form.TopMost                    = $false

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Astro Server First Time Setup"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(100,12)
$Label1.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "label"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(-50,82)
$Label2.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Owner Steam Name *"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(8,47)
$Label3.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "Server Name *"
$Label4.AutoSize                 = $true
$Label4.width                    = 25
$Label4.height                   = 10
$Label4.location                 = New-Object System.Drawing.Point(8,84)
$Label4.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "Server Password"
$Label5.AutoSize                 = $true
$Label5.width                    = 25
$Label5.height                   = 10
$Label5.location                 = New-Object System.Drawing.Point(8,117)
$Label5.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label6                          = New-Object system.Windows.Forms.Label
$Label6.text                     = "Max FPS *"
$Label6.AutoSize                 = $true
$Label6.width                    = 25
$Label6.height                   = 10
$Label6.location                 = New-Object System.Drawing.Point(7,155)
$Label6.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label7                          = New-Object system.Windows.Forms.Label
$Label7.text                     = "Reboot if needed"
$Label7.AutoSize                 = $true
$Label7.width                    = 25
$Label7.height                   = 10
$Label7.location                 = New-Object System.Drawing.Point(7,201)
$Label7.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label8                          = New-Object system.Windows.Forms.Label
$Label8.text                     = "Install AstroLauncher"
$Label8.AutoSize                 = $true
$Label8.width                    = 25
$Label8.height                   = 10
$Label8.location                 = New-Object System.Drawing.Point(8,247)
$Label8.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label9                          = New-Object system.Windows.Forms.Label
$Label9.text                     = "Expose AstroLauncher to external network **"
$Label9.AutoSize                 = $true
$Label9.width                    = 25
$Label9.height                   = 10
$Label9.location                 = New-Object System.Drawing.Point(7,294)
$Label9.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label10                         = New-Object system.Windows.Forms.Label
$Label10.text                    = "** Proceed with caution, could lead to potential attack"
$Label10.AutoSize                = $true
$Label10.width                   = 25
$Label10.height                  = 10
$Label10.location                = New-Object System.Drawing.Point(83,377)
$Label10.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$SteamOwnerName                  = New-Object system.Windows.Forms.TextBox
$SteamOwnerName.multiline        = $false
$SteamOwnerName.width            = 176
$SteamOwnerName.height           = 20
$SteamOwnerName.location         = New-Object System.Drawing.Point(165,47)
$SteamOwnerName.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ServerName                      = New-Object system.Windows.Forms.TextBox
$ServerName.multiline            = $false
$ServerName.width                = 176
$ServerName.height               = 20
$ServerName.location             = New-Object System.Drawing.Point(165,80)
$ServerName.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label11                         = New-Object system.Windows.Forms.Label
$Label11.text                    = "* Required"
$Label11.AutoSize                = $true
$Label11.width                   = 25
$Label11.height                  = 10
$Label11.location                = New-Object System.Drawing.Point(84,354)
$Label11.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ServerPassword                  = New-Object system.Windows.Forms.MaskedTextBox
$ServerPassword.multiline        = $false
$ServerPassword.width            = 177
$ServerPassword.height           = 20
$ServerPassword.location         = New-Object System.Drawing.Point(165,112)
$ServerPassword.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RebootIfNeeded                  = New-Object system.Windows.Forms.CheckBox
$RebootIfNeeded.AutoSize         = $false
$RebootIfNeeded.width            = 95
$RebootIfNeeded.height           = 20
$RebootIfNeeded.location         = New-Object System.Drawing.Point(167,202)
$RebootIfNeeded.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$InstallAstroLauncher            = New-Object system.Windows.Forms.CheckBox
$InstallAstroLauncher.AutoSize   = $false
$InstallAstroLauncher.width      = 95
$InstallAstroLauncher.height     = 20
$InstallAstroLauncher.enabled    = $true
$InstallAstroLauncher.location   = New-Object System.Drawing.Point(167,248)
$InstallAstroLauncher.Font       = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$InstallAstroLauncher.Checked    = $true

$CheckBox1                       = New-Object system.Windows.Forms.CheckBox
$CheckBox1.AutoSize              = $false
$CheckBox1.width                 = 95
$CheckBox1.height                = 20
$CheckBox1.location              = New-Object System.Drawing.Point(281,294)
$CheckBox1.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.text                   = "30"
$TextBox1.width                  = 177
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(165,153)
$TextBox1.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Start Setup"
$Button1.width                   = 130
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(252,329)
$Button1.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
# How do I make this validate input and continue once clicked?

$Form.controls.AddRange(@($Label1,$Label2,$Label3,$Label4,$Label5,$Label6,$Label7,$Label8,$Label9,$Label10,$SteamOwnerName,$ServerName,$Label11,$ServerPassword,$RebootIfNeeded,$InstallAstroLauncher,$CheckBox1,$TextBox1,$Button1))


