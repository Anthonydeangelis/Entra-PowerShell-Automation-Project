param(
    [Parameter(Mandatory)]
    [string]$CsvPath,
    [Parameter(Mandatory)]
    [string]$Domain
)

$users = Import-Csv -Path $CsvPath
$pass = Read-Host 'Enter temporary password' -AsSecureString
$existingUpns = @(
    Get-MgUser -All -Property UserPrincipalName |
        ForEach-Object UserPrincipalName
)
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
    Password = ConvertFrom-SecureString $pass -AsPlainText
    ForceChangePasswordNextSignIn = $true
    }
    $existingUpns += $upn
}
else {
        Write-Warning "$upn already exists—skipping."
    }
}
