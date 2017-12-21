[CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AccessKey, 

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SecretKey,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$PathToTemplateScale,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AMI,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$EC2Type,

        [string]$StackName="AutoStackScale",
        [string]$Region="us-east-1"
    )

$content = [string]$content=(Get-Content -path $PathToTemplateScale)
$timeoutminutes=2 
$timeoutfinish=(get-date).addminutes($timeoutminutes)

New-CFNStack -StackName $StackName `
             -TemplateBody $content `
             -Parameter @( @{ ParameterKey="AMI"; ParameterValue="$AMI"}, @{ ParameterKey="EC2Type"; ParameterValue="$EC2Type"}, @{ ParameterKey="KeyPairName"; ParameterValue="CloudFormation"}) `
             -DisableRollback $true -AccessKey $AccessKey -secretkey $SecretKey -region $Region

while (($stackinfo.StackStatus -ne "CREATE_COMPLETE") -and ($stackinfo.StackStatus -ne "CREATE_FAILED"))
    {
    $stackinfo=Get-CFNStack -StackName $StackName -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region
        if ((get-date) -ge $timeoutfinish) {
            Remove-CFNStack -StackName $StackName -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region -Confirm:$false
            Write-Host "===================================================================================================="
            throw "Skip deployment by timeout. Current timeout is $timeoutminutes minutes."
            Write-Host "===================================================================================================="
        }
         elseif ($stackinfo.StackStatus -eq "CREATE_FAILED") {
            Write-Host "===================================================================================================="
            throw "Proccess of deployment is failed."            
        }
        else {
            Write-Host "Proccess of deployment is running. Please wait. Current status is $($stackinfo.StackStatus)."
            Start-Sleep -Seconds 10
        }
    }


             


