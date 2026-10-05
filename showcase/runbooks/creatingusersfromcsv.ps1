# Sanitized lab showcase copy. See ../README.md before running.
Connect-AzAccount -Identity -ErrorAction Stop | Out-Null
Connect-MgGraph -Identity -NoWelcome -ErrorAction Stop

# Retrieve the password
$vaultName = 'YOUR-KEY-VAULT'
$secretName = 'EntraPW' # Replace with your secret name

$tempPassword = Get-AzKeyVaultSecret `
    -VaultName $vaultName `
    -Name $secretName `
    -AsPlainText `
    -ErrorAction Stop

# Connect to storage using the managed identity
$storageContext = New-AzStorageContext `
    -StorageAccountName 'YOUR_STORAGE_ACCOUNT' `
    -UseConnectedAccount `
    -ErrorAction Stop

# Download the CSV to the Azure worker
$CsvPath = Join-Path ([System.IO.Path]::GetTempPath()) `
    "users-$([guid]::NewGuid()).csv"

Get-AzStorageBlobContent `
    -Container 'runbookdata' `
    -Blob 'inputs/fake-users-25.csv' `
    -Destination $CsvPath `
    -Context $storageContext `
    -ErrorAction Stop | Out-Null

$users = Import-Csv -Path $CsvPath -ErrorAction Stop
$existingUpns = @(
    Get-MgUser -All -Property UserPrincipalName |
        ForEach-Object UserPrincipalName
)
$Domain = 'YOUR_TENANT.onmicrosoft.com'
foreach ($user in $users) {
    $upn = "$($user.UserName)@$domain"

    if ($upn -notin $existingUpns) {
        Write-Host "$upn does not exist—creating user."
    New-MgUser `
-DisplayName $user.DisplayName `
-UserPrincipalName "$($user.UserName)@$domain" `
-MailNickname $user.UserName `
-AccountEnabled:$true `
-Department $user.Department `
-JobTitle $user.JobTitle `
-UsageLocation $user.UsageLocation `
-PasswordProfile @{                                       
    Password =  $tempPassword 
    ForceChangePasswordNextSignIn = $true
    } `
    -ErrorAction Stop
    $existingUpns += $upn
    Write-Output "Creating $upn"
}
else {
        Write-Warning "$upn already exists—skipping."
    }
}
