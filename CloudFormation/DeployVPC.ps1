﻿[CmdletBinding()]
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
        [string]$PathToTemplate,

        [string]$StackName="AutoStackVPC",
        [string]$Region="us-east-1"
    )

$content = [string]$content=(Get-Content -path $PathToTemplate)
$timeoutminutes=2 
$timeoutfinish=(get-date).addminutes($timeoutminutes)

New-CFNStack -StackName $StackName `
             -TemplateBody $content `
             -Parameter @( @{ ParameterKey="GatewayName"; ParameterValue="Gateway"}, @{ ParameterKey="VPCName"; ParameterValue="VPC"}, @{ ParameterKey="PrivateSubnetCIDR"; ParameterValue="172.16.0.0/24"}, @{ ParameterKey="PublicSubnetCIDR"; ParameterValue="172.16.1.0/24"}, @{ ParameterKey="SubnetNamePrefix"; ParameterValue="SubNet"}, @{ ParameterKey="VPCCIDR"; ParameterValue="172.16.0.0/23"}) `
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


             


