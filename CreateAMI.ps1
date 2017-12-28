workflow CreateAWSAMI {
<#
.SYNOPSIS
Script for creating AWS AMI image.
#>
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
        [string]$Region,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AMIName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AMIDescription,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [array]$TagName
    )

    # Get EC2 instance ID
    $InstanceIds=(Get-EC2Tag -AccessKey $AccessKey -SecretKey $SecretKey -Region $region | where {($_.Key -like "name") -and ($TagName.Contains($_.Value)) -and ($_.ResourceType -eq "instance")}).ResourceId

    foreach -parallel ($InstanceId in $InstanceIds) {
        # Stop EC2 instance
        InlineScript { 
        Stop-EC2Instance -InstanceId $using:InstanceId -AccessKey $using:AccessKey -SecretKey $using:SecretKey -Region $using:Region

        # Check instance state
            while ($instancecurrentstate -ne "stopped") {
                Write-Host "============================= Waiting for instance $using:InstanceId stop. ============================="
                Start-Sleep -Seconds 30
                $instancecurrentstate=(Get-EC2Instance -InstanceId $using:InstanceId -AccessKey $using:AccessKey -SecretKey $using:SecretKey -Region $using:region).Instances.State.Name.Value
            }
    
        # Create EC2Image
        Write-Host "============================= Creating AMI for instance $using:InstanceId ============================="
        $imageId=New-EC2Image -InstanceId $using:InstanceId -AccessKey $using:AccessKey -SecretKey $using:SecretKey -Region $using:region -Description $using:AMIDescription -name $using:AMIName -Verbose

        # Check image state
            while ($imagecurrentstate -ne "available") {
                Write-Host "============================= Waiting for AMI $ImageId will become available. ============================="
                Start-Sleep -Seconds 20
                $imagecurrentstate=(Get-EC2Image -ImageId $using:ImageId -AccessKey $using:AccessKey -SecretKey $using:SecretKey -Region $using:region).State
            }
        }
    }
}

CreateAWSAMI