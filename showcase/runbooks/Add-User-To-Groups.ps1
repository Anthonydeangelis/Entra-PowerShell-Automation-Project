# Sanitized lab showcase copy. See ../README.md before running.
Connect-MgGraph -Identity -NoWelcome -ErrorAction Stop

$users = Get-MgUser -All `
    -Property Department, Id, DisplayName `
    -ErrorAction Stop

foreach ($user in $users) {
    if ([string]::IsNullOrWhiteSpace($user.Department)) {
        Write-Warning "$($user.DisplayName) has no department—skipping."
        continue
    }

    try {
        $department = $user.Department.Replace("'", "''")

        $groups = @(
            Get-MgGroup -All `
                -Filter "displayName eq '$department'" `
                -Property Id, DisplayName, GroupTypes `
                -ErrorAction Stop
        )

        if ($groups.Count -ne 1) {
            Write-Warning "$($user.Department): found $($groups.Count) groups; expected one—skipping."
            continue
        }

        $group = $groups[0]

        if ($group.GroupTypes -contains 'DynamicMembership') {
            Write-Warning "$($group.DisplayName) is dynamic—skipping."
            continue
        }

        $memberIds = @(
            Get-MgGroupMember -GroupId $group.Id -All `
                -ErrorAction Stop |
                Select-Object -ExpandProperty Id
        )

        if ($user.Id -in $memberIds) {
            Write-Output "$($user.DisplayName) is already in $($group.DisplayName)—skipping."
            continue
        }

        New-MgGroupMember `
            -GroupId $group.Id `
            -DirectoryObjectId $user.Id `
            -ErrorAction Stop

        Write-Output "Added $($user.DisplayName) to $($group.DisplayName)"
    }
    catch {
        Write-Warning "Failed for $($user.DisplayName): $($_.Exception.Message)"
        continue
    }
}
