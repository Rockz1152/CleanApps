# CleanAppsGUI.ps1 by Rockz - 5/26/21
# Remove/Reinstall non-essential Windows apps

# Hide PowerShell Console
$dllvar = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $dllvar -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)

# init GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# main window
$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = New-Object System.Drawing.Point(600,400)
$Form.StartPosition = 'CenterScreen'
$Form.FormBorderStyle = 'FixedSingle'
# $Form.MinimizeBox = $false
$Form.MaximizeBox = $false
# $Form.ShowIcon = $false
$Form.text = "Clean Windows Apps - v1.1"
$Form.TopMost = $false
$Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#252525")

$RemoveApps = New-Object system.Windows.Forms.Button
$RemoveApps.text = "Remove Apps"
$RemoveApps.width = 100
$RemoveApps.height = 30
$RemoveApps.location = New-Object System.Drawing.Point(15,140)
$RemoveApps.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$RemoveApps.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#81b772")

$ReinstallApps = New-Object system.Windows.Forms.Button
$ReinstallApps.text = "Reinstall Apps"
$ReinstallApps.width = 100
$ReinstallApps.height = 30
$ReinstallApps.location = New-Object System.Drawing.Point(480,140)
$ReinstallApps.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$ReinstallApps.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#ff9191")

$ExitButton = New-Object system.Windows.Forms.Button
$ExitButton.text = "Exit"
$ExitButton.width = 100
$ExitButton.height = 30
$ExitButton.location = New-Object System.Drawing.Point(130,140)
$ExitButton.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',8)
$ExitButton.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#81b772")
$ExitButton.Add_Click({$Form.Close()})#On click do function

$OutputBox = New-Object System.Windows.Forms.TextBox 
$OutputBox.Location = New-Object System.Drawing.Size(10,200)
$OutputBox.Size = New-Object System.Drawing.Size(580,190)
$OutputBox.MultiLine = $True 
$OutputBox.ScrollBars = "Vertical"
$OutputBox.ForeColor = "White"
$OutputBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#272727")
# $Form.Controls.Add($OutputBox)

$Title = New-Object System.Windows.Forms.Label
$Title.text = "Clean Windows Apps"
$Title.AutoSize = $true
$Title.location = New-Object System.Drawing.Point(170,15)
$Title.Font = 'Microsoft Sans Serif,20'
$Title.ForeColor = "White"

$SubTitle = New-Object System.Windows.Forms.Label
$SubTitle.text = "Brought to you by Rockz"
$SubTitle.AutoSize = $true
$SubTitle.location = New-Object System.Drawing.Point(230,50)
$SubTitle.Font = 'Microsoft Sans Serif,10'
$SubTitle.ForeColor = "White"

$Note = New-Object System.Windows.Forms.Label
$Note.text = "The Window will be unresponsive while an operation is in progress."
$Note.AutoSize = $true
$Note.location = New-Object System.Drawing.Point(20,180)
$Note.Font = 'Microsoft Sans Serif,10'
$Note.ForeColor = "White"

# add elements to the form
$Form.controls.AddRange(@($RemoveApps,$ReinstallApps,$OutputBox,$Note,$Title,$SubTitle,$ExitButton))

# add functions to buttons
$RemoveApps.Add_Click({ RemoveApps })
$ReinstallApps.Add_Click({ ConfirmDialogue })
$ExitButton.Add_Click({ ExitButton })

function RemoveApps {
Add-OutputBoxLine -Message "Removing Apps"
# Microsoft.549981C3F5F10 is cortana
$RemoveApps = "
Microsoft.MixedReality.Portal|
Microsoft.Wallet|
Microsoft.DesktopAppInstaller|
Microsoft.WindowsCamera|
Microsoft.BingNews|
Microsoft.GetHelp|
Microsoft.Getstarted|
Microsoft.YourPhone|
Microsoft.Messaging|
Microsoft.Microsoft3DViewer|
Microsoft.MicrosoftOfficeHub|
Microsoft.MicrosoftSolitaireCollection|
Microsoft.NetworkSpeedTest|
Microsoft.News|
Microsoft.Office.Lens|
Microsoft.Office.OneNote|
Microsoft.Office.Sway|
Microsoft.OneConnect|
Microsoft.People|
Microsoft.Print3D|
Microsoft.RemoteDesktop|
Microsoft.SkypeApp|
Microsoft.Office.Todo.List|
Microsoft.Whiteboard|
Microsoft.WindowsAlarms|
microsoft.windowscommunicationsapps|
Microsoft.WindowsFeedbackHub|
Microsoft.WindowsMaps|
Microsoft.BingWeather|
Microsoft.549981C3F5F10|
Microsoft.Advertising.Xaml|
CandyCrush|
EclipseManager|
ActiproSoftwareLLC|
AdobeSystemsIncorporated.AdobePhotoshopExpress|
Duolingo-LearnLanguagesforFree|
PandoraMediaInc|
BubbleWitch3Saga|
Wunderlist|
Flipboard|
Twitter|
Facebook|
Spotify|
Minecraft|
Royal Revolt|
Sway|
Speed Test|
Dolby
"
$RemoveApps = $RemoveApps -replace '\r*\n', ''
$progressPreference = 'silentlyContinue'
Add-OutputBoxLine -Message "Working ..."
Get-AppxPackage | where-object {$_.Name -match $RemoveApps} | Remove-AppxPackage -erroraction 'silentlycontinue'
$progressPreference = 'Continue'
Add-OutputBoxLine -Message "Done`r`n"
}

function ConfirmDialogue {
Add-Type -AssemblyName PresentationCore,PresentationFramework
$msgBody = "Reinstall default Windows Apps?"
$msgTitle = "Confirm"
$msgButton = 'YesNo'
$msgImage = 'Asterisk'
$Result = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
switch  ($Result) {
    'Yes' {
        ReinstallApps
    }
    'No' {
        # close the dialogue
    }
  }
}

function ReinstallApps {
Add-OutputBoxLine -Message "Reinstalling Apps"
$progressPreference = 'silentlyContinue'
# Generate a file to copy the acl from later on
Out-File -FilePath $Env:ALLUSERSPROFILE\acl.txt -Force
# Breakdown of long command below:
# - start an admin process to get a list of apps for all users
# - write that list out to a file
# - copy the acl from the above file and apply it to our list file
# - this allows the non admin context to read the app list from the admin context
Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"Get-AppxPackage -AllUsers | select InstallLocation | Format-Table -HideTableHeaders | Out-File -Width 1000 $Env:ALLUSERSPROFILE\applist.txt -Force; Get-Acl -Path $Env:ALLUSERSPROFILE\acl.txt | Set-Acl -Path $Env:ALLUSERSPROFILE\applist.txt`"" -Verb RunAs -Wait -WindowStyle Hidden
Add-OutputBoxLine -Message "Working ..."
# read the app list into a variable and go to work
if ((Test-Path $Env:ALLUSERSPROFILE\applist.txt) -eq "True") {
    $AppList = Get-Content $Env:ALLUSERSPROFILE\applist.txt
    # Cleanup temp files
    if ((Test-Path $Env:ALLUSERSPROFILE\applist.txt) -eq "True") {
        Remove-Item $Env:ALLUSERSPROFILE\applist.txt
    }
    if ((Test-Path $Env:ALLUSERSPROFILE\acl.txt) -eq "True") {
        Remove-Item $Env:ALLUSERSPROFILE\acl.txt
    }
    $AppList = $AppList.Trim()
    foreach ($App in $AppList) {
            if ($App -ne "" ) {
                Add-AppxPackage -DisableDevelopmentMode -Register "$App\appxmanifest.xml" -ErrorAction 'silentlycontinue' | Out-Null
            }
        }
    }
$progressPreference = 'Continue'
Add-OutputBoxLine -Message "Done`r`n"
}

function Add-OutputBoxLine {
    Param ($Message)
    $OutputBox.AppendText("`r`n$Message")
    $OutputBox.Refresh()
    $OutputBox.ScrollToCaret()
}

[void]$Form.ShowDialog()
