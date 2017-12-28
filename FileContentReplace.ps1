[CmdletBinding()]
<#
.SYNOPSIS
Script for replace any content in the text file.
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
        [string]$PatternForReplace,

        [Parameter(Mandatory, HelpMessage = "Specify the kind of pattern. Regular expression or simple string")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("regex","string")]
        [string]$KindOfPattern
    )

    Invoke-Command -ComputerName $ComputerName -ScriptBlock {

    if ($using:KindOfPattern -notlike "regex") {
        Write-Host "========================== Pattern is simple string. Escape special characters if it's necessary ======================="
        $patternforreplace=[regex]::Escape($using:PatternForReplace)
    }
    else {
        Write-Host "========================== Pattern is regular expression =========================="
        $patternforreplace=$using:PatternForReplace
    }

    # Check file exists
    $fileexists=[System.IO.file]::Exists("$using:PathToFile")
        if ($fileexists -eq $true) {

            # Get current file content
            $currentallfilecontent=[System.IO.File]::ReadAllText("$using:PathToFile")
            $newfilecontent = $currentallfilecontent -replace $patternforreplace,$using:ReplaceContent

            # Update backup file path and check folder exists
            $backuppathfile=[regex]::split($using:BackUpPathFile, "\\")
            $pathcounts=0..($backuppathfile.count-1)
  
                foreach ($pathcount in $pathcounts) {
    
                    if ($pathcount -ne $pathcounts[-1]) {
                        $backupfullpath=$backupfullpath+$backuppathfile[$($pathcount)]+"\"
                        $backupfolderpath=$backupfolderpath+$backuppathfile[$($pathcount)]+"\"   
                    }
                    else {
                        $backupfullpath=$backupfullpath+(get-date -format ddMMyyyyHHmmss)+"-"+$backuppathfile[$($pathcount)]
                    }  
                }
            Write-Host "========================== BackUp folder path: $backupfolderpath =========================="
            Write-Host "========================== BackUp full path: $backupfullpath =========================="
            $checkbackupdirectory=[System.IO.Directory]::Exists("$backupfolderpath")
                if ($checkbackupdirectory -ne $true) {
                    Write-Host "========================== BackUp folder does not exist. Creating ... =========================="
                    [system.io.directory]::CreateDirectory("$backupfolderpath") | Out-Null
                }
                    

            # Create backup in backup location
            [System.IO.file]::Copy("$using:PathToFile","$backupfullpath")
            
            # Check copy process
            $algorithm = [Security.Cryptography.HashAlgorithm]::Create("MD5")
            $bytesoriginfile = [io.File]::ReadAllBytes("$using:PathToFile")
            $bytesbackfile = [io.File]::ReadAllBytes("$backupfullpath")
            [string]$hashorigin = $algorithm.ComputeHash($bytesoriginfile)
            [string]$hashbackup = $algorithm.ComputeHash($bytesbackfile)

                if ($hashorigin -eq $hashbackup) {
                    Write-host "========================== Backup for file $using:PathToFile created successfully. Path: $backupfullpath. =========================="

                    # Replace text
                    [System.IO.file]::WriteAllText("$using:PathToFile","$newfilecontent")

                    # Check correct replace
                    $filecontentafterreplace=[System.IO.File]::ReadAllText("$using:PathToFile")
                        if ($filecontentafterreplace -eq $newfilecontent) {
                            Write-Host "========================== Replacement in the file $using:PathToFile was successfull. =========================="
                            $oldlines=(Compare-Object -ReferenceObject $(Get-Content $using:PathToFile) -DifferenceObject $(Get-Content $backupfullpath) | where {$_.SideIndicator -eq "=>"}).InputObject
                            $newlines=(Compare-Object -ReferenceObject $(Get-Content $using:PathToFile) -DifferenceObject $(Get-Content $backupfullpath) | where {$_.SideIndicator -eq "<="}).InputObject
                            Write-Host "========================== Old lines =========================="
                            $oldlines
                            Write-Host "========================== New lines =========================="
                            $newlines
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



    