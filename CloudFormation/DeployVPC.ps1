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
        [string]$PathToTemplate
    )

$content = [string]$content=(Get-Content -path $PathToTemplate)

New-CFNStack -StackName "AutoStack" `
             -TemplateBody $content `
             -Parameter @( @{ ParameterKey="GatewayName"; ParameterValue="Gateway"}, @{ ParameterKey="VPCName"; ParameterValue="VPC"}, @{ ParameterKey="PrivateSubnetCIDR"; ParameterValue="172.16.0.0/24"}, @{ ParameterKey="PublicSubnetCIDR"; ParameterValue="172.16.1.0/24"}, @{ ParameterKey="SubnetNamePrefix"; ParameterValue="SubNet"}, @{ ParameterKey="VPCCIDR"; ParameterValue="172.16.0.0/23"}) `
             -DisableRollback $true -AccessKey $AccessKey -secretkey $SecretKey -region us-east-1
                    


             


