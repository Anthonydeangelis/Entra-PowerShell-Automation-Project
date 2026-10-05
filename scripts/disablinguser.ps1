param(
    [string]$upn)
    $domain = 'Enter your domain' 
    $fullupn = "$($upn)@$domain"
    $user = Get-MgUser `
    -UserID $fullupn `
    -Property Id, DisplayName, UserPrincipalName, AccountEnabled 
    $user | Select-Object DisplayName, UserPrincipalName, AccountEnabled
    if ($user.AccountEnabled -eq $true) {
        Update-MgUser `
        -UserID $user.Id `
        -AccountEnabled:$false
    Write-Host "$($user.DisplayName) has been disabled" -ForegroundColor Green
    }
    else {
        Write-Host "$($user.DisplayName) is already disabled" -ForegroundColor Red
    }