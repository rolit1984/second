[CmdletBinding()]
<#
.SYNOPSIS
Script for replace any content in the text file.
Example
.\FileContentReplace.ps1 -PathToFile D:\test.txt -BackUpPathFile D:\backtest.txt -PatternForReplace "\d" -ReplaceContent "replace"
#>
    param
    (
        [Parameter(Mandatory, HelpMessage = "Please enter computer name where file locate")]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,

        [Parameter(Mandatory, HelpMessage = "Please enter the path to file.")]
        [ValidateNotNullOrEmpty()]
        [string]$PathToFile, 

        [Parameter(Mandatory, HelpMessage = "Please enter the path for backup file.")]
        [ValidateNotNullOrEmpty()]
        [string]$BackUpPathFile,

        [Parameter(Mandatory, HelpMessage = "Specify the content that you want to replace the existing content. Do not use quotes.")]
        [ValidateNotNullOrEmpty()]
        [string]$ReplaceContent,

        [Parameter(Mandatory, HelpMessage = "Specify the pattern for replace. Do not use quotes.")]
        [ValidateNotNullOrEmpty()]
        [string]$PatternForReplace
    )

    Invoke-Command -ComputerName $ComputerName -ScriptBlock {

    # Check file exists
    $fileexists=[System.IO.file]::Exists("$using:PathToFile")
        if ($fileexists -eq $true) {

            # Get current file content
            $currentallfilecontent=[System.IO.File]::ReadAllText("$using:PathToFile")
            $newfilecontent = $currentallfilecontent -replace $using:PatternForReplace,$using:ReplaceContent

            # Create backup in backup location
            [System.IO.file]::Copy("$using:PathToFile","$using:BackUpPathFile")
            
            # Check copy process
            $algorithm = [Security.Cryptography.HashAlgorithm]::Create("MD5")
            $bytesoriginfile = [io.File]::ReadAllBytes("$using:PathToFile")
            $bytesbackfile = [io.File]::ReadAllBytes("$using:BackUpPathFile")
            [string]$hashorigin = $algorithm.ComputeHash($bytesoriginfile)
            [string]$hashbackup = $algorithm.ComputeHash($bytesbackfile)

                if ($hashorigin -eq $hashbackup) {
                    Write-host "Backup for file $using:PathToFile created successfully. Path: $using:BackUpPathFile."

                    # Replace text
                    [System.IO.file]::WriteAllText("$using:PathToFile","$newfilecontent")

                    # Check correct replace
                    $filecontentafterreplace=[System.IO.File]::ReadAllText("$using:PathToFile")
                        if ($filecontentafterreplace -eq $newfilecontent) {
                            Write-Host "Replacement in the file $using:PathToFile was successfull."
                            $oldlines=(Compare-Object -ReferenceObject $(Get-Content $using:PathToFile) -DifferenceObject $(Get-Content $using:BackUpPathFile) | where {$_.SideIndicator -eq "=>"}).InputObject
                            $newlines=(Compare-Object -ReferenceObject $(Get-Content $using:PathToFile) -DifferenceObject $(Get-Content $using:BackUpPathFile) | where {$_.SideIndicator -eq "<="}).InputObject
                            Write-Host "Old lines"
                            Write-Host "--------------------------------"
                            $oldlines
                            Write-Host "--------------------------------"
                            Write-Host "New lines"
                            Write-Host "--------------------------------"
                            $newlines
                            Write-Host "--------------------------------"
                        }
                        else {
                            Write-host "Replacement in the file $using:PathToFile was failed."
                            return
                        }
                }
                else {
                    Write-host "Create backup of the file $using:PathToFile failed. Processing stopped."
                    return
                }
        }
    }



