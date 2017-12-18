[CmdletBinding()]
<#
.SYNOPSIS 
Script for replace any content in the text file. 
.DESCRIPTION
For remote startup, use Invoke-Command -ComputerName Server01, Server02 -FilePath .\FileContentReplace.ps1 -Credential (Get-Credential)
Example
.\FileContentReplace.ps1 -PathToFile D:\test.txt -BackUpPathFile D:\backtest.txt -PatternForReplace "\d" -ReplaceContent "replace"
#>
    param
    (
        #[Parameter(Mandatory, HelpMessage = "Please enter the path to file.")]
        [ValidateNotNullOrEmpty()]
        [string]$PathToFile,

        #[Parameter(Mandatory, HelpMessage = "Please enter the path for backup file.")]
        [ValidateNotNullOrEmpty()]
        [string]$BackUpPathFile,

        [Parameter(Mandatory, HelpMessage = "Specify the content that you want to replace the existing content. Do not use quotes.")]
        [ValidateNotNullOrEmpty()]
        [string]$ReplaceContent,

        [Parameter(Mandatory, HelpMessage = "Specify the pattern for replace. Do not use quotes.")]
        [ValidateNotNullOrEmpty()]
        [string]$PatternForReplace
        
    )

    # Check file exists
    $fileexists=[System.IO.file]::Exists("$PathToFile")
        if ($fileexists -eq $true) {

            # Get current file content
            $currentallfilecontent=[System.IO.File]::ReadAllText("$PathToFile")
            $newfilecontent = $currentallfilecontent -replace $PatternForReplace,$ReplaceContent

            # Create backup in backup location
            [System.IO.file]::Copy("$PathToFile","$BackUpPathFile")
            
            # Check copy process
            $algorithm = [Security.Cryptography.HashAlgorithm]::Create("MD5")
            $bytesoriginfile = [io.File]::ReadAllBytes("$PathToFile")
            $bytesbackfile = [io.File]::ReadAllBytes("$BackUpPathFile")
            [string]$hashorigin = $algorithm.ComputeHash($bytesoriginfile)
            [string]$hashbackup = $algorithm.ComputeHash($bytesbackfile)

                if ($hashorigin -eq $hashbackup) {
                    Write-host "Backup for file $PathToFile created successfully. Path: $BackUpPathFile."

                    # Replace text
                    [System.IO.file]::WriteAllText("$PathToFile","$newfilecontent")

                    # Check correct replace
                    $filecontentafterreplace=[System.IO.File]::ReadAllText("$PathToFile")
                        if ($filecontentafterreplace -eq $newfilecontent) {
                            Write-Host "Replacement in the file $PathToFile was successfull."
                            $oldlines=(Compare-Object -ReferenceObject $(Get-Content $PathToFile) -DifferenceObject $(Get-Content $BackUpPathFile) | where {$_.SideIndicator -eq "=>"}).InputObject
                            $newlines=(Compare-Object -ReferenceObject $(Get-Content $PathToFile) -DifferenceObject $(Get-Content $BackUpPathFile) | where {$_.SideIndicator -eq "<="}).InputObject
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
                            Write-host "Replacement in the file $PathToFile was failed."
                            return
                        }
                            }
                else {
                    Write-host "Create backup of the file $PathToFile failed. Processing stopped."
                    return
                }
            }



