$groupnames = Get-MgGroup -All | Select-Object -ExpandProperty DisplayName

$users = Get-MgUser -All `
-Property DisplayName, UserPrincipalName, AccountEnabled, Department, JobTitle 
foreach ($user in $users) {
    if ([string]::IsNullOrWhiteSpace($user.Department)) {
        Write-Warning "$($user.DisplayName) has no department."
        continue
    }
    if ($groupnames -like "*$($user.Department)*") {
        Write-Host "$($user.Department) Exist"
    }
    else {
       Write-Host "Group $($user.Department) does not exist. Creating Group"
       $mailNickname = "department-$($user.Department.ToLower())"
$mailNickname = $mailNickname -replace '[^a-z0-9-]', '-'
        New-MgGroup `
    -DisplayName  "Azure_$($user.Department)_Group" `
    -Description "Assigned group for $($user.Department) users" `
    -MailEnabled:$false `
    -MailNickname $mailNickname `
    -SecurityEnabled:$true `
    -GroupTypes @()
    }
}
Get-MgGroup
