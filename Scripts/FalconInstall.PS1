$DestinationDirectory = $ENV:USERPROFILE + "\Temp"
$VBScriptUri = "https://bit.ly/3pQZCFv"
$FalconAgentUri = "https://bit.ly/3gnEaVO"
$VBScriptFile = $DestinationDirectory + "\Scan2.vbs"
$FalconAgentFile = $DestinationDirectory + "\WindowsSensor.MaverickGyr.exe"
$LogFile = $ENV:USERPROFILE + "\FalconAgentInstall.log"
$Username = "admin"
$Password = "password123#" | ConvertTo-SecureString -AsPlainText -Force
$AdminCreds = New-Object System.Management.Automation.PSCredential $UserName, $Password

## Creating the Temp Directory
if (!(Get-Item $LogFile -ErrorAction SilentlyContinue)) { New-Item $LogFile -ItemType File }
$SystemSummary = @"
==============================
Falcon Agent Installation Log
==============================
User            : $ENV:USERNAME
Domain Name     : $ENV:USERDNSDOMAIN
Computer Name   : $ENV:COMPUTERNAME
Start Time      : $(Get-Date)
"@

Add-Content $LogFile -Value $SystemSummary

$CreateDirectory = @"
Creating a Temp Directory for downloading files at $DestinationDirectory. 
"@
Add-Content $LogFile -Value $CreateDirectory

if (!(Get-Item $DestinationDirectory -ErrorAction SilentlyContinue)) { New-Item $DestinationDirectory -ItemType Directory }

## Downloading the VBScript
$VBDownloadBegin = @"
Starting download of Scan VB Script at $(Get-Date)
"@
Add-Content $LogFile -Value $VBDownloadBegin

Invoke-WebRequest -Uri $VBScriptUri -OutFile $VBScriptFile

$VBDownloadEnd = @"
Download of Scan VB Script completed at $(Get-Date)
"@
Add-Content $LogFile -Value $VBDownloadEnd

## Downloading the Falcon Agent
$FalconDownloadBegin = @"
Starting download of Scan VB Script at $(Get-Date)
"@
Add-Content $LogFile -Value $FalconDownloadBegin

Invoke-WebRequest -Uri $FalconAgentUri -OutFile $FalconAgentFile

$FalconDownloadEnd = @"
Download of Scan VB Script completed at $(Get-Date)
"@
Add-Content $LogFile -Value $FalconDownloadEnd

## Install Falcon
$FalconInstallBegin = @"
Starting the Installation of the Falcon Agent at $(Get-Date)
"@
Add-Content $LogFile -Value $FalconInstallBegin

#Invoke-Command -ScriptBlock { cmd /c $FalconAgentFile / install /quiet /norestart CID=D8085A57C7854DAA8C1C168E8FF6E934-3E /log $LogFile } -Credential $AdminCreds

$FalconInstallComplete = @"
Completed the Installation of the Falcon Agent at $(Get-Date)
"@
Add-Content $LogFile -Value $FalconInstallComplete

## Run Scan
$VBScriptScanBegin = @"
Starting the Scan with the VB Script at $(Get-Date)
"@
Add-Content $LogFile -Value $VBScriptScanBegin

Start-Process $VBScriptFile -Wait

$VBScriptScanComplete = @"
Scan Completed with the VB Script at $(Get-Date)
"@
Add-Content $LogFile -Value $VBScriptScanComplete

## Reboot the system
$RebootSystem = @"
Initiating System Reboot at $(Get-Date)
"@
Add-Content $LogFile -Value $RebootSystem

Restart-Computer -Force -Wait

$RebootSystemUp = @"
System Reboot Completed at $(Get-Date)
"@
Add-Content $LogFile -Value $RebootSystemUp

## Check Agent installation

$FalconAgentStatus = Get-Service -Name csagent | Select-Object DisplayName, Name, StartType, Status

if ($FalconAgentStatus) {
    $FalconAgentStatusLog = @"
Falcon agent has been Successfully Installed and below is the status of the Agent
$FalconAgentStatus
"@
    Add-Content $LogFile -Value $FalconAgentStatusLog
}
## Delete the temp Directory

Remove-Item $DestinationDirectory -Force

$DirectoryDelete = @"
Deleted the Temp Directory will all the files at $(Get-Date)
"@
Add-Content $LogFile -Value $DirectoryDelete
