Function Initialize-InitalSetup {

    ### Variables
    $NHKFolder = "C:\ProgramData\NHK"
    $NHKScriptRoot = $NHKFolder + "\Scripts"
    $NHKModulesRoot = $NHKScriptRoot + "\Modules"
    $NHKSoftwareRoot = $NHKFolder + "\Softwares"
    $NHKLogFolder = $NHKFolder + "\LogFolder"
    ############################################################## Functions
    Function New-EventLogFolder {
        if ((Get-WinEvent -ListLog "NHK" -ErrorAction SilentlyContinue).Logname -eq 'NHK') {
            $Message = @"
NHK Event Log Folder already exists with the following providers
    
Provider Names
-----------------
$((Get-WinEvent -ListLog "NHK").ProviderNames | Format-Table | Out-String)
"@
    
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventId 6450 -Message $Message
            Start-Sleep 3
       
        } 

        else {

            New-EventLog -LogName "NHK" -Source "Script Status", "Scheduled Tasks", "Admin Tasks", "Script Log"

            $Message = @"
NHK Event Log Folder has been created with the following providers
    
Provider Names
-----------------
$((Get-WinEvent -ListLog "NHK").ProviderNames | Format-Table | Out-String)
"@
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EventId 6450 -EntryType Information -Message $Message

        }
    }

    function Disable-Firewall {

        if ((Get-NetFirewallProfile -Name Domain).Enabled -eq $False -and (Get-NetFirewallProfile -Name Private).Enabled -eq $False -and (Get-NetFirewallProfile -Name Public).Enabled -eq $False) {
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Firewall Already Disabled"

        } 


        else {

            Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled false 
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Firewall Disabled Successfully"
        }
    }

    function Enable-RDP {

        if ((Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).AllowTSConnections -eq '1') {
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "RDP Already Enabled"

        }
        else {

            (Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1, 1) | Out-Null
            (Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null

            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "RDP Enabled Successfully" 
        }
    }

    function New-NHKScriptFolder {
        New-Item -Path $NHKFolder -Name Scripts -ItemType Directory -ErrorAction SilentlyContinue
        $Value = @"
*****************************************************************
		     SCRIPTS FOLDER
*****************************************************************

This is the default Scripts Folder for the NHK Systems.

Please do not delete or modify any contents of this folder.

Regards,
NHK Team
"@
        New-Item -Path $NHKScriptRoot -Name "PLEASE_READ.txt" -ItemType File -Value $Value
        Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Scripts Folder Created Successfully"    
    }

    function New-NHKModulesFolder {
        New-Item -Path $NHKScriptRoot -Name Modules -ItemType Directory -ErrorAction SilentlyContinue
        $Value = @"
*****************************************************************
		     SCRIPTS FOLDER
*****************************************************************

This is the default Scripts Folder for the NHK Systems.

Please do not delete or modify any contents of this folder.

Regards,
NHK Team
"@
        New-Item -Path $NHKModulesRoot -Name "PLEASE_READ.txt" -ItemType File -Value $Value
        $CurrentValue1 = $ENV:PSModulePath
        [Environment]::SetEnvironmentVariable("PSModulePath", $CurrentValue1 + [System.IO.Path]::PathSeparator + $NHKModulesRoot + [System.IO.Path]::PathSeparator + $NHKScriptRoot, "Machine")
        $CurrentValue2 = $ENV:Path
        [Environment]::SetEnvironmentVariable("Path", $CurrentValue2 + [System.IO.Path]::PathSeparator + $NHKModulesRoot + [System.IO.Path]::PathSeparator + $NHKScriptRoot, "Machine")
        Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Modules Folder Created Successfully and Modules path has been added to the Enviorment Variable" 
    }

    function New-NHKSoftwareFolder {
        New-Item -Path $NHKFolder -Name Softwares -ItemType Directory -ErrorAction SilentlyContinue
        $Value = @"
*****************************************************************
		     SOFTWARES FOLDER
*****************************************************************

This is the default Sofwtares Folder for the NHK Systems.

Please do not delete or modify any contents of this folder.

Regards,
NHK Team
"@
        New-Item -Path $NHKSoftwareRoot -Name "PLEASE_READ.txt" -ItemType File -Value $Value
        Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Softwares Folder Created Successfully"    
    }

    function New-NHKLogFolder {
        New-Item -Path $NHKFolder -Name LogFolder -ItemType Directory -ErrorAction SilentlyContinue
        $Value = @"
*****************************************************************
		     LOGS FOLDER
*****************************************************************

This is the default Logs Folder for the NHK Systems.

Please do not delete or modify any contents of this folder.

Regards,
NHK Team
"@
        New-Item -Path $NHKLogFolder -Name "PLEASE_READ.txt" -ItemType File -Value $Value
        Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Logs Folder Created Successfully"    
    }

    Function New-NHKAdminUser {

        if (Get-LocalUser -Name NHKAdmin -ErrorAction SilentlyContinue) {
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "NHKAdmin Account Already Exists"

        } 


        else {
            $username = "NHKAdmin" 
            $password = "F1l@b1lillah" | ConvertTo-SecureString -asPlainText -Force 

            New-LocalUser $username -Password $Password -FullName "NHK Admin" -Description "Default Admin Account for NHK Care Team" -ErrorAction SilentlyContinue
            Set-LocalUser -Name $Username -PasswordNeverExpires $True -ErrorAction SilentlyContinue
            Add-LocalGroupMember -Group Administrators -Member $username -ErrorAction SilentlyContinue

            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "NHKAdmin Account Created Successfully with F1 password"
        }
    }

    ############################################################## Functions

    ############################## SCRIPT STARTING

    ######################################### Creating NHK Log Folder for Errors and Warning Details

    New-EventLogFolder

    ############################################################## Scripts Folder Creation ###########

    if (Test-Path $NHKFolder -ErrorAction SilentlyContinue) {

        Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "NHK Admin Folder Already Exists"

        if (Test-Path ($NHKScriptRoot + "\PLEASE_READ.txt")) {
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Scripts Folder Already Exists"
        }
        else {
            New-NHKScriptFolder        
        }

        if (Test-Path ($NHKModulesRoot + "\PLEASE_READ.txt")) {
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Modules Folder Already Exists"
        }
        else {
            New-NHKModulesFolder        
        }

        if (Test-Path ($NHKSoftwareRoot + "\PLEASE_READ.txt")) {
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Softwares Folder Already Exists"
        }
        else {
            New-NHKSoftwareFolder
        }

        if (Test-Path ($NHKLogFolder + "\PLEASE_READ.txt")) {
            Write-EventLog -LogName "NHK" -Source "Admin Tasks" -EntryType Information -EventID 6450 -Message "Logs Folder Already Exists"
        }
        else {
            New-NHKLogFolder
        }

    }

    else {
    
        New-Item -Path "C:\ProgramData" -Name NHK -ItemType Directory -ErrorAction SilentlyContinue
        New-NHKScriptFolder
        New-NHKModulesFolder
        New-NHKSoftwareFolder
        New-NHKLogFolder
    }

    ######################################################### Enabling Remote Desktop

    Enable-RDP

    ########################################################################## Disable Firewall

    Disable-Firewall

    ############################ Create Local User

    New-NHKAdminUser

}