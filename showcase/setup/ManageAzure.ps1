# Sanitized lab showcase copy. See ../README.md before running.
Connect-AzAccount -UseDeviceAuthentication  -Subscription "00000000-0000-0000-0000-000000000000"

$rg = 'YOUR_RESOURCE_GROUP'
$storageParameters = @{
    ResourceGroupName = "YOUR_RESOURCE_GROUP"
    Name              = "YOUR_STORAGE_ACCOUNT"
    Location          = "East US "
    SkuName           = "Standard_LRS"
    MinimumTlsVersion = "TLS1_2"
    Kind               = "StorageV2"
}
New-AzStorageAccount @storageParameters
$sa = Get-AzStorageAccount -Name "YOUR_STORAGE_ACCOUNT" -ResourceGroupName $rg
$aa = Get-AzAutomationAccount -Name "YOUR_AUTOMATION_ACCOUNT" -ResourceGroupName $rg
$context = New-AzStorageContext -StorageAccountName $sa.StorageAccountName -UseConnectedAccount
New-AzStorageContainer -Name "runbookdata" -Context $context
##New-AzRoleAssignment -ObjectId $aa.Identity.PrincipalId -RoleDefinitionName "Storage Blob Data Contributor" -Scope $sa.Id

#Added Key Vault to take password for creating accounts
New-AzKeyVault -VaultName 'YOUR-KEY-VAULT' -ResourceGroupName $rg -Location "eastus2"

#Adding csv to Sa to create users from auto account 
Set-AzStorageBlobContent `
-Container 'runbookdata' `
-File './Entra-Powershell-AutomationLab/outputs/fake-users-25.csv' `
-Blob 'inputs/fake-users-25.csv' `
-Context $context `
-ErrorAction Stop
