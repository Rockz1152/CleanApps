# CleanApps.ps1 by Rockz - 5/26/21
# Remove/Reinstall non-essential Windows apps

Write-Host " "
$oldtext = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "Green"
Write-Host "      :::::::::   ::::::::   ::::::::  :::    ::: ::::::::: ";
Write-Host "     :+:    :+: :+:    :+: :+:    :+: :+:   :+:       :+:   ";
Write-Host "    +:+    +:+ +:+    +:+ +:+        +:+  +:+       +:+     ";
Write-Host "   +#++:++#:  +#+    +:+ +#+        +#++:++       +#+       ";
Write-Host "  +#+    +#+ +#+    +#+ +#+        +#+  +#+     +#+         ";
Write-Host " #+#    #+# #+#    #+# #+#    #+# #+#   #+#   #+#           ";
Write-Host "###    ###  ########   ########  ###    ### #########       ";
$host.ui.RawUI.ForegroundColor = $oldtext
Remove-Variable oldtext
Write-Host "                Clean Windows Apps";

Write-Host " "
Write-Host "Available options:"
Write-Host " "
Write-Host "1)"
Write-Host "Remove non essential Windows Store Apps"
Write-Host " "
Write-Host "2)"
Write-Host "Reinstall all default Windows Store Apps"
Write-Host " "
Write-Host "To quit type 'q'"
Write-Host " "

write-host -nonewline "Please choose an option: "
 do { $key = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")}
    until ($key.Character -eq '1' -or $key.Character -eq '2' -or $key.Character -eq 'q')
if ($key.Character -eq 'q') { exit }
Write-Host $key.Character

if ($key.Character -eq '1') {
Write-Host "Removing Apps"
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
Write-Host "--Part 1"
Get-AppxPackage | where-object {$_.Name -match $RemoveApps} | Remove-AppxPackage -erroraction silentlycontinue
Write-Host "--Part 2"
Get-AppxPackage | where-object {$_.Name -match $RemoveApps} | Remove-AppxPackage -erroraction silentlycontinue
$progressPreference = 'Continue'
}

if ($key.Character -eq '2') {
Write-Host "Reinstalling Apps"
$progressPreference = 'silentlyContinue'
# We need to copy these acls later for when we cleanup
Out-File -FilePath $Env:ALLUSERSPROFILE\acl.txt -Force
Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -Command `"Get-AppxPackage -AllUsers | select InstallLocation | Format-Table -HideTableHeaders | Out-File -Width 1000 $Env:ALLUSERSPROFILE\applist.txt -Force; Get-Acl -Path $Env:ALLUSERSPROFILE\acl.txt | Set-Acl -Path $Env:ALLUSERSPROFILE\applist.txt`"" -Verb RunAs -Wait -WindowStyle Hidden
if ((Test-Path $Env:ALLUSERSPROFILE\applist.txt) -eq "True") {
    $AppList = Get-Content $Env:ALLUSERSPROFILE\applist.txt
    # Cleanup temp files
    Remove-Item $Env:ALLUSERSPROFILE\applist.txt
    Remove-Item $Env:ALLUSERSPROFILE\acl.txt
    $AppList = $AppList.Trim()
    foreach ($App in $AppList) {
            if ($App -ne "" ) {
                Add-AppxPackage -DisableDevelopmentMode -Register "$App\appxmanifest.xml" -ErrorAction SilentlyContinue
            }
        }
    }
if ((Test-Path $Env:ALLUSERSPROFILE\acl.txt) -eq "True") {
    Remove-Item $Env:ALLUSERSPROFILE\acl.txt
    }
$progressPreference = 'Continue'
}

Write-Host "All done, exiting..."
Sleep 3