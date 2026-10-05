# Sanitized lab showcase copy. See ../README.md before running.
$identityId = 'YOUR_MANAGED_IDENTITY_OBJECT_ID'
$identity = Get-MgServicePrincipal `
    -ServicePrincipalId $identityId `
    -ErrorAction Stop

$identity | Select-Object DisplayName, Id, ServicePrincipalType


$graph = Get-MgServicePrincipal `
    -Filter "appId eq '00000003-0000-0000-c000-000000000000'" `
    -ErrorAction Stop

$permissions = @(
    'User.ReadWrite.All'
    'Group.ReadWrite.All'
)

$existing = Get-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $identityId `
    -All `
    -ErrorAction Stop

foreach ($permission in $permissions) {
    $role = $graph.AppRoles | Where-Object {
        $_.Value -eq $permission -and
        $_.AllowedMemberTypes -contains 'Application' -and
        $_.IsEnabled
    }

    if (-not $role) {
        throw "Permission not found: $permission"
    }

    if ($existing | Where-Object {
        $_.ResourceId -eq $graph.Id -and
        $_.AppRoleId -eq $role.Id
    }) {
        Write-Host "$permission is already assigned."
        continue
    }

    New-MgServicePrincipalAppRoleAssignment `
        -ServicePrincipalId $identity.Id `
        -PrincipalId $identity.Id `
        -ResourceId $graph.Id `
        -AppRoleId $role.Id `
        -ErrorAction Stop | Out-Null

    Write-Host "Assigned $permission to $($identity.DisplayName)"
}
