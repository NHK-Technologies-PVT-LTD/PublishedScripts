#### Variables

$connectTestResult = Test-NetConnection -ComputerName proravidsa01.file.core.windows.net -Port 445
$DriveLetter = "I"
$ReportFile = $DriveLetter + ":\WindowsUpdateData\WindowsUpdateData.csv"

#### Mapping Network Drive
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"proravidsa01.file.core.windows.net`" /user:`"Azure\proravidsa01`" /pass:`"38qKhh17kWRDKO/q/1Zay4LiLDiUjZDAns4m1bMvbTaNcWSQFLGWixbDTna6sDxCCBtAxg8O+XPrLHWTQEvgbQ==`""
    # Mount the drive
    New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root "\\proravidsa01.file.core.windows.net\reports"
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

#### Adding Data to CSV File
Get-HotFix -ComputerName $ENV:COMPUTERNAME  | Sort-Object -Descending -Property InstalledOn -ErrorAction SilentlyContinue | Select-Object `
@{Name='Server Name';Expression={$_.PSComputerName}}, `
@{Name='Company Name';Expression={" "}}, `
@{Name='Supported By';Expression={" "}}, `
@{Name='Last Update Date';Expression={$_.InstalledON}}  -First 1 | `
Export-Csv -Path $ReportFile -Append -NoTypeInformation

#### Deleting Map Drive
# Remove-PsDrive $DriveLetter
# Net use ($DriveLetter + ":") /delete