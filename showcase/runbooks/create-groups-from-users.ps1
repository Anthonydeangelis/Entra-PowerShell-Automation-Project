# Sanitized lab showcase copy. See ../README.md before running.
Connect-MgGraph -Identity -NoWelcome -ErrorAction Stop
$groups = Get-MgUser -All -Property Department | Group-Object Department
foreach ($group in $groups){
     if ([string]::IsNullOrWhiteSpace($group.Name)) {
        continue
    }
New-MgGroup -DisplayName $group.Name -MailEnabled:$False  -MailNickName $group.Name -SecurityEnabled:$true
}
