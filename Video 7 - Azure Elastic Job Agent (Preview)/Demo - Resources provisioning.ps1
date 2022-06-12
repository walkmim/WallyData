Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Import-Module Az
Install-Module -Name SqlServer

Connect-AzAccount

#Tenants that i have permission
Get-AzTenant

#Subscription in the tenant context
Get-AzSubscription

#Tenant and subscription context
Get-AzContext


$Tenant = Get-AzTenant | Where-Object {$_.Name -like "*wal*" -or $_.Domains -like "*wal*"} | Select-Object Id
$Subscription = Get-AzSubscription | Where-Object {$_.Name -like "*msdn*" -and $_.TenantId -eq $Tenant.Id} | Select-Object Name

#Alterando meu contexto para Desenvolvimento
Set-AzContext `
-Tenant $Tenant.Id `
-Subscription $Subscription.Name


$password = ConvertTo-SecureString "@WallyData2022" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("walkmim", $password)

######################################################
##### Create Resource Group

New-AzResourceGroup -Name rg-elasticjob -Location westus3

Get-AzResource -ResourceGroupName "rg-elasticjob"

######################################################
##### Elastic Job sql server

New-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-ej `
-Location westus3 `
-SqlAdministratorCredentials $Cred

Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-ej `
-DisplayName sqladmin `
-ObjectId "d650efbc-8b80-47d6-93c5-ae3d3c5a736c" 

#Elastic Job DB
New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-ej `
-DatabaseName "dbdba" `
-Edition Standard `
-MaxSizeBytes 2147483648 `
-RequestedServiceObjectiveName S0


Get-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-ej

<#
New-AzSqlServerFirewallRule -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-ej `
-FirewallRuleName "myCLientIp" `
-StartIpAddress "177.62.243.111" `
-EndIpAddress "177.62.243.111" 
#>

#Elastic Job Agent
New-AzSqlElasticJobAgent -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-ej `
-AgentName wallydata-sqlagent `
-DatabaseName dbdba

######################################################
##### server - all 

New-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-all `
-Location westus3 `
-SqlAdministratorCredentials $Cred

Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-all `
-DisplayName sqladmin `
-ObjectId "d650efbc-8b80-47d6-93c5-ae3d3c5a736c" 

#DBs all
New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-all `
-DatabaseName "dbManaus" `
-Edition Basic 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-all `
-DatabaseName "dbParana" `
-Edition Basic 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-all `
-DatabaseName "dbPiaui" `
-Edition Basic 

######################################################
##### server - exclude

New-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-exclude `
-Location westus3 `
-SqlAdministratorCredentials $Cred

Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-exclude `
-DisplayName sqladmin `
-ObjectId "d650efbc-8b80-47d6-93c5-ae3d3c5a736c" 

#DBs exclude
New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-exclude `
-DatabaseName "dbManaus" `
-Edition Basic 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-exclude `
-DatabaseName "dbParana" `
-Edition Basic 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-exclude `
-DatabaseName "dbPiaui" `
-Edition Basic 

######################################################
##### server - specific

New-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-specific `
-Location westus3 `
-SqlAdministratorCredentials $Cred

Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-specific `
-DisplayName sqladmin `
-ObjectId "d650efbc-8b80-47d6-93c5-ae3d3c5a736c" 

#DBs specific
New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-specific `
-DatabaseName "dbManaus" `
-Edition Basic 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-specific `
-DatabaseName "dbParana" `
-Edition Basic 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-specific `
-DatabaseName "dbPiaui" `
-Edition Basic 

######################################################
##### elastic pool

New-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-pool `
-Location westus3 `
-SqlAdministratorCredentials $Cred 

Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-pool `
-DisplayName sqladmin `
-ObjectId "d650efbc-8b80-47d6-93c5-ae3d3c5a736c" 

New-AzSqlElasticPool -ResourceGroupName rg-elasticjob `
-ElasticPoolName pooldb `
-ServerName az-srv-wallydata-pool `
-Dtu 50

#DBs pool
New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ElasticPoolName pooldb `
-ServerName az-srv-wallydata-pool `
-DatabaseName "dbManaus" 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ElasticPoolName pooldb `
-ServerName az-srv-wallydata-pool `
-DatabaseName "dbParana" 

New-AzSqlDatabase -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-pool `
-DatabaseName "dbPiaui" `
-Edition Basic 

####################################################################

Get-AzSqlServer -ResourceGroupName rg-elasticjob 

Get-AzResource -ResourceGroupName rg-elasticjob | Where-Object {$_.Kind -notlike '*system*'} | select * | Format-Table -AutoSize

$SqlServers = Get-AzSqlServer -ResourceGroupName rg-elasticjob | Select SqlAdministratorLogin,FullyQualifiedDomainName,ResourceGroupName,ServerName

####################################################################
## Add Firewall rules
$SqlServers | ForEach-Object -Process { 

Write-Host "Starting ",$_.ServerName
New-AzSqlServerFirewallRule -ResourceGroupName $_.ResourceGroupName `
-ServerName $_.ServerName `
-FirewallRuleName "myClientIp" `
-StartIpAddress "177.62.243.111" `
-EndIpAddress "177.62.243.111" 

New-AzSqlServerFirewallRule -ResourceGroupName $_.ResourceGroupName `
-ServerName $_.ServerName `
-FirewallRuleName "AllowAllWindowsAzureIps" `
-StartIpAddress "0.0.0.0" `
-EndIpAddress "0.0.0.0" 
Write-Host "Ended ",$_.ServerName

}

####################################################################
## Create elastic job login and user on master database
$PasswordSTR = '@WallyData2022'

$query = "IF EXISTS (SELECT 1 FROM SYS.sql_logins WHERE name = 'user_elasticjob_cred')
DROP LOGIN user_elasticjob_cred;
CREATE LOGIN user_elasticjob_cred WITH PASSWORD = '@wallyData2022';
SELECT 'Login created' AS [ ]
DROP USER IF EXISTS user_elasticjob_cred;
CREATE USER user_elasticjob_cred FOR LOGIN user_elasticjob_cred;
SELECT 'User created' AS [ ] "

$SqlServers | ForEach-Object -Process { 

Write-Host "Starting ",$_.ServerName
Invoke-Sqlcmd -ServerInstance $_.FullyQualifiedDomainName -Username $Username -Password $PasswordSTR -Query $query -Verbose
Write-Host "Ended ",$_.ServerName `n

}


####################################################################
## Create elastic job user on scoped databases
$query = "DROP USER IF EXISTS user_elasticjob_cred;
CREATE USER user_elasticjob_cred FOR LOGIN user_elasticjob_cred;
SELECT 'User created' AS [ ]
EXEC sp_addrolemember N'db_ddladmin', N'user_elasticjob_cred' 
EXEC sp_addrolemember N'db_datareader', N'user_elasticjob_cred' 
SELECT 'Permissions granted' AS [ ]
"

$SqlServers | ForEach-Object -Process { 
$ServerNameURL = $_.FullyQualifiedDomainName
Get-AzSqlDatabase -ResourceGroupName rg-elasticjob -ServerName $_.ServerName | Where-Object DatabaseName -ne 'master' | Select ServerName,DatabaseName |
ForEach-Object -Process {
        Write-Host "Starting on server:",$_.ServerName," , Database: ",$_.DatabaseName
        Invoke-Sqlcmd -ServerInstance $ServerNameURL -Username $Username -Password $PasswordSTR -Database $_.DatabaseName -Query $query
        Write-Host "Ended on server:",$_.ServerName," , Database: ",$_.DatabaseName `n
    }
}

####################################################################

####################################################################
## Validation

$query = "
IF EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'tb_wallyDataDBAs')
    SELECT DB_NAME() AS [DatabaseName],'YES' AS EXIST_TABLE
ELSE
    SELECT DB_NAME() AS [DatabaseName], 'NO' AS EXIST_TABLE

"

$SqlServers |  Where-Object ServerName -ne 'az-srv-wallydata-ej' | ForEach-Object -Process { 
$ServerNameURL = $_.FullyQualifiedDomainName

Write-Host "Starting on server:",$_.ServerName `n

Get-AzSqlDatabase -ResourceGroupName rg-elasticjob -ServerName $_.ServerName -WarningAction Ignore | Where-Object DatabaseName -ne 'master' | Select ServerName,DatabaseName |
ForEach-Object -Process {
        Invoke-Sqlcmd -ServerInstance $ServerNameURL -Username $Username -Password $PasswordSTR -Database $_.DatabaseName -Query $query
    }
Write-Host "Ended on server:",$_.ServerName `n
}


####################################################################

Remove-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-all 

Remove-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-exclude 

Remove-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-specific 

Remove-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-pool 

Remove-AzSqlServer -ResourceGroupName rg-elasticjob `
-ServerName az-srv-wallydata-ej `
-Force



Get-AzResource -ResourceGroupName "rg-elasticjob"

Remove-AzResourceGroup rg-elasticjob -Force