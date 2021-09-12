#############################################################################################################
## Environment prepare

# Installing az cli"
#https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli-windows?tabs=azure-cli
$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# Connecting to azure account
az login

#############################################################################################################
## Parameters value

$location="East US"
$randomIdentifier="wallydatacli"

$resourceGroup="rg-$randomIdentifier"
$server="server-$randomIdentifier"
$database="database-$randomIdentifier"

$login="wally"
$password="CabelereiraLeila1"

$startIP="179.999.999.999"
$endIP="179.999.999.999"


#############################################################################################################
## SQL Database Deploy

# creating resourcegroup
az group create `
--name $resourceGroup `
--location "$location"


# Creating logical server
az sql server create `
--name $server `
--resource-group $resourceGroup `
--location "$location" `
--admin-user $login `
--admin-password $password


# Creating firewall server role to allow public connection through my notebook
az sql server firewall-rule create `
--resource-group $resourceGroup `
--server $server -n AllowMyIp `
--start-ip-address $startIP `
--end-ip-address $endIP


# Creating database
az sql db create `
--resource-group $resourceGroup `
--server $server `
--name $database `
--sample-name AdventureWorksLT `
--edition GeneralPurpose `
--family Gen5 `
--capacity 1 `
--compute-model Serverless `
--auto-pause-delay 180
