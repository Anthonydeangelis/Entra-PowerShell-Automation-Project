# Sanitized lab showcase copy. See ../README.md before running.
param (
    [string]$SubscriptionId = "00000000-0000-0000-0000-000000000000",
    [string]$StorageAccountName = "YOUR_STORAGE_ACCOUNT",
    [string]$ContainerName = "runbookdata"
)

$ErrorActionPreference = "Stop"

try {
    # Prevent another Automation job's context from being reused
    Disable-AzContextAutosave -Scope Process

    # Authenticate as the Automation Account's managed identity
    $connection = (Connect-AzAccount -Identity).Context

    $azureContext = Set-AzContext `
        -SubscriptionId $SubscriptionId `
        -DefaultProfile $connection

    Write-Output "Connected to subscription: $($azureContext.Subscription.Name)"

    # Create an authenticated Storage context without account keys
    $storageContext = New-AzStorageContext `
        -StorageAccountName $StorageAccountName `
        -UseConnectedAccount

    # Create the blob container if it doesn't exist
    $container = Get-AzStorageContainer `
        -Name $ContainerName `
        -Context $storageContext `
        -ErrorAction SilentlyContinue

    # Collect Azure resource information
    $resources = Get-AzResource -DefaultProfile $azureContext |
        Select-Object Name, ResourceType, ResourceGroupName,
            Location, ResourceId

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $fileName = "azure-resource-inventory_$timestamp.csv"
    $temporaryFile = Join-Path ([IO.Path]::GetTempPath()) $fileName

    $resources |
        Export-Csv `
            -Path $temporaryFile `
            -NoTypeInformation

    # Upload the report
    Set-AzStorageBlobContent `
        -File $temporaryFile `
        -Container $ContainerName `
        -Blob "inventory/$fileName" `
        -Context $storageContext `
        -Force | Out-Null

    Write-Output "Uploaded: $ContainerName/inventory/$fileName"
}
catch {
    Write-Error "Inventory failed: $($_.Exception.Message)"
    throw
}
finally {
    if ($temporaryFile -and (Test-Path $temporaryFile)) {
        Remove-Item $temporaryFile -Force
    }
}
