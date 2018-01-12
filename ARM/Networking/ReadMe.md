# Azure Foundation Workloads

This folder contains the network deployed as part of the Azure Foundation.  Using the metadata spreadsheet to get the correct parameters created.  
There is a DeploymentRead-Me tab in the metadata spreadsheet with specific details of how the network is laid down.

## Setup - Connecting to the Government Cloud
Any number of tools can be used to work with the Azure Government Cloud. Popular tools include:

* PowerShell
* PowerShell ISE
* Visual Studio Code
* Visual Studio 2015 Community/Professional/Enterprise editions

Connecting to Azure Government cloud from Visual Studio Communty/Professional/Enterprise requires that a registry key be set. Visual Studio will not be able to connect to the public cloud until this registry key is removed. The files that will set/remove the required registry key are included in the /DeveloperSetup folder.

### Connecting
To connect to the Azure Government cloud, run the following PowerShell command:

```Powershell
Add-AzureRmAccount -EnvironmentName AzureUSGovernment
```



