[CmdLetBinding()]
	Param (
		[Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()] 
        [string] $AzureCloudServiceName
	)

(Get-AzureDeployment -ServiceName $AzureCloudServiceName -Slot staging).Configuration | out-file d:\stagingconfiguration.xml
(Get-AzureDeployment -ServiceName $AzureCloudServiceName -Slot production).Configuration | out-file d:\productionconfiguration.xml



https://management.core.windows.net/b4d05768-e295-4195-9cdb-c07ecd987720/services/hostedservices/zakr/deployments/zakr/package










#New-AzureService -ServiceName "zakr" -Location "East US"



#New-AzureDeployment -ServiceName zakr -Package D:\tmp\ACS\AzureCloudService5.cspkg -Configuration D:\tmp\ACS\ServiceConfiguration.Cloud.cscfg -Name zakr1 -Label evfrf -slot staging 
