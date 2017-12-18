<#
.SYNOPSIS
Script for extend systemdrive on windows server.
This script use diskpart tool. 
.DESCRIPTION
#>

$computername = ""
$pass = "" | ConvertTo-SecureString -AsPlainText -Force
$user = "local\Administrator"
$credential = New-Object Management.Automation.PSCredential $user,$pass

$ss = New-PSSession -Computername $computername -Credential $credential
Invoke-Command -session $ss  -ScriptBlock {

    # Disk capacity information before extend
    $diskinfobeforeextend=get-psdrive -Name ($env:systemdrive -replace ":","") -ErrorAction SilentlyContinue
    $totalcapacity=($diskinfobeforeextend.free + $diskinfobeforeextend.used)/1073741824
    Write-Host "=========================================================================="
    Write-Host "Current total capacity $env:systemdrive is $totalcapacity Gb"
    Write-Host "Current free capacity $env:systemdrive is $($diskinfobeforeextend.free/1073741824) Gb"
    Write-Host "Current used capacity $env:systemdrive is $($diskinfobeforeextend.used/1073741824) Gb"
    Write-Host "=========================================================================="

    # Create file and folder for diskpart config file
    $tempfoldername=get-date -Format ddMMyyyyHHmmss
    New-Item -Path $env:systemdrive\temp\$tempfoldername -ItemType directory | out-null
    Set-Content -Path $env:systemdrive\temp\$tempfoldername\diskpartconfig.txt -Force -Value "rescan `r`nselect volume $env:systemdrive `r`nextend"

    # Run diskpart with parameters file and save log in $env:systemdrive\temp\$tempfoldername\log.txt
    diskpart /s $env:systemdrive\temp\$tempfoldername\diskpartconfig.txt > $env:systemdrive\temp\$tempfoldername\log.txt

    # Translation diskpart log to the console 
    $log=Get-Content -Path $env:systemdrive\temp\$tempfoldername\log.txt -raw
    Write-Host $log

    # Disk capacity information after extend
    $diskinfoafterextend=get-psdrive -Name ($env:systemdrive -replace ":","") -ErrorAction SilentlyContinue
    $totalcapacity=($diskinfoafterextend.free + $diskinfoafterextend.used)/1073741824
    Write-Host "=========================================================================="
    Write-Host "Total capacity (after extend) $env:systemdrive is $totalcapacity Gb"
    Write-Host "Free capacity (after extend) $env:systemdrive is $($diskinfoafterextend.free/1073741824) Gb"
    Write-Host "Used capacity (after extend) $env:systemdrive is $($diskinfoafterextend.used/1073741824) Gb"
    Write-Host "=========================================================================="
}
Remove-PSSession $ss
