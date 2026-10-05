# Sanitized lab showcase copy. See ../README.md before running.
Get-MgGroup -All | ForEach-Object {
    $members = @(
        Get-MgGroupMemberAsUser -GroupId $_.Id -All -ErrorAction Stop
    )

    [PSCustomObject]@{
        GroupName   = $_.DisplayName
        MemberCount = $members.Count
    }
}
